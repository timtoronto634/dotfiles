function cdp() {
  local selected_dir=$(ghq list -p | peco)
  if [ -n "$selected_dir" ]; then
    cd "$selected_dir"
  fi
}
