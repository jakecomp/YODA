#!/bin/bash   

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

find_ip_info() {  

    #Store result of whois command into a variable
    whoisinfo=$"whois $1"

    echo "-- $1 FOUND NAMES" 
    echo "" 
    $whoisinfo | grep -v ":$" | grep 'Name:' | sed -e 's/^\s*//'
    echo ""

    echo "-- $1 FOUND EMAILS" 
    echo "" 
    $whoisinfo | grep -v ":$" | grep -i 'Email:' | sed -e 's/^\s*//'
    echo ""  

    echo "-- $1 FOUND PHONE NUMBERS" 
    echo "" 
    $whoisinfo | grep -v ":$" | grep -i 'Phone:' | sed -e 's/^\s*//'
    echo "" 

    if [ $2 = true ]
    then 
        echo "NO DOMAIN NAME PROVIDED ... FINDING DOMAIN NAME WITH NSLOOKUP"  
        nslookup $1 | grep -i 'Name'

    fi
}

find_domain_info() {

    whoisinfo=$"whois $1" 

    echo "--$1 IMPORTANT DATES" 
    echo ""
    $whoisinfo | grep -v ":$" | grep -i "Date:"  | sed -e 's/^\s*//'
    echo ""

    echo "--$1 FOUND NAMES" 
    echo "" 
    $whoisinfo | grep -v ":$" | grep -i 'Name:\|Organization:' | grep -i -v "Server" | sed -e 's/^\s*//'
    echo "" 

    echo "--$1 FOUND EMAILS" 
    echo "" 
    $whoisinfo | grep -v ":$" | grep -i "Email:" | sed -e 's/^\s*//'
    echo "" 

    echo "--$1 FOUND PHONE NUMBERS"
    echo ""
    $whoisinfo | grep -v ":$" | grep -i 'Phone:' | sed -e 's/^\s*//'
    echo "" 

    echo "--$1 FOUND GEOGRAPHICAL LOCATIONS" 
    echo "" 
    $whoisinfo | grep -v ":$" | grep -i 'Country:\|State/Province:\|City:' | sed -e 's/^\s*//' 
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
    find_domain_info $domian 

elif ! [ -z $email ] 
then 

    
    domain=$( echo "$email" | sed -n -e 's/^.*@//p') 
    find_domain_info $domain 

else 

    find_domain_info $1

fi 

echo "" 
echo "See through you...we can" 
echo "" 

# Umcomment line below with yoda_logo.txt file to see some yoda ASCII art
#cat yoda_logo.txt
