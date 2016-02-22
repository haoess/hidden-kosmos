#!/bin/bash

POST_XSLT="`dirname $0`/spliced2orig+reg.xsl"

for i in $*; do
  TARGET_CAB="`dirname $i`/`basename $i .orig.xml`.norm_tmp.xml"
  TARGET_POST="`dirname $i`/`basename $i .orig.xml`.norm.xml"
  curl -X POST -sSF "qd=@$i" -o "$TARGET_CAB" "http://www.deutschestextarchiv.de/demo/cab/query?fmt=tei"
  xsltproc "$POST_XSLT" "$TARGET_CAB" | perl -pE 's{<lb xmlns="http://www.tei-c.org/ns/1.0"/>}{<lb/>}g;s{ xmlns=""}{}g' > "$TARGET_POST"
  rm "$TARGET_CAB"
done
