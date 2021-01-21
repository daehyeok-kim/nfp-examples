#!/bin/sh

rm -rf out

nfp4build  \
	--output-nffw-filename ./out/app.nffw \
	--incl-p4-build ./simple.p4 ./headers.p4  \
 	--sku AMDA0081-0001:0  \
 	--platform hydrogen  \
 	--reduced-thread-usage  \
 	--shared-codestore  \
 	--nfp4c_p4_version 16 \
	--nfp4c_p4_compiler p4c-nfp  \
 	--nfirc_default_table_size 65536 \
	--nfirc_no_all_header_ops  \
 	--nfirc_implicit_header_valid  \
 	--nfirc_no_zero_new_headers  \
 	--nfirc_multicast_group_count 16  \
	--nfirc_multicast_group_size 16  \
 	--nfirc_no_mac_ingress_timestamp
