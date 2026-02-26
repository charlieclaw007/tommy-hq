const REPO = 'charlieclaw007/tommy-hq';
const FILE = 'data/activity.json';
const GH = 'https://api.github.com';

function ghHeaders() {
  return {
    Authorization: `Bearer ${process.env.GITHUB_TOKEN}`,
    Accept: 'application/vnd.github+json',
    'Content-Type': 'application/json',
    'X-GitHub-Api-Version': '2022-11-28',
  };
}

async function readData() {
  const res = await fetch(`${GH}/repos/${REPO}/contents/${FILE}?ref=main&t=${Date.now()}`, { headers: ghHeaders() });
  if (!res.ok) return { data: [], sha: null };
  const json = await res.json();
  try {
    const data = JSON.parse(Buffer.from(json.content, 'base64').toString('utf8'));
    return { data, sha: json.sha };
  } catch { return { data: [], sha: json.sha }; }
}

async function writeData(data, sha) {
  const content = Buffer.from(JSON.stringify(data, null, 2)).toString('base64');
  const body = { message: 'data: update activity', content, branch: 'main' };
  if (sha) body.sha = sha;
  const res = await fetch(`${GH}/repos/${REPO}/contents/${FILE}`, {
    method: 'PUT', headers: ghHeaders(), body: JSON.stringify(body),
  });
  return res.ok;
}

function cors(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-API-Key');
  res.setHeader('Cache-Control', 'no-cache, no-store');
}

function genId() {
  return Date.now().toString(36) + Math.random().toString(36).slice(2, 6);
}

export default async function handler(req, res) {
  cors(res);
  if (req.method === 'OPTIONS') return res.status(200).end();

  try {
    if (req.method === 'GET') {
      const { data } = await readData();
      const sorted = data.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp)).slice(0, 100);
      return res.status(200).json(sorted);
    }

    if (req.method === 'POST') {
      const { agent, action, details } = req.body || {};
      if (!action) return res.status(400).json({ error: 'action required' });
      const item = {
        id: genId(),
        agent: agent || 'charlie',
        action,
        details: details || '',
        timestamp: new Date().toISOString(),
      };
      const { data, sha } = await readData();
      data.unshift(item);
      const trimmed = data.slice(0, 200); // keep last 200 entries
      await writeData(trimmed, sha);
      return res.status(201).json(item);
    }

    return res.status(405).json({ error: 'Method not allowed' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: err.message });
  }
}
