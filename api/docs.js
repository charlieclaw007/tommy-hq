import { put, list, del } from '@vercel/blob';
import { readFile } from 'fs/promises';

const PREFIX = 'doc/';

function cors(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-API-Key');
  res.setHeader('Cache-Control', 'no-cache, no-store');
}

function auth(req) {
  return req.headers['x-api-key'] === process.env.API_KEY;
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
  return items;
}

function genId() {
  return Math.random().toString(36).slice(2, 10);
}

export default async function handler(req, res) {
  cors(res);
  if (req.method === 'OPTIONS') return res.status(200).end();

  // GET with path param = read file content
  if (req.method === 'GET' && req.query.path) {
    const filePath = decodeURIComponent(req.query.path);
    if (!filePath.startsWith('/Users/charlieclaw/.openclaw/')) {
      return res.status(403).json({ error: 'Access denied — path not allowed' });
    }
    try {
      const content = await readFile(filePath, 'utf-8');
      return res.status(200).json({ content });
    } catch (err) {
      return res.status(404).json({ error: 'File not found' });
    }
  }

  if (req.method === 'GET') return res.status(200).json(await getAll());

  if (!auth(req)) return res.status(401).json({ error: 'Invalid API key' });

  try {
    if (req.method === 'POST') {
      const { title, agent, category, description, file_path, tags } = req.body;
      if (!title) return res.status(400).json({ error: 'title required' });
      const item = {
        id: genId(), title,
        agent: agent || 'charlie',
        category: category || 'SOP',
        description: description || '',
        file_path: file_path || '',
        tags: tags || [],
        created_at: new Date().toISOString(),
      };
      await put(PREFIX + item.id + '.json', JSON.stringify(item), { access: 'public', contentType: 'application/json', addRandomSuffix: false });
      return res.status(201).json(item);
    }

    if (req.method === 'PUT') {
      const { id, ...updates } = req.body;
      if (!id) return res.status(400).json({ error: 'id required' });
      const { blobs } = await list({ prefix: PREFIX + id });
      if (!blobs.length) return res.status(404).json({ error: 'not found' });
      const existing = await (await fetch(blobs[0].url + '?t=' + Date.now())).json();
      const updated = { ...existing, ...updates, id };
      await put(PREFIX + id + '.json', JSON.stringify(updated), { access: 'public', contentType: 'application/json', addRandomSuffix: false });
      return res.status(200).json(updated);
    }

    if (req.method === 'DELETE') {
      const { id } = req.body;
      if (!id) return res.status(400).json({ error: 'id required' });
      const { blobs } = await list({ prefix: PREFIX + id });
      for (const b of blobs) await del(b.url);
      return res.status(200).json({ deleted: id });
    }

    res.status(405).json({ error: 'Method not allowed' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
}
