# Releasing

This repository documents a hosted server, so there is no package to build or publish. What gets released is the server's entry in MCP registries and directories, made from [`server.json`](server.json).

## server.json

- Format: the official MCP Registry's [`server.json` schema, 2025-12-11](https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json), a remote (`streamable-http`) server with no package.
- Name: `io.github.Replyze/knowledge-base-mcp-server`. The registry checks this namespace letter for letter, so keep the capital `R` of the organization's name.
- `version` matches the `serverInfo.version` the server answers `initialize` with (`1.0.0`). Publish a new version when the tools or the sign-in change.
- The URL has one variable, `{help_center_slug}`: a registry client asks for the help center's address and puts it in the URL. There is no key.
- CI checks it on every push: against the schema (`check-jsonschema`) and with the registry's own validator (`mcp-publisher validate`, which publishes nothing).

## Publish to the official MCP Registry

The registry gives the `io.github.Replyze/*` namespace only to someone who can prove they are an **Owner** of the Replyze GitHub organization. The browser login (`mcp-publisher login github`) can't prove that at the moment ([registry issue #1468](https://github.com/modelcontextprotocol/registry/issues/1468)), so use one of these:

1. **GitHub Actions (no secret needed).** Merge to `main`, then Actions → **Publish to MCP Registry** → **Run workflow**. The workflow ([`publish-mcp-registry.yml`](.github/workflows/publish-mcp-registry.yml)) signs in with the run's OIDC token, which names the organization.
2. **From a computer**, as an Owner of the organization, with a classic personal access token that has the `read:org` scope (and no repository scopes):

   ```bash
   mcp-publisher login github --token <token>
   mcp-publisher publish server.json
   ```

   `mcp-publisher` is on the registry's [releases page](https://github.com/modelcontextprotocol/registry/releases) and in Homebrew (`brew install mcp-publisher`).

Then check the entry:

```bash
curl "https://registry.modelcontextprotocol.io/v0.1/servers?search=io.github.Replyze/knowledge-base-mcp-server"
```

## Other directories

| Directory | How a server gets in | Notes for this server |
|---|---|---|
| [GitHub MCP Registry](https://github.com/mcp) | Reads the official MCP Registry | Nothing more to do after publishing above. |
| VS Code | Looks names up in its active MCP gallery: `vscode:mcp/by-name/io.github.Replyze/knowledge-base-mcp-server` | Works only once a gallery VS Code uses lists the server. |
| [PulseMCP](https://www.pulsemcp.com/submit) | Not taking submissions; picks up the official MCP Registry | Nothing to do. |
| [Docker MCP Catalog](https://github.com/docker/mcp-registry/blob/main/CONTRIBUTING.md) | A pull request to `docker/mcp-registry` (`task remote-wizard`), reviewed by Docker | Takes remote `streamable-http` servers. |
| [Claude connectors directory](https://claude.com/docs/connectors/building/submission) | A submission form (`claude.ai/directory/manage`), reviewed by Anthropic | Public data with no sign-in is allowed, and the tools carry the `title` and `readOnlyHint` annotations it asks for. A server whose URL differs per user (here, per help center) is published only once the listing has the Verified label. |
