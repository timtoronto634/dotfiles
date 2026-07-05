#!/bin/sh
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "unknown"')

# Context: green normally, yellow >18%, red >20%
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ]; then
  used_int=${used%.*}
  if [ "$used_int" -gt 20 ]; then ctx_color="31"
  elif [ "$used_int" -gt 18 ]; then ctx_color="33"
  else ctx_color="32"; fi
  context_str="ctx:${used}%"
else
  ctx_color="33"
  context_str="ctx:-"
fi

cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$cost" ]; then
  cost_str=$(printf '$%.2f' "$cost")
else
  cost_str="\$-"
fi

# 5h rate limit with reset time (HH:MM local)
usage=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
if [ -n "$usage" ]; then
  usage_str="${usage}%"
  if [ -n "$resets" ]; then
    reset_hm=$(date -r "$resets" +%H:%M 2>/dev/null)
    [ -n "$reset_hm" ] && usage_str="${usage_str}@${reset_hm}"
  fi
else
  usage_str="-"
fi

# Lines added/removed this session
added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
lines_str=$(printf "\033[32m+%s\033[0m\033[31m-%s\033[0m" "$added" "$removed")

# Session duration, compact (47m / 1h23m)
dur_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
if [ -n "$dur_ms" ]; then
  mins=$((${dur_ms%.*} / 60000))
  if [ "$mins" -ge 60 ]; then
    dur_str="$((mins / 60))h$((mins % 60))m"
  else
    dur_str="${mins}m"
  fi
else
  dur_str="0m"
fi

# Effort level, abbreviated
effort=$(echo "$input" | jq -r '.effort.level // empty')
case "$effort" in
  low) effort_str="lo" ;;
  medium) effort_str="med" ;;
  high) effort_str="hi" ;;
  xhigh) effort_str="xhi" ;;
  max) effort_str="max" ;;
  *) effort_str="" ;;
esac

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
home="$HOME"
short_cwd=$(echo "$cwd" | sed "s|^$home|~|")

# Git branch + dirty marker (skip optional locks for safety)
branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" -c core.fsmonitor=false symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ] && [ -n "$(git -C "$cwd" -c core.fsmonitor=false status --porcelain 2>/dev/null | head -1)" ]; then
    branch="${branch}*"
  fi
fi

out=$(printf "\033[36m%s\033[0m" "$model")
[ -n "$effort_str" ] && out="$out $(printf "\033[2m%s\033[0m" "$effort_str")"
out="$out $(printf "\033[%sm%s\033[0m \033[35m%s\033[0m \033[33m%s\033[0m %s \033[2m%s\033[0m \033[34m%s\033[0m" \
  "$ctx_color" "$context_str" "$cost_str" "$usage_str" "$lines_str" "$dur_str" "$short_cwd")"
if [ -n "$branch" ]; then
  out="$out $(printf "\033[32m%s\033[0m" "$branch")"
fi
printf "%s" "$out"
