#!/bin/bash

# ─────────────────────────────────────────────
#   COLOR PALETTE
# ─────────────────────────────────────────────
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

BOLD=$(tput bold)
DIM=$'\033[2m'
RESET=$(tput sgr0)

TEAL=$'\033[38;5;50m'
ORANGE=$'\033[38;5;214m'
PINK=$'\033[38;5;213m'
LAVENDER=$'\033[38;5;183m'
LIME=$'\033[38;5;154m'

# ─────────────────────────────────────────────
#   UTILITY FUNCTIONS
# ─────────────────────────────────────────────

spinner() {
    local pid=$1
    local msg="${2:-Processing...}"
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0
    tput civis
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${CYAN}${frames[$i]}${RESET}  ${DIM}${WHITE}${msg}${RESET}   "
        i=$(( (i+1) % ${#frames[@]} ))
        sleep 0.08
    done
    printf "\r  ${LIME}${BOLD}✔${RESET}  ${WHITE}${msg}${RESET}$(tput el)\n"
    tput cnorm
}

step_banner() {
    local title="$1"
    local icon="${2:-⚙}"
    echo
    echo "  ${MAGENTA}${BOLD}╔══════════════════════════════════════════════╗${RESET}"
    printf "  ${MAGENTA}${BOLD}║${RESET}  ${CYAN}${BOLD}${icon}  %-42s${RESET}${MAGENTA}${BOLD}║${RESET}\n" "${title}"
    echo "  ${MAGENTA}${BOLD}╚══════════════════════════════════════════════╝${RESET}"
    echo
}

success() { echo "  ${LIME}${BOLD}✔${RESET}  ${WHITE}$1${RESET}"; }
info()    { echo "  ${TEAL}➜${RESET}  ${DIM}${WHITE}$1${RESET}"; }
warn()    { echo "  ${YELLOW}${BOLD}⚠${RESET}  ${YELLOW}$1${RESET}"; }
label()   { printf "  ${LAVENDER}${BOLD}◈${RESET}  ${BOLD}${WHITE}%-18s${RESET}  ${YELLOW}%s${RESET}\n" "$1" "$2"; }

divider() {
    echo "  ${DIM}${LAVENDER}──────────────────────────────────────────────────${RESET}"
}

run_silent() {
    local msg="$1"; shift
    "$@" &>/dev/null &
    spinner $! "$msg"
}

clear

# ─────────────────────────────────────────────
#   BANNER
# ─────────────────────────────────────────────
# Welcome message
echo "${BLUE_TEXT}${BOLD_TEXT}"
echo "  ██████╗██╗      ██████╗ ██╗   ██╗██████╗  ██████╗  █████╗ ██████╗  ██████╗ "
echo " ██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██╔════╝ "
echo " ██║     ██║     ██║   ██║██║   ██║██║  ██║██║   ██║███████║██████╔╝██║      "
echo " ██║     ██║     ██║   ██║██║   ██║██║  ██║██║   ██║██╔══██║██╔══██╗██║      "
echo " ╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝╚██████╔╝██║  ██║██║  ██║╚██████╗ "
echo "  ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ "
echo "${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}─────────── Cloud Lab ───────────${RESET_FORMAT}"
echo
echo "  ${CYAN}${BOLD}   ✦  Set Up a Google Cloud Network: Challenge Lab  ✦${RESET}"
divider
echo "  ${DIM}${WHITE}   Preparing your challenge environment... 🧠💡${RESET}"
divider
sleep 0.5

# ─────────────────────────────────────────────
#   STEP 1: USER INPUT
# ─────────────────────────────────────────────
step_banner "Lab Configuration Input" "📋"

echo "  ${DIM}${WHITE}Enter the values as shown in your Challenge Lab task.${RESET}"
echo

prompt_input() {
    local varname="$1"
    local label_text="$2"
    printf "  ${PINK}${BOLD}❯  %-14s : ${RESET}" "$label_text"
    read -r "$varname"
}

prompt_input VPC_NAME   "VPC_NAME"
echo
prompt_input SUBNET_A   "SUBNET_A"
echo
prompt_input SUBNET_B   "SUBNET_B"
echo
prompt_input FIREWALL_1 "FIREWALL_1"
echo
prompt_input FIREWALL_2 "FIREWALL_2"
echo
prompt_input FIREWALL_3 "FIREWALL_3"
echo
prompt_input ZONE_1     "ZONE_1"
echo
prompt_input ZONE_2     "ZONE_2"
echo

# Derive regions from zones
export REGION_1="${ZONE_1%-*}"
export REGION_2="${ZONE_2%-*}"
export VM_1=us-test-01
export VM_2=us-test-02

divider
label "VPC"        "$VPC_NAME"
label "Subnet A"   "$SUBNET_A  ($REGION_1)"
label "Subnet B"   "$SUBNET_B  ($REGION_2)"
label "Firewall 1" "$FIREWALL_1"
label "Firewall 2" "$FIREWALL_2"
label "Firewall 3" "$FIREWALL_3"
label "Zone 1"     "$ZONE_1"
label "Zone 2"     "$ZONE_2"
label "VM 1"       "$VM_1"
label "VM 2"       "$VM_2"
divider

# ─────────────────────────────────────────────
#   STEP 2: CREATE VPC
# ─────────────────────────────────────────────
step_banner "Creating Custom VPC Network" "🌐"

run_silent "Creating VPC  →  ${VPC_NAME}..." \
    gcloud compute networks create "$VPC_NAME" \
        --project="$DEVSHELL_PROJECT_ID" \
        --subnet-mode=custom \
        --mtu=1460 \
        --bgp-routing-mode=regional
success "VPC  ${CYAN}${VPC_NAME}${RESET}  created"

# ─────────────────────────────────────────────
#   STEP 3: CREATE SUBNETS
# ─────────────────────────────────────────────
step_banner "Provisioning Subnets" "🗺"

run_silent "Subnet A  →  ${SUBNET_A}  (${REGION_1})..." \
    gcloud compute networks subnets create "$SUBNET_A" \
        --project="$DEVSHELL_PROJECT_ID" \
        --region="$REGION_1" \
        --network="$VPC_NAME" \
        --range=10.10.10.0/24 \
        --stack-type=IPV4_ONLY
success "Subnet A  ${CYAN}${SUBNET_A}${RESET}  →  10.10.10.0/24  [${REGION_1}]"

run_silent "Subnet B  →  ${SUBNET_B}  (${REGION_2})..." \
    gcloud compute networks subnets create "$SUBNET_B" \
        --project="$DEVSHELL_PROJECT_ID" \
        --region="$REGION_2" \
        --network="$VPC_NAME" \
        --range=10.10.20.0/24 \
        --stack-type=IPV4_ONLY
success "Subnet B  ${CYAN}${SUBNET_B}${RESET}  →  10.10.20.0/24  [${REGION_2}]"

# ─────────────────────────────────────────────
#   STEP 4: FIREWALL RULES
# ─────────────────────────────────────────────
step_banner "Configuring Firewall Rules" "🔥"

run_silent "${FIREWALL_1}  →  SSH  (tcp:22)..." \
    gcloud compute firewall-rules create "$FIREWALL_1" \
        --project="$DEVSHELL_PROJECT_ID" \
        --network="$VPC_NAME" \
        --direction=INGRESS \
        --priority=1000 \
        --action=ALLOW \
        --rules=tcp:22 \
        --source-ranges=0.0.0.0/0 \
        --target-tags=all
success "${CYAN}${FIREWALL_1}${RESET}   ${DIM}→ INGRESS  tcp:22  (SSH)${RESET}"

run_silent "${FIREWALL_2}  →  RDP  (tcp:3389)..." \
    gcloud compute firewall-rules create "$FIREWALL_2" \
        --project="$DEVSHELL_PROJECT_ID" \
        --network="$VPC_NAME" \
        --direction=INGRESS \
        --priority=65535 \
        --action=ALLOW \
        --rules=tcp:3389 \
        --source-ranges=0.0.0.0/24 \
        --target-tags=all
success "${CYAN}${FIREWALL_2}${RESET}   ${DIM}→ INGRESS  tcp:3389  (RDP)${RESET}"

run_silent "${FIREWALL_3}  →  ICMP  (ping)..." \
    gcloud compute firewall-rules create "$FIREWALL_3" \
        --project="$DEVSHELL_PROJECT_ID" \
        --network="$VPC_NAME" \
        --direction=INGRESS \
        --priority=1000 \
        --action=ALLOW \
        --rules=icmp \
        --source-ranges=0.0.0.0/24 \
        --target-tags=all
success "${CYAN}${FIREWALL_3}${RESET}   ${DIM}→ INGRESS  icmp  (ICMP/Ping)${RESET}"

# ─────────────────────────────────────────────
#   STEP 5: CREATE VMs
# ─────────────────────────────────────────────
step_banner "Launching VM Instances" "🖥"

run_silent "Creating  ${VM_1}  in  ${ZONE_1}..." \
    gcloud compute instances create "$VM_1" \
        --project="$DEVSHELL_PROJECT_ID" \
        --zone="$ZONE_1" \
        --subnet="$SUBNET_A" \
        --tags=allow-icmp
success "${VM_1}  →  ${CYAN}${ZONE_1}${RESET}  [${SUBNET_A}]"

run_silent "Creating  ${VM_2}  in  ${ZONE_2}..." \
    gcloud compute instances create "$VM_2" \
        --project="$DEVSHELL_PROJECT_ID" \
        --zone="$ZONE_2" \
        --subnet="$SUBNET_B" \
        --tags=allow-icmp
success "${VM_2}  →  ${CYAN}${ZONE_2}${RESET}  [${SUBNET_B}]"

# ─────────────────────────────────────────────
#   STEP 6: WAIT FOR VMs
# ─────────────────────────────────────────────
step_banner "Waiting for VMs to Initialize" "⏳"

for i in $(seq 20 -1 1); do
    printf "\r  ${TEAL}◷${RESET}  ${DIM}${WHITE}Waiting...  ${RESET}${BOLD}${YELLOW}%2d s${RESET}  remaining   " "$i"
    sleep 1
done
printf "\r  ${LIME}${BOLD}✔${RESET}  ${WHITE}VMs are ready!${RESET}$(tput el)\n"

# ─────────────────────────────────────────────
#   STEP 7: CONNECTIVITY TEST
# ─────────────────────────────────────────────
step_banner "Testing VM Connectivity" "📡"

export EXTERNAL_IP_2=$(gcloud compute instances describe "$VM_2" \
    --zone="$ZONE_2" \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

info "External IP of ${VM_2}  →  ${YELLOW}${EXTERNAL_IP_2}${RESET}"
echo
info "Pinging  ${VM_2}  from  ${VM_1}..."
echo

gcloud compute ssh "$VM_1" \
    --zone="$ZONE_1" \
    --project="$DEVSHELL_PROJECT_ID" \
    --quiet \
    --command="ping -c 3 $EXTERNAL_IP_2 && ping -c 3 $VM_2.$ZONE_2"

echo
success "Connectivity test complete  ${CYAN}${VM_1} → ${VM_2}${RESET}"

# ─────────────────────────────────────────────
#   DONE
# ─────────────────────────────────────────────
echo
echo "  ${GREEN}${BOLD}╔══════════════════════════════════════════════════╗${RESET}"
echo "  ${GREEN}${BOLD}║                                                  ║${RESET}"
echo "  ${GREEN}${BOLD}║        🎉  LAB COMPLETED SUCCESSFULLY!  🎉       ║${RESET}"
echo "  ${GREEN}${BOLD}║                                                  ║${RESET}"
echo "  ${GREEN}${BOLD}╚══════════════════════════════════════════════════╝${RESET}"
echo
echo "  ${ORANGE}${BOLD}🎥  More labs on  →  ${RESET}${BOLD}${WHITE}CloudoArc${RESET}  ${ORANGE}${BOLD}(YouTube)${RESET}"
echo "  ${DIM}${LAVENDER}  Drop a ⭐ if this helped you out!${RESET}"
echo
