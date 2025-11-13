#!/bin/bash

# Color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner function
function banner() {
echo "${BLUE_TEXT}${BOLD_TEXT}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}┃           C l o u d o A r c          ┃${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}┃               Cloud Lab              ┃${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET_FORMAT}"
echo
    echo -e "${NC}"
    echo -e "${YELLOW}Subscribe to CloudoArc${NC}"
}

# Display banner
banner

# User input section with colors
read -p "$(echo -e "${RED}VPC_NAME: ${NC}")" VPC_NAME
echo ""

read -p "$(echo -e "${RED}SUBNET_A: ${NC}")" SUBNET_A
echo ""

read -p "$(echo -e "${RED}SUBNET_B: ${NC}")" SUBNET_B
echo ""

read -p "$(echo -e "${RED}FIREWALL_1: ${NC}")" FIREWALL_1
echo ""

read -p "$(echo -e "${RED}FIREWALL_2: ${NC}")" FIREWALL_2
echo ""

read -p "$(echo -e "${RED}FIREWALL_3: ${NC}")" FIREWALL_3
echo ""

read -p "$(echo -e "${RED}ZONE_1: ${NC}")" ZONE_1
echo ""

read -p "$(echo -e "${RED}ZONE_2: ${NC}")" ZONE_2
echo ""

# Export derived variables
export REGION_1=${ZONE_1%-*}
export REGION_2=${ZONE_2%-*}
export VM_1=us-test-01
export VM_2=us-test-02


# Create VPC
echo -e "${YELLOW}Creating VPC: $VPC_NAME${NC}"
gcloud compute networks create $VPC_NAME \
    --project=$DEVSHELL_PROJECT_ID \
    --subnet-mode=custom \
    --mtu=1460 \
    --bgp-routing-mode=regional && \

# Create Subnet A
echo -e "${YELLOW}Creating Subnet A $SUBNET_A in $REGION_1${NC}"
gcloud compute networks subnets create $SUBNET_A \
    --project=$DEVSHELL_PROJECT_ID \
    --region=$REGION_1 \
    --network=$VPC_NAME \
    --range=10.10.10.0/24 \
    --stack-type=IPV4_ONLY && \


# Create Subnet B
echo -e "${YELLOW}Creating Subnet B $SUBNET_B in $REGION_2${NC}"
gcloud compute networks subnets create $SUBNET_B \
    --project=$DEVSHELL_PROJECT_ID \
    --region=$REGION_2 \
    --network=$VPC_NAME \
    --range=10.10.20.0/24 \
    --stack-type=IPV4_ONLY && \


# Create Firewall Rules
echo -e "${YELLOW}Creating Firewall Rule 1 $FIREWALL_1 (SSH)${NC}"
gcloud compute firewall-rules create $FIREWALL_1 \
    --project=$DEVSHELL_PROJECT_ID \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --priority=1000 \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=all && \


echo -e "${YELLOW}Creating Firewall Rule 2 $FIREWALL_2 (RDP)${NC}"
gcloud compute firewall-rules create $FIREWALL_2 \
    --project=$DEVSHELL_PROJECT_ID \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --priority=65535 \
    --action=ALLOW \
    --rules=tcp:3389 \
    --source-ranges=0.0.0.0/24 \
    --target-tags=all && \


echo -e "${YELLOW}Creating Firewall Rule 3 $FIREWALL_3 (ICMP)${NC}"
gcloud compute firewall-rules create $FIREWALL_3 \
    --project=$DEVSHELL_PROJECT_ID \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --priority=1000 \
    --action=ALLOW \
    --rules=icmp \
    --source-ranges=0.0.0.0/24 \
    --target-tags=all && \


# Create VMs
echo -e "${YELLOW}Creating VM 1 $VM_1 in $ZONE_1${NC}"
gcloud compute instances create $VM_1 \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE_1 \
    --subnet=$SUBNET_A \
    --tags=allow-icmp && \


echo -e "${YELLOW}Creating VM 2 $VM_2 in $ZONE_2${NC}"
gcloud compute instances create $VM_2 \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE_2 \
    --subnet=$SUBNET_B \
    --tags=allow-icmp && \


# Wait for VMs to be ready
echo -e "${YELLOW}Waiting 20 seconds for VMs to initialize...${NC}"
sleep 20
echo ""

# Test connectivity
echo -e "${RED}connection b/w vms...${NC}"
export EXTERNAL_IP_2=$(gcloud compute instances describe $VM_2 \
    --zone=$ZONE_2 \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

echo -e "${RED}Testing ping from $VM_1 to $VM_2...${NC}"
gcloud compute ssh $VM_1 --zone=$ZONE_1 --project=$DEVSHELL_PROJECT_ID --quiet --command="ping -c 3 $EXTERNAL_IP_2 && ping -c 3 $VM_2.$ZONE_2" && \


# Completion message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}               LAB COMPLETED SUCCESSFULLY!!!           ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo

# ====== GCP DECODE Footer ======
echo "${RED_TEXT}${BOLD_TEXT}🎥 Watch more labs on:  ${RESET_FORMAT}"
echo "${WHITE_TEXT}${BOLD_TEXT}CloudoArc — YouTube${RESET_FORMAT}"
