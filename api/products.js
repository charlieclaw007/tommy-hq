// Products & Ad Batches API — GitHub-backed JSON storage
const REPO = 'charlieclaw007/tommy-hq';
const FILE = 'data/products.json';
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
  const body = { message: 'data: update products', content, branch: 'main' };
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
  return Math.random().toString(36).slice(2, 10) + Date.now().toString(36);
}

export default async function handler(req, res) {
  cors(res);
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'GET' && !auth(req)) return res.status(401).json({ error: 'Invalid API key' });

  try {
    if (req.method === 'GET') {
      const { data } = await readData();
      return res.status(200).json(data);
    }

    if (req.method === 'POST') {
      // Create or update a product + add/replace a batch
      // Body: { id?, name, subtitle, status, stage, storeUrl, notes, batch? }
      // batch: { name, concept, batchStatus, copy: { hook, body1, body2, headline1, headline2 } }
      const { data, sha } = await readData();
      const { id, name, subtitle, status, stage, storeUrl, notes, batch } = req.body;
      if (!name) return res.status(400).json({ error: 'name required' });

      let productId = id;
      let product = data.find(p => p.id === productId || p.name.toLowerCase() === name.toLowerCase());

      if (product) {
        // Update existing product
        Object.assign(product, {
          name: name || product.name,
          subtitle: subtitle || product.subtitle,
          status: status || product.status,
          stage: stage !== undefined ? stage : product.stage,
          storeUrl: storeUrl || product.storeUrl,
          notes: notes !== undefined ? notes : product.notes,
          updatedAt: new Date().toISOString(),
        });
        if (batch) {
          if (!product.batches) product.batches = [];
          const existingBatch = product.batches.find(b => b.name === batch.name);
          if (existingBatch) {
            Object.assign(existingBatch, batch);
          } else {
            product.batches.push({ id: genId(), ...batch });
          }
        }
      } else {
        // Create new product
        product = {
          id: id || genId(),
          name, subtitle: subtitle || '',
          status: status || 'BUILDING',
          stage: stage !== undefined ? stage : 0,
          storeUrl: storeUrl || '',
          notes: notes || '',
          batches: batch ? [{ id: genId(), ...batch }] : [],
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        };
        data.unshift(product);
      }

      await writeData(data, sha);
      return res.status(201).json(product);
    }

    if (req.method === 'PUT') {
      const { id, ...updates } = req.body;
      if (!id) return res.status(400).json({ error: 'id required' });
      const { data, sha } = await readData();
      const product = data.find(p => p.id === id);
      if (!product) return res.status(404).json({ error: 'product not found' });
      Object.assign(product, updates, { id, updatedAt: new Date().toISOString() });
      await writeData(data, sha);
      return res.status(200).json(product);
    }

    if (req.method === 'DELETE') {
      const { id } = req.body;
      if (!id) return res.status(400).json({ error: 'id required' });
      const { data, sha } = await readData();
      const filtered = data.filter(p => p.id !== id);
      await writeData(filtered, sha);
      return res.status(200).json({ deleted: id });
    }

    return res.status(405).json({ error: 'Method not allowed' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
