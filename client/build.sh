#!/bin/bash

BASEURL=https://download.mikrotik.com/routeros/winbox
ARCHIVE=WinBox_Linux.zip
VERSION=$(curl -s $BASEURL/LATEST.4)
URL=$BASEURL/$VERSION/$ARCHIVE

if [ ! -v CT_USER ]; then
  export CT_USER=admin;
else
  export CT_USER;
fi
if [ ! -v CT_PASSWD ]; then
  export CT_PASSWD=$CT_USER;
else
  export CT_PASSWD;
fi
export CT_VERSION=$VERSION

pushd compose > /dev/null && \
curl -s -o /tmp/$ARCHIVE $URL && \
unzip -xoqq /tmp/$ARCHIVE WinBox && \
docker compose build && \
docker tag winbox:$VERSION winbox:latest && \
popd > /dev/null
