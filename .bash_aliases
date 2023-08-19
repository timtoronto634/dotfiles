alias kc="kubectl"
alias dc="docker-compose"
alias ..="cd .."

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

function cdp() {
	local selected_dir=$(ghq list -p | peco)
	if [ -n "$selected_dir" ]; then
		cd ${selected_dir}
	fi
}

alias dif='docker images --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}"'
alias reload="source ~/.bashrc"

docker_rmi_peco() {
  local selected
  selected=$(docker images | peco | awk '{print $3}')
  if [ -n "$selected" ]; then
    docker rmi "$selected"
  else
    echo "No image selected"
  fi
}

