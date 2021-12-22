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
	ARGS=$(getopt -o p:o: --long passwd:,os: -n 'pyen_install.sh' -- "$@")
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

is_done(){
  if [ $? -ne 0 ]; then
    fmt_error "安装出现异常，将退出Pyenv安装"
    exit 2
  fi
}

check(){
	# 这里写判断条件,如果已经安装了则返回1 否则返回0
	if not command_exists zsh; then
	  fmt_error "zsh未安装"
	  exit 2
  fi
	if  command_exists pyenv ; then
		fmt_error "pyenv已安装，将退出Pyenv安装"
		exit 2	
	else
		return 0
	fi
}
# TODO: 需要添加安装判断
install(){
	git clone https://gitee.com/mirrors/pyenv.git   ~/.pyenv
	is_done
	echo '# Pyenv' >> ~/.zshrc
	echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
	echo 'export PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
	echo 'if which pyenv > /dev/null; then' >> ~/.zshrc
	echo '  eval "$(pyenv init -)";' >> ~/.zshrc
  echo 'fi' >> ~/.zshrc
  git clone https://gitee.com/crownor/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
  is_done
  echo 'if which pyenv-virtualenv-init > /dev/null; then' >> ~/.zshrc
	echo '  eval "$(pyenv virtualenv-init -)";' >> ~/.zshrc
	echo 'fi' >> ~/.zshrc
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
