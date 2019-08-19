#!/bin/bash
# Parameters definition
PROGNAME=$(basename $0)
ARGS="$@"
DEF_PASSWORD=sapiens

function usage {
    cat <<- EOF
Usage: $PROGNAME -l Login -f FirstName -L LastName [ -i userid -g groupid -p password -e email ...]

Optional arguments:
    -i: numeric userid (default: latest available)
    -g: numeric groupid (default: 10000)
    -p: password (default: $DEF_PASSWORD)
    -e: user email address
    -t: title

This program creates LDIF file so you can import them into OpenLDAP.

EOF

    exit 0
}

function parse_arguments {
    while getopts "l:f:L:g:i:p:e:h:t" OPTION;
    do
        case $OPTION in
            l) LOGIN=$OPTARG;;
            f) FIRST_NAME=$OPTARG;;
            L) LAST_NAME=$OPTARG;;
            g) GROUPID=$OPTARG;;
            i) USERID=$OPTARG;;
            p) PASSWORD=$OPTARG;;
            e) EMAIL=$OPTARG;;
            t) TITLE=$OPTARG;;
            h) usage;;
        esac
    done
}

function generate_ldif {
    if [[ -z "$FIRST_NAME" ]]; then
        echo "Error: First name can't be empty!"
        usage
    fi

    if [[ -z "$LAST_NAME" ]]; then
        echo "Error: Last name can't be empty!"
        usage
    fi

    if [[ -z "$USERID" ]]; then
        latestuid=`ldapsearch -x "objectclass=posixAccount" uidNumber | grep -v \^dn | grep -v \^\$ | sed -e 's/uidNumber: //g' | grep -E "^[0-9]{3,5}$" | sort -n | tail -n 1`
        USERID=$((latestuid + 1))
    fi

        # Template definition
        cat <<- EOF > /tmp/$LOGIN.ldif
        dn: cn=$FIRST_NAME $LAST_NAME,ou=People,dc=hq,dc=sapiens,dc=solutions
        objectClass: posixAccount
        objectClass: inetOrgPerson
        objectClass: organizationalPerson
        objectClass: person
        homeDirectory: /home/$LOGIN
        loginShell: /bin/false
        uid: $LOGIN
        cn: $FIRST_NAME $LAST_NAME
        gidNumber: 10000
        uidNumber: $USERID
        sn: $LAST_NAME
        givenName: $FIRST_NAME
        userPassword: ${PASSWORD:-$DEF_PASSWORD}
        title: ${TITLE:-none}
        mail: $LOGIN@sapiens.solutions
EOF


}

function main {
    parse_arguments $ARGS
    generate_ldif
    ldapadd -x -w `cat /root/ldap_admin_pwd` -D "cn=admin,dc=hq,dc=sapiens,dc=solutions" -f /tmp/$LOGIN.ldif
}

main
