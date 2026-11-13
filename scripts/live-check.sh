#!/usr/bin/env bash
# Asks the live help center MCP endpoint what the README says it answers for an
# address with no published help center: 404 with a JSON-RPC error.
# Changes nothing.
#   bash scripts/live-check.sh
set -euo pipefail

BASE="${KB_MCP_BASE:-https://client.replyze.chat/api/mcp/kb}"
SLUG="no-help-center-here-ci-check"
BODY='{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
failed=0

# expect <what> <status> <text the body must contain> <curl arguments...>
expect() {
  local what=$1 status=$2 text=$3
  shift 3
  local out code
  out=$(curl -sS --retry 3 --max-time 20 -w '\n%{http_code}' "$@")
  code=${out##*$'\n'}
  out=${out%$'\n'*}
  if [ "$code" = "$status" ] && [[ "$out" == *"$text"* ]]; then
    echo "ok   $what: $code"
  else
    echo "FAIL $what: expected $status with $text, got $code $out"
    failed=1
  fi
}

expect "no help center at the address" 404 'There is no public help center at this address.' \
  -X POST "$BASE/$SLUG" -H 'Content-Type: application/json' -d "$BODY"
expect "JSON-RPC error shape" 404 '"jsonrpc":"2.0","id":null,"error":{"code":-32600' \
  -X POST "$BASE/$SLUG" -H 'Content-Type: application/json' -d "$BODY"

exit "$failed"
