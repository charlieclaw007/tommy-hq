# Drainova PDP Rebuild v2 — Build Report

*Executed July 16, 2026 by Claude Code from the "DRAINOVA PDP REBUILD — CLAUDE CODE BUILD BRIEF" (July 15, 2026).*

## Store verification (guardrail check)

Connected store confirmed: **Anakampsi / drainova.co** (`anakampsihealth`). NOT ai-blueprint-360. Product, variant, SKU, price all match the brief's known identifiers.

## What was built

### Preview theme (safe sandbox)
The Shopify connection in this session blocks theme-file writes to the **live** theme, so instead of writing the alternate template directly onto the live theme (brief Step 2), the live theme was **duplicated** to an unpublished copy — even safer, zero risk to production:

- Live theme (untouched): `Drainove | Shrine theme pro | OPT` — `gid://shopify/OnlineStoreTheme/165217501501`
- Preview build theme: `Drainova v2 preview (Claude build)` — `gid://shopify/OnlineStoreTheme/189719281981` (UNPUBLISHED)

### New alternate template
`templates/product.drainova-v2.json` (in this folder; also upserted to the preview theme). Composed 100% from existing Shrine section types — no custom sections needed:

| Brief section | Theme section used | Notes |
|---|---|---|
| S1 Announcement (rotating) | `horizontal-ticker` | 5 messages verbatim. NOTE: the global header ticker (header-group) still shows its own 5 old messages ("Support Gentle Detox"…) on every page — updating/hiding it is a live global change, flagged below. |
| S2 Hero / buy box | `main-product` | title, subheadline (text block), price, 3 ✓ bullets (emoji_benefits), Add To Cart (buy_buttons), "Ready to ship — arrives by [dynamic date] · 60-Day Guarantee" (estimated_shipping, 3–6 days), sticky ATC (no stars), payment badges. Gallery images inherited from the product. NO review badge. |
| S3 Mechanism | `icon-bar` (4 cards) | OPEN / MOVE / DE-PUFF / ENERGIZE with herb names + traditional-role copy verbatim, Material Symbols icons. |
| S4 Expectation timeline | `icon-bar` (3 cards) | Week 1 / Weeks 2–3 / Weeks 4–8, copy verbatim. |
| S5 Benefits grid | `icon-bar` (4 cards) | Copy verbatim. |
| S6 Ingredients | `icon-bar` (4 cards) | Reuses existing herb photos from the live page: Stillingia `6.webp`, Cleavers `7.webp`, Red Clover `5.webp`, Prickly Ash `4.webp`. |
| S6 CTA | `rich-text` | Button "Try Drainova Risk-Free" + caption "60-Day Money-Back Guarantee". |
| S7 5 Reasons | `icon-bar` (5 cards) | Copy verbatim. |
| S8 Comparison table | `comparison-table` | Heading kept from live page ("See the Difference for Yourself"). Row 1 changed to "Built on a 4-step drainage sequence"; rows 2–6 kept from the live table (Pure herbal formula / No giant capsules / Vegan-friendly / No harsh stimulants / Fulfilled in the USA). |
| Reviews slot | `custom-liquid` | Contains only `<!-- REVIEWS: pending real review app -->` per guardrail #2. |
| S9 FAQ | `collapsible-content` | Full 7-question replacement, copy verbatim. |
| S10 Guarantee | `image-with-text` | 60-day copy verbatim + existing `hand.webp` imagery. Footer FDA disclaimer untouched (footer group not modified). |

### Deliberately NOT carried over (guardrail #2 — fabricated proof on the old page)
- "Rated 4.9 'Excellent' | 736+ Reviews" badge
- Six named "Verified Buyer" testimonials (Sophia Martinez, Linda Parker, Rachel T., Patricia R., Deborah Collins, Angela Morris)
- "As Seen On: Woman's Health / WIRED / Forbes / Men's Health" ticker (present in old disabled template sections)
- "92%/89%/95% of customers…" results section (old disabled template sections)

## Preview URL (Approval Gate 1)

**https://anakampsihealth.myshopify.com/products/drainova-lymphatic-drainage-new?preview_theme_id=189719281981&view=drainova-v2**

(Also works via drainova.co with the same query string.) Review desktop + mobile. Nothing goes live until approved.

