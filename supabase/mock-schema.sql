begin;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 40),
  avatar text not null default '🌿', city text not null default '',
  date_range text not null default '', interests text[] not null default '{}',
  pace text not null default '适中', intro text not null default '' check (char_length(intro) <= 500),
  verified boolean not null default false, is_public boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.trips (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id),
  city text not null, date_range text not null default '', timezone text not null default 'Asia/Shanghai',
  budget numeric(12,2) not null default 0 check (budget >= 0),
  currency text not null default 'CNY' check (currency ~ '^[A-Z]{3}$'),
  cover_emoji text not null default '🧳', status text not null default 'draft' check (status in ('draft','saved')),
  is_private boolean not null default true, version integer not null default 1 check (version > 0),
  created_at timestamptz not null default now()
);

create table public.trip_days (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  date date, label text not null default '', sort_order integer not null check (sort_order >= 0),
  unique(trip_id, sort_order), unique(trip_id, date),
  created_at timestamptz not null default now()
);

create table public.trip_items (
  id uuid primary key default gen_random_uuid(),
  day_id uuid not null references public.trip_days(id) on delete cascade,
  time time, end_time time, title text not null, area text not null default '',
  duration text not null default '', transport text, cost numeric(12,2) check (cost >= 0),
  locked boolean not null default false, pending_verification boolean not null default true,
  sort_order integer not null check (sort_order >= 0), unique(day_id, sort_order),
  created_at timestamptz not null default now()
);

create table public.activities (
  id uuid primary key default gen_random_uuid(),
  organizer_id uuid not null references public.profiles(id),
  title text not null check (char_length(title) between 2 and 100), city text not null, category text not null,
  starts_at timestamptz not null, ends_at timestamptz not null,
  meetup_area text not null, description text not null default '',
  capacity integer not null check (capacity between 2 and 6), cost_policy text not null default '',
  status text not null default 'open' check (status in ('open','full','cancelled','completed')),
  tags text[] not null default '{}', check (starts_at < ends_at),
  created_at timestamptz not null default now()
);

create table public.activity_applications (
  id uuid primary key default gen_random_uuid(),
  activity_id uuid not null references public.activities(id) on delete cascade,
  applicant_id uuid not null references public.profiles(id),
  status text not null default 'pending' check (status in ('pending','approved','confirmed','rejected','withdrawn','expired')),
  intro text not null default '', reviewed_at timestamptz, confirmed_at timestamptz,
  unique(activity_id, applicant_id),
  created_at timestamptz not null default now()
);

create table public.teams (
  id uuid primary key default gen_random_uuid(),
  activity_id uuid not null unique references public.activities(id) on delete cascade,
  leader_id uuid not null references public.profiles(id), meetup_detail text not null default '',
  created_at timestamptz not null default now()
);

create table public.team_members (
  team_id uuid not null references public.teams(id) on delete cascade,
  user_id uuid not null references public.profiles(id),
  role text not null default 'member' check (role in ('leader','member')),
  joined_at timestamptz not null default now(), left_at timestamptz,
  primary key(team_id,user_id),
  created_at timestamptz not null default now()
);

create table public.team_messages (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams(id) on delete cascade,
  sender_id uuid references public.profiles(id), body text not null check (char_length(body) between 1 and 2000),
  is_system boolean not null default false, client_nonce uuid not null default gen_random_uuid(),
  check ((is_system and sender_id is null) or (not is_system and sender_id is not null)),
  unique(team_id,sender_id,client_nonce),
  created_at timestamptz not null default now()
);

create table public.team_proposals (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams(id) on delete cascade,
  proposer_id uuid not null references public.profiles(id),
  title text not null, before_text text not null, after_text text not null,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  resolved_by uuid references public.profiles(id), resolved_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id), title text not null,
  city text not null, cover_emoji text not null default '🏞️', summary text not null default '',
  places text[] not null default '{}',
  status text not null default 'draft' check (status in ('draft','published','archived')),
  created_at timestamptz not null default now()
);

create table public.post_bookmarks (
  user_id uuid not null references public.profiles(id),
  post_id uuid not null references public.posts(id) on delete cascade, primary key(user_id,post_id),
  created_at timestamptz not null default now()
);

create schema if not exists gogo_private;
revoke all on schema gogo_private from public, anon, authenticated;
grant usage on schema gogo_private to authenticated;

create function gogo_private.is_member(target_team uuid)
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.team_members
    where team_id = target_team and user_id = auth.uid() and left_at is null
  );
$$;
revoke all on function gogo_private.is_member(uuid) from public, anon;
grant execute on function gogo_private.is_member(uuid) to authenticated;

