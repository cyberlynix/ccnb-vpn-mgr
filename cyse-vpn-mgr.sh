# Created by Lynix (Anthony Roy) Cyber Security Student (c) 2023
# Description: This script will allow you to manage your VPN users for the course of Cybersecurity.

 echo "=== CYSE VPN Manager ==="
 echo "Created by Lynix - Cyber Security Student (c) 2023"

    echo "Please select an option:"
    echo "1. Create VPN Users"
    echo "2. Revoke VPN User"
    echo "3. Show all VPN users"
    echo "4. Exit"

read option_choice
case $option_choice in
    1)
        echo "How many users (students) do you want to create?"
        echo "The format for each username will be student# which you can assign to students"
        read user_count
        for ((i=1; i<=$user_count; i++)); do
            echo "Enter the name of the user (student) you want to create:"
            read user_name
            create_profile $user_name
        done
        ;;
    2)
        echo "Not Implemented! Try again in a future release"
        ;;
    3)
        echo "You selected option 3."
        ;;
    4)
        echo "Goodbye!"
        exit 0
        ;;
    *)
        echo "Invalid choice. Please try again."
        ;;
esac

new_client () {
        # Generates the custom client.ovpn
        {
        cat /etc/openvpn/server/client-common.txt
        echo "<ca>"
        cat /etc/openvpn/server/easy-rsa/pki/ca.crt
        echo "</ca>"
        echo "<cert>"
        sed -ne '/BEGIN CERTIFICATE/,$ p' /etc/openvpn/server/easy-rsa/pki/issued/"$client".crt
        echo "</cert>"
        echo "<key>"
        cat /etc/openvpn/server/easy-rsa/pki/private/"$client".key
        echo "</key>"
        echo "<tls-crypt>"
        sed -ne '/BEGIN OpenVPN Static key/,$ p' /etc/openvpn/server/tc.key
        echo "</tls-crypt>"
        } > ~/"$client".ovpn
}

create_profile () {
    client=$(sed 's/[^0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-]/_/g' <<< "$1")
    echo "Creating profile for $client ..."
    while [[ -z "$client" || -e /etc/openvpn/server/easy-rsa/pki/issued/"$client".crt ]]; do
        echo "$client: invalid name."
        read -p "Name: " unsanitized_client
        client=$(sed 's/[^0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-]/_/g' <<< "$unsanitized_client")
    done
    cd /etc/openvpn/server/easy-rsa/
    ./easyrsa --batch --days=3650 build-client-full "$client" nopass
    echo "[INFO] $client added. Configuration available in:" ~/"$client.ovpn"
}
