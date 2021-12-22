#!/usr/bin/env bash
# 用来标记具体包下载路径的，会在prepare_packages中使用
declare -A packages=()
packages=(
	[zsh]="https://gitee.com/crownor/env/scripts/components/zsh_install.sh"
	[oh-my-zsh]="https://gitee.com/crownor/env/scripts/components/omz_install.sh"
	[pyenv]="https://gitee.com/crownor/env/scripts/components/pyenv_install.sh"
	[item-integrate]="https://gitee.com/crownor/env/scripts/components/item-integrate.sh"
	[tmux]="https://gitee.com/crownor/env/scripts/components/tmux_install.sh"
	[spacevim]="https://gitee.com/crownor/env/scripts/components/SpaceVim_install.sh"
)
# 通过数组来确保安装的顺序不会变
declare -a package_name=()
package_name=("zsh" "oh-my-zsh" "pyenv" "item-integrate" "tmux" "spacevim")

declare -a package_confirmd=()
declare -a success_installed=()

command_exists() {
	command -v "$@" >/dev/null 2>&1
}

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
  # shellcheck disable=SC2145
  echo ${RED}"Error: $@"${RESET} >&2
}

end_notify(){
	echo "已成功安装以下包："
	echo "${success_installed[*]}"
}

exec_success(){
	flag=$?
	if [ $flag == 0 ]; then
		success_installed=(${success_installed[@]} "$@")
	elif [[ $flag != 2 ]]; then
		fmt_error "安装失败，发生失败的包为：$@"
		end_notify
		exit 1
	fi
}

get_params(){
  ARGS=`getopt  -o p:o: --long passwd:,os: -n 'init.sh' -- "$@"`
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


get_options(){
	printf "${YELLOW}确定操作系统[centos/ubuntu]: ${RESET}"
	read os
	confirm "是否需要提供sudo密码"
	if [[ $? == 1 ]]; then
		# 需要提供密码
		echo -n "${YELLOW}sudo密码: ${RESET}"
		stty -echo
		read passwd
		stty echo
		echo ""
	fi
	echo "默认安装以下配置："
	echo "${package_name[@]}"
	confirm "是否需要进行默认安装?"
	if [[ $? == 0 ]]; then
		fully_install=0
	fi
}

confirm(){
	while [[ true ]]; do
		# 获取基本的参数
		printf "${YELLOW}$@[Y/n/q]: ${RESET} "
		read opt 
		case $opt in
			Y*|y*|"") return 1 ;;
			N*|n*) return 0 ;;
			Q*|q*) exit 0 ;;
			*) echo "输入超出范围，请重新输入" ;;
		esac
	done
}


prepare_install_options(){
	# 
	if [[ $fully_install != 1 ]]; then
	 	# 非全体安装
	 	for each_package in ${package_name[*]}; do
	 		confirm "是否安装$each_package?"
	 		if [[ $? == 1 ]]; then
	 			# 不安装
	 			package_confirmd+=($each_package)
	 		fi
	 	done
	else
		package_confirmd=(${package_name[@]})
	fi 
}

start_install(){
	for each in "${package_confirmd[@]}"; do
		if [ $passwd ]; then
			curl ${packages[$each]} -o- -L | bash -s --  -o $os -p $passwd
		else
			curl ${packages[$each]} -o- -L | bash -s --  -o $os
		fi
		
		exec_success $each
	done
}



main(){
	setup_color
	fully_install=1

	# 是传参还是本地执行
	if [[ $# -eq 0 ]]; then
		# 本地执行
		get_options 
	else
		# 传参执行
		get_params $@
	fi

	prepare_install_options
	start_install
	end_notify

}

main "$@"
