import { put, list, del } from '@vercel/blob';

const BLOB_KEY = 'tasks.json';

function cors(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-API-Key');
}

function auth(req) {
  const key = req.headers['x-api-key'];
  return key === process.env.API_KEY;
}

async function getTasks() {
  try {
    const { blobs } = await list({ prefix: BLOB_KEY });
    if (blobs.length === 0) return [];
    const res = await fetch(blobs[0].url);
    return await res.json();
  } catch {
    return [];
  }
}

async function saveTasks(tasks) {
  // Delete old blob first
  try {
    const { blobs } = await list({ prefix: BLOB_KEY });
    for (const b of blobs) await del(b.url);
  } catch {}
  await put(BLOB_KEY, JSON.stringify(tasks), {
    access: 'public',
    contentType: 'application/json',
    addRandomSuffix: false,
  });
}

function id() {
  return Math.random().toString(36).slice(2, 10);
}

export default async function handler(req, res) {
  cors(res);
  if (req.method === 'OPTIONS') return res.status(200).end();

  // GET is public (frontend needs it), mutations need auth
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
        id: id(),
        title,
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
