import { put, list, del } from '@vercel/blob';

const PREFIX = 'task/';

function cors(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-API-Key');
  res.setHeader('Cache-Control', 'no-cache, no-store');
}

function auth(req) {
  return req.headers['x-api-key'] === process.env.API_KEY;
}

async function getAllTasks() {
  const tasks = [];
  let cursor = undefined;
  do {
    const result = await list({ prefix: PREFIX, cursor });
    for (const blob of result.blobs) {
      try {
        const res = await fetch(blob.url + '?t=' + Date.now());
        if (res.ok) tasks.push(await res.json());
      } catch {}
    }
    cursor = result.hasMore ? result.cursor : undefined;
  } while (cursor);
  return tasks;
}

function genId() {
  return Math.random().toString(36).slice(2, 10);
}

export default async function handler(req, res) {
  cors(res);
  if (req.method === 'OPTIONS') return res.status(200).end();

  if (req.method !== 'GET' && !auth(req)) {
    return res.status(401).json({ error: 'Invalid API key' });
  }

  try {
    if (req.method === 'GET') {
      const tasks = await getAllTasks();
      return res.status(200).json(tasks);
    }

    if (req.method === 'POST') {
      const { title, agent, priority, status } = req.body;
      if (!title) return res.status(400).json({ error: 'title required' });
      const task = {
        id: genId(), title,
        agent: agent || 'charlie',
        priority: priority || 'medium',
        status: status || 'todo',
        date: new Date().toISOString().slice(0, 10),
      };
      await put(PREFIX + task.id + '.json', JSON.stringify(task), {
        access: 'public',
        contentType: 'application/json',
        addRandomSuffix: false,
      });
      return res.status(201).json(task);
    }

    if (req.method === 'PUT') {
      const { id: taskId, ...updates } = req.body;
      if (!taskId) return res.status(400).json({ error: 'id required' });
      
      // Find existing task blob
      const { blobs } = await list({ prefix: PREFIX + taskId });
      if (!blobs.length) return res.status(404).json({ error: 'task not found' });
      
      const existing = await (await fetch(blobs[0].url + '?t=' + Date.now())).json();
      const updated = { ...existing, ...updates, id: taskId };
      
      await put(PREFIX + taskId + '.json', JSON.stringify(updated), {
        access: 'public',
        contentType: 'application/json',
        addRandomSuffix: false,
      });
      return res.status(200).json(updated);
    }

    if (req.method === 'DELETE') {
      const { id: taskId } = req.body;
      if (!taskId) return res.status(400).json({ error: 'id required' });
      
      const { blobs } = await list({ prefix: PREFIX + taskId });
      for (const b of blobs) await del(b.url);
      return res.status(200).json({ deleted: taskId });
    }

    res.status(405).json({ error: 'Method not allowed' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
}
