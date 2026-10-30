# Agent instructions for supabase-wf

## Project overview

This is a Supabase-backed workflow playground. It uses:

- Nix for the dev shell (`flake.nix`)
- Supabase CLI for local/remote database management
- Declarative schema under `supabase/database/`
- A custom `wf` schema for all workflow-related tables (do not use `public` for app tables)

## Critical conventions

1. **Always run commands inside `nix develop`.** The dev shell provides the patched Supabase CLI 2.122.0 and the Git credential helper.
2. **Do not put app tables in the `public` schema.** Use the `wf` schema.
3. **Enable RLS on every table.** Add explicit policies; do not rely on default grants.
4. **Do not expose secrets in chat output.** API keys, bearer tokens, JWTs, passwords, connection strings, and PATs must be redacted with `<REDACTED>` or safe prefixes. If a secret is accidentally exposed, tell the user to rotate it.
5. **The GitHub PAT lives at `~/.config/secrets/gh_pat`.** Do not copy it to other files. The git remote uses `git-credential-supabase-wf` to read it at runtime.

## Common commands

```bash
# Enter dev shell
nix develop

# Verify login and link
supabase projects list
supabase link --project-ref qfdrsttcqpnjwiypdvvx

# Apply schema directly (Docker-free workaround)
supabase db query --linked -f supabase/database/wf.sql
supabase config push

# Preferred path when Docker is available
supabase db schema declarative sync --schema wf

# Check the remote schema
supabase db query --linked "select schemaname, tablename from pg_tables where schemaname = 'wf';"
```

## Files to know

- `supabase/config.toml` — project config; `api.schemas` includes `wf`
- `supabase/database/wf.sql` — declarative schema for the `wf` schema
- `flake.nix` — dev shell with Supabase CLI and git credential helper
- `~/.pi/agent/skills/redacted-secrets/` — user-wide skill for safe secret handling

## Testing API access

When testing the Data API for `wf` tables, use the `Accept-Profile: wf` header:

```bash
curl https://qfdrsttcqpnjwiypdvvx.supabase.co/rest/v1/workflows \
  -H "apikey: <REDACTED>" \
  -H "Authorization: Bearer <REDACTED>" \
  -H "Accept-Profile: wf"
```

Anon requests should be denied; authenticated requests should return `[]` until rows are inserted.
