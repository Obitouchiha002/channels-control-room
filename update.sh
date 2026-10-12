#!/bin/zsh
# Every 30 min: rebuild the encrypted status and publish it to GitHub Pages (only if it changed).
cd /Library/code/channels-autopilot && /Library/code/doc-channel/.venv/bin/python dashboard/make_status.py >/dev/null || exit 1
cd /Library/code/channels-dashboard && cp ../channels-autopilot/dashboard/{status.enc.json,index.html,manifest.webmanifest,sw.js,icon-192.png,icon-512.png} . && rsync -a ../channels-autopilot/dashboard/thumbs/ thumbs/
git add -A && git commit -qm "status $(date '+%d %b %H:%M')"; git pull -q --rebase -X theirs origin main && git push -q origin main  # cloud may have published while the Mac was off; the Mac copy wins
exit 0
