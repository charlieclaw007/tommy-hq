# Tommy HQ — Kanban Board

## What to Build
A single-page kanban board web app. Static HTML/CSS/JS — no framework needed. Must be deployable to Vercel as a static site.

## Design
- **DARK futuristic UI** — deep blacks (#0a0a0f), dark grays (#12121a)
- **OpenClaw brand colors:** coral-red (#ff6b6b) and cyan-teal (#00d4aa) as accent colors
- **Glowing effects** — subtle neon glow on cards, borders, and headers using the brand colors
- **Font:** Use Inter or system fonts. Clean, modern.
- **Vibe:** Think sci-fi command center / AI dashboard. Sleek, minimal, powerful.

## Structure
- **4 columns:** To Do → In Progress → Review → Done
- **4 agent tabs/filters at the top:**
  - 🚀 Charlie (Main/Super Agent)
  - 🕶️ Neo (Dropshipping)
  - 🥊 Drago (KYVO Performance)
  - ⛳ Happy (@casualgolfdad)
  - Plus an "All" view that shows everything
- Each card shows: task title, agent badge, priority (low/med/high), date added
- Cards are color-coded by agent (each agent gets a subtle accent color variation)
- **Drag and drop** cards between columns

## Features (v1)
- Add new task (modal or inline) — pick agent, title, priority
- Drag and drop between columns
- Filter by agent tab
- Delete task (small X or swipe)
- Data persists in localStorage (no backend needed for v1)
- Responsive — works on mobile too
- Subtle animations on card hover and column transitions

## Pre-populated Tasks
Add these real tasks to demonstrate:

### Charlie (Main)
- "Connect Meta Ads account" — In Progress, High
- "Set up 5 AM morning brief cron" — To Do, Medium
- "Build Kanban board (this!)" — In Progress, High

### Neo (Dropshipping)
- "Run pipeline test with fixed sub-agents" — In Progress, High
- "Veloura advertorial + landing page" — To Do, High
- "Find 3 new winning products" — To Do, Medium
- "RestCalm — monitor test results" — Review, Medium

### Drago (KYVO)
- "Finalize gummy formulation R&D" — In Progress, High
- "Build early access landing page" — To Do, Medium
- "Competitor analysis — top 5 golf supplement brands" — To Do, Medium

### Happy (Golf)
- "Plan next week's content calendar" — To Do, Medium
- "Research equipment sponsorship targets" — To Do, Low
- "Genesis Invitational recap content" — To Do, High

## File Structure
Keep it simple:
- index.html (single file with inline CSS and JS is fine, or separate files)
- vercel.json (if needed)
- package.json (minimal, for Vercel deploy)

## Important
- NO frameworks (React, Vue, etc.) — vanilla HTML/CSS/JS only
- Must look INCREDIBLE. This is a showcase piece.
- Smooth 60fps animations
- The glow effects should be subtle, not overwhelming
- Mobile responsive
