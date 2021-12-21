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
	ARGS=$(getopt -o p:o: --long passwd:,os: -n 'init.sh' -- "$@")
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
	if  command_exists nvim ; then
		fmt_error "nvim已安装，将跳过nvim安装"
		exit 2
	else
		return 0
	fi
}
# TODO: 需要添加安装判断
install(){
  # 安装nvim
  if [ "$os" = "centos" ]; then
    sudo yum install -y epel-release
    sudo yum install -y nvim
  elif [ "$os" = "ubuntu" ]; then
    sudo apt-get install -y nvim
  elif [ "$os" = "mac" ]; then
    brew install nvim
  fi
  # 安装spacevim
  curl -sLf https://gitee.com/crownor/env/assets/spacevim-install.sh | bash
  # 配置环境
  curl -sLf https://gitee.com/crownor/env/vim/init.toml  > ~/.SpaceVim.d/init.toml
  curl -sLf https://gitee.com/crownor/env/vim/autoload/myspacevim.vim  > ~/.SpaceVim.d/autoload/myspacevim.vim
  # 安装copilot插件
  git clone https://gitee.com/crownor/copilot.vim.git \
  ~/.SpaceVim.d/plugin/copilot.vim
}

main(){
	setup_color
	get_params $@
	check
	if [[ $? == 0 ]]; then
		# 说明没有安装
		install
	fi
}
main "$@"
