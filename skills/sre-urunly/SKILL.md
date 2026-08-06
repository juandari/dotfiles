---
name: sre-urunly
description: Use whenever operating on the live Urunly Contabo VPS (Germany, or Singapore post-migration) — diagnosing incidents, checking deploy health, inspecting Coolify/Traefik/Postgres/MinIO, or investigating "the site is down / slow / erroring" type reports. Also load before any migration or infra-topology work on this box.
---

# Urunly VPS — SRE Reference

Static facts about the production topology so you don't have to
re-derive them from scratch every session. Verify anything time-sensitive
(container status, DNS, secrets) live — this file describes shape, not
current state.

## Stack topology

- **Orchestration**: Coolify (self-hosted PaaS), version `4.1.2` at last
  check. Coolify itself runs as containers: `coolify`, `coolify-db`
  (postgres:15-alpine), `coolify-redis`, `coolify-realtime`,
  `coolify-proxy` (Traefik v3), `coolify-sentinel`.
- **Apps** (both deployed from `juandari/juandari-monorepo`, branch `main`,
  container names are Coolify-generated hashes — use `docker ps` to
  resolve current names, don't hardcode them):
  - `split-bill-api` — Go 1.26 + htmx + Tailwind, port 8080, public at
    `https://urunly.com`
  - `split-bill-auth` — Hono + Better Auth, port 3005, public at
    `https://auth.urunly.com`
- **Database**: Coolify-managed Postgres (`postgres:16-alpine` on the
  Germany box), internal network only, no public port. DB user/name both
  `splitbill`. Both apps share this one DB.
- **Object storage**: MinIO, buckets `split-bill-uploads` and
  `split-bill-backups`.
- **DNS**: Cloudflare, both `urunly.com` and `auth.urunly.com` are
  **proxied (orange-cloud)** — public A records resolve to Cloudflare
  anycast IPs, not the origin VPS IP directly.
- **Firewall**: `ufw` is inactive by default on these boxes — Coolify
  manages its own Traefik/iptables rules. Don't assume `ufw` rules are
  the reason something is blocked/open.

## Gotchas (found the hard way)

- **GitHub source is a GitHub App, not a deploy key.** Coolify's git
  connection to the (private) `juandari-monorepo` repo goes through a
  custom-registered GitHub App named `juandari`, not SSH. If Coolify
  can't see the repo, check the GitHub App installation/webhook config
  before assuming it's an SSH key problem.
- **`WEB_SESSION_SECRET`** (split-bill-api) **and `BETTER_AUTH_SECRET`**
  (split-bill-auth) are intentionally set to the **same value** — the two
  services interoperate on session/JWT signing. Don't rotate one without
  the other.
- **Auth flow**: split-bill-api validates JWTs against
  `AUTH_JWKS_URL=https://auth.urunly.com/api/auth/jwks`. If sign-in breaks
  but auth.urunly.com itself looks healthy, check the JWKS endpoint
  returns 200 first.
- **Go migrations run automatically** at split-bill-api boot via an
  advisory lock (`schema_migrations` table). A container that crash-loops
  on startup may mean a previous crashed run left the lock held — check
  that table before assuming it's a code bug.
- **Migration/backup snapshots**, when taken, live in
  `/root/urunly-migration-secrets/` on whichever VPS is current — kept
  deliberately **outside** the git repo (never commit secrets there).

## Standard diagnostic runbook

Read-only checks, safe to run anytime:

```bash
# Container health at a glance
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'

# Recent logs for a suspect container
docker logs --tail 200 -f <container_name>

# App-level health
curl -I https://urunly.com/
curl -I https://auth.urunly.com/api/auth/jwks

# DB reachability + migration lock state (read-only)
docker exec <postgres_container> psql -U splitbill -d splitbill -c \
  "SELECT * FROM schema_migrations ORDER BY version DESC LIMIT 5;"

# Full env vars for a running app container (careful: prints secrets to
# your terminal/context — don't paste output into shared/logged channels)
docker inspect <container_name> --format '{{range .Config.Env}}{{println .}}{{end}}'
```

## What NOT to do without explicit user go-ahead

This is a live production box serving real traffic. Treat these as
requiring explicit confirmation each time, not something to run because a
runbook step suggested it:

- Restarting/recreating containers (`docker restart`, `docker compose up
  -d --force-recreate`, redeploying via Coolify)
- Any DB write, migration rollback, or `DELETE`/`UPDATE`/`DROP`
- Rotating or regenerating secrets (`BETTER_AUTH_SECRET`,
  `WEB_SESSION_SECRET`, `ADMIN_SECRET`, MinIO keys, Midtrans/Resend/Mistral
  keys)
- DNS changes in Cloudflare
- `ufw` / firewall rule changes
- Anything under `deploy/MIGRATION_SINGAPORE.md` beyond read-only survey —
  see that doc and `.claude/plans/PLAN-migrate-singapore.md` inside the
  `juandari-monorepo` checkout for the actual migration sequencing (locate
  the checkout with `find / -maxdepth 3 -iname juandari-monorepo
  2>/dev/null` if it's not at the usual `~/juandari-monorepo`).

Diagnose, report findings, propose the fix — then stop and ask before
acting on anything in the list above.
