export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.json({
    hasBlobToken: !!process.env.BLOB_READ_WRITE_TOKEN,
    blobTokenPrefix: process.env.BLOB_READ_WRITE_TOKEN ? process.env.BLOB_READ_WRITE_TOKEN.substring(0, 20) : null,
    hasApiKey: !!process.env.API_KEY,
    nodeEnv: process.env.NODE_ENV
  });
}