**Preview access note:** the template was verified byte-exact on the preview theme (MD5 roundtrip match), but the URL above returns **403 to anonymous/scripted requests** — Shopify requires an authenticated admin session (or a share link) to preview an unpublished theme, so HTTP-200 verification wasn't possible from this environment. To view: open the URL while logged into Shopify admin, or go to **Online Store → Themes → "Drainova v2 preview (Claude build)" → Preview**, then navigate to `/products/drainova-lymphatic-drainage-new?view=drainova-v2` (or use the theme's Share preview link).

## Go-live steps (Approval Gates 2–3 — NOT executed)

1. Copy `templates/product.drainova-v2.json` onto the **live** theme. This session's Shopify connection blocks live-theme file writes, so either: (a) paste the file via Online Store → Themes → live theme → Edit code → Add new template, or (b) approve a follow-up session with the custom-app token flow from the brief's SETUP section.
2. Set the product's template: `productUpdate` → `templateSuffix: "drainova-v2"` (currently `pf-eaed84b5`, which is the rollback value — NOT null as the brief assumed; the live page is a PageFly template).
3. SEO fields (same approval), prepared but not executed:
   - title: `Drainova Lymphatic Drainage Drops | Support Natural Fluid Balance`
   - description: `Four traditional herbs in a honey-flavored daily drop. Drainova supports your body's natural lymphatic flow and fluid balance. 60-day money-back guarantee.`
4. **Rollback**: set `templateSuffix` back to `pf-eaed84b5`.

## QA checklist results

1. **Inventory/oversell:** inventory shows 0, but the variant is **untracked** (`tracked: false`) with policy `CONTINUE` → the buy button will NOT block. ✅ No action needed.
2. **Preview renders:** template accepted by Shopify's theme validation (first upsert attempt surfaced 5 setting-range/richtext errors; fixed and re-upserted clean) and verified byte-exact on the preview theme. Anonymous HTTP check returns 403 because unpublished-theme previews require an admin session — visual desktop+mobile QA is the approval-gate step for Tommy. ⚠️ pending Tommy's eyes
3. **60-Day everywhere:** 10 "60-Day/60 day" mentions in the new template; **zero** "30-Day" strings. (The only "30" is "delivered every 30 days" — subscription cadence from the brief — and "60 days, not 30" in the timeline copy.) ✅
4. **No placeholder/lorem text, no empty blocks.** ✅ (automated check)
5. **Price:** rendered from the product record ($39.99). Subscription widget: main-product supports app blocks (`@app`) — Tommy adds the Appstle/Recharge widget block in the theme editor and configures the $31.99/20% monthly plan in the app admin. The buy box leaves room for it above the buy button. ⚠️ manual step
6. **No testimonials/review counts/expert names** anywhere in the new template. ✅ (automated check)
7. **Brand colors:** template uses the theme's own color schemes (inherited unchanged from the live Shrine theme); comparison-table checkmarks set to teal `#1F4E47`, X to charcoal `#2A2A2A`. No Anakampsi-generic copy introduced. ✅
8. **Old template untouched; `templateSuffix` unchanged** (`pf-eaed84b5`). Live theme has zero modifications. ✅

## Flags / out-of-scope follow-ups (from the brief)

- **Nav "Shop" link:** confirmed stale — Main Menu → Shop points to `/products/drainova-lymphatic-drainage` (the OLD product). Menu `gid://shopify/Menu/227315056957`. Fix via Online Store → Navigation (or a `menuUpdate` mutation on approval) to `/products/drainova-lymphatic-drainage-new`. Footer menu also still links "Smart Eye Massager" (`/products/eye-revive-pro`).
- **Global header ticker** still runs old messages ("Support Gentle Detox / Enhance Skin Radiance / …") site-wide; the old buy-box accordion and trust-badge strip on the PageFly page contain **six "30-Day guarantee" strings** — they remain live until this template ships. Worth fixing at go-live.
- **Subscription selling plan:** app admin config (Tommy), out of scope here.
- **Store-level brand identity** (Anakampsi → Drainova name/logo): follow-up, not touched.

## Files created/changed

- `projects/drainova-pdp-v2/templates/product.drainova-v2.json` (this repo) — also upserted to preview theme `189719281981`
- Shopify: new unpublished theme `Drainova v2 preview (Claude build)` (duplicate of live)
- Live theme, product record, menus, header/footer groups: **unchanged**
