#!/bin/zsh
# Every 2 min: rebuild the encrypted status → the `data` branch (no Pages rebuild; the page reads it via the GitHub API).
# YouTube numbers only every 30 min (API quota). Page files (index/sw/icons/thumbs) → `main` (Pages) only when they change.
cd /Library/code/channels-autopilot || exit 1
YT=--no-youtube; [ $(( $(date +%M) % 30 )) -lt 2 ] && YT=""
python3 /Library/code/channels-autopilot/buffer.py --status >/dev/null 2>&1  # buffer days stay fresh on the dashboard
/Library/code/doc-channel/.venv/bin/python dashboard/make_status.py $YT >/dev/null || exit 1
cd /Library/code/channels-dashboard-data && cp ../channels-autopilot/dashboard/status.enc.json . && git add status.enc.json \
  && git commit -q --amend -m "status $(date '+%d %b %H:%M')" && git push -q -f origin data   # one commit, overwritten each time
cd /Library/code/channels-dashboard && cp ../channels-autopilot/dashboard/{index.html,manifest.webmanifest,sw.js,icon-192.png,icon-512.png} . \
  && cp ../channels-autopilot/dashboard/status.enc.json . && rsync -a ../channels-autopilot/dashboard/thumbs/ thumbs/ && rsync -a --delete ../channels-autopilot/dashboard/media/ media/ 2>/dev/null
if [ -n "$(git status --porcelain -- index.html sw.js manifest.webmanifest thumbs media icon-192.png icon-512.png)" ] || [ -z "$YT" ]; then
  git fetch -q origin main && git reset -q --soft origin/main  # the cloud may have published: its history stays, this Mac's files win
  git add -A && git commit -qm "status $(date '+%d %b %H:%M')" && git push -q origin main   # Pages fallback copy + heartbeat (every 30 min)
fi
exit 0
