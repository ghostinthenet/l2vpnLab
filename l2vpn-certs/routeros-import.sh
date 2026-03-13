#!/usr/bin/zsh
#
CA=$1
NAME=$2
echo '/file' > $NAME.rsc
cat $1.crt >> $NAME.rsc
sed -i "s/^-----BEGIN CERTIFICATE-----$/add name=$1.crt type=file contents=\"&/" $NAME.rsc
if [ -f $NAME.key ]; then
  cat $NAME.crt $NAME.key >> $NAME.rsc
  sed -i "s/^-----BEGIN CERTIFICATE-----$/add name=$NAME.crt type=file contents=\"&/" $NAME.rsc
  sed -i "s/^-----BEGIN PRIVATE KEY-----$/add name=$NAME.key type=file contents=\"&/" $NAME.rsc
fi
sed -i '2,$s/$/\\n/' $NAME.rsc && sed -i 's/^\(.*END.*\)\\n/\1"/' $NAME.rsc
echo '/certificate; import; :foreach counter=entry in=[find] do={set $entry name=[get $entry common-name]}' >> $NAME.rsc
