# Tommy HQ — Kanban Command Center

Live at: https://tommy-hq.vercel.app

## API

Base URL: `https://tommy-hq.vercel.app/api/tasks`

All mutation requests require `X-API-Key` header. GET is public.

### GET /api/tasks
Returns all tasks as JSON array.

### POST /api/tasks
Create a new task.
```bash
curl -X POST https://tommy-hq.vercel.app/api/tasks \
  -H "X-API-Key: YOUR_KEY" \
  -H "Content-Type: application/json" \
  -d '{"title":"Do the thing","agent":"neo","priority":"high","status":"todo"}'
```

Fields: `title` (required), `agent` (charlie|neo|drago|happy), `priority` (high|medium|low), `status` (todo|in-progress|review|done)

### PUT /api/tasks
Update a task (move columns, change title, etc).
```bash
curl -X PUT https://tommy-hq.vercel.app/api/tasks \
  -H "X-API-Key: YOUR_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"abc123","status":"done"}'
```

### DELETE /api/tasks
Delete a task.
```bash
curl -X DELETE https://tommy-hq.vercel.app/api/tasks \
  -H "X-API-Key: YOUR_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"abc123"}'
```

## Helper Script
```bash
./scripts/add-task.sh "Task title" neo high todo
```

## Stack
- Static HTML frontend (dark futuristic UI)
- Vercel Serverless Functions (api/)
- Vercel Blob Storage (persistence)
- API key auth for mutations
