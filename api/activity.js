import { put, list } from '@vercel/blob';

const PREFIX = 'activity/';

function cors(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-API-Key');
  res.setHeader('Cache-Control', 'no-cache, no-store');
}

async function getAll() {
  const items = [];
  let cursor = undefined;
  do {
    const result = await list({ prefix: PREFIX, cursor });
    for (const blob of result.blobs) {
      try {
        const res = await fetch(blob.url + '?t=' + Date.now());
        if (res.ok) items.push(await res.json());
      } catch {}
    }
    cursor = result.hasMore ? result.cursor : undefined;
  } while (cursor);
  return items.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp)).slice(0, 100);
}

function genId() {
  return Math.random().toString(36).slice(2, 10);
}

export default async function handler(req, res) {
  cors(res);
  if (req.method === 'OPTIONS') return res.status(200).end();

  try {
    if (req.method === 'GET') return res.status(200).json(await getAll());

    if (req.method === 'POST') {
      const { agent, action, details } = req.body;
      if (!action) return res.status(400).json({ error: 'action required' });
      const item = {
        id: genId(),
        agent: agent || 'charlie',
        action,
        details: details || '',
        timestamp: new Date().toISOString(),
      };
      await put(PREFIX + item.id + '.json', JSON.stringify(item), { access: 'public', contentType: 'application/json', addRandomSuffix: false });
      return res.status(201).json(item);
    }

    res.status(405).json({ error: 'Method not allowed' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
}
