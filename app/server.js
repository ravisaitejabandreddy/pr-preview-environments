// Tiny zero-dependency web app for PR previews.
// Pure Node http module => no `npm install`, tiny image, fast builds.
const http = require("http");

const PORT = process.env.PORT || 3000;
const PR_NUMBER = process.env.PR_NUMBER || "local";
const GIT_SHA = process.env.GIT_SHA || "dev";
const GIT_BRANCH = process.env.GIT_BRANCH || "local";

// Derive a stable color from the branch name so each preview *looks* different.
function branchColor(branch) {
  let hash = 0;
  for (let i = 0; i < branch.length; i++) {
    hash = branch.charCodeAt(i) + ((hash << 5) - hash);
  }
  const hue = Math.abs(hash) % 360;
  return `hsl(${hue} 70% 45%)`;
}

const color = branchColor(GIT_BRANCH);

const page = `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>PR #${PR_NUMBER} preview</title>
  <style>
    :root { color-scheme: light dark; }
    body {
      margin: 0; min-height: 100vh; display: grid; place-items: center;
      font-family: ui-sans-serif, system-ui, -apple-system, sans-serif;
      background: ${color}; color: white;
    }
    .card {
      background: rgba(0,0,0,.25); padding: 2.5rem 3rem; border-radius: 1rem;
      backdrop-filter: blur(6px); box-shadow: 0 10px 40px rgba(0,0,0,.3);
      text-align: center; max-width: 32rem;
    }
    h1 { margin: 0 0 .25rem; font-size: 2.5rem; }
    .badge {
      display: inline-block; background: rgba(255,255,255,.2);
      padding: .25rem .75rem; border-radius: 999px; font-size: .85rem;
      margin: .25rem; font-variant-numeric: tabular-nums;
    }
    code { font-family: ui-monospace, SFMono-Regular, monospace; }
    p { opacity: .9; margin-top: 1.25rem; line-height: 1.5; }
  </style>
</head>
<body>
  <div class="card">
    <h1>🚀 Preview #${PR_NUMBER}</h1>
    <p>This is an <strong>ephemeral environment</strong> spun up from a pull request.</p>
    <div>
      <span class="badge">branch: <code>${GIT_BRANCH}</code></span>
      <span class="badge">sha: <code>${GIT_SHA.slice(0, 7)}</code></span>
    </div>
    <p>Edit anything in this branch, push, and watch this page change color &amp; content automatically.</p>
  </div>
</body>
</html>`;

const server = http.createServer((req, res) => {
  if (req.url === "/healthz") {
    res.writeHead(200, { "content-type": "application/json" });
    res.end(JSON.stringify({ status: "ok", pr: PR_NUMBER, sha: GIT_SHA }));
    return;
  }
  res.writeHead(200, { "content-type": "text/html; charset=utf-8" });
  res.end(page);
});

server.listen(PORT, () => {
  console.log(`PR #${PR_NUMBER} (${GIT_BRANCH}@${GIT_SHA}) listening on :${PORT}`);
});
