#!/bin/sh

openssl sha256 ppaste.sh | cut -d ' ' -f2 > sha256sum.txt
