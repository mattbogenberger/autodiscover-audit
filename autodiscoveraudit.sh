#!/bin/bash

#Initialize variables
counter=0
errors=0

#Iterate thru domains listed in domains.txt
while read domain; do
#Perform DNS queries and manipulate results
autorecord=`dig autodiscover.$domain +short`
autoCNAME=`dig autodiscover.$domain | grep autodiscover.$domain.*CNAME`
CNAMEshort=`echo $autoCNAME | sed 's/.*CNAME//g'`
SRVrecord=`dig srv _autodiscover._tcp.$domain +short`
SRVmatch=`echo $SRVrecord | grep mail.xcentric.com`
#echo $autorecord
#echo $autoCNAME
#echo $CNAMEshort
#echo $SRVrecord
#echo $SRVmatch

#Evaluate DNS records and set flags 
if [[ ! -z $autorecord ]]; then
	# echo "autodiscover record present"
	autodiscoverpresent=true
else
	# echo "autodiscover record not present"
	autodiscoverpresent=false
fi

if [[ ! -z $autoCNAME ]]; then
	# echo "CNAME record present"
	CNAMEpresent=true
else
	# echo "CNAME record not present"
	CNAMEpresent=false
	if $autodiscoverpresent; then
		# echo "A record present"
		Apresent=true
	else
		# echo "A record not present"
		Apresent=false
	fi
fi

if [[ ! -z $SRVrecord ]]; then
	# echo "SRV record present"
	SRVpresent=true
else
	# echo "SRV record not present"
	SRVpresent=false
fi

if [[ ! -z $SRVmatch ]]; then
	# echo "SRV record correct"
	SRVcorrect=true
else
	# echo "SRV record incorrect"
	SRVcorrect=false
fi

#Print domain name and record details if misconfigured
if $autodiscoverpresent || ! $SRVcorrect; then
	echo $domain
fi

if $autodiscoverpresent; then
	if $CNAMEpresent; then
		echo "Autodiscover CNAME record present:" $CNAMEshort
	else
		echo "Autodiscover A record present:" $autorecord
	fi
fi

if ! $SRVcorrect; then
	if ! $SRVpresent; then
		echo "Autodiscover SRV record missing."
	else
		echo "Autodiscover SRV record incorrect:" $SRVrecord
	fi
fi

if $autodiscoverpresent || ! $SRVcorrect; then
	echo ""
	((++errors))
fi

((++counter))

done <domains.txt
echo $errors "of" $counter "domains had autodiscover DNS misconfigurations."