#!/bin/bash  

echo "" 
echo "See through you...we can" 
echo ""

cat yoda_logo.txt 
echo ""

while getopts i:d:e:u:* flag 

do 

    case "${flag}" in 

        i) ip=${OPTARG} 
            ;; 
        d) domain=${OPTARG} 
            ;;
        e) email=${OPTARG}
            ;; 
        u) url=${OPTARG}
            ;; 
        *) exit 0;; 


    esac 

done  

echo "MY URL IS $url"

find_ip_info() {  

    #Store result of whois command into a variable
    whoisinfo=$"whois $1"

    echo "-- $1 FOUND NAMES" 
    echo "" 
    $whoisinfo | grep 'Org' | grep -v ":$" | grep 'Name'
    echo ""

    echo "-- $1 FOUND EMAILS" 
    echo "" 
    $whoisinfo | grep 'Org' | grep -v ":$" | grep 'Email'
    echo ""  

    echo "-- $1 FOUND PHONE NUMBERS" 
    echo "" 
    $whoisinfo | grep 'Org' | grep -v ":$" | grep 'Phone'
    echo "" 

    if [ $2 = true ]
    then 
        echo "NO DOMAIN GIVEN" 
    fi
}

find_domain_info() {

    whoisinfo=$"whois $1" 

    echo "--$1 IMPORTANT DATES" 
    echo ""
    $whoisinfo | grep -v ":$" | grep "Date" 
    echo ""

    echo "--$1 FOUND NAMES" 
    echo "" 
    $whoisinfo | grep -v ":$" | grep 'Name\|Organization' | grep -v "Server"
    echo "" 

    echo "--$1 FOUND EMAILS" 
    echo "" 
    $whoisinfo | grep -v ":$" | grep "Email" 
    echo "" 

    echo "--$1 FOUND PHONE NUMBERS"
    echo ""
    $whoisinfo | grep -v ":$" | grep 'Phone' 
    echo "" 

    echo "--$1 FOUND GEOGRAPHICAL LOCATIONS" 
    echo "" 
    $whoisinfo | grep -v ":$" | grep 'Country\|State/Province\|City' 
    echo ""
    
    declare -a name_servers=($($whoisinfo | grep -v ":$" | sed -n -e 's/^.*Name Server://p'))

    echo "--$1 FOUND NAME SERVERS" 
    echo ""
    for i in "${name_servers[@]}" 
    do 
        echo "Name Server: $i , IP: $(dig +short $i)"
    done 

    echo ""  
    echo "--$1 FOUND INFO ON NAME SERVERS" 
    echo ""
    for i in "${name_servers[@]}" 
    do 
        find_ip_info $(dig +short $i) false 
    done 

    echo "" 
    echo "--$1 TRACE ROUTE" 
    echo "" 
    traceroute $1


}


# Our script is primarly after the domain since 
# we can find a large amount of information through the domain
if ! [ -z $domain ] 
then 

    find_domain_info $domain 

    if ! [ -z $ip ] 
    then 

        find_ip_info $ip false 

    fi

elif ! [ -z $ip ] 
then 

    find_ip_info $ip true 

elif ! [ -z $url ] 
then  

    echo "WE HAVE A URL!"

    domain=$( echo "$url" | sed -n -e 's/^.*www.//p')
    echo "DOMAIN IS $domain"
fi