alter table public.profiles enable row level security;
revoke all on public.profiles from public, anon, authenticated;
grant all on public.profiles to service_role;
alter table public.trips enable row level security;
revoke all on public.trips from public, anon, authenticated;
grant all on public.trips to service_role;
alter table public.trip_days enable row level security;
revoke all on public.trip_days from public, anon, authenticated;
grant all on public.trip_days to service_role;
alter table public.trip_items enable row level security;
revoke all on public.trip_items from public, anon, authenticated;
grant all on public.trip_items to service_role;
alter table public.activities enable row level security;
revoke all on public.activities from public, anon, authenticated;
grant all on public.activities to service_role;
alter table public.activity_applications enable row level security;
revoke all on public.activity_applications from public, anon, authenticated;
grant all on public.activity_applications to service_role;
alter table public.teams enable row level security;
revoke all on public.teams from public, anon, authenticated;
grant all on public.teams to service_role;
alter table public.team_members enable row level security;
revoke all on public.team_members from public, anon, authenticated;
grant all on public.team_members to service_role;
alter table public.team_messages enable row level security;
revoke all on public.team_messages from public, anon, authenticated;
grant all on public.team_messages to service_role;
alter table public.team_proposals enable row level security;
revoke all on public.team_proposals from public, anon, authenticated;
grant all on public.team_proposals to service_role;
alter table public.posts enable row level security;
revoke all on public.posts from public, anon, authenticated;
grant all on public.posts to service_role;
alter table public.post_bookmarks enable row level security;
revoke all on public.post_bookmarks from public, anon, authenticated;
grant all on public.post_bookmarks to service_role;

grant select on public.profiles, public.activities, public.posts to anon, authenticated;
grant insert(id,name,avatar,city,date_range,interests,pace,intro,is_public) on public.profiles to authenticated;
grant update(name,avatar,city,date_range,interests,pace,intro,is_public) on public.profiles to authenticated;
create policy profiles_read on public.profiles for select using (id = auth.uid() or is_public);
create policy profiles_insert on public.profiles for insert to authenticated with check (id = auth.uid() and not verified);
create policy profiles_update on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

grant select,insert,update,delete on public.trips, public.trip_days, public.trip_items to authenticated;
create policy trips_owner on public.trips for all to authenticated using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy days_owner on public.trip_days for all to authenticated
using (exists(select 1 from public.trips where id = trip_id and owner_id = auth.uid()))
with check (exists(select 1 from public.trips where id = trip_id and owner_id = auth.uid()));
create policy items_owner on public.trip_items for all to authenticated
using (exists(select 1 from public.trip_days where id = day_id))
with check (exists(select 1 from public.trip_days where id = day_id));

create policy activities_public on public.activities for select using (status in ('open','full','completed') or organizer_id = auth.uid());
grant select on public.activity_applications, public.teams, public.team_members, public.team_messages, public.team_proposals to authenticated;
create policy applications_read on public.activity_applications for select to authenticated
using (applicant_id = auth.uid() or exists(select 1 from public.activities where id = activity_id and organizer_id = auth.uid()));
create policy teams_read on public.teams for select to authenticated using (gogo_private.is_member(id));
create policy members_read on public.team_members for select to authenticated using (gogo_private.is_member(team_id));
create policy messages_read on public.team_messages for select to authenticated using (gogo_private.is_member(team_id));
create policy proposals_read on public.team_proposals for select to authenticated using (gogo_private.is_member(team_id));

grant insert(team_id,sender_id,body,client_nonce) on public.team_messages to authenticated;
create policy messages_insert on public.team_messages for insert to authenticated
with check (sender_id = auth.uid() and not is_system and gogo_private.is_member(team_id));
grant insert(team_id,proposer_id,title,before_text,after_text) on public.team_proposals to authenticated;
create policy proposals_insert on public.team_proposals for insert to authenticated
with check (proposer_id = auth.uid() and status = 'pending' and resolved_by is null and resolved_at is null and gogo_private.is_member(team_id));

create policy posts_read on public.posts for select using (status = 'published' or author_id = auth.uid());
grant insert(author_id,title,city,cover_emoji,summary,places), update(title,city,cover_emoji,summary,places), delete on public.posts to authenticated;
create policy posts_insert on public.posts for insert to authenticated with check (author_id = auth.uid() and status = 'draft');
create policy posts_update on public.posts for update to authenticated using (author_id = auth.uid() and status = 'draft') with check (author_id = auth.uid() and status = 'draft');
create policy posts_delete on public.posts for delete to authenticated using (author_id = auth.uid());
grant select,insert,delete on public.post_bookmarks to authenticated;
create policy bookmarks_read on public.post_bookmarks for select to authenticated using (user_id = auth.uid());
create policy bookmarks_insert on public.post_bookmarks for insert to authenticated with check (
user_id = auth.uid() and exists(select 1 from public.posts where id = post_id and status = 'published'));
create policy bookmarks_delete on public.post_bookmarks for delete to authenticated using (user_id = auth.uid());

create index trips_owner_idx on public.trips(owner_id);
create index activities_city_time_idx on public.activities(city,starts_at);
create index activities_organizer_idx on public.activities(organizer_id);
create index applications_user_idx on public.activity_applications(applicant_id);
create index members_user_idx on public.team_members(user_id);
create index messages_team_time_idx on public.team_messages(team_id,created_at,id);
create index proposals_team_idx on public.team_proposals(team_id);
create index posts_city_status_idx on public.posts(city,status);
create index posts_author_idx on public.posts(author_id);
create index bookmarks_post_idx on public.post_bookmarks(post_id);

notify pgrst, 'reload schema';
commit;

select tablename, rowsecurity from pg_tables
where schemaname = 'public' and tablename in (
'profiles', 'trips', 'trip_days', 'trip_items', 'activities', 'activity_applications', 'teams', 'team_members', 'team_messages', 'team_proposals', 'posts', 'post_bookmarks'
) order by tablename;
