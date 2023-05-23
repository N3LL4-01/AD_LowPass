#!/bin/bash

# AD-Server-Informationen
AD_SERVER="your_ad_server"
AD_PORT="389"
BASE_DN="your_base_dn"
USERNAME="your_username"
PASSWORD="your_password"

# LDAP-Suche
SEARCH_FILTER="(&(objectClass=user)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))"
SEARCH_ATTRIBUTES="sAMAccountName"
SEARCH_SCOPE="sub"

# Durchführen der LDAP-Suche
OUTPUT=$(ldapsearch -x -h $AD_SERVER -p $AD_PORT -D "$USERNAME" -w "$PASSWORD" -b "$BASE_DN" -LLL "$SEARCH_FILTER" $SEARCH_ATTRIBUTES -s $SEARCH_SCOPE)

# Verarbeiten der Ergebnisse
IFS=$'\n' read -r -d '' -a USER_ARRAY <<< "$OUTPUT"

for USER in "${USER_ARRAY[@]}"; do
    if [[ "$USER" =~ ^sAMAccountName:\ ([a-zA-Z]+)$ ]]; then
        USERNAME="${BASH_REMATCH[1]}"
        PASSWORD_CHECK=$(ldapsearch -x -h $AD_SERVER -p $AD_PORT -D "$USERNAME" -w "$PASSWORD" -b "$BASE_DN" -LLL "(&(objectClass=user)(sAMAccountName=$USERNAME))" "userPassword")
        
        if [[ "$PASSWORD_CHECK" != *"userPassword: "*[0-9]* ]] && [[ "$PASSWORD_CHECK" != *"userPassword: "*[[:punct:]]* ]]; then
            echo "Benutzer ohne Sonderzeichen und Zahlen im Passwort gefunden: $USERNAME"
        fi
    fi
done
