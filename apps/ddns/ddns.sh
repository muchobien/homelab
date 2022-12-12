#!/usr/bin/env bash

apk --no-cache add curl jq bind-tools &> /dev/null

ip=$(curl -s ip.me)

echo "Current IP address: $ip"

if host $DNS_RECORD 1.1.1.1 | grep "has address" | grep "$ip"; then
    echo "$DNS_RECORD is currently set to $ip; no changes needed"
    exit
fi

zoneid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$ZONE&status=active" \
-H "Authorization: Bearer $AUTH_KEY" \
-H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

echo "Zoneid for $ZONE is $zoneid"

dnsrecordid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records?type=A&name=$DNS_RECORD" \
-H "Authorization: Bearer $AUTH_KEY" \
-H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

echo "DNSrecordid for $DNS_RECORD is $dnsrecordid"

curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records/$dnsrecordid" \
-H "Authorization: Bearer $AUTH_KEY" \
-H "Content-Type: application/json" \
--data "{\"type\":\"A\",\"name\":\"$DNS_RECORD\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":false}" | jq
