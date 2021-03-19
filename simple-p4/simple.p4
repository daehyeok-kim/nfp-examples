#include <core.p4>
#include <v1model.p4>

#include "headers.p4"

struct my_headers_t {
    ethernet_h   ethernet;
    vlan_tag_h   vlan_tag;
    ipv4_h       ipv4;
    tcp_h        tcp;
}

    /******  G L O B A L   I N G R E S S   M E T A D A T A  *********/

struct my_metadata_t {
    //bool  ipv4_checksum_err;
    //bool checksum_update_ipv4;
    bit<32> test;
}

parser c_Parser(packet_in        pkt,
    out my_headers_t          hdr,
    inout my_metadata_t         meta,
    inout standard_metadata_t standard_metadata)
{

    /* This is a mandatory state, required by Tofino Architecture */
     state start {
        //pkt.extract(ig_intr_md);
        //pkt.advance(PORT_METADATA_SIZE);
        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type) {
            ETHERTYPE_VLAN:  parse_vlan_tag;
            ETHERTYPE_IPV4:  parse_ipv4;
            default: accept;
        }
    }

    state parse_vlan_tag {
        pkt.extract(hdr.vlan_tag);
        transition select(hdr.vlan_tag.ether_type) {
            ETHERTYPE_IPV4:  parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        //meta.ipv4_checksum_err = ipv4_checksum.verify();
        transition accept;
    }
}

control c_verify_checksum(inout my_headers_t hdr, inout my_metadata_t meta) {
    apply {
        verify_checksum(
	    hdr.ipv4.isValid(),
            { hdr.ipv4.version,
	      hdr.ipv4.ihl,
              hdr.ipv4.diffserv,
              hdr.ipv4.total_len,
              hdr.ipv4.identification,
              hdr.ipv4.flags,
              hdr.ipv4.frag_offset,
              hdr.ipv4.ttl,
              hdr.ipv4.protocol,
              hdr.ipv4.src_addr,
              hdr.ipv4.dst_addr },
            hdr.ipv4.hdr_checksum,
            HashAlgorithm.csum16);
    }
}
control c_compute_checksum(inout my_headers_t hdr, inout my_metadata_t meta) {
    apply {
        update_checksum(
	    hdr.ipv4.isValid(),
            { hdr.ipv4.version,
	      hdr.ipv4.ihl,
              hdr.ipv4.diffserv,
              hdr.ipv4.total_len,
              hdr.ipv4.identification,
              hdr.ipv4.flags,
              hdr.ipv4.frag_offset,
              hdr.ipv4.ttl,
              hdr.ipv4.protocol,
              hdr.ipv4.src_addr,
              hdr.ipv4.dst_addr },
            hdr.ipv4.hdr_checksum,
            HashAlgorithm.csum16);
    }
}
control NextHop(
    inout my_headers_t                       my_hdr,
    inout my_metadata_t         meta,
    inout standard_metadata_t standard_metadata)
{

    action drop() {
        mark_to_drop();
    }

    action set_nhop(bit<16> port){
        standard_metadata.egress_spec = port;
        meta.test = my_hdr.ipv4.dst_addr;
    }
    
    table ipv4_lpm {
        key = {
		my_hdr.ipv4.dst_addr : exact;
		my_hdr.ipv4.src_addr : exact;
	}  
        actions = { set_nhop; drop; }
        default_action = drop();
	size = 1000000;
    }
    table ipv4_lpm2 {
        key = {
		my_hdr.ipv4.dst_addr : exact;
		my_hdr.ipv4.src_addr : exact;
	}  
        actions = { set_nhop; drop; }
        default_action = drop();
	size = 1000000;
    }
    table ipv4_lpm3 {
        key = {
		my_hdr.ipv4.dst_addr : exact;
		my_hdr.ipv4.src_addr : exact;
	}  
        actions = { set_nhop; drop; }
        default_action = drop();
	size = 1000000;
    }
    table ipv4_lpm4 {
        key = {meta.test : exact;}  
        actions = { set_nhop; drop; }
        default_action = drop();
	size = 1000000;
    }

    apply {
        ipv4_lpm.apply();
        ipv4_lpm2.apply();
        ipv4_lpm3.apply();
        ipv4_lpm4.apply();
    }
}
control c_Ingress(
    /* User */
    inout my_headers_t                       hdr,
    inout my_metadata_t                      meta,
    /* Intrinsic */
    inout standard_metadata_t standard_meta)
{

    NextHop() nexthop;
        
    apply {
        nexthop.apply(hdr, meta, standard_meta);
    }
}


/*************************************************************************
 ****************  E G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/


    /***************** M A T C H - A C T I O N  *********************/

control c_Egress(
    /* User */
    inout my_headers_t                          hdr,
    inout my_metadata_t                         meta,
    /* Intrinsic */    
    inout standard_metadata_t standard_metadata)
{
    apply {
    }
}

    /*********************  D E P A R S E R  ************************/

control c_Deparser(packet_out pkt,
    /* User */
    in my_headers_t                       hdr)
{
    apply {
        pkt.emit(hdr);
    }
}

/************ F I N A L   P A C K A G E ******************************/
V1Switch(
    c_Parser(),
    c_verify_checksum(),
    c_Ingress(),
    c_Egress(),
    c_compute_checksum(),
    c_Deparser()
) main;
