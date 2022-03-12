#!/bin/bash  

echo "" 
echo "See through you...we can" 
echo ""

cat yoda_logo.txt

while getopts i:d:e:u flag 

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
}

find_domain_info() {  

    whoisinfo=$"whois $1"

    echo "--$1 ADMIN INFO" 
    echo "" 
    $whoisinfo | grep 'Admin' | grep -v ":$" | grep 'Name\|City\|State/Province\|Country\|Email\|Phone\|Organization'  
    echo ""  
    
    declare -a name_servers=($($whoisinfo | grep -v ":$" | sed -n -e 's/^.*Name Server://p'))

    echo "--$1 NAME SERVER INFO" 
    echo ""
    for i in "${name_servers[@]}" 
    do 
        echo "Name Server: $i , IP: $(dig +short $i)"
    done
}


# Our script is primarly after the domain since 
# we can find a large amount of information through the domain
if ! [ -z $domain ] 
then 

    find_domain_info $domain 

elif ! [ -z $ip ] 
then 

    find_ip_info $ip
fi
