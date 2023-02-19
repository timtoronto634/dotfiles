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
alias dif="docker images --format "{{.ID}}> {{.Repository}}:{{.Tag}}"
