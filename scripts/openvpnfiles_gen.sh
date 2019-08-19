#!/bin/bash
# Iterate over list, generate key for each user, send it to email
# Will put all keys into /etc/openvpn/easy-rsa/keys
# all zips to /root/keygen

function generate_keys {
    client=$1

    if [[ -z "$client" ]]; then
        echo "Error: Empty client name"
        exit 1
    fi

    if [[ ! -e "/etc/openvpn/easy-rsa/keys/$client.key" ]]; then
        /etc/openvpn/easy-rsa/2.0/pkitool $client
        echo "Keys for $client generated."
    fi
}

function zip_keys {
    client=$1
    zip="/root/keygen/$client.zip"

    if [[ ! -e "$zip" ]]; then
        echo "Creating zip archive for client"
        tmpdir="/tmp/$client-conf"
        mkdir $tmpdir
        cp /etc/openvpn/easy-rsa/keys/ta.key "$tmpdir"
        cp /etc/openvpn/easy-rsa/custom.ovpn "$tmpdir"
        cp /etc/openvpn/easy-rsa/keys/ca.crt "$tmpdir"
        cp "/etc/openvpn/easy-rsa/keys/$client.key" "$tmpdir/client.key"
        cp "/etc/openvpn/easy-rsa/keys/$client.crt" "$tmpdir/client.crt"
        zip -r "$zip" "$tmpdir"
        rm -rf "$tmpdir"
        echo "...zip archive created"
     else
        echo "keys/$client.zip already exists"

fi
}

cd /etc/openvpn/easy-rsa
source /etc/openvpn/easy-rsa/vars

while read -u10 email; do
    user=`echo $email | cut -d@ -f1`
    printf "Creating keys for : $user, his mail is $email\n"
    generate_keys $user
    zip_keys $user
   # change mail
    echo "New keys and config are in attachment. You need to replace keys and config file for your OpenVPN client." |mail -s "Your openVPN keys" -a /root/keygen/$user.zip -r d.tukan@sapiens.solutions $email
    printf "Sent new keys to $email\n"
done 10< /root/keygen/scripts/new_user.txt
