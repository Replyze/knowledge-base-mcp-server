// node install-links.mjs acme-help
const slug = process.argv[2] ?? 'acme-help';
const url = `https://client.replyze.chat/api/mcp/kb/${slug}`;

// VS Code: vscode:mcp/install?<URL-encoded JSON>, wrapped in https://vscode.dev/redirect for web pages
const vscode = 'vscode:mcp/install?' + encodeURIComponent(JSON.stringify({ name: slug, type: 'http', url }));
console.log('VS Code:', 'https://vscode.dev/redirect?url=' + encodeURIComponent(vscode));

// Cursor: the server's config as base64 JSON
const config = Buffer.from(JSON.stringify({ url })).toString('base64');
console.log('Cursor: ', `cursor://anysphere.cursor-deeplink/mcp/install?name=${encodeURIComponent(slug)}&config=${config}`);
