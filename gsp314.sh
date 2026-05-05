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
GOLD=$'\033[38;5;220m'

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

ok()      { echo "  ${LIME}${BOLD}✔${RESET}  ${WHITE}$1${RESET}"; }
fail()    { echo "  ${RED}${BOLD}✘${RESET}  ${RED}$1${RESET}"; }
info()    { echo "  ${TEAL}➜${RESET}  ${DIM}${WHITE}$1${RESET}"; }
warn()    { echo "  ${YELLOW}${BOLD}⚠${RESET}  ${YELLOW}$1${RESET}"; }
label()   { printf "  ${LAVENDER}${BOLD}◈${RESET}  ${BOLD}${WHITE}%-18s${RESET}  ${YELLOW}%s${RESET}\n" "$1" "$2"; }

divider() { echo "  ${DIM}${LAVENDER}──────────────────────────────────────────────────${RESET}"; }

run_step() {
    local spin_msg="$1"; local ok_msg="$2"; local fail_msg="$3"
    shift 3
    "$@" &>/dev/null &
    spinner $! "$spin_msg"
    if "$@" &>/dev/null; then
        ok "$ok_msg"
    else
        fail "$fail_msg"
    fi
    echo
}

clear

# ─────────────────────────────────────────────
#   BANNER
# ─────────────────────────────────────────────
echo
echo "${BLUE}${BOLD}"
echo "   ██████╗██╗      ██████╗ ██╗   ██╗██████╗  ██████╗  █████╗ ██████╗  ██████╗"
echo "  ██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██╔════╝"
echo "  ██║     ██║     ██║   ██║██║   ██║██║  ██║██║   ██║███████║██████╔╝██║     "
echo "  ██║     ██║     ██║   ██║██║   ██║██║  ██║██║   ██║██╔══██║██╔══██╗██║     "
echo "  ╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝╚██████╔╝██║  ██║██║  ██║╚██████╗"
echo "   ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝"
echo "${RESET}"
echo "  ${CYAN}${BOLD}   ✦  Set Up a Google Cloud Network : Challenge Lab  ✦${RESET}"
divider
echo "  ${DIM}${WHITE}   Initializing your challenge environment... 🧠💡${RESET}"
divider
sleep 0.5

# ─────────────────────────────────────────────
#   STEP 1: USER INPUT
# ─────────────────────────────────────────────
step_banner "Lab Configuration Input" "📋"
echo "  ${DIM}${WHITE}Enter values exactly as shown in your Challenge Lab task.${RESET}"
echo

ask() {
    local varname="$1" label_text="$2" hint="$3"
    [[ -n "$hint" ]] && printf "  ${PINK}${BOLD}❯  %-14s ${DIM}(%s)${RESET}${PINK}${BOLD} : ${RESET}" "$label_text" "$hint" \
                     || printf "  ${PINK}${BOLD}❯  %-14s : ${RESET}" "$label_text"
    read -r "$varname"
    echo
}

ask VPC_NAME   "VPC_NAME"
ask SUBNET_A   "SUBNET_A"
ask SUBNET_B   "SUBNET_B"
ask FIREWALL_1 "FIREWALL_1"
ask FIREWALL_2 "FIREWALL_2"
ask FIREWALL_3 "FIREWALL_3"
ask ZONE_1     "ZONE_1"     "e.g. us-east4-b"
ask ZONE_2     "ZONE_2"     "e.g. us-west1-a"

# Derive regions
export REGION_1="${ZONE_1%-*}"
export REGION_2="${ZONE_2%-*}"
export VM_1=us-test-01
export VM_2=us-test-02

# ─── Config Summary Box ───────────────────────
echo
echo "  ${GREEN}${BOLD}╔════════════════════════════════════════════════════╗${RESET}"
echo "  ${GREEN}${BOLD}║           ✦  CONFIGURATION SUMMARY  ✦             ║${RESET}"
echo "  ${GREEN}${BOLD}╠════════════════════════════════════════════════════╣${RESET}"
echo "  ${GREEN}${BOLD}║${RESET}"
label "  VPC"          "$VPC_NAME"
label "  Subnet A"     "$SUBNET_A  →  $REGION_1  (10.10.10.0/24)"
label "  Subnet B"     "$SUBNET_B  →  $REGION_2  (10.10.20.0/24)"
label "  Firewall 1"   "$FIREWALL_1  [SSH tcp:22]"
label "  Firewall 2"   "$FIREWALL_2  [RDP tcp:3389]"
label "  Firewall 3"   "$FIREWALL_3  [ICMP]"
label "  Zone 1"       "$ZONE_1"
label "  Zone 2"       "$ZONE_2"
label "  VM 1"         "$VM_1"
label "  VM 2"         "$VM_2"
echo "  ${GREEN}${BOLD}║${RESET}"
echo "  ${GREEN}${BOLD}╚════════════════════════════════════════════════════╝${RESET}"
echo

