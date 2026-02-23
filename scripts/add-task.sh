#!/bin/bash
# Add a task to Tommy HQ Kanban
# Usage: ./add-task.sh "Task title" [agent] [priority] [status]
#   agent: charlie|neo|drago|happy (default: charlie)
#   priority: high|medium|low (default: medium)
#   status: todo|in-progress|review|done (default: todo)

API_URL="https://tommy-hq.vercel.app/api/tasks"
API_KEY="thq_25741469f31452628a1d8ae7372155ef2a2bf0b7d0138d96"

TITLE="${1:?Usage: add-task.sh \"title\" [agent] [priority] [status]}"
AGENT="${2:-charlie}"
PRIORITY="${3:-medium}"
STATUS="${4:-todo}"

curl -s -X POST "$API_URL" \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"title\":\"$TITLE\",\"agent\":\"$AGENT\",\"priority\":\"$PRIORITY\",\"status\":\"$STATUS\"}"

echo ""
