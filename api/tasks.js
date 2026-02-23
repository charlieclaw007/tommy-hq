import { put, head, del, list } from '@vercel/blob';

const BLOB_PATH = 'tasks.json';

function cors(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-API-Key');
}

function auth(req) {
  return req.headers['x-api-key'] === process.env.API_KEY;
}

async function getTasks() {
  try {
    const { blobs } = await list({ prefix: BLOB_PATH, limit: 1 });
    if (!blobs.length) return [];
    // Fetch with cache-busting
    const res = await fetch(blobs[0].url + '?t=' + Date.now());
    if (!res.ok) return [];
    return await res.json();
  } catch (e) {
    console.error('getTasks error:', e);
    return [];
  }
}

async function saveTasks(tasks) {
  // Clean up any old blobs
  try {
    const { blobs } = await list({ prefix: BLOB_PATH });
    for (const b of blobs) {
      try { await del(b.url); } catch {}
    }
  } catch {}
  
  const blob = await put(BLOB_PATH, JSON.stringify(tasks), {
    access: 'public',
    contentType: 'application/json',
    addRandomSuffix: false,
  });
  console.log('Saved blob:', blob.url, 'tasks:', tasks.length);
  return blob;
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
      const tasks = await getTasks();
      return res.status(200).json(tasks);
    }

    if (req.method === 'POST') {
      const { title, agent, priority, status } = req.body;
      if (!title) return res.status(400).json({ error: 'title required' });
      const tasks = await getTasks();
      const task = {
        id: genId(), title,
        agent: agent || 'charlie',
        priority: priority || 'medium',
        status: status || 'todo',
        date: new Date().toISOString().slice(0, 10),
      };
      tasks.push(task);
      await saveTasks(tasks);
      return res.status(201).json(task);
    }

    if (req.method === 'PUT') {
      const { id: taskId, ...updates } = req.body;
      if (!taskId) return res.status(400).json({ error: 'id required' });
      const tasks = await getTasks();
      const idx = tasks.findIndex(t => t.id === taskId);
      if (idx === -1) return res.status(404).json({ error: 'task not found' });
      Object.assign(tasks[idx], updates);
      await saveTasks(tasks);
      return res.status(200).json(tasks[idx]);
    }

    if (req.method === 'DELETE') {
      const { id: taskId } = req.body;
      if (!taskId) return res.status(400).json({ error: 'id required' });
      let tasks = await getTasks();
      tasks = tasks.filter(t => t.id !== taskId);
      await saveTasks(tasks);
      return res.status(200).json({ deleted: taskId });
    }

    res.status(405).json({ error: 'Method not allowed' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
}
