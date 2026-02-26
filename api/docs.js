const REPO = 'charlieclaw007/tommy-hq';
const FILE = 'data/docs.json';
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
  const body = { message: 'data: update docs', content, branch: 'main' };
  if (sha) body.sha = sha;
  const res = await fetch(`${GH}/repos/${REPO}/contents/${FILE}`, {
    method: 'PUT', headers: ghHeaders(), body: JSON.stringify(body),
  });
  return res.ok;
}

function cors(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-API-Key');
  res.setHeader('Cache-Control', 'no-cache, no-store');
}

function auth(req) {
  return req.headers['x-api-key'] === process.env.API_KEY;
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
      return res.status(200).json(data);
    }

    if (!auth(req)) return res.status(401).json({ error: 'Invalid API key' });

    if (req.method === 'POST') {
      const { title, agent, folder, description, gdoc_url, tags } = req.body || {};
      if (!title) return res.status(400).json({ error: 'title required' });
      const item = {
        id: genId(), title,
        agent: agent || 'charlie',
        folder: folder || 'Strategy',
        description: description || '',
        gdoc_url: gdoc_url || '',
        tags: tags || [],
        created_at: new Date().toISOString(),
      };
      const { data, sha } = await readData();
      data.unshift(item);
      await writeData(data, sha);
      return res.status(201).json(item);
    }

    if (req.method === 'PUT') {
      const { id, ...updates } = req.body || {};
      if (!id) return res.status(400).json({ error: 'id required' });
      const { data, sha } = await readData();
      const idx = data.findIndex(d => d.id === id);
      if (idx === -1) return res.status(404).json({ error: 'not found' });
      data[idx] = { ...data[idx], ...updates, id };
      await writeData(data, sha);
      return res.status(200).json(data[idx]);
    }

    if (req.method === 'DELETE') {
      const { id } = req.body || {};
      if (!id) return res.status(400).json({ error: 'id required' });
      const { data, sha } = await readData();
      const filtered = data.filter(d => d.id !== id);
      await writeData(filtered, sha);
      return res.status(200).json({ deleted: id });
    }

    return res.status(405).json({ error: 'Method not allowed' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: err.message });
  }
}
