#!/bin/bash


# ==========================================
# Legal Firm System Administration Script
# ==========================================


BACKUP_SOURCE="/data"
BACKUP_DEST="/backup"
LOG_FILE="/var/log/legal_firm_admin.log"


CPU_LIMIT=80
DISK_LIMIT=85
FAILED_LOGIN_LIMIT=5


RUNNING=true


# -------- Environment Setup --------
init_environment() {


    # Create source directory if missing
    if [ ! -d "$BACKUP_SOURCE" ]; then
        mkdir -p "$BACKUP_SOURCE"
        echo "Created source directory: $BACKUP_SOURCE"
    fi


    # Create backup directory if missing
    if [ ! -d "$BACKUP_DEST" ]; then
        mkdir -p "$BACKUP_DEST"
        echo "Created backup directory: $BACKUP_DEST"
    fi


    # Create log directory + file
    LOG_DIR=$(dirname "$LOG_FILE")


    if [ ! -d "$LOG_DIR" ]; then
        mkdir -p "$LOG_DIR"
        echo "Created log directory: $LOG_DIR"
    fi


    if [ ! -f "$LOG_FILE" ]; then
        touch "$LOG_FILE"
        echo "Created log file: $LOG_FILE"
    fi
}


# -------- Logging --------
log_action() {
    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE"
    echo "$(date) : $1" >> "$LOG_FILE"
}


# -------- Ctrl+C Handler --------
ctrl_c() {
    echo ""
    echo "Ctrl+C detected, stopping automatic monitoring."
    log_action "Automatic monitoring stopped by user"
    RUNNING=false
}


# -------- Admin Check --------
check_admin() {
    if [ "$EUID" -ne 0 ]; then
        echo "ALERT: Unauthorized administrative access attempt detected."
        log_action "Unauthorized admin command attempt by user $USER"
        exit 1
    fi
}


# -------- Backup --------
perform_backup() {


    check_admin


    DATE=$(date +"%Y-%m-%d_%H-%M-%S")


    mkdir -p "$BACKUP_SOURCE"
    mkdir -p "$BACKUP_DEST"


    tar -czf "$BACKUP_DEST/backup_$DATE.tar.gz" "$BACKUP_SOURCE"


    if [ $? -eq 0 ]; then
        echo "Backup completed successfully."
        log_action "Backup created by $USER"
    else
        echo "Backup failed."
        log_action "Backup failure"
    fi
}


# -------- Monitor --------
monitor_system() {


    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2+$4}')
    MEM=$(free | awk '/Mem/ {printf("%.2f"), $3/$2 * 100}')
    DISK=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')


    echo "CPU Usage: $CPU%"
    echo "Memory Usage: $MEM%"
    echo "Disk Usage: $DISK%"
    echo ""


    CPU_INT=${CPU%.*}


    if [ "$CPU_INT" -gt "$CPU_LIMIT" ]; then
        echo "WARNING: High CPU usage detected!"
        log_action "High CPU usage alert"
    fi


    if [ "$DISK" -gt "$DISK_LIMIT" ]; then
        echo "WARNING: Disk space running low!"
        log_action "Disk usage alert"
    fi


    log_action "System monitoring executed"
}


# -------- Auto Monitor --------
auto_monitor() {


    RUNNING=true
    trap ctrl_c SIGINT


    echo "Automatic monitoring started (every 5 seconds)"
    echo "Press CTRL+C to stop"
    echo ""
    echo "Start Check: $(date)"


    while $RUNNING
    do
        monitor_system
        sleep 5 & wait $!
        echo "Check Update: $(date)"
    done


    echo "Monitoring stopped safely."
}


# -------- Add User --------
add_user() {


    check_admin


    read -p "Enter new username: " username


    if id "$username" &>/dev/null; then
        echo "User already exists."
        log_action "Attempted duplicate user creation: $username"
        return
    fi


    useradd "$username"


    if [ $? -eq 0 ]; then
        echo "User created successfully."
        log_action "User $username created by $USER"
    else
        echo "Error creating user."
        log_action "User creation failed"
    fi
}


# -------- Delete User --------
delete_user() {


    check_admin


    read -p "Enter username to delete: " username


    if ! id "$username" &>/dev/null; then
        echo "User does not exist."
        log_action "Attempted deletion of non-existing user"
        return
    fi


    userdel "$username"


    if [ $? -eq 0 ]; then
        echo "User deleted successfully."
        log_action "User $username deleted by $USER"
    else
        echo "Error deleting user."
        log_action "User deletion failed"
    fi
}


# -------- List Users --------
list_users() {
    echo "System Users:"
    cut -d: -f1 /etc/passwd
    log_action "User list viewed"
}


# -------- Security Logs --------
check_security_logs() {


    LOG="/var/log/auth.log"


    if [ ! -f "$LOG" ]; then
        echo "Authentication log not found."
        log_action "Log file missing"
        return
    fi


    FAILED=$(grep "Failed password" "$LOG" | wc -l)


    echo "Failed Login Attempts: $FAILED"


    if [ "$FAILED" -gt "$FAILED_LOGIN_LIMIT" ]; then
        echo "SECURITY ALERT: Multiple failed login attempts detected!"
        log_action "Security alert: excessive failed logins"
    fi


    log_action "Security log check performed"
}


# -------- INIT --------
init_environment


# -------- Main Menu --------
while true
do
    echo ""
    echo "================================="
    echo " Legal Firm IT Administration Tool"
    echo "================================="
    echo "1. Perform Data Backup"
    echo "2. Monitor System Performance"
    echo "3. Start Automatic Monitoring"
    echo "4. Add User"
    echo "5. Delete User"
    echo "6. List Users"
    echo "7. Check Security Logs"
    echo "8. Exit"
    echo "================================="


    read -p "Select an option: " choice


    case $choice in
        1) perform_backup ;;
        2) monitor_system ;;
        3) auto_monitor ;;
        4) add_user ;;
        5) delete_user ;;
        6) list_users ;;
        7) check_security_logs ;;
        8) echo "Exiting administration console."; exit 0 ;;
        *) echo "Invalid option selected."; log_action "Invalid menu input" ;;
    esac
done
