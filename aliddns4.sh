aliDnsAk=""
aliDnsSk=""
subdomainName=''
domainName=''
ttl="600"

if [ "$subdomainName" = "@" ]
then
  DomainFullName=$domainName
else
  DomainFullName=$subdomainName.$domainName
fi

timestamp=$(date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ")
now=$(date "+%Y-%m-%d %H:%M:%S")

pppoeWanIpv4Address=$(ip addr show pppoe-wan | grep "inet.*peer" | awk '{print $2}' | awk -F"/" '{print $1}')
echo "$now current pppoe-wan ipv4 address: $pppoeWanIpv4Address"

signatureNonce="$(date +%s)-$DomainFullName"
echo "$now current signatureNonce: $signatureNonce"

urlEncode() {
  out=""
  while read -r -n1 c
  do
    case $c in
      [a-zA-Z0-9._-]) out="$out$c" ;;
      *) out="$out$(printf '%%%02X' "'$c")" ;;
    esac
  done
  echo -n "$out"
}

enc() {
  echo -n "$1" | urlEncode
}

sendRequest() {
  args="AccessKeyId=$aliDnsAk&Action=$1&Format=json&$2&Version=2015-01-09"
  signature=$(echo -n "GET&%2F&$(enc "$args")" | openssl dgst -sha1 -hmac "$aliDnsSk&" -binary | openssl base64)
  curl -s "http://alidns.aliyuncs.com/?$args&Signature=$(enc "$signature")"
}

getRecordId() {
  grep -Eo '"RecordId":"[0-9]+"' | cut -d':' -f2 | tr -d '"'
}

getRecordValue() {
  grep -Eo '"Value":"[^"]+"' | cut -d':' -f2 | tr -d '"'
}

queryRecordId() {
  sendRequest "DescribeSubDomainRecords" "SignatureMethod=HMAC-SHA1&SignatureNonce=$signatureNonce&SignatureVersion=1.0&SubDomain=$DomainFullName&Timestamp=$timestamp&Type=A"
}

updateRecord() {
  sendRequest "UpdateDomainRecord" "RR=$subdomainName&RecordId=$1&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&TTL=$ttl&Timestamp=$timestamp&Type=A&Value=$pppoeWanIpv4Address"
}

addRecord() {
  sendRequest "AddDomainRecord&domainName=$domainName" "RR=$subdomainName&SignatureMethod=HMAC-SHA1&SignatureNonce=$signatureNonce&SignatureVersion=1.0&ttl=$ttl&Timestamp=$timestamp&Type=A&Value=$pppoeWanIpv4Address"
}

if [ "$domainRecordId" = "" ]
then
  domainRecordRes=$(queryRecordId)
  domainRecordId=$(echo "$domainRecordRes" | getRecordId)
  domainRecordValue=$(echo "$domainRecordRes" | getRecordValue)
  echo "$now domain record res: $domainRecordRes"
  echo "$now domain record id: $domainRecordId"
  echo "$now domain record Value: $domainRecordValue"
fi
if [ "$domainRecordId" = "" ]
then
  echo "$now no record found, please check the domain name"
  exit 1
else
  if [ "$domainRecordValue" = "$pppoeWanIpv4Address" ]
  then
    echo "$now domain record value is the same as current ipv4 address, no need to update"
  else
    updateRecord "$domainRecordId"
    echo "$now updated record $domainRecordId"
  fi
fi
