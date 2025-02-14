#!/usr/bin/env bash
#
# System Required:  CentOS 7+, Debian9+, Ubuntu16+
# Description:      Script to Xray manage
#
# Copyright (C) 2023 zxcvos
#
# Xray-script: https://github.com/zxcvos/Xray-script
# Xray-core: https://github.com/XTLS/Xray-core
# REALITY: https://github.com/XTLS/REALITY
# Xray-examples: https://github.com/chika0801/Xray-examples
# Docker cloudflare-warp: https://github.com/e7h4n/cloudflare-warp
# Cloudflare Warp: https://github.com/haoel/haoel.github.io#943-docker-%E4%BB%A3%E7%90%86

readonly RED='\033[1;31;31m'
readonly GREEN='\033[1;31;32m'
readonly YELLOW='\033[1;31;33m'
readonly NC='\033[0m'
readonly xray_config_manage='/usr/local/etc/xray-script/xray_config_manage.sh'

declare domain
declare domain_path
declare new_port

function _info() {
  printf "${GREEN}[information] ${NC}"
  printf -- "%s" "$1"
  printf "\n"
}

function _warn() {
  printf "${YELLOW}[warn] ${NC}"
  printf -- "%s" "$1"
  printf "\n"
}

function _error() {
  printf "${RED}[                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ] ${NC}"
  printf -- "%s" "$1"
  printf "\n"
  exit 1
}

function _exists() {
  local cmd="$1"
  if eval type type >/dev/null 2>&1; then
    eval type "$cmd" >/dev/null 2>&1
  elif command >/dev/null 2>&1; then
    command -v "$cmd" >/dev/null 2>&1
  else
    which "$cmd" >/dev/null 2>&1
  fi
  local rt=$?
  return ${rt}
}

function _os() {
  local os=""
  [ -f "/etc/debian_version" ] && source /etc/os-release && os="${ID}" && printf -- "%s" "${os}" && return
  [ -f "/etc/redhat-release" ] && os="centos" && printf -- "%s" "${os}" && return
}

function _os_full() {
  [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
  [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
  [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

function _os_ver() {
  local main_ver="$(echo $(_os_full) | grep -oE "[0-9.]+")"
  printf -- "%s" "${main_ver%%.*}"
}

function _error_detect() {
  local cmd="$1"
  _info "${cmd}"
  eval ${cmd}
  if [ $? -ne 0 ]; then
    _error "Execution command (${cmd}) failed, please check it and try again."
  fi
}

function _is_digit() {
  local input=${1}
  if [[ "$input" =~ ^[0-9]+$ ]]; then
    return 0
  else
    return 1
  fi
}

function _version_ge() {
  test "$(echo "$@" | tr ' ' '\n' | sort -rV | head -n 1)" == "$1"
}

function _is_tlsv1_3_h2() {
  local check_url=$(echo $1 | grep -oE '[^/]+(\.[^/]+)+\b' | head -n 1)
  local check_num=$(echo QUIT | stdbuf -oL openssl s_client -connect "${check_url}:443" -tls1_3 -alpn h2 2>&1 | grep -Eoi '(TLSv1.3)|(^ALPN\s+protocol:\s+h2$)|(X25519)' | sort -u | wc -l)
  if [[ ${check_num} -eq 3 ]]; then
    return 0
  else
    return 1
  fi
}

function _install_update() {
  local package_name="$@"
  case "$(_os)" in
  centos)
    if _exists "yum"; then
      yum update -y
      _error_detect "yum install -y epel-release yum-utils"
      yum update -y
      _error_detect "yum install -y ${package_name}"
    elif _exists "dnf"; then
      dnf update -y
      _error_detect "dnf install -y dnf-plugins-core"
      dnf update -y
      _error_detect "dnf install -y ${package_name}"
    fi
    ;;
  ubuntu | debian)
    apt update -y
    _error_detect "apt install -y ${package_name}"
    ;;
  esac
}

function _systemctl() {
  local cmd="$1"
  local server_name="$2"
  case "${cmd}" in
  start)
    _info "turning on ${server_name} Serve"
    systemctl -q is-active ${server_name} || systemctl -q start ${server_name}
    systemctl -q is-enabled ${server_name} || systemctl -q enable ${server_name}
    sleep 2
    systemctl -q is-active ${server_name} && _info "Have started ${server_name} 服务" || _error "${server_name} Startup failed"
    ;;
  stop)
    _info "Being suspended ${seServeer_name} Server"
    systemctl -q is-active ${server_name} && systemctl -q stop ${server_name}
    systemctl -q is-enabled ${server_name} && systemctl -q disable ${server_name}
    sleep 2
    systemctl -q is-active ${server_name} || _info "Paused ${server_name} Server"
    ;;
  restart)
    _info "Are restarting ${server_name} Server"
    systemctl -q is-active ${server_name} && systemctl -q restart ${server_name} || systemctl -q start ${server_name}
    systemctl -q is-enabled ${server_name} || systemctl -q enable ${server_name}
    sleep 2
    systemctl -q is-active ${server_name} && _info "Restart ${server_name} Server" || _error "${server_name} Startup failed"
    ;;
  reload)
    _info "Re -load ${server_name} Server"
    systemctl -q is-active ${server_name} && systemctl -q reload ${server_name} || systemctl -q start ${server_name}
    systemctl -q is-enabled ${server_name} || systemctl -q enable ${server_name}
    sleep 2
    systemctl -q is-active ${server_name} && _info "Re -load ${server_name} Server"
    ;;
  dr)
    _info "Re -load systemd Configuration file"
    systemctl daemon-reload
    ;;
  esac
}

