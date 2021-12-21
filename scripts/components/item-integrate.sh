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

install(){
	curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
	echo "source ~/.iterm2_shell_integration.zsh" >> ~/.zshrc
}

main(){
	setup_color
	get_params $@
	install
}
main "$@"
