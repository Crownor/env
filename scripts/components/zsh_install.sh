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
  # Get the parameters
	ARGS=$(getopt -o p:o: --long passwd:,os: -n 'zsh_install.sh' -- "$@")
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
	if command_exists zsh ; then
		fmt_error "ZSH已存在，将退出ZSH安装"		
		exit 2	
	else
		return 0
	fi
}

is_done(){
  if [ $? -ne 0 ]; then
    fmt_error "安装出现异常，将退出ZSH安装"
    exit 2
  fi
}

install(){
	if [[ $os == "ubuntu" ]]; then
	  echo $passwd | sudo apt-get install -y zsh build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl git
    is_done
	elif [[ $os == "centos" ]]; then
	    echo $passwd | sudo -S yum install -y git make ncurses-devel gcc autoconf man @development zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel xz xz-devel libffi-devel findutils
	    is_done
	    git clone -b zsh-5.8 https://gitee.com/crownor/zsh.git ~/zshtmp
	    is_done
	    .~/zshtmp/Util/preconfig
	    .~/zhstmp/configure
	    echo $passwd | sudo -S make -j 20 install.bin install.modules install.fns
	    is_done
	    echo $passwd | sudo -S ln -s /usr/local/bin/zsh /bin/zsh
	    is_done
	    echo $passwd | sudo -S sh -c "echo \"/bin/zsh\" >> /etc/shells"
	    is_done
	fi
	echo $passwd | chsh -s /bin/zsh
}

main(){
	echo ${BLUE}"开始准备安装ZSH"${RESET}	
	setup_color
	get_params $@
	check
	if [[ $? == 0 ]]; then
		# 说明没有安装
		install
	fi
}
main "$@"
