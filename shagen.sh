#!/bin/sh

sha256sum  src/ppaste.sh > sign/sha256sum.txt

cat sign/sha256sum.txt
