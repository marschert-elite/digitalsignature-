#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if OpenSSL is installed and install if not
check_and_install_openssl() {
    if ! command -v openssl &> /dev/null; then
        echo "OpenSSL is not installed."
        read -p "Would you like to install OpenSSL? (y/n): " install_openssl
        if [ "$install_openssl" = "y" ]; then
            echo "Installing OpenSSL..."
            sudo apt-get update
            sudo apt-get install openssl -y
            echo "OpenSSL has been installed. Please restart your terminal session and run the script again."
            exit 1
        else
            echo "OpenSSL is required for this script to run. Exiting."
            exit 1
        fi
    else
        echo "OpenSSL is already installed."
    fi
}

# Function to ask for file to be signed or verified with validation loop
ask_for_file() {
    while true; do
        read -p "Enter the path of the file to be signed or verified: " file_path
        if [ -f "$file_path" ]; then
            file_name=$(basename "$file_path")
            file_base_name="${file_name%.*}"
            break
        else
            echo "Error: File not found! Please enter a valid file path."
        fi
    done
}

# Function to create directory and ask for storage paths
create_directory() {
    read -p "Enter the path to store the keys and signature files (default is current directory): " storage_path
    storage_path=${storage_path:-$(pwd)}
    mkdir -p "$storage_path/$file_base_name"
    storage_path="$storage_path/$file_base_name"
    echo -e "${GREEN}Files will be stored in: $storage_path${NC}"
}

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$storage_path/digital_signature.log"
}

# Function to generate a key pair
generate_keys() {
    read -p "Would you like to password-protect the private key? (y/n): " encrypt_key
    if [ "$encrypt_key" = "y" ]; then
        echo "Generating RSA key pair with password protection..."
        openssl genpkey -algorithm RSA -aes256 -out "$storage_path/private_${file_base_name}_key.pem"
    else
        echo "Generating RSA key pair..."
        openssl genpkey -algorithm RSA -out "$storage_path/private_${file_base_name}_key.pem"
    fi
    openssl rsa -pubout -in "$storage_path/private_${file_base_name}_key.pem" -out "$storage_path/public_${file_base_name}_key.pem"
    echo -e "${GREEN}Keys generated successfully: private_${file_base_name}_key.pem and public_${file_base_name}_key.pem${NC}"
    log_action "Generated RSA key pair."
}

# Function to sign a document
sign_document() {
    read -p "Choose hashing algorithm (sha256, sha512, etc.): " hash_algo
    read -p "Enter the password for the private key (if applicable): " -s key_pass
    echo "Signing document: $file_path with $hash_algo..."
    if [ -n "$key_pass" ]; then
        openssl dgst -"$hash_algo" -sign <(openssl rsa -in "$storage_path/private_${file_base_name}_key.pem" -passin pass:"$key_pass") -out "$storage_path/${file_base_name}_signature.bin" "$file_path"
    else
        openssl dgst -"$hash_algo" -sign "$storage_path/private_${file_base_name}_key.pem" -out "$storage_path/${file_base_name}_signature.bin" "$file_path"
    fi
    if [ $? -eq 0 ]; then
        echo "Document signed successfully: ${file_base_name}_signature.bin"
        log_action "Signed document $file_path with $hash_algo."
    else
        echo -e "${RED}Failed to sign document: ${file_base_name}_signature.bin${NC}"
    fi
    read -p "Would you like to sign another file? (y/n): " sign_another
    if [ "$sign_another" = "y" ]; then
        ask_for_file
        create_directory
        generate_keys
        sign_document
    fi
}

# Function to verify a document's signature
verify_signature() {
    while true; do
        echo "Verifying document: $file_path..."
        openssl dgst -sha256 -verify "$storage_path/public_${file_base_name}_key.pem" -signature "$storage_path/${file_base_name}_signature.bin" "$file_path"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Signature verification successful for file: $file_path${NC}"
            log_action "Verified document $file_path successfully."
        else
            echo -e "${RED}Signature verification failed for file: $file_path${NC}"
            log_action "Failed to verify document $file_path."
        fi
        read -p "Would you like to verify another file? (y/n): " verify_another
        if [ "$verify_another" = "y" ]; then
            ask_for_file
            create_directory
        else
            break
        fi
    done
}

# Function to show help
show_help() {
    echo "Usage: ./digital_signature.sh"
    echo "Options:"
    echo "  1. Generate Key Pair: Generates a new RSA key pair."
    echo "  2. Sign Document: Signs a specified document using the generated private key."
    echo "  3. Verify Document Signature: Verifies the digital signature of a specified document using the generated public key."
    echo "  4. Help: Displays this help message."
    echo "  5. Exit: Exits the script."
}

# Main menu loop
check_and_install_openssl
echo "Digital Signature Automation Script"
ask_for_file
create_directory

while true; do
    echo "1. Generate Key Pair"
    echo "2. Sign Document"
    echo "3. Verify Document Signature"
    echo "4. Help"
    echo "5. Exit"
    read -p "Choose an option: " option

    case $option in
        1)
            generate_keys
            ;;
        2)
            sign_document
            ;;
        3)
            verify_signature
            ;;
        4)
            show_help
            ;;
        5)
            echo "Exiting script."
            exit 0
            ;;
        *)
            echo "Invalid option, please try again."
            ;;
    esac
done
