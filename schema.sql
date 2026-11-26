-- Run in Supabase: SQL Editor > New query > paste all > Run
create table public.citizens (
  id bigint generated always as identity primary key,
  name text not null check (char_length(name) <= 100),
  mobile text not null check (char_length(mobile) = 10),
  email text not null check (char_length(email) <= 200),
  consent boolean not null check (consent),
  created_at timestamptz default now()
);
alter table public.citizens enable row level security;
-- Website visitors can only ADD a row. Nobody can read them from the website; you read them in Table Editor.
create policy "visitors can register" on public.citizens for insert to anon with check (true);
