<p align="center">
  <a href="https://replyze.chat/?utm_source=github&utm_medium=knowledge-base-mcp-server">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/Replyze/.github/main/assets/logo-on-dark.png">
      <img src="https://raw.githubusercontent.com/Replyze/.github/main/assets/logo-on-light.png" alt="Replyze" height="48">
    </picture>
  </a>
</p>

# Knowledge base MCP server: your help center in Claude, ChatGPT, Cursor and VS Code

Turn your help center into an [MCP](https://modelcontextprotocol.io) server, so any AI assistant can search your published articles, read them and link to them. Your customers ask their own assistant and get your current answer instead of a guess. Your developers ask from Cursor or VS Code without leaving the editor. It is a **remote server with no key**: you share one URL. There is nothing to install, host or keep in sync, because the help center is the server.

This page documents the knowledge base MCP server that every [Replyze](https://replyze.chat/?utm_source=github&utm_medium=knowledge-base-mcp-server) public help center has. Replyze is AI customer support: an AI agent that answers from your docs, live chat for your website, and one inbox for chat, email, WhatsApp and Telegram.

```
https://client.replyze.chat/api/mcp/kb/<your-help-center-slug>
```

## Contents

[Why](#why-put-your-help-center-in-an-ai-assistant) ·
[Turn it on](#turn-it-on) ·
[Tools](#tools) ·
[Connect an assistant](#connect-an-assistant) ([Claude](#claudeai-and-claude-desktop) · [Claude Code](#claude-code) · [ChatGPT](#chatgpt) · [Cursor](#cursor) · [VS Code](#vs-code) · [Other clients](#other-clients)) ·
[Tell your customers](#tell-your-customers) ·
[Protocol](#protocol) ·
[Errors](#errors) ·
[FAQ](#faq)

## Why put your help center in an AI assistant

- **People ask assistants first.** "How do I reset my password in Acme?" goes to ChatGPT or Claude before it goes to your site. Without your docs, the assistant answers from whatever it remembers, which may be old or wrong. Connected to this server, it searches your published articles and links to the one it used.
- **Developers stay in the editor.** If your product has an API or an SDK, users can ask from Cursor or VS Code and get the answer from your docs, with the link.
- **Your team gets a shortcut.** Support agents who already work in Claude can look up the right article and paste the link.
- **Nothing to maintain.** The server reads the help center itself. Publish or edit an article and the next search finds it. Drafts never show.

## Turn it on

1. In the Replyze dashboard, open **Knowledge Base**. Under **Public help center**, choose **Set up**.
2. Pick the **Address** (for example `acme-help`). That is your slug, and the help center is at `https://client.replyze.chat/help/acme-help`.
3. Switch on **Publish the help center**.

The MCP server is live at the same moment, at `https://client.replyze.chat/api/mcp/kb/acme-help`. The dashboard also shows the URL in **Settings → Integrations → Developer**, in the MCP card.

The public help center is part of the paid plans and the free trial; see [pricing](https://replyze.chat/pricing?utm_source=github&utm_medium=knowledge-base-mcp-server). When the help center is switched off, or the plan no longer includes it, the server is gone too (`404`). No account yet? [Sign up](https://client.replyze.chat/register?utm_source=github&utm_medium=knowledge-base-mcp-server).

## Tools

Two read-only tools. They see exactly what a visitor of the help center sees: published articles, nothing else.

| Tool | What it does | Arguments |
|---|---|---|
| `search_articles` | Searches the published articles the way the help center's own search does. Returns the best matches with their URL and a short summary. | `query` (required, 2 to 200 characters, plain words like a customer would type), `locale` (one of the help center's languages; default: its main language), `limit` (1 to 20, default 5) |
| `get_article` | One published article with its full text and URL. | `slug` (the last part of the article's URL, from `search_articles`) or `article_id` |

`search_articles` returns:

```json
{
  "articles": [
    {
      "id": 812,
      "title": "Shipping times",
      "slug": "shipping-times",
      "locale": "en",
      "url": "https://client.replyze.chat/help/acme-help/articles/shipping-times",
      "summary": "Parcels arrive in 3 to 5 working days..."
    }
  ]
}
```

`get_article` returns `{ "article": { "id", "title", "slug", "locale", "url", "content", "updated_at" } }`, where `content` is the article as plain text (up to 20,000 characters) and `updated_at` is ISO 8601 in UTC.

On `initialize`, the server tells the assistant whose help center it is and to answer from the articles and link the article URL, so most assistants cite the page without being asked.

## Connect an assistant

Replace `acme-help` with your slug. The name you give the server (`acme-help` below) is only a label in your assistant. Ready-made files are in [`examples/`](examples).

### claude.ai and Claude Desktop

Add it as a **custom connector** with the URL `https://client.replyze.chat/api/mcp/kb/acme-help`. No authentication is needed.

Or, in Claude Desktop only, through [`mcp-remote`](https://www.npmjs.com/package/mcp-remote) (needs Node.js). Open Settings → Developer → Edit Config, add this to `claude_desktop_config.json` and restart Claude:

```json
{
  "mcpServers": {
    "acme-help": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://client.replyze.chat/api/mcp/kb/acme-help"]
    }
  }
}
```

### Claude Code

```bash
claude mcp add --transport http acme-help https://client.replyze.chat/api/mcp/kb/acme-help
```

### ChatGPT

In developer mode, create a connector with the URL `https://client.replyze.chat/api/mcp/kb/acme-help` and no authentication.

### Cursor

Cursor → Settings → MCP → Add new server, or `.cursor/mcp.json` in a project (`~/.cursor/mcp.json` for every project):

```json
{
  "mcpServers": {
    "acme-help": {
      "url": "https://client.replyze.chat/api/mcp/kb/acme-help"
    }
  }
}
```

### VS Code

`.vscode/mcp.json`:

```json
{
  "servers": {
    "acme-help": {
      "type": "http",
      "url": "https://client.replyze.chat/api/mcp/kb/acme-help"
    }
  }
}
```

### Other clients

Any client that connects to a remote MCP server over Streamable HTTP works: give it the URL, no headers. Clients that only start local (stdio) servers can go through `npx -y mcp-remote <url>`, as in the Claude Desktop example. The [MCP Inspector](https://github.com/modelcontextprotocol/inspector) is handy for a first look: transport Streamable HTTP, the URL, no authentication.

## Tell your customers

The server only helps if people know it exists. Put a short note in your help center, for example as an article called "Use our help center in your AI assistant":

```markdown
## Ask our help center from ChatGPT, Claude, Cursor or VS Code

Add this MCP server to your assistant and it will answer from our articles, with links:

    https://client.replyze.chat/api/mcp/kb/acme-help

- **Claude:** Settings → Connectors → add a custom connector with the URL above.
- **ChatGPT:** developer mode → create a connector with the URL above, no authentication.
- **Cursor or VS Code:** add a remote (HTTP) MCP server with the URL above.

It is read-only and needs no account. It only sees our published help articles.
```

## Protocol

For client authors and debugging. The server follows the MCP spec's Streamable HTTP transport, stateless:

- JSON-RPC 2.0 messages are POSTed to the URL, and each request gets one JSON answer. There is no event stream and no session: GET and DELETE answer `405`.
- Protocol version `2025-06-18`. Clients on `2025-03-26` or `2024-11-05` are answered in their version. An `MCP-Protocol-Version` header with another version gets `400`.
- Methods: `initialize`, `ping`, `tools/list`, `tools/call`. Notifications get `202` with no body. Batches (older clients) are accepted.
- Tool results come both as text (the JSON, which every client reads) and as `structuredContent`. A tool that fails returns `isError: true` with a message.
- Requests are rate limited per IP. Answers carry `X-RateLimit-Limit` and `X-RateLimit-Remaining`, and are never cached (`Cache-Control: no-store`).

Try it with cURL ([`examples/curl.sh`](examples/curl.sh) runs these three calls):

```bash
URL=https://client.replyze.chat/api/mcp/kb/acme-help

curl -s "$URL" -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"curl","version":"1.0"}}}'

curl -s "$URL" -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"search_articles","arguments":{"query":"how long does shipping take"}}}'

curl -s "$URL" -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"get_article","arguments":{"slug":"shipping-times"}}}'
```

## Errors

| Status | When | Body |
|---|---|---|
| `404` | There is no help center with this slug, it is switched off, or its plan doesn't include it. | JSON-RPC error `-32600`, "There is no public help center at this address." |
| `429` | Too many requests from your IP. Wait `Retry-After` seconds. | JSON-RPC error `-32600`, "Too many requests. Try again in N seconds." |
| `405` | A GET or DELETE. | The server takes POST only. |
| `400` | A body that isn't JSON (`-32700`), or an `MCP-Protocol-Version` header with a version the server doesn't speak (`-32600`, with the supported versions). | JSON-RPC error. |
| `200` | An unknown tool. | JSON-RPC error `-32602`. |
| `200` | Arguments that don't fit the tool's schema. | A tool result with `isError: true` and `structuredContent.error` = `invalid_arguments`. |
| `200` | `get_article` for an article that isn't published in this help center. | A tool result with `isError: true` and `structuredContent.error` = `tool_error`: "This help center has no published article like that. Use search_articles to find one." |

## FAQ

**Does it expose anything private?**
No. It sees the same published articles anyone can read on the help center: no drafts, no conversations, no contacts, nothing from other help centers. There is no key, because there is nothing secret behind it.

**Does it use the website pages my Replyze AI learned from?**
No. Only the help center's published articles. Your workspace's [authenticated MCP server](https://github.com/Replyze/replyze-mcp) searches everything your AI answers from, with an API key.

**What about other languages?**
If the help center has articles in several languages, `search_articles` takes a `locale`, and its schema lists the help center's languages so the assistant can pick one.

**How is this different from the Replyze MCP server?**
[replyze-mcp](https://github.com/Replyze/replyze-mcp) is for your team. It needs an API key and can read and answer conversations, assign them, look up contacts and search all your knowledge. This server is for anyone: read-only, published articles only, no key.

## Related

- [replyze-mcp](https://github.com/Replyze/replyze-mcp): your support inbox in Claude, Cursor and VS Code, with an API key
- [replyze](https://github.com/Replyze/replyze): the chat widget, its JavaScript API, the REST API and webhooks
- [add-live-chat-to-website](https://github.com/Replyze/add-live-chat-to-website): the chat on any website, platform by platform

The tools, the protocol and the error behavior on this page follow the server's source and its test suite (November 2026).

## License

MIT, see [LICENSE](LICENSE).
