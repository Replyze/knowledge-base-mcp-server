<p align="center">
  <a href="https://replyze.chat/?utm_source=github&utm_medium=referral&utm_campaign=knowledge-base-mcp-server">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/Replyze/.github/main/assets/logo-on-dark.png">
      <img src="https://raw.githubusercontent.com/Replyze/.github/main/assets/logo-on-light.png" alt="Replyze" height="48">
    </picture>
  </a>
</p>

# Knowledge base MCP server: your help center in Claude, ChatGPT, Cursor and VS Code

Turn your help center into an [MCP](https://modelcontextprotocol.io) server, so any AI assistant can search your published articles, read them and link to them. Your customers ask their own assistant and get your current answer instead of a guess. Your developers ask from Cursor or VS Code without leaving the editor. It is a **remote server with no key**: you share one URL. There is nothing to install, host or keep in sync, because the help center is the server.

This page documents the knowledge base MCP server that every [Replyze](https://replyze.chat/?utm_source=github&utm_medium=referral&utm_campaign=knowledge-base-mcp-server) public help center has. Replyze is AI customer support: an AI agent that answers from your docs, live chat for your website, and one inbox for chat, email, WhatsApp and Telegram.

**[Create a free account](https://client.replyze.chat/register?utm_source=github&utm_medium=referral&utm_campaign=knowledge-base-mcp-server&utm_content=cta-top)** · [Live demo](https://replyze.chat/?utm_source=github&utm_medium=referral&utm_campaign=knowledge-base-mcp-server&utm_content=live-demo) · [Docs](https://github.com/Replyze/replyze)

```
https://client.replyze.chat/api/mcp/kb/<your-help-center-slug>
```

## Quickstart

1. **Publish your help center.** [Create a free account](https://client.replyze.chat/register?utm_source=github&utm_medium=referral&utm_campaign=knowledge-base-mcp-server&utm_content=quickstart), open **Knowledge Base → Public help center → Set up**, pick its address (say `acme-help`) and switch on **Publish the help center**. [Details](#turn-it-on).
2. **Take the URL:** `https://client.replyze.chat/api/mcp/kb/acme-help`, with your address in place of `acme-help`.
3. **Add it to an assistant.** In Claude Code:

   ```bash
   claude mcp add --transport http acme-help https://client.replyze.chat/api/mcp/kb/acme-help
   ```

   Then ask it something your articles answer. [Claude, ChatGPT, Cursor and VS Code](#connect-an-assistant) are below, and [one-click install links](#one-click-install-links) for your customers.

## Contents

[Quickstart](#quickstart) ·
[Why](#why-put-your-help-center-in-an-ai-assistant) ·
[Turn it on](#turn-it-on) ·
[Tools](#tools) ·
[Connect an assistant](#connect-an-assistant) ([Claude](#claudeai-and-claude-desktop) · [Claude Code](#claude-code) · [ChatGPT](#chatgpt) · [Cursor](#cursor) · [VS Code](#vs-code) · [Other clients](#other-clients)) ·
[Tell your customers](#tell-your-customers) ·
[One-click install links](#one-click-install-links) ·
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

Whether a workspace has the public help center depends on its plan; see [pricing](https://replyze.chat/pricing?utm_source=github&utm_medium=referral&utm_campaign=knowledge-base-mcp-server). When the help center is switched off, or the plan no longer includes it, the server is gone too (`404`). No account yet? [Sign up](https://client.replyze.chat/register?utm_source=github&utm_medium=referral&utm_campaign=knowledge-base-mcp-server).

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

When an assistant connects (`initialize`, or `server/discover` in protocol `2026-07-28`), the server tells it whose help center it is and to answer from the articles and link the article URL, so most assistants cite the page without being asked.

## Connect an assistant

Replace `acme-help` with your slug. The name you give the server (`acme-help` below) is only a label in your assistant. Ready-made files are in [`examples/`](examples).

### claude.ai and Claude Desktop

Add it as a **custom connector** with the URL `https://client.replyze.chat/api/mcp/kb/acme-help`. No authentication is needed.

Or, in Claude Desktop only, through [`mcp-remote`](https://github.com/punkpeye/mcp-remote) (needs Node.js). Open Settings → Developer → Edit Config, add this to `claude_desktop_config.json` and restart Claude:

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
- **VS Code:** [install it in one click](https://vscode.dev/redirect?url=vscode%3Amcp%2Finstall%3F%257B%2522name%2522%253A%2522acme-help%2522%252C%2522type%2522%253A%2522http%2522%252C%2522url%2522%253A%2522https%253A%252F%252Fclient.replyze.chat%252Fapi%252Fmcp%252Fkb%252Facme-help%2522%257D).
- **Cursor:** add a remote (HTTP) MCP server with the URL above.

It is read-only and needs no account. It only sees our published help articles.
```

Replace `acme-help` in the URL and in the VS Code link (it appears there twice). To make the link for your address, see the next section.

## One-click install links

VS Code and Cursor open an install prompt from a link. Both take the server's configuration in the link, so you make one per help center address. This prints both for yours (Node.js 18 or newer; the formats are VS Code's [install URL handler](https://code.visualstudio.com/api/extension-guides/ai/mcp) and Cursor's [install links](https://cursor.com/docs/mcp/install-links)):

```js
// node install-links.mjs acme-help
const slug = process.argv[2] ?? 'acme-help';
const url = `https://client.replyze.chat/api/mcp/kb/${slug}`;

// VS Code: vscode:mcp/install?<URL-encoded JSON>, wrapped in https://vscode.dev/redirect for web pages
const vscode = 'vscode:mcp/install?' + encodeURIComponent(JSON.stringify({ name: slug, type: 'http', url }));
console.log('VS Code:', 'https://vscode.dev/redirect?url=' + encodeURIComponent(vscode));

// Cursor: the server's config as base64 JSON
const config = Buffer.from(JSON.stringify({ url })).toString('base64');
console.log('Cursor: ', `cursor://anysphere.cursor-deeplink/mcp/install?name=${encodeURIComponent(slug)}&config=${config}`);
```

For `acme-help` that gives:

- VS Code: [`https://vscode.dev/redirect?url=vscode%3Amcp%2Finstall...`](https://vscode.dev/redirect?url=vscode%3Amcp%2Finstall%3F%257B%2522name%2522%253A%2522acme-help%2522%252C%2522type%2522%253A%2522http%2522%252C%2522url%2522%253A%2522https%253A%252F%252Fclient.replyze.chat%252Fapi%252Fmcp%252Fkb%252Facme-help%2522%257D)
- Cursor: `cursor://anysphere.cursor-deeplink/mcp/install?name=acme-help&config=eyJ1cmwiOiJodHRwczovL2NsaWVudC5yZXBseXplLmNoYXQvYXBpL21jcC9rYi9hY21lLWhlbHAifQ==`

The VS Code link is an ordinary `https` link and works anywhere. The Cursor link starts with `cursor://`, which only some pages keep: GitHub READMEs drop such links, and so do Replyze help center articles (they keep `https`, `mailto` and `tel` links only). Put it on your own website, with Cursor's button: `https://cursor.com/deeplink/mcp-install-dark.svg` (or `mcp-install-light.svg`). [`examples/install-links.mjs`](examples/install-links.mjs) is the script above.

## Protocol

For client authors and debugging. The server follows the MCP spec's Streamable HTTP transport, stateless:

- JSON-RPC 2.0 messages are POSTed to the URL, and each request gets one JSON answer. There is no event stream and no session: GET and DELETE answer `405`.
- Protocol versions: `2026-07-28`, and the `initialize`-based `2025-11-25`, `2025-06-18`, `2025-03-26` and `2024-11-05`. Clients that speak `2026-07-28` find it with `server/discover`; the others use `initialize` as before.
- `2026-07-28` has no handshake. Every request names the version and the client's capabilities in `params._meta` (`io.modelcontextprotocol/protocolVersion`, `io.modelcontextprotocol/clientCapabilities`) and repeats them in headers: `MCP-Protocol-Version`, `Mcp-Method`, and `Mcp-Name` on `tools/call`. A missing header or one that disagrees with the body gets `400`. Every result carries `resultType: "complete"` and the server's name and version in `_meta["io.modelcontextprotocol/serverInfo"]`.
- The `initialize`-based versions: `initialize` answers in the client's version when it is one of the four, and in `2025-11-25` otherwise. Their answers have no `resultType` and no caching hints.
- Methods: `server/discover`, `tools/list` and `tools/call` in `2026-07-28`; `initialize`, `ping`, `tools/list` and `tools/call` in the older versions. Notifications get `202` with no body. Batches are accepted from older clients only. The tool list doesn't push changes (`listChanged: false`), so there is no `subscriptions/listen`.
- Tool results come both as text (the JSON, which every client reads) and as `structuredContent`. A tool that fails returns `isError: true` with a message.
- Requests are rate limited per IP. Answers carry `X-RateLimit-Limit` and `X-RateLimit-Remaining`, and HTTP caches may not keep them (`Cache-Control: no-store`). In `2026-07-28`, `server/discover` and `tools/list` tell the MCP client itself how long it may reuse them: `ttlMs: 300000` (5 minutes) and `cacheScope: "public"`, because every caller gets the same tools.

Try it with cURL. In `2025-11-25`, `initialize` first, then the tools:

```bash
URL=https://client.replyze.chat/api/mcp/kb/acme-help

curl -s "$URL" -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"curl","version":"1.0"}}}'

curl -s "$URL" -H "Content-Type: application/json" -H "MCP-Protocol-Version: 2025-11-25" \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"search_articles","arguments":{"query":"how long does shipping take"}}}'
```

In `2026-07-28`, with no `initialize`:

```bash
curl -s "$URL" -H "Content-Type: application/json" \
  -H "MCP-Protocol-Version: 2026-07-28" -H "Mcp-Method: tools/call" -H "Mcp-Name: get_article" \
  -d '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"get_article","arguments":{"slug":"shipping-times"},"_meta":{"io.modelcontextprotocol/protocolVersion":"2026-07-28","io.modelcontextprotocol/clientCapabilities":{}}}}'
```

[`examples/curl.sh`](examples/curl.sh) runs a whole `2026-07-28` session: `server/discover`, `search_articles`, then `get_article` for the first match. The [MCP Inspector](https://github.com/modelcontextprotocol/inspector) CLI uses `2026-07-28` with `--protocol-era auto` (or `modern`) and `2025-11-25` by default.

## Errors

| Status | When | Body |
|---|---|---|
| `404` | There is no help center with this slug, it is switched off, or its plan doesn't include it. | JSON-RPC error `-32600`, "There is no public help center at this address." |
| `429` | Too many requests from your IP. Wait `Retry-After` seconds. | JSON-RPC error `-32600`, "Too many requests. Try again in N seconds." |
| `405` | A GET or DELETE. | The server takes POST only. |
| `400` | A body that isn't JSON. | JSON-RPC error `-32700`. |
| `400` | An `MCP-Protocol-Version` header, or a `2026-07-28` `_meta`, with a version the server doesn't speak. | JSON-RPC error `-32022`; `data.supported` lists the versions it speaks, `data.requested` the one you sent. |
| `400` | `2026-07-28`: the `MCP-Protocol-Version`, `Mcp-Method` or `Mcp-Name` header is missing or disagrees with the body, or `initialize` was sent with `MCP-Protocol-Version: 2026-07-28`. | JSON-RPC error `-32020`. |
| `400` | `2026-07-28`: `params._meta` lacks `io.modelcontextprotocol/protocolVersion` or `io.modelcontextprotocol/clientCapabilities`, or one of its values has the wrong type. | JSON-RPC error `-32602`. |
| `400` | `2026-07-28`: a batch, or a body that isn't a JSON-RPC 2.0 request. | JSON-RPC error `-32600`. |
| `404` | `2026-07-28`: a method the server doesn't have, including `initialize` and `ping`, which that version doesn't define. | JSON-RPC error `-32601`. |
| `200` | An unknown method, in the older versions. | JSON-RPC error `-32601`. |
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

The tools, the protocol and the error behavior on this page follow the server's source and its test suite, and were checked with the MCP Inspector and the official TypeScript and Python SDKs (November 2026).

## For registries

[`server.json`](server.json) describes this server in the format of the official [MCP Registry](https://registry.modelcontextprotocol.io). How it gets published, and to which other directories: [RELEASING.md](RELEASING.md). CI checks the example configs, `server.json` and the live server's error answers on every push.

## License

MIT, see [LICENSE](LICENSE).
