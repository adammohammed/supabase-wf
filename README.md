# supabase-wf

Supabase-backed workflow playground with a Nix-managed dev shell and a declarative `wf` schema.

## What's inside

- **`flake.nix`** — Nix dev shell with Supabase CLI 2.122.0 and a Git credential helper for the GitHub PAT.
- **`supabase/`** — Supabase project configuration.
- **`supabase/database/wf.sql`** — Declarative schema for the `wf` schema:
  - `wf.workflows`
  - `wf.runs`
  - RLS enabled on both tables
  - `authenticated` users can read all rows via `SELECT` policies
- **`.pi/`** — (previously held a project skill; moved to `~/.pi/agent/skills/redacted-secrets`)

## Getting started

Enter the dev shell:

```bash
nix develop
```

Log in to Supabase (one-time):

```bash
supabase login
```

Link to the remote project:

```bash
supabase link --project-ref qfdrsttcqpnjwiypdvvx
```

## Schema workflow

The project uses Supabase's declarative schema support. Edit `supabase/database/wf.sql`, then sync to the remote project.

> `supabase db schema declarative sync` requires Docker/Podman for a local shadow database. If Docker is unavailable, you can apply the SQL directly:
>
> ```bash
> supabase db query --linked -f supabase/database/wf.sql
> supabase config push
> ```
>
> The direct query approach bypasses migration history generation, so prefer the Docker-based sync when possible.

### Querying the API

Tables in the `wf` schema are exposed via the Supabase Data API because `wf` is listed in `api.schemas`. Use the `Accept-Profile: wf` header:

```bash
curl https://<project-ref>.supabase.co/rest/v1/workflows \
  -H "apikey: <anon-key>" \
  -H "Authorization: Bearer <user-jwt>" \
  -H "Accept-Profile: wf" \
  -H "Accept: application/json"
```

Only authenticated users can read rows; anonymous requests are denied by RLS.

## Git authentication

The dev shell provides `git-credential-supabase-wf`, which reads the GitHub PAT from `~/.config/secrets/gh_pat`. The remote is configured to use this helper, so the PAT is not stored in `.git/config`.

```bash
cat ~/.config/secrets/gh_pat
```

## Secrets handling

A user-wide Pi skill (`redacted-secrets`) is installed at `~/.pi/agent/skills/redacted-secrets/`. It helps verify secrets without leaking them in chat output. If any Supabase API keys or GitHub PATs are ever exposed, rotate them immediately.
