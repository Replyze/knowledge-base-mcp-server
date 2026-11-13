#!/usr/bin/env bash
# Talks to a help center's knowledge base MCP server with cURL: initialize,
# search the published articles, then read the first match.
#   ./curl.sh acme-help "How long does shipping take?"
set -euo pipefail

SLUG="${1:?Usage: ./curl.sh <help-center-slug> [question]}"
QUESTION="${2:-How long does shipping take?}"
URL="${KB_MCP_URL:-https://client.replyze.chat/api/mcp/kb/$SLUG}"

call() {
  curl -sS --fail-with-body "$URL" \
    -H "Content-Type: application/json" \
    -H "MCP-Protocol-Version: 2025-06-18" \
    -d "$1"
  echo
}

# Escape backslashes and double quotes so the question is valid inside JSON.
json_escape() {
  local s=${1//\\/\\\\}
  printf '%s' "${s//\"/\\\"}"
}

echo "== initialize"
call '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"curl","version":"1.0"}}}'

echo "== tools/call search_articles"
found=$(call "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/call\",\"params\":{\"name\":\"search_articles\",\"arguments\":{\"query\":\"$(json_escape "$QUESTION")\",\"limit\":3}}}")
echo "$found"

# The first slug in the structured result, without needing jq.
slug=$(printf '%s' "$found" | grep -o '"slug":"[^"]*"' | head -n 1 | cut -d'"' -f4 || true)
if [ -n "$slug" ]; then
  echo "== tools/call get_article ($slug)"
  call "{\"jsonrpc\":\"2.0\",\"id\":3,\"method\":\"tools/call\",\"params\":{\"name\":\"get_article\",\"arguments\":{\"slug\":\"$(json_escape "$slug")\"}}}"
fi
