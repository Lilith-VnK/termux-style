#!/bin/bash
export TERM=xterm-256color
export HISTTIMEFORMAT="%d/%m/%y %T "
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
WHITE="\e[97m"
RESET="\e[0m"
_e() { echo -e "$1"; }
progress_bar() { for ((i=0; i<=100; i+=10)); do _e "${CYAN}\rProgress: ${YELLOW}$i%${RESET}"; sleep 0.1; done; echo; }
dynamic_ps1() {
  local user hostname ip exit_status=$?
  user=$(whoami)
  hostname=$(hostname -s | cut -c 1-8)
  ip=$(
    hostname -I 2>/dev/null | awk '{print $1}' ||
    ip route get 8.8.8.8 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1)}' ||
    curl -s --max-time 3 ifconfig.me 2>/dev/null ||
    echo "N/A"
  )
  local prompt_line1="\n${CYAN}┌─[${YELLOW}${user}${CYAN}@${YELLOW}${hostname}${CYAN}]"
  local prompt_line2="─[${GREEN}${ip:0:15}${CYAN}]"
  local prompt_line3="\n└─▶ ${RESET}"
  if [ $exit_status -ne 0 ]; then
    prompt_line2+="${CYAN}─[${RED}✗${exit_status}${CYAN}]"
  fi
  PS1="${prompt_line1}${prompt_line2}${prompt_line3}"
}
PROMPT_COMMAND=dynamic_ps1
system_header() {
  clear
  if command -v figlet &>/dev/null; then 
    figlet "Termux CLI" | lolcat
  else 
    _e "${CYAN}====== Termux CLI ======${RESET}"
  fi
  OS_NAME=$(uname -o)
  KERNEL=$(uname -sr)
  ARCH=$(uname -m)
  SHELL_NAME=$(basename "$SHELL")
  TERMUX_VERSION=$(apt show termux-tools 2>/dev/null | grep Version | awk '{print $2}' | head -n1)
  UPTIME_INFO=$(uptime -p | sed 's/up //')
  STORAGE_INFO=$(df -h "$HOME" | awk 'NR==2 {print $4 " free of " $2}')
  MEMORY_INFO=$(free -m | awk 'NR==2 {printf "%sMB used / %sMB total", $3, $2}')
  CPU_MODEL=$(lscpu 2>/dev/null | grep 'Model name' | cut -d':' -f2 | xargs)
  IP_ADDR=$(ip route get 1.2.3.4 2>/dev/null | awk '{print $7}' | xargs)
  _e "${BLUE}══════════════ System Information ═════════════${RESET}"
  _e "${GREEN}● OS         : ${YELLOW}$OS_NAME ${MAGENTA}(Android $(getprop ro.build.version.release 2>/dev/null))${RESET}"
  _e "${GREEN}● Kernel     : ${YELLOW}$KERNEL${RESET}"
  _e "${GREEN}● Arch       : ${YELLOW}$ARCH${RESET}"
  _e "${GREEN}● Uptime     : ${YELLOW}$UPTIME_INFO${RESET}"
  _e "${GREEN}● Shell      : ${YELLOW}$SHELL_NAME ${BASH_VERSION%%(*}${RESET}"
  _e "${GREEN}● Termux     : ${YELLOW}${TERMUX_VERSION:-'N/A'}${RESET}"
  _e "${GREEN}● Storage    : ${YELLOW}$STORAGE_INFO${RESET}"
  _e "${GREEN}● Memory     : ${YELLOW}$MEMORY_INFO${RESET}"
  _e "${GREEN}● CPU        : ${YELLOW}${CPU_MODEL:-'N/A'}${RESET}"
  _e "${GREEN}● IP Address : ${YELLOW}${IP_ADDR:-'N/A'}${RESET}"
  _e "${BLUE}════════════════════════════════════════════════${RESET}"
}
termux_api_notification() {
  clear
  _e "${YELLOW}[NOTIFIKASI]${RESET} Mengirim notifikasi percobaan..."
  termux-notification --title "Test Notifikasi" --content "Termux API berjalan lancar!" 2>/dev/null
  _e "${GREEN}Notifikasi terkirim. Tekan ENTER untuk kembali...${RESET}"
  read -r
}
setup_storage_access() {
  clear
  _e "${YELLOW}[STORAGE]${RESET} Mengatur akses storage Termux..."
  termux-setup-storage
  _e "${GREEN}Akses storage telah diatur. Tekan ENTER untuk kembali...${RESET}"
  read -r
}
clipboard_tools() {
  clear
  _e "${YELLOW}[CLIPBOARD] Pilih opsi:${RESET}"
  _e " 1. Salin teks ke clipboard"
  _e " 2. Tampilkan isi clipboard"
  read -rp "${GREEN}Pilih opsi [1-2]: ${RESET}" copt
  case $copt in 
    1) read -rp "${YELLOW}Masukkan teks: ${RESET}" ctxt; termux-clipboard-set "$ctxt" && _e "${GREEN}Teks disalin.${RESET}";; 
    2) _e "${YELLOW}Isi Clipboard:${RESET}"; termux-clipboard-get || _e "${RED}Clipboard kosong.${RESET}";; 
    *) _e "${RED}Opsi tidak valid.${RESET}";; 
  esac
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
termux_get_location() {
  clear
  _e "${YELLOW}[MENGAMBIL LOKASI]${RESET} Meminta lokasi..."
  loc=$(termux-location -p minimal 2>/dev/null)
  if [ -z "$loc" ]; then 
    _e "${RED}Gagal mendapatkan lokasi.${RESET}"
  else 
    _e "${GREEN}Data Lokasi:${RESET}"
    echo "$loc" | jq 2>/dev/null || echo "$loc"
  fi
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
termux_list_contacts() {
  clear
  _e "${YELLOW}[CONTACT]${RESET} Mengambil kontak..."
  termux-contact-list 2>/dev/null | jq 2>/dev/null || _e "${RED}Gagal menampilkan kontak.${RESET}"
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
run_python() {
  clear
  _e "${YELLOW}[PYTHON] Memulai interpreter...${RESET}"
  python || _e "${RED}Python tidak tersedia.${RESET}"
}
run_ruby() {
  clear
  _e "${YELLOW}[RUBY] Memulai interpreter...${RESET}"
  ruby -v || _e "${RED}Ruby tidak tersedia.${RESET}"
}
display_neofetch() {
  clear
  neofetch || _e "${RED}Neofetch tidak tersedia.${RESET}"
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
display_htop() {
  clear
  command -v htop &>/dev/null && htop || (_e "${RED}Htop belum terpasang.${RESET}"; sleep 2)
}
display_disk_usage() {
  clear
  _e "${YELLOW}[Disk Usage]:${RESET}"
  df -h
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
display_memory_usage() {
  clear
  _e "${YELLOW}[Memory Usage]:${RESET}"
  free -m
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
perform_diagnostics() {
  clear
  _e "${YELLOW}[DIAGNOSTICS] Mengumpulkan data sistem...${RESET}"
  progress_bar
  system_header
  _e "${GREEN}Diagnostik selesai. Tekan ENTER...${RESET}"
  read -r
}
configuration_manager() {
  clear
  _e "${YELLOW}[CONFIG] Pilih opsi:${RESET}"
  _e " 1. Reset .bashrc ke backup"
  _e " 2. Tampilkan konfigurasi"
  read -rp "${GREEN}Pilih opsi [1-2]: ${RESET}" conf
  case $conf in 
    1) [ -f "$HOME/.bashrc.bak" ] && cp "$HOME/.bashrc.bak" "$HOME/.bashrc" && _e "${GREEN}Konfigurasi direset. Tekan ENTER...${RESET}" || _e "${RED}Backup tidak ditemukan.${RESET}"; read -r;;
    2) _e "${YELLOW}Isi .bashrc:${RESET}"; cat "$HOME/.bashrc"; _e "${GREEN}Tekan ENTER...${RESET}"; read -r;;
    *) _e "${RED}Opsi tidak valid.${RESET}"; sleep 1;;
  esac
}
dns_lookup() {
  clear
  _e "${YELLOW}[DNS] Masukkan domain:${RESET}"
  read -r domain
  [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && _e "${RED}Gunakan nama domain bukan IP!${RESET}" && return
  [ -z "$domain" ] && _e "${RED}Domain kosong.${RESET}" && return
  dig "$domain" ANY +noall +answer 2>/dev/null || _e "${RED}Gagal lookup.${RESET}"
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
ping_test() {
  clear
  _e "${YELLOW}[PING] Masukkan host:${RESET}"
  read -r host
  [ -z "$host" ] && _e "${RED}Host kosong.${RESET}" && return
  ping -c 4 "$host" 2>/dev/null || _e "${RED}Ping gagal.${RESET}"
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
traceroute_test() {
  clear
  _e "${YELLOW}[TRACEROUTE] Masukkan host:${RESET}"
  read -r host
  [ -z "$host" ] && _e "${RED}Host kosong.${RESET}" && return
  traceroute -m 15 "$host" 2>/dev/null || _e "${RED}Traceroute gagal.${RESET}"
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
internet_speed_test() {
  clear
  _e "${YELLOW}[INTERNET SPEED] Menguji kecepatan download...${RESET}"
  servers=("cachefly.cachefly.net" "speedtest.tele2.net" "speedtest-sgp1.digitalocean.com")
  server=${servers[$RANDOM % ${#servers[@]}]}
  url="http://$server/1GB.bin"
  start=$(date +%s%N)
  wget -q -O /dev/null "$url" &
  pid=$!
  while kill -0 $pid 2>/dev/null; do sleep 1; done
  end=$(date +%s%N)
  diff=$(( (end - start) / 1000000 ))
  speed=$(( 1000000000 / diff ))
  _e "${GREEN}Kecepatan: ${YELLOW}$speed Mbps${RESET}"
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
battery_info() {
  clear
  _e "${YELLOW}[BATTERY] Status baterai...${RESET}"
  termux-battery-status | jq 2>/dev/null || termux-battery-status
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
calendar_view() {
  clear
  _e "${YELLOW}[CALENDAR]${RESET}"
  cal -3
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
file_search() {
  clear
  _e "${YELLOW}[FILE SEARCH] Masukkan pola pencarian:${RESET}"
  read -r pattern
  [ -z "$pattern" ] && _e "${RED}Pola kosong!${RESET}" && return
  find "$HOME" -iname "*$pattern*" 2>/dev/null | head -n 50 || _e "${RED}Tidak ditemukan.${RESET}"
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
custom_calculator() {
  clear
  _e "${YELLOW}[CALCULATOR] Masukkan ekspresi:${RESET}"
  read -r expr
  result=$(echo "scale=2; $expr" | bc -l 2>/dev/null)
  [ -z "$result" ] && _e "${RED}Ekspresi tidak valid.${RESET}" || _e "${GREEN}Hasil: ${YELLOW}$result${RESET}"
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
open_url() {
  clear
  _e "${YELLOW}[OPEN URL] Masukkan URL:${RESET}"
  read -r url
  [ -z "$url" ] && _e "${RED}URL kosong.${RESET}" && return
  termux-open "$url" 2>/dev/null && _e "${GREEN}Berhasil dibuka.${RESET}" || _e "${RED}Gagal membuka URL.${RESET}"
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
system_monitor() {
  clear
  _e "${YELLOW}[SYSTEM MONITOR] Menampilkan vmstat...${RESET}"
  vmstat 1 5 2>/dev/null || _e "${RED}vmstat tidak tersedia.${RESET}"
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
resource_usage() {
  clear
  _e "${YELLOW}[RESOURCE USAGE] Proses sistem:${RESET}"
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 20
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
quick_backup() {
  clear
  _e "${YELLOW}[FILE BACKUP] Masukkan path file:${RESET}"
  read -r fpath
  [ ! -f "$fpath" ] && _e "${RED}File tidak ditemukan.${RESET}" && return
  progress_bar
  cp -v "$fpath" "$fpath.bak" && _e "${GREEN}Backup dibuat: ${YELLOW}$fpath.bak${RESET}"
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
send_sms() {
  clear
  _e "${YELLOW}[SMS] Masukkan nomor tujuan:${RESET}"
  read -r number
  [[ ! $number =~ ^\+?[0-9]+$ ]] && _e "${RED}Format nomor salah!${RESET}" && return
  _e "${YELLOW}Masukkan pesan:${RESET}"
  read -r msg
  termux-sms-send -n "$number" "$msg" && _e "${GREEN}SMS terkirim.${RESET}" || _e "${RED}Gagal mengirim SMS.${RESET}"
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
vibrate_phone() {
  clear
  _e "${YELLOW}[VIBRATE] Masukkan durasi getar (ms):${RESET}"
  read -r dur
  [[ ! $dur =~ ^[0-9]+$ ]] && _e "${RED}Hanya angka yang diperbolehkan!${RESET}" && return
  termux-vibrate -d "$dur" && _e "${GREEN}Getaran dikirim.${RESET}" || _e "${RED}Gagal mengirim getaran.${RESET}"
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
wifi_scan() {
  clear
  _e "${YELLOW}[WIFI SCAN] Memindai jaringan WiFi...${RESET}"
  if ! command -v termux-wifi-scaninfo >/dev/null 2>&1; then
    _e "${RED}Error: Perintah 'termux-wifi-scaninfo' tidak ditemukan. Pastikan Termux dan paket yang diperlukan telah diinstal.${RESET}"
    return 1
  fi
  if ! command -v jq >/dev/null 2>&1; then
    _e "${RED}Error: Perintah 'jq' tidak ditemukan. Instal jq agar output dapat diformat dengan baik.${RESET}"
    return 1
  fi
  local scan_output
  scan_output=$(termux-wifi-scaninfo --no-header 2>/dev/null)
  if [ $? -ne 0 ] || [ -z "$scan_output" ]; then
    _e "${RED}Gagal memindai WiFi. Pastikan WiFi aktif dan ponsel dalam jangkauan jaringan yang tersedia.${RESET}"
    return 1
  fi
  echo "$scan_output" | jq 2>/dev/null
  if [ ${PIPESTATUS[1]} -ne 0 ]; then
    _e "${RED}Terjadi kesalahan saat memformat output dengan jq.${RESET}"
    return 1
  fi
  _e "${GREEN}Tekan ENTER untuk kembali...${RESET}"
  read -r
}
list_packages() {
  clear
  _e "${YELLOW}[PACKAGES] Daftar paket terinstal:${RESET}"
  pkg list-installed | head -n 30
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
process_killer() {
  clear
  _e "${YELLOW}[PROCESS KILLER] Masukkan PID untuk menghentikan:${RESET}"
  read -r pid
  [[ ! $pid =~ ^[0-9]+$ ]] && _e "${RED}PID harus angka!${RESET}" && return
  kill -9 "$pid" 2>/dev/null && _e "${GREEN}Proses $pid dihentikan.${RESET}" || _e "${RED}Gagal menghentikan proses.${RESET}"
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
world_clock() {
  clear
  _e "${YELLOW}[WORLD CLOCK] Masukkan zona waktu (contoh: Europe/London):${RESET}"
  read -r tz
  timedatectl list-timezones 2>/dev/null | grep -i "$tz" || _e "${RED}Zona waktu tidak valid!${RESET}"
  _e "${GREEN}Waktu saat ini:${RESET}"
  TZ="$tz" date +"%Y-%m-%d %H:%M:%S %Z" || date
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
encryption_tool() {
  clear
  _e "${YELLOW}[ENCRYPTION] Pilih jenis hash:${RESET}"
  select algo in md5 sha1 sha256 sha512; do 
    echo -n "Masukkan teks: "
    read txt
    echo -n "$txt" | openssl $algo | awk '{print $2}'
    break
  done
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
port_scanner() {
  clear
  _e "${YELLOW}[PORT SCANNER] Masukkan host:${RESET}"
  read host
  _e "${YELLOW}Masukkan port range (1-1000):${RESET}"
  read ports
  nmap -p "$ports" "$host" 2>/dev/null || _e "${RED}Gagal melakukan scan.${RESET}"
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
network_diagnostics() {
  clear
  _e "${YELLOW}[NETWORK DIAG] Menjalankan test koneksi...${RESET}"
  curl --connect-timeout 5 -I https://google.com 2>/dev/null | head -n 10 || _e "${RED}Tidak ada koneksi internet.${RESET}"
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
ip_info() {
  clear
  _e "${YELLOW}[IP INFO] Menampilkan Public IP...${RESET}"
  ip_pub=$(curl -s ifconfig.me)
  _e "${GREEN}Public IP: ${YELLOW}${ip_pub}${RESET}"
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
weather_check() {
  clear
  _e "${YELLOW}[WEATHER] Informasi cuaca...${RESET}"
  curl -s wttr.in | lolcat
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
logcat_view() {
  clear
  _e "${YELLOW}[LOGCAT] Menampilkan logcat...${RESET}"
  logcat || _e "${RED}Logcat tidak tersedia.${RESET}"
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
fun_message() {
  clear
  if command -v cowsay &>/dev/null; then 
    cowsay "Hello from Termux CLI"
  else 
    _e "${GREEN}Hello from Termux CLI${RESET}"
  fi
  _e "${GREEN}Tekan ENTER...${RESET}"
  read -r
}
storage_management() {
  while true; do
    clear
    _e "┌────────────────────────────────────────────────────────┐"
    _e "│              Storage Management Menu                 │"
    _e "├────────────────────────────────────────────────────────┤"
    _e " 1. Storage Statistics"
    _e " 2. Organize Files by Type"
    _e " 3. Clean Junk Files"
    _e " 4. Backup Storage"
    _e " 5. Restore Backup"
    _e " 6. Find Large Files"
    _e " 7. Monitor Storage Changes"
    _e " 8. Kembali ke Menu Utama"
    read -rp "Pilih opsi [1-8]: " sto
    case $sto in
      1) clear; _e "${YELLOW}[STORAGE STATS]${RESET}"; df -h; _e "\n${CYAN}File Types Count:${RESET}"; find "$HOME" -type f | grep -Eo "\.[^./]+$" | sort | uniq -c | sort -nr | head -n10; _e "${GREEN}Tekan ENTER...${RESET}"; read -r ;;
      2) clear; mkdir -p "$HOME/storage/{Images,Documents,Music,Videos,Downloads,Others}"; find "$HOME" -maxdepth 1 -type f -iname "*.jpg" -o -iname "*.png" -exec mv -t "$HOME/storage/Images" {} +; find "$HOME" -maxdepth 1 -type f -iname "*.pdf" -o -iname "*.doc*" -exec mv -t "$HOME/storage/Documents" {} +; find "$HOME" -maxdepth 1 -type f -iname "*.mp3" -o -iname "*.wav" -exec mv -t "$HOME/storage/Music" {} +; find "$HOME" -maxdepth 1 -type f -iname "*.mp4" -o -iname "*.mkv" -exec mv -t "$HOME/storage/Videos" {} +; find "$HOME" -maxdepth 1 -type f -iname "*.deb" -o -iname "*.apk" -exec mv -t "$HOME/storage/Downloads" {} +; find "$HOME" -maxdepth 1 -type f -exec mv -t "$HOME/storage/Others" {} +; _e "${GREEN}File organized! Tekan ENTER...${RESET}"; read -r ;;
      3) clear; _e "${YELLOW}[CLEAN JUNK FILES]${RESET}"; find "$HOME" -name "*.tmp" -o -name "*.temp" -o -name "*.log" -delete; _e "${GREEN}Pembersihan selesai! Tekan ENTER...${RESET}"; read -r ;;
      4) clear; timestamp=$(date +%Y%m%d-%H%M%S); mkdir -p "$HOME/backups"; tar -czf "$HOME/backups/storage-backup-$timestamp.tar.gz" "$HOME/storage"; _e "${GREEN}Backup dibuat: ${YELLOW}$HOME/backups/storage-backup-$timestamp.tar.gz${RESET}"; _e "${GREEN}Tekan ENTER...${RESET}"; read -r ;;
      5) clear; ls "$HOME/backups"; read -rp "Masukkan nama file backup: " bfile; [ -f "$HOME/backups/$bfile" ] && tar -xzf "$HOME/backups/$bfile" -C /; _e "${GREEN}Tekan ENTER...${RESET}"; read -r ;;
      6) clear; find "$HOME" -type f -size +10M -exec ls -lh {} \; 2>/dev/null | awk '{print $5, $9}' | sort -hr | head -n20; _e "${GREEN}Tekan ENTER...${RESET}"; read -r ;;
      7) clear; _e "${YELLOW}[REALTIME MONITOR]${RESET}"; inotifywait -r -m "$HOME/storage" 2>/dev/null ;;
      8) break ;;
      *) _e "${RED}Opsi tidak valid.${RESET}"; sleep 1 ;;
    esac
  done
}
extended_menu() {
  while true; do
    clear
    _e "┌────────────────────────────────────────────────────────┐"
    _e "│               Extended Advanced Menu                 │"
    _e "├────────────────────────────────────────────────────────┤"
    _e " 1. DNS Lookup"
    _e " 2. Ping Test"
    _e " 3. Traceroute Test"
    _e " 4. Internet Speed Test"
    _e " 5. Battery Status"
    _e " 6. Calendar View"
    _e " 7. File Search"
    _e " 8. Calculator"
    _e " 9. Open URL"
    _e " 10. System Monitor"
    _e " 11. Resource Usage"
    _e " 12. Quick File Backup"
    _e " 13. Send SMS"
    _e " 14. Vibrate Phone"
    _e " 15. WiFi Scan"
    _e " 16. List Packages"
    _e " 17. Process Killer"
    _e " 18. World Clock"
    _e " 19. Encryption Tool"
    _e " 20. Storage Management"
    _e " 21. Port Scanner"
    _e " 22. Network Diagnostics"
    _e " 23. View Logcat"
    _e " 24. Fun Message"
    _e " 25. IP Info"
    _e " 26. Weather Check"
    _e " 27. Kembali ke Menu Utama"
    read -rp "Pilih opsi [1-27]: " ext
    case $ext in
      1) dns_lookup ;; 2) ping_test ;; 3) traceroute_test ;; 4) internet_speed_test ;;
      5) battery_info ;; 6) calendar_view ;; 7) file_search ;; 8) custom_calculator ;;
      9) open_url ;; 10) system_monitor ;; 11) resource_usage ;; 12) quick_backup ;;
      13) send_sms ;; 14) vibrate_phone ;; 15) wifi_scan ;; 16) list_packages ;;
      17) process_killer ;; 18) world_clock ;; 19) encryption_tool ;; 20) storage_management ;;
      21) port_scanner ;; 22) network_diagnostics ;; 23) logcat_view ;; 24) fun_message ;;
      25) ip_info ;; 26) weather_check ;; 27) break ;;
      *) _e "${RED}Opsi tidak valid.${RESET}"; sleep 1 ;;
    esac
  done
}
interactive_menu() {
  while true; do
    clear
    _e "┌─────────────────────────────────────────────────────────┐"
    _e "│                 Termux Interactive Menu               │"
    _e "├─────────────────────────────────────────────────────────┤"
    _e " 1.  System Information"
    _e " 2.  Update System"
    _e " 3.  Edit .bashrc"
    _e " 4.  Setup Storage"
    _e " 5.  Test Notifications"
    _e " 6.  Show Neofetch"
    _e " 7.  Htop Monitor"
    _e " 8.  Disk Usage"
    _e " 9.  Memory Usage"
    _e " 10. Git Status"
    _e " 11. Python REPL"
    _e " 12. Ruby REPL"
    _e " 13. Tools"
    _e " 14. Clear Screen"
    _e " 15. Exit Menu"
    read -rp "Pilih opsi [1-15]: " opt
    case $opt in
      1) system_header; read -r ;; 
      2) pkg update -y && pkg upgrade -y; read -r ;; 
      3) nano "$HOME/.bashrc" ;; 
      4) setup_storage_access ;; 
      5) termux_api_notification ;; 
      6) display_neofetch ;; 
      7) display_htop ;; 
      8) display_disk_usage ;; 
      9) display_memory_usage ;; 
      10) git status || _e "${RED}Not a Git repo.${RESET}"; read -r ;; 
      11) run_python ;; 
      12) run_ruby ;; 
      13) extended_menu ;; 
      14) cls ;; 
      15) break ;; 
      *) _e "${RED}Invalid option.${RESET}"; sleep 1 ;;
    esac
  done
}
alias update='pkg update -y && pkg upgrade -y'
alias igit='pkg install git -y'
alias sysinfo='system_header'
alias menu='interactive_menu'
alias cls='clear'
alias ex='exit'
alias ll='ls -alh'
alias la='ls -A'
alias l='ls -CF'
alias home='cd ~'
alias docs='cd ~/Documents'
alias downloads='cd ~/Downloads'
alias desktop='cd ~/Desktop'
alias work='cd ~/Work'
alias projects='cd ~/Projects'
alias sdcard='cd /sdcard'
alias tree='tree -C'
alias editbash='nano ~/.bashrc'
alias reload='source ~/.bashrc'
alias psg='ps aux | grep'
alias search='grep -R'
alias findfile='find . -name'
alias mkdirp='mkdir -p'
alias untar='tar -xvf'
alias zipit='zip -r'
alias ipinfo='curl ipinfo.io/ip'
alias myip='curl ifconfig.me'
alias pinggoogle='ping -c 4 google.com'
alias ports='netstat -tulanp'
alias hist='history | less'
alias gc='git clone'
alias gs='git status'
alias ga='git add .'
alias gcmsg='git commit -m'
alias gp='git push'
alias open='xdg-open'
alias view='less'
alias meminfo='free -m'
alias cpuinfo='lscpu'
alias diskinfo='df -h'
alias topinfo='top'
alias prompt='PS1="\e[32m\u@\h:\w\e[m\$ "'
alias edit='nano'
alias wget='wget -c'
alias curlget='curl -LO'
alias flushdns='sudo systemd-resolve --flush-caches'
alias updatepip='pip install --upgrade pip'
alias dockerprune='docker system prune -a'
alias logtail='tail -f /var/log/syslog'
alias terminfo='termux-info'
alias battery='termux-battery-status'
alias storage='termux-setup-storage'
alias weather='termux-weather'
alias launch='termux-open'
alias clipget='termux-clipboard-get'
alias clipset='termux-clipboard-set'
alias keys='termux-keys'
alias contact='termux-contact-list'
alias dial='termux-telephony-call'
alias wifi='termux-wifi-connectioninfo'
[ -z "$THEME_LOADED" ] && { system_header; _e "${GREEN}Ketik menu untuk membuka menu${RESET}"; export THEME_LOADED=1; }