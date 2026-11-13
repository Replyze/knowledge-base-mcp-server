#!/usr/bin/env bash
# Talks to a help center's knowledge base MCP server with cURL, in protocol
# 2026-07-28: ask the server what it speaks, search the published articles,
# then read the first match.
#   ./curl.sh acme-help "How long does shipping take?"
set -euo pipefail

SLUG="${1:?Usage: ./curl.sh <help-center-slug> [question]}"
QUESTION="${2:-How long does shipping take?}"
URL="${KB_MCP_URL:-https://client.replyze.chat/api/mcp/kb/$SLUG}"

# 2026-07-28 has no initialize: every request names the protocol version and
# the client's capabilities in _meta, and repeats the version, the method and
# (for tools/call) the tool's name in headers.
META='"_meta":{"io.modelcontextprotocol/protocolVersion":"2026-07-28","io.modelcontextprotocol/clientCapabilities":{},"io.modelcontextprotocol/clientInfo":{"name":"curl","version":"1.0"}}'
id=0

# call <method> <params without _meta, as JSON members, may be empty> [tool name]
call() {
  local method=$1 params=$2 tool=${3:-}
  id=$((id + 1))
  local headers=(-H "Content-Type: application/json" -H "Accept: application/json, text/event-stream"
    -H "MCP-Protocol-Version: 2026-07-28" -H "Mcp-Method: $method")
  if [ -n "$tool" ]; then headers+=(-H "Mcp-Name: $tool"); fi
  curl -sS --fail-with-body "$URL" "${headers[@]}" \
    -d "{\"jsonrpc\":\"2.0\",\"id\":$id,\"method\":\"$method\",\"params\":{${params:+$params,}$META}}"
  echo
}

# Escape backslashes and double quotes so the question is valid inside JSON.
json_escape() {
  local s=${1//\\/\\\\}
  printf '%s' "${s//\"/\\\"}"
}

echo "== server/discover"
call server/discover ''

echo "== tools/call search_articles"
found=$(call tools/call "\"name\":\"search_articles\",\"arguments\":{\"query\":\"$(json_escape "$QUESTION")\",\"limit\":3}" search_articles)
echo "$found"

# The first slug in the structured result, without needing jq.
slug=$(printf '%s' "$found" | grep -o '"slug":"[^"]*"' | head -n 1 | cut -d'"' -f4 || true)
if [ -n "$slug" ]; then
  echo "== tools/call get_article ($slug)"
  call tools/call "\"name\":\"get_article\",\"arguments\":{\"slug\":\"$(json_escape "$slug")\"}" get_article
fi