# ─────────────────────────────────────────────
#   STEP 2: CREATE VPC
# ─────────────────────────────────────────────
step_banner "Creating Custom VPC Network" "🌐"

gcloud compute networks create "$VPC_NAME" \
    --project="$DEVSHELL_PROJECT_ID" \
    --subnet-mode=custom \
    --mtu=1460 \
    --bgp-routing-mode=regional &>/dev/null &
spinner $! "Creating VPC  →  $VPC_NAME ..."
gcloud compute networks describe "$VPC_NAME" --project="$DEVSHELL_PROJECT_ID" &>/dev/null \
    && ok "VPC  ${CYAN}${VPC_NAME}${RESET}  created" \
    || fail "VPC creation failed — check your project ID"
echo

# ─────────────────────────────────────────────
#   STEP 3: SUBNETS
# ─────────────────────────────────────────────
step_banner "Provisioning Subnets" "🗺"

gcloud compute networks subnets create "$SUBNET_A" \
    --project="$DEVSHELL_PROJECT_ID" \
    --region="$REGION_1" --network="$VPC_NAME" \
    --range=10.10.10.0/24 --stack-type=IPV4_ONLY &>/dev/null &
spinner $! "Creating Subnet A  →  $SUBNET_A  [$REGION_1] ..."
gcloud compute networks subnets describe "$SUBNET_A" --region="$REGION_1" --project="$DEVSHELL_PROJECT_ID" &>/dev/null \
    && ok "Subnet A  ${CYAN}${SUBNET_A}${RESET}  →  10.10.10.0/24  [$REGION_1]" \
    || fail "Subnet A creation failed"
echo

gcloud compute networks subnets create "$SUBNET_B" \
    --project="$DEVSHELL_PROJECT_ID" \
    --region="$REGION_2" --network="$VPC_NAME" \
    --range=10.10.20.0/24 --stack-type=IPV4_ONLY &>/dev/null &
spinner $! "Creating Subnet B  →  $SUBNET_B  [$REGION_2] ..."
gcloud compute networks subnets describe "$SUBNET_B" --region="$REGION_2" --project="$DEVSHELL_PROJECT_ID" &>/dev/null \
    && ok "Subnet B  ${CYAN}${SUBNET_B}${RESET}  →  10.10.20.0/24  [$REGION_2]" \
    || fail "Subnet B creation failed"
echo

# ─────────────────────────────────────────────
#   STEP 4: FIREWALL RULES
# ─────────────────────────────────────────────
step_banner "Configuring Firewall Rules" "🔥"

gcloud compute firewall-rules create "$FIREWALL_1" \
    --project="$DEVSHELL_PROJECT_ID" --network="$VPC_NAME" \
    --direction=INGRESS --priority=1000 --action=ALLOW \
    --rules=tcp:22 --source-ranges=0.0.0.0/0 &>/dev/null &
spinner $! "$FIREWALL_1  →  SSH (tcp:22) ..."
gcloud compute firewall-rules describe "$FIREWALL_1" --project="$DEVSHELL_PROJECT_ID" &>/dev/null \
    && ok "${CYAN}${FIREWALL_1}${RESET}  ${DIM}→ INGRESS  tcp:22  SSH${RESET}" \
    || fail "$FIREWALL_1  creation failed"
echo

gcloud compute firewall-rules create "$FIREWALL_2" \
    --project="$DEVSHELL_PROJECT_ID" --network="$VPC_NAME" \
    --direction=INGRESS --priority=65535 --action=ALLOW \
    --rules=tcp:3389 --source-ranges=0.0.0.0/24 &>/dev/null &
spinner $! "$FIREWALL_2  →  RDP (tcp:3389) ..."
gcloud compute firewall-rules describe "$FIREWALL_2" --project="$DEVSHELL_PROJECT_ID" &>/dev/null \
    && ok "${CYAN}${FIREWALL_2}${RESET}  ${DIM}→ INGRESS  tcp:3389  RDP${RESET}" \
    || fail "$FIREWALL_2  creation failed"
echo

