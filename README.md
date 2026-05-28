# ⚖️ JurisGuard SysAdmin Suite

![Project Status](https://img.shields.io/badge/Status-Complete-success.svg?style=flat-square)
![OS Compatibility](https://img.shields.io/badge/Platform-Linux%20%7C%20Ubuntu-orange.svg?style=flat-square)
![Language](https://img.shields.io/badge/Language-Bash%20Shell-blue.svg?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)

**JurisGuard** is a robust, production-grade Unix systems administration console and network infrastructure design blueprint, specifically engineered to secure and automate the IT operations of a modern **Legal Firm**. 

In high-compliance environments like legal firms, data security, absolute auditability, strict access control, and seamless disaster recovery are critical. JurisGuard satisfies these needs by marrying an advanced star-backbone hybrid network architecture with an automated, modular shell automation script (`legal_firm_admin.sh`).

---

## 🏛️ System Architecture & Network Design

Designed to support the confidential operations of a multi-department legal practice, the infrastructure is built on a private Local Area Network (LAN) using a segmented Class C subnet (`192.168.1.0/24`).

### 1. Hybrid Network Topology (Star-Backbone)
*   **Administrative & Management Star:** The IT Admin PC and Management workstations connect directly via high-speed Gigabit Ethernet to a central network switch for isolated and high-speed telemetry.
*   **Client Backbone:** General workstations operate over a logical bus backbone topology to represent shared client communication.
*   **Security Perimeter:** A hardware firewall stands between the internal switch and the internet gateway router, actively filtering traffic and forwarding security event telemetry to the auditing system.

### 2. Network Segmentation & Address Scheme
| Segment | IP Range / Target IP | Purpose |
| :--- | :--- | :--- |
| **Internet Gateway** | `192.168.1.1/24` | Gateway Router / Edge Firewall |
| **Admin Network** | `192.168.1.10/24` | Central Document/Case Management Server |
| **IT Workstations** | `192.168.1.20/24` | System Administrator Desktop |
| **Management** | `192.168.1.21/24` | Executive Management Desktop |
| **Client Network** | `192.168.1.30` - `192.168.1.50` | Employee Client Workstations |

### 3. Service Ports
- **SSH (Port 22):** Secure remote administration of system resources.
- **HTTP/HTTPS (Port 80/443):** Encrypted communication for web-based legal management services.
- **MySQL Database (Port 3306):** Central repository hosting highly confidential client databases and cases.

---

## 🛠️ Automated Shell Administration Suite

The backend control panel (`legal_firm_admin.sh`) is designed to run in a Linux environment (Ubuntu 22.04 LTS recommended) to automate day-to-day sysadmin responsibilities.

### Key Interactive Features:

1. **Automated Data Backup (`perform_backup`)**
   - Automatically builds directory structures and zips target data directories into highly compressed timestamped gzip archives (`backup_YYYY-MM-DD_HH-MM-SS.tar.gz`).
   - Standardizes directory formats for reliable restore vectors.
2. **Dynamic Resource Monitoring (`monitor_system`)**
   - Fetches and displays real-time CPU, RAM, and Disk space utilization.
   - Triggers terminal-wide **WARNING logs** if limits exceed safety thresholds (CPU > 80%, Disk Space > 85%).
3. **Continuous Polling Loop (`auto_monitor`)**
   - Simulates enterprise polling telemetry by checking system health at periodic intervals (default: 5s).
   - Features robust Unix signal handling using POSIX traps to catch terminal interrupts (`SIGINT`/`Ctrl+C`) and shut down safely.
4. **Provisioning Engine (`add_user` & `delete_user`)**
   - Facilitates administrative user accounts addition and termination.
   - Includes input sanitization to prevent duplicate usernames or crashing on non-existent users.
5. **Security Event Auditing (`check_security_logs`)**
   - Scans system authorization logs (`/var/log/auth.log`) to count authentication failures.
   - Generates immediate **SECURITY ALERTS** if failed attempts exceed a threshold (default: 5), flagging possible brute-force vectors.
6. **Central Audit Log (`log_action`)**
   - Tracks all administrative commands, successes, and errors. Writes logs directly to a secure, write-append system log `/var/log/legal_firm_admin.log`.

---

## 📂 Project Structure

```bash
jurisguard-sysadmin-suite/
├── legal_firm_admin.sh            # Production-ready interactive Bash automation script
├── README.md                      # Comprehensive project documentation
├── COMP2000-Assignment2025(1).pdf # Academic design guidelines and project requirements
└── Comp2000 Computer Systems.pdf  # Comprehensive system setup & network architecture report
```

---

## 🚀 Getting Started

To install, explore, and run the administration utility, execute the following commands in a Unix/Linux environment:

### Prerequisites
- Operating System: **Linux (Ubuntu/Debian)**
- Privileges: **Sudo (Root)** access is required for operations modifying security logs or system users.
- Target directories for backups:
  - Source directory: `/data`
  - Backup target: `/backup`

### 1. Installation
Clone the repository and enter the project directory:
```bash
git clone https://github.com/ahmed-ali-codes/jurisguard-sysadmin-suite.git
cd jurisguard-sysadmin-suite
```

### 2. Grant Executables Permission
Make the administration script executable:
```bash
chmod +x legal_firm_admin.sh
```

### 3. Launching the Console
Execute with administrative (root) privileges to enable user additions and auth log monitoring:
```bash
sudo ./legal_firm_admin.sh
```

---

## 🧪 Comprehensive Testing & Validation
The suite has been thoroughly audited across **20 rigorous test cases** in a virtualized Ubuntu sandbox.

### Sample Test Log Results:
*   **TC1 (Backup Archive Verification):** Verified successful creation of timestamped compressed packages under `/backup` when `/data` contains sensitive records.
*   **TC4 (Duplicate Provisioning Prevention):** Validated that the system flags and rejects existing username insertions, outputting structured error alerts.
*   **TC12 (Resource Boundary Detection):** Simulated high CPU loads to verify prompt threshold triggers and logging of notifications.
*   **TC16 (Permission Guardrails):** Ensured that launching the script without `sudo` privileges gracefully prevents user management or secure log parsing, preserving operational containment.

---

## ✒️ Authors & Contribution
This system was designed and implemented by:
*   **Ahmed Ali** - Systems Automation & Script Development
*   **Mohammed Salem Omar Almashgari** - Systems Architecture & Technical Documentation

*Developed as part of the Computer Systems (COMP2000) curriculum at Curtin University, School of EECMS.*
