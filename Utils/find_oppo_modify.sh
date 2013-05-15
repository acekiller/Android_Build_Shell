#!/bin/bash
#
#		Program
#	this shell is used to find all the files modified by OPPO
#	and copy it to the specified directory.
#
#
rm -fr oppo_modify
mkdir oppo_modify

OUT_DIR=$PWD/oppo_modify

cd $1

grep -r VENDOR_EDIT * -l | xargs cp --parents -t $OUT_DIR