# FIX: ICMP source ranges must be subnet ranges, not 0.0.0.0/24
gcloud compute firewall-rules create "$FIREWALL_3" \
    --project="$DEVSHELL_PROJECT_ID" --network="$VPC_NAME" \
    --direction=INGRESS --priority=1000 --action=ALLOW \
    --rules=icmp --source-ranges=10.10.10.0/24,10.10.20.0/24 &>/dev/null &
spinner $! "$FIREWALL_3  →  ICMP (ping) ..."
gcloud compute firewall-rules describe "$FIREWALL_3" --project="$DEVSHELL_PROJECT_ID" &>/dev/null \
    && ok "${CYAN}${FIREWALL_3}${RESET}  ${DIM}→ INGRESS  icmp  Ping${RESET}" \
    || fail "$FIREWALL_3  creation failed"
echo

# ─────────────────────────────────────────────
#   STEP 5: CREATE VMs
# ─────────────────────────────────────────────
step_banner "Launching VM Instances" "🖥"

# FIX: removed --tags=allow-icmp (lab uses "all instances" target, no tags needed)
gcloud compute instances create "$VM_1" \
    --project="$DEVSHELL_PROJECT_ID" \
    --zone="$ZONE_1" \
    --machine-type=e2-micro \
    --subnet="$SUBNET_A" &>/dev/null &
spinner $! "Creating  $VM_1  in  $ZONE_1 ..."
gcloud compute instances describe "$VM_1" --zone="$ZONE_1" --project="$DEVSHELL_PROJECT_ID" &>/dev/null \
    && ok "${VM_1}  →  ${CYAN}${ZONE_1}${RESET}  [${SUBNET_A}]" \
    || fail "$VM_1  creation failed"
echo

gcloud compute instances create "$VM_2" \
    --project="$DEVSHELL_PROJECT_ID" \
    --zone="$ZONE_2" \
    --machine-type=e2-micro \
    --subnet="$SUBNET_B" &>/dev/null &
spinner $! "Creating  $VM_2  in  $ZONE_2 ..."
gcloud compute instances describe "$VM_2" --zone="$ZONE_2" --project="$DEVSHELL_PROJECT_ID" &>/dev/null \
    && ok "${VM_2}  →  ${CYAN}${ZONE_2}${RESET}  [${SUBNET_B}]" \
    || fail "$VM_2  creation failed"
echo

# ─────────────────────────────────────────────
#   STEP 6: COUNTDOWN WAIT
# ─────────────────────────────────────────────
step_banner "Waiting for VMs to Initialize" "⏳"

for i in $(seq 30 -1 1); do
    printf "\r  ${TEAL}◷${RESET}  ${DIM}${WHITE}VMs booting...  ${RESET}${BOLD}${GOLD}%2d s${RESET}  remaining   " "$i"
    sleep 1
done
printf "\r  ${LIME}${BOLD}✔${RESET}  ${WHITE}VMs are live and ready!${RESET}$(tput el)\n"
echo

# ─────────────────────────────────────────────
#   STEP 7: CONNECTIVITY TEST
# ─────────────────────────────────────────────
step_banner "Testing VM Connectivity" "📡"

# FIX: Use INTERNAL IP for ping — ICMP firewall only allows subnet ranges, not all external IPs
export INTERNAL_IP_2=$(gcloud compute instances describe "$VM_2" \
    --zone="$ZONE_2" \
    --project="$DEVSHELL_PROJECT_ID" \
    --format='get(networkInterfaces[0].networkIP)')

info "Internal IP of  ${CYAN}${VM_2}${RESET}  →  ${YELLOW}${INTERNAL_IP_2}${RESET}"
echo
info "SSH into  ${CYAN}${VM_1}${RESET}  and pinging  ${CYAN}${VM_2}${RESET}  via internal IP + hostname..."
echo
divider

# FIX: ping internal IP first, then hostname format for latency test
gcloud compute ssh "$VM_1" \
    --zone="$ZONE_1" \
    --project="$DEVSHELL_PROJECT_ID" \
    --quiet \
    --command="ping -c 3 $INTERNAL_IP_2 && ping -c 3 $VM_2.$ZONE_2" \
    && { echo; ok "Connectivity test  ${CYAN}${VM_1} → ${VM_2}${RESET}  passed 🎯"; } \
    || { echo; fail "Connectivity test failed — check firewall rules"; }

divider

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
echo "  ${DIM}${LAVENDER}  Drop a like if this helped you out!${RESET}"
echo
