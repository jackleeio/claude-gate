#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [[ "$(id -u)" != "0" ]]; then
  echo "must run as root" >&2
  exit 1
fi
install -d -m 755 /usr/local/libexec
install -m 755 -o root -g wheel "$ROOT/pf/claude-gate-pf" /usr/local/libexec/claude-gate-pf
install -m 644 -o root -g wheel "$ROOT/pf/claude-gate.pf" /etc/pf.anchors/claude-gate
install -m 644 -o root -g wheel "$ROOT/launchd/com.jacklee.claude-gate-pf.plist" /Library/LaunchDaemons/com.jacklee.claude-gate-pf.plist
/sbin/pfctl -n -f /etc/pf.anchors/claude-gate
/sbin/pfctl -E >/dev/null
/sbin/pfctl -a com.apple/claude-gate -f /etc/pf.anchors/claude-gate
launchctl bootout system/com.jacklee.claude-gate-pf >/dev/null 2>&1 || true
launchctl bootstrap system /Library/LaunchDaemons/com.jacklee.claude-gate-pf.plist
launchctl enable system/com.jacklee.claude-gate-pf
echo "LOADED"
/sbin/pfctl -a com.apple/claude-gate -sr
