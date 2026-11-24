-- Run in Supabase: SQL Editor > New query > paste all > Run
create table public.profiles (
  id uuid primary key references auth.users on delete cascade,
  name text, mobile text,
  user_type text not null default 'cit' check (user_type in ('cit','pro','stu')),
  category text,
  created_at timestamptz default now()
);
alter table public.profiles enable row level security;
create policy "read own profile" on public.profiles for select using (auth.uid() = id);

create function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, name, mobile, user_type, category)
  values (new.id, new.raw_user_meta_data->>'name', new.raw_user_meta_data->>'mobile',
    case when new.raw_user_meta_data->>'user_type' in ('pro','stu') then new.raw_user_meta_data->>'user_type' else 'cit' end,
    new.raw_user_meta_data->>'category');
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users
for each row execute function public.handle_new_user();

create table public.feedback (
  id bigint generated always as identity primary key,
  user_id uuid default auth.uid(),
  kind text, name text, email text,
  message text not null check (char_length(message) <= 2000),
  created_at timestamptz default now()
);
alter table public.feedback enable row level security;
create policy "anyone can send feedback" on public.feedback for insert to anon, authenticated with check (true);
-- Only you (project owner) can read feedback, in Table Editor.
