#!/bin/bash

# Drosera-Network Setup Script
# This script automates the setup of Drosera testnet based on the provided README

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print messages
print_msg() {
    echo -e "${GREEN}[INFO] $1${NC}"
}

# Function to print errors
print_err() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

# Prompt for required inputs
read -p "Enter your GitHub Email: " GITHUB_EMAIL
read -p "Enter your GitHub Username: " GITHUB_USERNAME
read -sp "Enter your EVM Wallet Private Key (Holesky ETH funded): " DROSERA_PRIVATE_KEY
echo

# Validate inputs
if [[ -z "$GITHUB_EMAIL" || -z "$GITHUB_USERNAME" || -z "$DROSERA_PRIVATE_KEY" ]]; then
    print_err "All inputs (GitHub Email, Username, Private Key) are required!"
fi

# Step 1: Install Dependencies
print_msg "Installing system dependencies..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install -y curl ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev

# Step 2: Install Docker
print_msg "Installing Docker..."
sudo apt update -y && sudo apt upgrade -y
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
    sudo apt-get remove -y $pkg || true
done

sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(source /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y && sudo apt upgrade -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Test Docker
print_msg "Testing Docker installation..."
sudo docker run hello-world || print_err "Docker test failed!"

# Step 3: Install Drosera CLI
print_msg "Installing Drosera CLI..."
curl -L https://app.drosera.io/install | bash
source /root/.bashrc
droseraup

# Step 4: Install Foundry CLI
print_msg "Installing Foundry CLI..."
curl -L https://foundry.paradigm.xyz | bash
source /root/.bashrc
foundryup

# Step 5: Install Bun
print_msg "Installing Bun..."
curl -fsSL https://bun.sh/install | bash

# Step 6: Deploy Contract & Trap
print_msg "Setting up Trap..."
mkdir -p my-drosera-trap
cd my-drosera-trap

# Configure Git
print_msg "Configuring Git..."
git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_USERNAME"

# Initialize Trap
print_msg "Initializing Trap..."
forge init -t drosera-network/trap-foundry-template

# Compile Trap
print_msg "Compiling Trap..."
bun install
forge build

# Deploy Trap
print_msg "Deploying Trap..."
DROSERA_PRIVATE_KEY=$DROSERA_PRIVATE_KEY drosera apply
print_msg "When prompted, type 'ofc' and press Enter in the terminal."

# Step 7: Whitelist Operator
print_msg "Configuring Operator Whitelist..."
# Assuming Operator_Address is the public address derived from the private key (not provided in README)
# Placeholder for Operator Address; user must replace or derive it
OPERATOR_ADDRESS="YOUR_OPERATOR_ADDRESS"
echo -e "\nprivate_trap = true\nwhitelist = [\"$OPERATOR_ADDRESS\"]" >> drosera.toml

# Update Trap Configuration
print_msg "Updating Trap Configuration..."
DROSERA_PRIVATE_KEY=$DROSERA_PRIVATE_KEY drosera apply

# Step 8: Install Operator CLI
print_msg "Installing Operator CLI..."
cd ~
curl -LO https://github.com/drosera-network/releases/releases/download/v1.16.2/drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
tar -xvf drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
chmod +x drosera-operator
./drosera-operator --version || print_err "Operator CLI installation failed!"

# Move to global path
sudo cp drosera-operator /usr/bin
drosera-operator --version || print_err "Global Operator CLI setup failed!"

# Step 9: Register Operator
print_msg "Registering Operator..."
drosera-operator register --eth-rpc-url https://ethereum-holesky-rpc.publicnode.com --eth-private-key $DROSERA_PRIVATE_KEY

# Step 10: Create Operator Systemd Service
print_msg "Creating Systemd Service..."
sudo tee /etc/systemd/system/drosera.service > /dev/null <<EOF
[Unit]
Description=drosera node service
After=network-online.target

[Service]
User=$USER
Restart=always
RestartSec=15
LimitNOFILE=65535
ExecStart=$(which drosera-operator) node --db-file-path $HOME/.drosera.db --network-p2p-port 31313 --server-port 31314 \
    --eth-rpc-url https://ethereum-holesky...
