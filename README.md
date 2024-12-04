Digital Signature Automation Script
Overview
This script automates the process of generating, signing, and verifying digital signatures for documents. It ensures the integrity and authenticity of documents using RSA key pairs and secure hashing algorithms. The script is user-friendly, with interactive prompts to guide users through each step.

Features
OpenSSL Check and Installation: Ensures OpenSSL is installed, and prompts for installation if not.

File and Directory Management: Prompts for file paths and creates directories for storing keys and signatures.

Key Pair Generation: Generates RSA key pairs specific to each document with optional password protection.

Document Signing: Signs documents using the private key and stores digital signatures.

Document Verification: Verifies documents using the corresponding public key and digital signature.

Interactive User Prompts: Provides options for signing and verifying multiple files, with clear feedback messages.

Usage Instructions
Clone or Download the Script

sh
git clone <repository_url>
cd <repository_directory>
Make the Script Executable

sh
chmod +x digital_signature.sh
Run the Script

sh
./digital_signature.sh
Menu Options
Generate Key Pair

Generates an RSA key pair (private and public keys) for the specified document.

Option to password-protect the private key.

Sign Document

Signs the specified document using the generated private key.

Prompts for the password if the private key is encrypted.

Verify Document Signature

Verifies the specified document using the corresponding public key and digital signature.

Displays success or failure messages, mentioning the file being verified.

Help

Displays usage instructions and information about the script.

Exit

Exits the script.

Example Workflow
Initialization:

The script checks if OpenSSL is installed and prompts for installation if not.

File Selection:

Prompt the user to select a file for signing or verification.

Directory Creation:

Create a unique directory for storing keys and signatures.

Key Management:

Generate RSA key pairs and optionally password-protect the private key.

Signing Process:

Sign the selected document and prompt the user for signing additional files.

Verification Process:

Verify the selected document and prompt the user for verifying additional files.

Conclusion:

Provide feedback on the actions taken.

Option to exit or restart the process based on user input.

Security Considerations
Ensure the private key is stored securely and not exposed unnecessarily.

Use strong passwords for encrypting the private key.

Choose secure hashing algorithms (e.g., sha256, sha512) for signing documents.

Contributions
Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

License
This project is licensed under the MIT License.