function _print_list() {
  local p_list=($@)
  for ((i = 1; i <= ${#p_list[@]}; i++)); do
    hint="${p_list[$i - 1]}"
    echo -e "${GREEN}${i}${NC}) ${hint}"
  done
}

function select_data() {
  local data_list=($(awk -v FS=',' '{for (i=1; i<=NF; i++) arr[i]=$i} END{for (i in arr) print arr[i]}' <<<"${1}"))
  local index_list=($(awk -v FS=',' '{for (i=1; i<=NF; i++) arr[i]=$i} END{for (i in arr) print arr[i]}' <<<"${2}"))
  local result_list=()
  if [ ${#index_list[@]} -ne 0 ]; then
    for i in "${index_list[@]}"; do
      if _is_digit "${i}" && [ ${i} -ge 1 ] && [ ${i} -le ${#data_list[@]} ]; then
        i=$((i - 1))
        result_list+=("${data_list[${i}]}")
      fi
    done
  else
    result_list=("${data_list[@]}")
  fi
  if [ ${#result_list[@]} -eq 0 ]; then
    result_list=("${data_list[@]}")
  fi
  echo "${result_list[@]}"
}

function select_dest() {
  local dest_list=($(jq '.xray.serverNames | keys_unsorted' /usr/local/etc/xray-script/config.json | grep -Eoi '".*"' | sed -En 's|"(.*)"|\1|p'))
  local cur_dest=$(jq -r '.xray.dest' /usr/local/etc/xray-script/config.json)
  local pick_dest=""
  local all_sns=""
  local sns=""
  local prompt="Please select you dest, Currently used default \"${cur_dest}\", Self -filled election 0: "
  until [[ ${is_dest} =~ ^[Yy]$ ]]; do
    echo -e "---------------- dest List -----------------"
    _print_list "${dest_list[@]}"
    read -p "${prompt}" pick
    if [[ "${pick}" == "" && "${cur_dest}" != "" ]]; then
      pick_dest=${cur_dest}
      break
    fi
    if ! _is_digit "${pick}" || [[ "${pick}" -lt 0 || "${pick}" -gt ${#dest_list[@]} ]]; then
      prompt="input error, please enter 0-${#dest_list[@]} Numbers between: "
      continue
    fi
    if [[ "${pick}" == "0" ]]; then
      _warn "If there are already domain names in the input list, the Servernames will be modified"
      _warn "When using the domain name, make sure the domain name is connected in China"
      read_domain
      _info "Checking \"${domain}\" Whether to support TLSV1.3 and H2"
      if ! _is_tlsv1_3_h2 "${domain}"; then
        _warn "\"${domain}\" Do not support TLSV1.3 or H2, or Client Hello is not X25519"
        continue
      fi
      _info "\"${domain}\" support TLSv1.3 and h2"
      _info "retrieving Allowed domains"
      pick_dest=${domain}
      all_sns=$(xray tls ping ${pick_dest} | sed -n '/with SNI/,$p' | sed -En 's/\[(.*)\]/\1/p' | sed -En 's/Allowed domains:\s*//p' | jq -R -c 'split(" ")' | jq --arg sni "${pick_dest}" '. += [$sni]')
      sns=$(echo ${all_sns} | jq 'map(select(test("^[^*]+$"; "g")))' | jq -c 'map(select(test("^((?!cloudflare|akamaized|edgekey|edgesuite|cloudfront|azureedge|msecnd|edgecastcdn|fastly|googleusercontent|kxcdn|maxcdn|stackpathdns|stackpathcdn).)*$"; "ig")))')
      _info "Before filtering SNI"
      _print_list $(echo ${all_sns} | jq -r '.[]')
      _info "After filtering the matching SNI"
      _print_list $(echo ${sns} | jq -r '.[]')
      read -p "Please choose what you want to use serverName , Divide in English commas, Default: " pick_num
      sns=$(select_data "$(awk 'BEGIN{ORS=","} {print}' <<<"$(echo ${sns} | jq -r -c '.[]')")" "${pick_num}" | jq -R -c 'split(" ")')
      _info "If more serverNames please at /usr/local/etc/xray-script/config.json Self -editing"
    else
      pick_dest="${dest_list[${pick} - 1]}"
    fi
    read -r -p "use or notdest: \"${pick_dest}\" [y/n] " is_dest
    prompt="Please select your Dest, the current default use \"${cur_dest}\", Self -filled election 0: "
    echo -e "-------------------------------------------"
  done
  _info "Modify configuration"
  [ "${domain_path}" != "" ] && pick_dest="${pick_dest}${domain_path}"
  if echo ${pick_dest} | grep -q '/$'; then
    pick_dest=$(echo ${pick_dest} | sed -En 's|/+$||p')
  fi
  [ "${sns}" != "" ] && jq --argjson sn "{\"${pick_dest}\": ${sns}}" '.xray.serverNames += $sn' /usr/local/etc/xray-script/config.json >/usr/local/etc/xray-script/new.json && mv -f /usr/local/etc/xray-script/new.json /usr/local/etc/xray-script/config.json
  jq --arg dest "${pick_dest}" '.xray.dest = $dest' /usr/local/etc/xray-script/config.json >/usr/local/etc/xray-script/new.json && mv -f /usr/local/etc/xray-script/new.json /usr/local/etc/xray-script/config.json
}

function read_domain() {
  until [[ ${is_domain} =~ ^[Yy]$ ]]; do
    read -p "Please enter the domain name:" domain
    check_domain=$(echo ${domain} | grep -oE '[^/]+(\.[^/]+)+\b' | head -n 1)
    read -r -p "Please confirm the domain name: \"${check_domain}\" [y/n] " is_domain
  done
  domain_path=$(echo "${domain}" | sed -En "s|.*${check_domain}(/.*)?|\1|p")
  domain=${check_domain}
}

function read_port() {
  local prompt="${1}"
  local cur_port="${2}"
  until [[ ${is_port} =~ ^[Yy]$ ]]; do
    echo "${prompt}"
    read -p "Please enter the custom port(1-65535), Do not modify the default: " new_port
    if [[ "${new_port}" == "" || ${new_port} -eq ${cur_port} ]]; then
      new_port=${cur_port}
      _info "Do not modify, continue to use the original port: ${cur_port}"
      break
    fi
    if ! _is_digit "${new_port}" || [[ ${new_port} -lt 1 || ${new_port} -gt 65535 ]]; then
      prompt="input error, The port range is 1-65535 Numbers between"
      continue
    fi
    read -r -p "Please confirm the port: \"${new_port}\" [y/n] " is_port
    prompt="${1}"
  done
}

function read_uuid() {
  _info 'If you are not a standard format, you will use XRAY UUID -i "custom string" to be used for UUIDV5 mapping if it is not a standard format.'
  read -p "Please enter the custom UUID, the default is automatically generated: " in_uuid
}

function check_os() {
  [ -z "$(_os)" ] && _error "Not supported OS"
  case "$(_os)" in
  ubuntu)
    [ -n "$(_os_ver)" -a "$(_os_ver)" -lt 16 ] && _error "Not supported OS, please change to Ubuntu 16+ and try again."
    ;;
  debian)
    [ -n "$(_os_ver)" -a "$(_os_ver)" -lt 9 ] && _error "Not supported OS, please change to Debian 9+ and try again."
    ;;
  centos)
    [ -n "$(_os_ver)" -a "$(_os_ver)" -lt 7 ] && _error "Not supported OS, please change to CentOS 7+ and try again."
    ;;
  *)
    _error "Not supported OS"
    ;;
  esac
}

function install_dependencies() {
  _info "Download related dependencies"
  _install_update "ca-certificates openssl lsb-release curl wget jq tzdata"
  case "$(_os)" in
  centos)
    _install_update "crontabs util-linux iproute procps-ng"
    ;;
  debian | ubuntu)
    _install_update "cron bsdmainutils iproute2 procps"
    ;;
  esac
}

function install_update_xray() {
  _info "Installation or update Xray"
  _error_detect 'bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root --beta'
  jq --arg ver "$(xray version | head -n 1 | cut -d \( -f 1 | grep -Eoi '[0-9.]*')" '.xray.version = $ver' /usr/local/etc/xray-script/config.json >/usr/local/etc/xray-script/new.json && mv -f /usr/local/etc/xray-script/new.json /usr/local/etc/xray-script/config.json
  wget -O /usr/local/etc/xray-script/update-dat.sh https://raw.githubusercontent.com/zxcvos/Xray-script/main/tool/update-dat.sh
  chmod a+x /usr/local/etc/xray-script/update-dat.sh
  crontab -l | {
    cat
    echo "30 22 * * * /usr/local/etc/xray-script/update-dat.sh >/dev/null 2>&1"
  } | uniq | crontab -
  /usr/local/etc/xray-script/update-dat.sh
}

function purge_xray() {
  _info "Uninstalled Xray"
  crontab -l | grep -v "/usr/local/etc/xray-script/update-dat.sh >/dev/null 2>&1" | crontab -
  _systemctl "stop" "xray"
  bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove --purge
  rm -rf /etc/systemd/system/xray.service
  rm -rf /etc/systemd/system/xray@.service
  rm -rf /usr/local/bin/xray
  rm -rf /usr/local/etc/xray
  rm -rf /usr/local/share/xray
  rm -rf /var/log/xray
}

function service_xray() {
  _info "正在配置 xray.service"
  wget -O ${HOME}/xray.service https://raw.githubusercontent.com/zxcvos/Xray-script/main/service/xray.service
  mv -f ${HOME}/xray.service /etc/systemd/system/xray.service
  _systemctl dr
}

function config_xray() {
  _info "Configuration xray config.json"
  "${xray_config_manage}" --path ${HOME}/config.json --download
  local xray_x25519=$(xray x25519)
  local xs_private_key=$(echo ${xray_x25519} | awk '{print $3}')
  local xs_public_key=$(echo ${xray_x25519} | awk '{print $6}')
  # Xray-script config.json
  jq --arg privateKey "${xs_private_key}" '.xray.privateKey = $privateKey' /usr/local/etc/xray-script/config.json >/usr/local/etc/xray-script/new.json && mv -f /usr/local/etc/xray-script/new.json /usr/local/etc/xray-script/config.json
  jq --arg publicKey "${xs_public_key}" '.xray.publicKey = $publicKey' /usr/local/etc/xray-script/config.json >/usr/local/etc/xray-script/new.json && mv -f /usr/local/etc/xray-script/new.json /usr/local/etc/xray-script/config.json
  # Xray-core config.json
  "${xray_config_manage}" --path ${HOME}/config.json -p ${new_port}
  "${xray_config_manage}" --path ${HOME}/config.json -u ${in_uuid}
  "${xray_config_manage}" --path ${HOME}/config.json -d "$(jq -r '.xray.dest' /usr/local/etc/xray-script/config.json | grep -Eoi '([a-zA-Z0-9](\-?[a-zA-Z0-9])*\.)+[a-zA-Z]{2,}')"
  "${xray_config_manage}" --path ${HOME}/config.json -sn "$(jq -c -r '.xray | .serverNames[.dest] | .[]' /usr/local/etc/xray-script/config.json | tr '\n' ',')"
  "${xray_config_manage}" --path ${HOME}/config.json -x "${xs_private_key}"
  "${xray_config_manage}" --path ${HOME}/config.json -rsid
  mv -f ${HOME}/config.json /usr/local/etc/xray/config.json
  _systemctl "restart" "xray"
}

function show_config() {
  local IPv4=$(wget -qO- -t1 -T2 ipv4.icanhazip.com)
  local xs_inbound=$(jq '.inbounds[] | select(.tag == "xray-script-xtls-reality")' /usr/local/etc/xray/config.json)
  local xs_port=$(echo ${xs_inbound} | jq '.port')
  local xs_protocol=$(echo ${xs_inbound} | jq '.protocol')
  local xs_ids=$(echo ${xs_inbound} | jq '.settings.clients[] | .id' | tr '\n' ',')
  local xs_public_key=$(jq '.xray.publicKey' /usr/local/etc/xray-script/config.json)
  local xs_serverNames=$(echo ${xs_inbound} | jq '.streamSettings.realitySettings.serverNames[]' | tr '\n' ',')
  local xs_shortIds=$(echo ${xs_inbound} | jq '.streamSettings.realitySettings.shortIds[]' | tr '\n' ',')
  local xs_spiderX=$(jq '.xray.dest' /usr/local/etc/xray-script/config.json)
  [ "${xs_spiderX}" == "${xs_spiderX##*/}" ] && xs_spiderX='"/"' || xs_spiderX="\"/${xs_spiderX#*/}"
  echo -e "-------------- client config --------------"
  echo -e "address     : \"${IPv4}\""
  echo -e "port        : ${xs_port}"
  echo -e "protocol    : ${xs_protocol}"
  echo -e "id          : ${xs_ids%,}"
  echo -e "flow        : \"xtls-rprx-vision\""
  echo -e "network     : \"tcp\""
  echo -e "TLS         : \"reality\""
  echo -e "SNI         : ${xs_serverNames%,}"
  echo -e "Fingerprint : \"chrome\""
  echo -e "PublicKey   : ${xs_public_key}"
  echo -e "ShortId     : ${xs_shortIds%,}"
  echo -e "SpiderX     : ${xs_spiderX}"
  echo -e "------------------------------------------"
  read -p "Whether to generate a sharing link[y/n]: " is_show_share_link
  echo
  if [[ ${is_show_share_link} =~ ^[Yy]$ ]]; then
    show_share_link
  else
    echo -e "------------------------------------------"
    echo -e "${RED}This script is for communication and learning only, please do not use this script line illegal。${NC}"
    echo -e "${RED}The illegal place outside the Internet, if you do illegal things, will accept legal sanctions。${NC}"
    echo -e "------------------------------------------"
  fi
}

function show_share_link() {
  local sl=""
  # share lnk contents
  local sl_host=$(wget -qO- -t1 -T2 ipv4.icanhazip.com)
  local sl_inbound=$(jq '.inbounds[] | select(.tag == "xray-script-xtls-reality")' /usr/local/etc/xray/config.json)
  local sl_port=$(echo ${sl_inbound} | jq -r '.port')
  local sl_protocol=$(echo ${sl_inbound} | jq -r '.protocol')
  local sl_ids=$(echo ${sl_inbound} | jq -r '.settings.clients[] | .id')
  local sl_public_key=$(jq -r '.xray.publicKey' /usr/local/etc/xray-script/config.json)
  local sl_serverNames=$(echo ${sl_inbound} | jq -r '.streamSettings.realitySettings.serverNames[]')
  local sl_shortIds=$(echo ${sl_inbound} | jq '.streamSettings.realitySettings.shortIds[]')
  # share link fields
  local sl_uuid=""
  local sl_security='security=reality'
  local sl_flow='flow=xtls-rprx-vision'
  local sl_fingerprint='fp=chrome'
  local sl_publicKey="pbk=${sl_public_key}"
  local sl_sni=""
  local sl_shortId=""
  local sl_spiderX='spx=%2F'
  local sl_descriptive_text='VLESS-XTLS-uTLS-REALITY'
  # select show
  _print_list "${sl_ids[@]}"
  read -p "Please choose to, Divide in English commas, a sharing link UUID , Divide in English commas, Default: " pick_num
  sl_id=($(select_data "$(awk 'BEGIN{ORS=","} {print}' <<<"${sl_ids[@]}")" "${pick_num}"))
  _print_list "${sl_serverNames[@]}"
  read -p "Please choose to generate a sharing link serverName , Divide in English commas, Default: " pick_num
  sl_serverNames=($(select_data "$(awk 'BEGIN{ORS=","} {print}' <<<"${sl_serverNames[@]}")" "${pick_num}"))
  _print_list "${sl_shortIds[@]}"
  read -p "Please choose to generate a sharing link shortId , Divide in English commas, Default: " pick_num
  sl_shortIds=($(select_data "$(awk 'BEGIN{ORS=","} {print}' <<<"${sl_shortIds[@]}")" "${pick_num}"))
  echo -e "--------------- share link ---------------"
  for sl_id in "${sl_ids[@]}"; do
    sl_uuid="${sl_id}"
    for sl_serverName in "${sl_serverNames[@]}"; do
      sl_sni="sni=${sl_serverName}"
      echo -e "---------- serverName ${sl_sni} ----------"
      for sl_shortId in "${sl_shortIds[@]}"; do
        [ "${sl_shortId//\"/}" != "" ] && sl_shortId="sid=${sl_shortId//\"/}" || sl_shortId=""
        sl="${sl_protocol}://${sl_uuid}@${sl_host}:${sl_port}?${sl_security}&${sl_flow}&${sl_fingerprint}&${sl_publicKey}&${sl_sni}&${sl_spiderX}&${sl_shortId}"
        echo "${sl%&}#${sl_descriptive_text}"
      done
      echo -e "------------------------------------------------"
    done
  done
  echo -e "------------------------------------------"
  echo -e "${RED}This script is for communication and use only. Do not use this script line illegal.${NC}"
  echo -e "${RED}The illegal land and illegal things will accept legal sanctions.${NC}"
  echo -e "------------------------------------------"
}

function menu() {
  check_os
  clear
  echo -e "--------------- Xray-script ---------------"
  echo -e " Version      : ${GREEN}v2023-03-15${NC}(${RED}beta${NC})"
  echo -e " Description  : Xray Management script"
  echo -e "----------------- Load management ----------------"
  echo -e "${GREEN}1.${NC} Install"
  echo -e "${GREEN}2.${NC} renew"
  echo -e "${GREEN}3.${NC} Uninstalled"
  echo -e "----------------- Operation management ----------------"
  echo -e "${GREEN}4.${NC} start up"
  echo -e "${GREEN}5.${NC} stopped"
  echo -e "${GREEN}6.${NC} Heavy."
  echo -e "----------------- Configuration management ----------------"
  echo -e "${GREEN}101.${NC} View configuration"
  echo -e "${GREEN}102.${NC} Information statistics"
  echo -e "${GREEN}103.${NC} Modify ID"
  echo -e "${GREEN}104.${NC} Modify Dest"
  echo -e "${GREEN}105.${NC} Modify X25519 Key"
  echo -e "${GREEN}106.${NC} Modify shortids"
  echo -e "${GREEN}107.${NC} Modify the XRAY monitor port"
  echo -e "${GREEN}108.${NC} refresh the existing shortids"
  echo -e "${GREEN}109.${NC} Additional customized SHORTIDS"
  echo -e "${GREEN}110.${NC} Use warp to divert and open Openai"
  echo -e "----------------- other options ----------------"
  echo -e "${GREEN}201.${NC} Update to the latest stable version kernel"
  echo -e "${GREEN}202.${NC} Uninstall the excess kernel"
  echo -e "${GREEN}203.${NC} Modify the SSH port"
  echo -e "${GREEN}204.${NC} Network Connection Optimization"
  echo -e "-------------------------------------------"
  echo -e "${RED}0.${NC} quit"
  read -rp "Choose: " idx
  ! _is_digit "${idx}" && _error "Please enter the correct option value"
  if [[ ! -d /usr/local/etc/xray-script && (${idx} -ne 0 && ${idx} -ne 1 && ${idx} -lt 201) ]]; then
    _error "Unused Xray-script Installation"
  fi
  if [ -d /usr/local/etc/xray-script ] && ([ ${idx} -gt 102 ] || [ ${idx} -lt 111 ]); then
    wget -qO ${xray_config_manage} https://raw.githubusercontent.com/zxcvos/Xray-script/main/tool/xray_config_manage.sh
    chmod a+x ${xray_config_manage}
  fi
  case "${idx}" in
  1)
    if [ ! -d /usr/local/etc/xray-script ]; then
      mkdir -p /usr/local/etc/xray-script
      wget -O /usr/local/etc/xray-script/config.json https://raw.githubusercontent.com/zxcvos/Xray-script/main/config/config.json
      wget -O ${xray_config_manage} https://raw.githubusercontent.com/zxcvos/Xray-script/main/tool/xray_config_manage.sh
      chmod a+x ${xray_config_manage}
      install_dependencies
      install_update_xray
      local xs_port=$(jq '.xray.port' /usr/local/etc/xray-script/config.json)
      read_port "xray config Configuration default: ${xs_port}" "${xs_port}"
      read_uuid
      select_dest
      config_xray
      show_config
    fi
    ;;
  2)
    _info "Judgment Xray Whether to use a new version"
    local current_xray_version="$(jq -r '.xray.version' /usr/local/etc/xray-script/config.json)"
    local latest_xray_version="$(wget -qO- --no-check-certificate https://api.github.com/repos/XTLS/Xray-core/releases | jq -r '.[0].tag_name ' | cut -d v -f 2)"
    if [ "${latest_xray_version}" != "${current_xray_version}" ] && _version_ge "${latest_xray_version}" "${current_xray_version}"; then
      _info "The new version is available for detecting"
      install_update_xray
    else
      _info "It is currently the latest version: ${current_xray_version}"
    fi
    ;;
  3)
    purge_xray
    [ -f /usr/local/etc/xray-script/sysctl.conf.bak ] && mv -f /usr/local/etc/xray-script/sysctl.conf.bak /etc/sysctl.conf && _info "已还原网络连接设置"
    rm -rf /usr/local/etc/xray-script
    if docker ps | grep -q cloudflare-warp; then
      _info 'Stop cloudflare-warp'
      docker container stop cloudflare-warp
      docker container rm cloudflare-warp
    fi
    if docker images | grep -q e7h4n/cloudflare-warp; then
      _info 'Uninstalled cloudflare-warp'
      docker image rm e7h4n/cloudflare-warp
    fi
    rm -rf ${HOME}/.warp
    _info 'Docker Please uninstall it yourself'
    _info "Already completed uninstalled"
    ;;
  4)
    _systemctl "start" "xray"
    ;;
  5)
    _systemctl "stop" "xray"
    ;;
  6)
    _systemctl "restart" "xray"
    ;;
  101)
    show_config
    ;;
  102)
    [ -f /usr/local/etc/xray-script/traffic.sh ] || wget -O /usr/local/etc/xray-script/traffic.sh https://raw.githubusercontent.com/zxcvos/Xray-script/main/tool/traffic.sh
    bash /usr/local/etc/xray-script/traffic.sh
    ;;
  103)
    read_uuid
    _info "Modify the user id"
    "${xray_config_manage}" -u "${in_uuid}"
    _info "Successfully modified users id"
    _systemctl "restart" "xray"
    show_config
    ;;
  104)
    _info "under revision dest and serverNames"
    select_dest
    "${xray_config_manage}" -d "$(jq -r '.xray.dest' /usr/local/etc/xray-script/config.json | grep -Eoi '([a-zA-Z0-9](\-?[a-zA-Z0-9])*\.)+[a-zA-Z]{2,}')"
    "${xray_config_manage}" -sn "$(jq -c -r '.xray | .serverNames[.dest] | .[]' /usr/local/etc/xray-script/config.json | tr '\n' ',')"
    _info "Modified successfully dest and serverNames"
    _systemctl "restart" "xray"
    show_config
    ;;
  105)
    _info "正在修改 x25519 key"
    local xray_x25519=$(xray x25519)
    local xs_private_key=$(echo ${xray_x25519} | awk '{print $3}')
    local xs_public_key=$(echo ${xray_x25519} | awk '{print $6}')
    # Xray-script config.json
    jq --arg privateKey "${xs_private_key}" '.xray.privateKey = $privateKey' /usr/local/etc/xray-script/config.json >/usr/local/etc/xray-script/new.json && mv -f /usr/local/etc/xray-script/new.json /usr/local/etc/xray-script/config.json
    jq --arg publicKey "${xs_public_key}" '.xray.publicKey = $publicKey' /usr/local/etc/xray-script/config.json >/usr/local/etc/xray-script/new.json && mv -f /usr/local/etc/xray-script/new.json /usr/local/etc/xray-script/config.json
    # Xray-core config.json
    "${xray_config_manage}" -x "${xs_private_key}"
    _info "Modified successfully x25519 key"
    _systemctl "restart" "xray"
    show_config
    ;;
  106)
    _info "shortId Value definition: Accept a hexadecimal value The length is 2 The multiple of the length of length is 16"
    _info "shortId List default value is[\"\"]，If there is this, the client shortId Can be empty"
    read -p "Please enter custom shortIds Value, multiple values are separated by English comma: " sid_str
    _info "under revision shortIds"
    "${xray_config_manage}" -sid "${sid_str}"
    _info "Modified successfully shortIds"
    _systemctl "restart" "xray"
    show_config
    ;;
  107)
    local xs_port=$(jq '.inbounds[] | select(.tag == "xray-script-xtls-reality") | .port' /usr/local/etc/xray/config.json)
    read_port "current xray The monitoring port is: ${xs_port}" "${xs_port}"
    if [[ "${new_port}" && ${new_port} -ne ${xs_port} ]]; then
      "${xray_config_manage}" -p ${new_port}
      _info "current xray The monitoring port has been modified to: ${new_port}"
      _systemctl "restart" "xray"
      show_config
    fi
    ;;
  108)
    _info "under revision shortIds"
    "${xray_config_manage}" -rsid
    _info "Modified successfully shortIds"
    _systemctl "restart" "xray"
    show_config
    ;;
  109)
    until [ ${#sid_str} -gt 0 ] && [ ${#sid_str} -le 16 ] && [ $((${#sid_str} % 2)) -eq 0 ]; do
      _info "shortId Definition: Accept a hexadecimal value, multiple length of 2, and the upper limit of length is 16"
      read -p "Please enter custom shortIds Value, not empty, multiple values are separated by English comma: " sid_str
    done
    _info "Customized shortIds"
    "${xray_config_manage}" -asid "${sid_str}"
    _info "Successful adding custom shortIds"
    _systemctl "restart" "xray"
    show_config
    ;;
  110)
    if ! _exists "docker"; then
      read -r -p "The script uses docker for warp management, whether to installDocker [y/n] " is_docker
      if [[ ${is_docker} =~ ^[Yy]$ ]]; then
        curl -fsSL https://get.docker.com | sh
      else
        _warn "Cancel the diversion operation"
        exit 0
      fi
    fi
    if docker ps | grep -q cloudflare-warp; then
      _info "WARP Has been opened, please do not repeat the settings"
    else
      _info "Getting and starting Cloudflare-WARP mirror"
      docker run -v $HOME/.warp:/var/lib/cloudflare-warp:rw --restart=always --name=cloudflare-warp e7h4n/cloudflare-warp
      _info "Being configured ROUTING"
      local routing='{"type":"field","domain":["domain:ipinfo.io","domain:ip.sb","geosite:openai"],"outboundTag":"warp"}'
      _info "Configuration outbounds"
      local outbound=$(echo '{"tag":"warp","protocol":"socks","settings":{"servers":[{"address":"172.17.0.2","port":40001}]}}' | jq -c --arg addr "$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cloudflare-warp)" '.settings.servers[].address = $addr')
      jq --argjson routing "${routing}" '.routing.rules += [$routing]' /usr/local/etc/xray/config.json >/usr/local/etc/xray-script/new.json && mv -f /usr/local/etc/xray-script/new.json /usr/local/etc/xray/config.json
      jq --argjson outbound "${outbound}" '.outbounds += [$outbound]' /usr/local/etc/xray/config.json >/usr/local/etc/xray-script/new.json && mv -f /usr/local/etc/xray-script/new.json /usr/local/etc/xray/config.json
      _systemctl "restart" "xray"
      show_config
    fi
    ;;
  201)
    bash <(wget -qO- https://raw.githubusercontent.com/zxcvos/system-automation-scripts/main/update-kernel.sh)
    ;;
  202)
    bash <(wget -qO- https://raw.githubusercontent.com/zxcvos/system-automation-scripts/main/remove-kernel.sh)
    ;;
  203)
    local ssh_port=$(sed -En "s/^[#pP].*ort\s*([0-9]*)$/\1/p" /etc/ssh/sshd_config)
    read_port "The current SSH connection port is: ${ssh_port}" "${ssh_port}"
    if [[ "${new_port}" && ${new_port} -ne ${ssh_port} ]]; then
      sed -i "s/^[#pP].*ort\s*[0-9]*$/Port ${new_port}/" /etc/ssh/sshd_config
      systemctl restart sshd
      _info "The current SSH connection port has been modified:: ${new_port}"
    fi
    ;;
  204)
    read -r -p "Whether to select network connection optimization [y/n] " is_opt
    if [[ ${is_opt} =~ ^[Yy]$ ]]; then
      [ -f /usr/local/etc/xray-script/sysctl.conf.bak ] || cp -af /etc/sysctl.conf /usr/local/etc/xray-script/sysctl.conf.bak
      wget -O /etc/sysctl.conf https://raw.githubusercontent.com/zxcvos/Xray-script/main/config/sysctl.conf
      sysctl -p
    fi
    ;;
  0)
    exit 0
    ;;
  *)
    _error "Please enter the correct option value"
    ;;
  esac
}

[[ $EUID -ne 0 ]] && _error "This script must be run as root"

menu
