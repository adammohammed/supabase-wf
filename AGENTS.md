# Agent instructions for supabase-wf

## Project overview

This is a Supabase-backed workflow playground. It uses:

- Nix for the dev shell (`flake.nix`)
- Supabase CLI for local/remote database management
- Declarative schema under `supabase/database/`
- A custom `wf` schema for all workflow-related tables (do not use `public` for app tables)

## Critical conventions

1. **Always run commands inside `nix develop`.** The dev shell provides the patched Supabase CLI 2.122.0.
2. **Do not put app tables in the `public` schema.** Use the `wf` schema.
3. **Enable RLS on every table.** Add explicit policies; do not rely on default grants.

## Common commands

```bash
# Enter dev shell
nix develop

# Verify login and link
supabase projects list
supabase link --project-ref <your-project-ref>

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
- `flake.nix` — dev shell with Supabase CLI

## Testing API access

When testing the Data API for `wf` tables, use the `Accept-Profile: wf` header:

```bash
curl https://<project-ref>.supabase.co/rest/v1/workflows \
  -H "apikey: <REDACTED>" \
  -H "Authorization: Bearer <REDACTED>" \
  -H "Accept-Profile: wf"
```

Anon requests should be denied; authenticated requests should return `[]` until rows are inserted.
