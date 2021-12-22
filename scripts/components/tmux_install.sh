setup_color() {
	# Only use colors if connected to a terminal
	if [ -t 1 ]; then
		RED=$(printf '\033[31m')
		GREEN=$(printf '\033[32m')
		YELLOW=$(printf '\033[33m')
		BLUE=$(printf '\033[34m')
		BOLD=$(printf '\033[1m')
		RESET=$(printf '\033[m')
	else
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
		BOLD=""
		RESET=""
	fi
}

fmt_error() {
  echo ${RED}"Error: $@"${RESET} >&2
}
command_exists() {
	command -v "$@" >/dev/null 2>&1
}
get_params(){

  ARGS=$(getopt  -o p:o: --long passwd:,os: -n 'tmux_install.sh' -- "$@")
#	ARGS=$(getopt -o p:o: --long passwd:,os: -n 'init.sh' -- "$@")
	eval set -- "${ARGS}"
	while [ -n "$1" ]
	do
		case "$1" in
			-p|--pass) passwd="$2" ;;
			-o|--os) os="$2" ;;
		esac
		shift
	done
}

check(){
	# 这里写判断条件,如果已经安装了则返回1 否则返回0
	if  command_exists tmux ; then
		fmt_error "Tmux，将跳过安装"
		exit 2
	else
		return 0
	fi
}

install_tmux(){
  if [ "$os" = "centos" ]; then
    # yum上的版本太老，换源装新版
    curl -L http://galaxy4.net/repo/RHEL/7/noarch/galaxy4-release-7-1.noarch.rpm
    echo $passwd | sudo yum install -y galaxy4-release-7-1.noarch.rpm
    echo $passwd | sudo yum install -y tmux
  elif [ "$os" = "ubuntu" ]; then
    # TODO：未完善
    sudo apt-get install -y tmux
  elif [ "$os" = "mac" ]; then
    brew install tmux
  fi
}

prepare_profile(){
  # 配置tmux环境
  curl -L https://gitee.com/crownor/env/raw/master/tmux/.tmux.conf > ~/.tmux.conf
  curl -L https://gitee.com/crownor/env/raw/master/tmux/.tmux.conf.local > ~/.tmux.conf.local
}

main(){
	setup_color
	get_params $@
	check
	if [[ $? == 0 ]]; then
		# 说明没有安装
		install_tmux
	fi

}
main "$@"
