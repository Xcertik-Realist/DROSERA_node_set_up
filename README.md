Below is a concise and well-structured README.md file for the Drosera-Network setup based on the provided instructions. It includes clear steps for installation, Trap deployment, operator setup, and additional details like system requirements and useful links, formatted for clarity on GitHub.
markdown

# Drosera-Network Setup Guide

This guide walks you through setting up and contributing to the Drosera testnet by installing the CLI, deploying a vulnerable contract, setting up a Trap, and connecting an operator.

## Recommended System Requirements
- **CPU**: 2 Cores
- **RAM**: 4 GB
- **Disk**: 20 GB
- **OS**: Ubuntu (recommended)

## Official Resources
- [Drosera Discord](https://discord.com/invite/drosera) *(Insert official link if available)*

## Installation

### 1. Install Dependencies
Update your system and install required packages:
```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install -y curl ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev

2. Install Docker
Remove old Docker installations and set up the latest version:
bash

sudo apt update -y && sudo apt upgrade -y
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove -y $pkg; done

sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(source /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y && sudo apt upgrade -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

Test Docker:
bash

sudo docker run hello-world

Trap Setup
1. Configure Environment
Install required CLIs:
Drosera CLI:
bash

curl -L https://app.drosera.io/install | bash
source /root/.bashrc
droseraup

Foundry CLI:
bash

curl -L https://foundry.paradigm.xyz | bash
source /root/.bashrc
foundryup

Bun:
bash

curl -fsSL https://bun.sh/install | bash

2. Deploy Contract & Trap
Create a new Trap project:
bash

mkdir my-drosera-trap && cd my-drosera-trap

Configure Git:
bash

git config --global user.email "YOUR_GITHUB_EMAIL"
git config --global user.name "YOUR_GITHUB_USERNAME"

Initialize and compile the Trap:
bash

forge init -t drosera-network/trap-foundry-template
bun install
forge build

Deploy the Trap:
bash

DROSERA_PRIVATE_KEY=your_private_key drosera apply

Replace your_private_key with your funded Holesky ETH wallet private key. When prompted, type ofc and press Enter.
3. Check Trap in Dashboard
Visit Drosera Dashboard and connect your Drosera EVM wallet.

Navigate to Traps Owned or search for your Trap address.

4. Bloom Boost Trap
Open your Trap in the dashboard.

Click Send Bloom Boost and deposit Holesky ETH.

Operator Setup
1. Whitelist Operator
Edit the Trap configuration:
bash

cd my-drosera-trap
nano drosera.toml

Add to the bottom:
toml

private_trap = true
whitelist = ["YOUR_OPERATOR_ADDRESS"]

Replace YOUR_OPERATOR_ADDRESS with your EVM wallet public address.
Update the configuration:
bash

DROSERA_PRIVATE_KEY=your_private_key drosera apply

2. Install Operator CLI
Download and set up the operator CLI:
bash

cd ~
curl -LO https://github.com/drosera-network/releases/releases/download/v1.16.2/drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
tar -xvf drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
./drosera-operator --version
sudo cp drosera-operator /usr/bin

3. Register Operator
Register your operator:
bash

drosera-operator register --eth-rpc-url https://ethereum-holesky-rpc.publicnode.com --eth-private-key your_private_key

Use the same private key as your Trap wallet.
4. Create Systemd Service
Set up the operator as a service:
bash

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
    --eth-rpc-url https://ethereum-holesky-rpc.publicnode.com \
    --eth-backup-rpc-url https://1rpc.io/holesky \
    --drosera-address 0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8 \
    --eth-private-key your_private_key \
    --listen-address 0.0.0.0 \
    --network-external-p2p-address localhost \
    --disable-dnr-confirmation true

[Install]
WantedBy=multi-user.target
EOF

Replace your_private_key in the file.
5. Open Ports
Configure the firewall:
bash

sudo ufw allow ssh
sudo ufw allow 22
sudo ufw allow 31313/tcp
sudo ufw allow 31314/tcp
sudo ufw enable

6. Run Operator
Start the operator service:
bash

sudo systemctl daemon-reload
sudo systemctl enable drosera
sudo systemctl start drosera

7. Check Node Health
Monitor the node:
bash

journalctl -u drosera.service -f

8. Opt-in Trap
In the dashboard, click Opt-in to connect your operator to the Trap.

9. Check Node Liveness
Verify your node is producing green blocks in the dashboard.

Optional Commands
Stop the node:
bash

sudo systemctl stop drosera

Restart the node:
bash

sudo systemctl restart drosera

Notes
Ensure your EVM wallet is funded with Holesky ETH before deploying.

Replace placeholder values (your_private_key, YOUR_OPERATOR_ADDRESS) with your actual details.

For issues, check the Drosera Dashboard or join the official Discord.

About
This repository provides a setup guide for contributing to the Drosera testnet. No further description or website is provided at this time.

