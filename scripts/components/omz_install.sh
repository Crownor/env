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
is_done() {
  if [ $? -ne 0 ]; then
    echo "安装出现异常，将退出ZSH安装"
    exit 2
  fi
}
get_params() {
  ARGS=$(getopt -o p:o: --long passwd:,os: -n 'omz_install.sh' -- "$@")
  eval set -- "${ARGS}"
  while [ -n "$1" ]; do
    case "$1" in
    -p | --pass) passwd="$2" ;;
    -o | --os) os="$2" ;;
    esac
    shift
  done
}

is_done(){
  if [ $? -ne 0 ]; then
    fmt_error "安装出现异常，将退出OMZ安装"
    exit 2
  fi
}

check() {
  # 这里写判断条件,如果已经安装了则返回1 否则返回0
  if [[ -d "~/.oh-my-zsh" ]]; then
    fmt_error "检测到omz路径存在，将退出omz安装"
    exit 2
  else
    return 0
  fi

}

install() {
  sh -c "$(curl https://gitee.com/crownor/env/raw/master/assets/oh-my-zsh-install-mirror.sh)"
  is_done
  git clone https://gitee.com/crownor/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://gitee.com/crownor/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  git clone https://gitee.com/crownor/autojump.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autojump
  cd ~/.oh-my-zsh/custom/plugins/autojump
  ./install.py
  git clone --depth=1 https://gitee.com/crownor/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
  # 修改zshrc、主题、插件等
  curl -fsSL https://gitee.com/crownor/env/zsh/.zshrc >~/.zshrc
  is_done
  curl -fsSL https://gitee.com/crownor/env/zsh/.p10k.zsh >~/.p10k.zsh
  is_done
  #	sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc
  #	sed -i 's/plugins=(git)/plugins=(git extract zsh-autosuggestions zsh-syntax-highlighting zsh_reload autojump)/g' ~/.zshrc
}

main() {
  setup_color
  get_params $@
  check
  if [[ $? == 0 ]]; then
    # 说明没有安装
    install
  fi
}
main "$@"
