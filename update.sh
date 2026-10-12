#!/bin/zsh
# Every 30 min: rebuild the encrypted status and publish it to GitHub Pages (only if it changed).
cd /Library/code/channels-autopilot && /Library/code/doc-channel/.venv/bin/python dashboard/make_status.py >/dev/null || exit 1
cd /Library/code/channels-dashboard && cp ../channels-autopilot/dashboard/status.enc.json ../channels-autopilot/dashboard/index.html .
git add -A && git commit -qm "status $(date '+%d %b %H:%M')" && git push -q origin main
exit 0
