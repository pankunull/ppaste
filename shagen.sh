#!/bin/sh

openssl sha256 src/ppaste.sh | cut -d ' ' -f2 > sign/sha256sum.txt

cat sign/sha256sum.txt
