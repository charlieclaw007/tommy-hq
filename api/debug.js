import { put, list } from '@vercel/blob';

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  
  try {
    // Check if token exists
    const hasToken = !!process.env.BLOB_READ_WRITE_TOKEN;
    const tokenPrefix = process.env.BLOB_READ_WRITE_TOKEN ? process.env.BLOB_READ_WRITE_TOKEN.slice(0, 20) : 'NONE';
    
    // Try to write
    const blob = await put('debug-test.txt', 'hello ' + Date.now(), {
      access: 'public',
      addRandomSuffix: false,
    });
    
    // Try to list
    const { blobs } = await list();
    
    return res.status(200).json({
      hasToken,
      tokenPrefix,
      writtenBlob: blob.url,
      allBlobs: blobs.map(b => ({ pathname: b.pathname, url: b.url.slice(0, 80) })),
    });
  } catch (err) {
    return res.status(500).json({ error: err.message, stack: err.stack });
  }
}
