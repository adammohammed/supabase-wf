create schema if not exists wf;

grant usage on schema wf to anon, authenticated;

create table wf.workflows (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table wf.workflows is 'Example workflow definitions.';

alter table wf.workflows enable row level security;

create policy "authenticated users can view workflows"
  on wf.workflows
  for select
  to authenticated
  using (true);

create table wf.runs (
  id uuid primary key default gen_random_uuid(),
  workflow_id uuid not null references wf.workflows (id) on delete cascade,
  status text not null default 'pending',
  started_at timestamptz not null default now(),
  finished_at timestamptz
);

comment on table wf.runs is 'Example workflow runs.';

alter table wf.runs enable row level security;

create policy "authenticated users can view runs"
  on wf.runs
  for select
  to authenticated
  using (true);

grant select on all tables in schema wf to authenticated;
alter default privileges in schema wf grant select on tables to authenticated;
