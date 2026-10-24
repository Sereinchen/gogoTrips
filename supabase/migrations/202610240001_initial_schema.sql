begin;

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (char_length(display_name) between 1 and 40),
  avatar_path text,
  about text not null default '' check (char_length(about) <= 500),
  interest_tags text[] not null default '{}',
  travel_pace text not null default '适中' check (travel_pace in ('松弛慢游', '适中', '活力探索')),
  companion_eligible boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.travel_intents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  destination_city text not null,
  start_date date not null,
  end_date date not null,
  availability text not null default '',
  interest_tags text[] not null default '{}',
  public_note text not null default '' check (char_length(public_note) <= 500),
  visibility text not null default 'private' check (visibility in ('private', 'public')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (start_date <= end_date)
);

create table if not exists public.trips (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  destination_city text not null,
  starts_on date not null,
  ends_on date not null,
  timezone text not null default 'Asia/Shanghai',
  budget_currency char(3) not null default 'CNY',
  budget_limit numeric(12,2) check (budget_limit is null or budget_limit >= 0),
  visibility text not null default 'private' check (visibility in ('private', 'shared')),
  status text not null default 'draft' check (status in ('draft', 'saved', 'archived')),
  version integer not null default 1 check (version > 0),
  source_post_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (starts_on <= ends_on)
);

create table if not exists public.trip_items (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  day_date date not null,
  sort_order integer not null default 0 check (sort_order >= 0),
  place_provider_id text,
  place_name text not null,
  latitude numeric(9,6),
  longitude numeric(9,6),
  starts_at timestamptz,
  ends_at timestamptz,
  estimated_cost numeric(12,2) check (estimated_cost is null or estimated_cost >= 0),
  cost_currency char(3) not null default 'CNY',
  locked boolean not null default false,
  pending_verification boolean not null default false,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  check (starts_at is null or ends_at is null or starts_at < ends_at),
  check (latitude is null or latitude between -90 and 90),
  check (longitude is null or longitude between -180 and 180),
  unique (trip_id, day_date, sort_order)
);

create table if not exists public.trip_versions (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  version integer not null check (version > 0),
  snapshot jsonb not null,
  created_by uuid not null references public.profiles(id) on delete restrict,
  created_at timestamptz not null default now(),
  unique (trip_id, version)
);

create table if not exists public.activities (
  id uuid primary key default gen_random_uuid(),
  organizer_id uuid not null references public.profiles(id) on delete restrict,
  trip_id uuid references public.trips(id) on delete set null,
  title text not null check (char_length(title) between 2 and 80),
  city text not null,
  category text not null,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  meetup_area text not null check (char_length(meetup_area) <= 120),
  description text not null default '' check (char_length(description) <= 2000),
  capacity integer not null check (capacity between 2 and 6),
  cost_policy text not null default '' check (char_length(cost_policy) <= 500),
  status text not null default 'open' check (status in ('draft', 'open', 'full', 'cancelled', 'completed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (starts_at < ends_at)
);

create table if not exists public.activity_private_details (
  activity_id uuid primary key references public.activities(id) on delete cascade,
  meetup_detail text not null default '',
  organizer_note text not null default '',
  updated_at timestamptz not null default now()
);

create table if not exists public.activity_applications (
  id uuid primary key default gen_random_uuid(),
  activity_id uuid not null references public.activities(id) on delete cascade,
  applicant_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected', 'confirmed', 'withdrawn')),
  intro text not null default '' check (char_length(intro) <= 500),
  reviewed_by uuid references public.profiles(id) on delete set null,
  reviewed_at timestamptz,
  confirmed_at timestamptz,
  created_at timestamptz not null default now(),
  unique (activity_id, applicant_id)
);

create table if not exists public.teams (
  id uuid primary key default gen_random_uuid(),
  activity_id uuid not null unique references public.activities(id) on delete cascade,
  leader_id uuid not null references public.profiles(id) on delete restrict,
  created_at timestamptz not null default now()
);

create table if not exists public.team_members (
  team_id uuid not null references public.teams(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null default 'member' check (role in ('leader', 'member')),
  joined_at timestamptz not null default now(),
  left_at timestamptz,
  primary key (team_id, user_id)
);

create table if not exists public.team_messages (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete restrict,
  body text not null check (char_length(body) between 1 and 2000),
  client_nonce text,
  created_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (sender_id, client_nonce)
);

create table if not exists public.team_proposals (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams(id) on delete cascade,
  proposer_id uuid not null references public.profiles(id) on delete restrict,
  proposal jsonb not null,
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  resolved_by uuid references public.profiles(id) on delete set null,
  resolved_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete restrict,
  title text not null check (char_length(title) between 2 and 120),
  body text not null default '',
  summary text not null default '' check (char_length(summary) <= 500),
  city text not null,
  cover_path text,
  status text not null default 'draft' check (status in ('draft', 'review', 'published', 'archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.trips drop constraint if exists trips_source_post_id_fkey;
alter table public.trips add constraint trips_source_post_id_fkey foreign key (source_post_id) references public.posts(id) on delete set null;

create table if not exists public.post_places (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  place_id text,
  place_name text not null,
  sort_order integer not null default 0 check (sort_order >= 0),
  unique (post_id, sort_order)
);

create table if not exists public.post_bookmarks (
  user_id uuid not null references public.profiles(id) on delete cascade,
  post_id uuid not null references public.posts(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, post_id)
);

create table if not exists public.blocks (
  blocker_id uuid not null references public.profiles(id) on delete cascade,
  blocked_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  target_type text not null check (target_type in ('profile', 'activity', 'post', 'message')),
  target_id uuid not null,
  reason text not null check (char_length(reason) between 2 and 500),
  status text not null default 'pending' check (status in ('pending', 'reviewing', 'resolved', 'dismissed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  kind text not null,
  payload jsonb not null default '{}'::jsonb,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists travel_intents_search_idx on public.travel_intents (destination_city, start_date, end_date) where visibility = 'public';
create index if not exists trips_owner_idx on public.trips (owner_id, created_at desc);
create index if not exists trip_items_trip_idx on public.trip_items (trip_id, day_date, sort_order);
create index if not exists activities_search_idx on public.activities (city, starts_at, status);
create index if not exists activity_applications_applicant_idx on public.activity_applications (applicant_id, status, created_at desc);
create index if not exists activity_applications_activity_idx on public.activity_applications (activity_id, status);
create index if not exists team_members_user_idx on public.team_members (user_id, left_at);
create index if not exists team_messages_team_idx on public.team_messages (team_id, created_at desc);
create index if not exists posts_feed_idx on public.posts (status, city, created_at desc);
create index if not exists notifications_user_idx on public.notifications (user_id, created_at desc);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name, avatar_path)
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data ->> 'display_name', ''), '旅行者'),
    new.raw_user_meta_data ->> 'avatar_url'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();

create or replace function public.protect_profile_privileges()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.id <> old.id then
    raise exception 'profile id cannot be changed';
  end if;
  if new.companion_eligible is distinct from old.companion_eligible
    and current_user not in ('postgres', 'supabase_admin')
    and coalesce(auth.role(), '') <> 'service_role' then
    raise exception 'companion eligibility requires a trusted verification flow';
  end if;
  return new;
end;
$$;

drop trigger if exists protect_profile_privileges on public.profiles;
create trigger protect_profile_privileges before update on public.profiles for each row execute function public.protect_profile_privileges();

do $$
declare table_name text;
begin
  foreach table_name in array array['profiles','travel_intents','trips','activities','activity_private_details','posts','reports']
  loop
    execute format('drop trigger if exists set_%I_updated_at on public.%I', table_name, table_name);
    execute format('create trigger set_%I_updated_at before update on public.%I for each row execute function public.set_updated_at()', table_name, table_name);
  end loop;
end;
$$;

create or replace function public.is_active_team_member(p_team_id uuid, p_user_id uuid default auth.uid())
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.team_members
    where team_id = p_team_id and user_id = p_user_id and left_at is null
  );
$$;

create or replace function public.are_users_blocked(p_first_user uuid, p_second_user uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.blocks
    where (blocker_id = p_first_user and blocked_id = p_second_user)
       or (blocker_id = p_second_user and blocked_id = p_first_user)
  );
$$;

create or replace function public.apply_for_activity(p_activity_id uuid, p_intro text default '')
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_activity public.activities%rowtype;
  v_application public.activity_applications%rowtype;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  select * into v_activity from public.activities where id = p_activity_id for share;
  if not found or v_activity.status <> 'open' or v_activity.starts_at <= now() then
    raise exception 'activity is not available';
  end if;
  if v_activity.organizer_id = auth.uid() then raise exception 'organizer cannot apply'; end if;
  if not exists (select 1 from public.profiles where id = auth.uid() and companion_eligible) then
    raise exception 'companion eligibility required';
  end if;
  if public.are_users_blocked(auth.uid(), v_activity.organizer_id) then
    raise exception 'application is not allowed';
  end if;

  insert into public.activity_applications (activity_id, applicant_id, intro)
  values (p_activity_id, auth.uid(), left(coalesce(p_intro, ''), 500))
  on conflict (activity_id, applicant_id) do update
    set intro = excluded.intro,
        status = case when public.activity_applications.status = 'withdrawn' then 'pending' else public.activity_applications.status end
  returning * into v_application;
  return jsonb_build_object('ok', true, 'data', to_jsonb(v_application), 'error', null);
end;
$$;

create or replace function public.review_application(p_application_id uuid, p_decision text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare v_application public.activity_applications%rowtype;
begin
  if p_decision not in ('approved', 'rejected') then raise exception 'invalid decision'; end if;
  select aa.* into v_application
  from public.activity_applications aa
  join public.activities a on a.id = aa.activity_id
  where aa.id = p_application_id and a.organizer_id = auth.uid()
  for update of aa;
  if not found then raise exception 'application not found or forbidden'; end if;
  if v_application.status <> 'pending' then raise exception 'application is no longer pending'; end if;

  update public.activity_applications
  set status = p_decision, reviewed_by = auth.uid(), reviewed_at = now()
  where id = p_application_id
  returning * into v_application;
  return jsonb_build_object('ok', true, 'data', to_jsonb(v_application), 'error', null);
end;
$$;

create or replace function public.confirm_application(p_application_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_application public.activity_applications%rowtype;
  v_activity public.activities%rowtype;
  v_team_id uuid;
  v_member_count integer;
begin
  select * into v_application from public.activity_applications
  where id = p_application_id and applicant_id = auth.uid() for update;
  if not found or v_application.status <> 'approved' then raise exception 'application is not ready to confirm'; end if;
  select * into v_activity from public.activities where id = v_application.activity_id for update;
  if v_activity.status <> 'open' or v_activity.starts_at <= now() then raise exception 'activity is not available'; end if;
  if public.are_users_blocked(auth.uid(), v_activity.organizer_id) then
    raise exception 'confirmation is not allowed';
  end if;

  insert into public.teams (activity_id, leader_id)
  values (v_activity.id, v_activity.organizer_id)
  on conflict (activity_id) do update set activity_id = excluded.activity_id
  returning id into v_team_id;
  insert into public.team_members (team_id, user_id, role)
  values (v_team_id, v_activity.organizer_id, 'leader')
  on conflict (team_id, user_id) do update set left_at = null, role = 'leader';

  select count(*) into v_member_count from public.team_members where team_id = v_team_id and left_at is null;
  if v_member_count >= v_activity.capacity then
    update public.activities set status = 'full' where id = v_activity.id;
    raise exception 'activity is full';
  end if;

  insert into public.team_members (team_id, user_id, role)
  values (v_team_id, auth.uid(), 'member')
  on conflict (team_id, user_id) do update set left_at = null, role = 'member';
  update public.activity_applications set status = 'confirmed', confirmed_at = now() where id = p_application_id;
  select count(*) into v_member_count from public.team_members where team_id = v_team_id and left_at is null;
  if v_member_count >= v_activity.capacity then update public.activities set status = 'full' where id = v_activity.id; end if;
  return jsonb_build_object('ok', true, 'data', jsonb_build_object('team_id', v_team_id), 'error', null);
end;
$$;

create or replace function public.resolve_team_proposal(p_proposal_id uuid, p_decision text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare v_proposal public.team_proposals%rowtype;
begin
  if p_decision not in ('approved', 'rejected') then raise exception 'invalid decision'; end if;
  select tp.* into v_proposal
  from public.team_proposals tp
  join public.teams t on t.id = tp.team_id
  where tp.id = p_proposal_id and t.leader_id = auth.uid()
  for update of tp;
  if not found then raise exception 'proposal not found or forbidden'; end if;
  if v_proposal.status <> 'pending' then raise exception 'proposal already resolved'; end if;
  update public.team_proposals set status = p_decision, resolved_by = auth.uid(), resolved_at = now()
  where id = p_proposal_id returning * into v_proposal;
  return jsonb_build_object('ok', true, 'data', to_jsonb(v_proposal), 'error', null);
end;
$$;

alter table public.profiles enable row level security;
alter table public.travel_intents enable row level security;
alter table public.trips enable row level security;
alter table public.trip_items enable row level security;
alter table public.trip_versions enable row level security;
alter table public.activities enable row level security;
alter table public.activity_private_details enable row level security;
alter table public.activity_applications enable row level security;
alter table public.teams enable row level security;
alter table public.team_members enable row level security;
alter table public.team_messages enable row level security;
alter table public.team_proposals enable row level security;
alter table public.posts enable row level security;
alter table public.post_places enable row level security;
alter table public.post_bookmarks enable row level security;
alter table public.blocks enable row level security;
alter table public.reports enable row level security;
alter table public.notifications enable row level security;

create policy "profiles readable by owner or eligible public" on public.profiles for select using (id = auth.uid() or companion_eligible);
create policy "profiles insert self" on public.profiles for insert with check (id = auth.uid());
create policy "profiles update self" on public.profiles for update using (id = auth.uid()) with check (id = auth.uid());

create policy "travel intents readable by owner or public" on public.travel_intents for select using (
  user_id = auth.uid() or (
    visibility = 'public'
    and exists (select 1 from public.profiles p where p.id = user_id and p.companion_eligible)
    and not public.are_users_blocked(auth.uid(), user_id)
  )
);
create policy "travel intents insert self" on public.travel_intents for insert with check (user_id = auth.uid());
create policy "travel intents update self" on public.travel_intents for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "travel intents delete self" on public.travel_intents for delete using (user_id = auth.uid());

create policy "trips owner access" on public.trips for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy "trip items owner access" on public.trip_items for all using (exists (select 1 from public.trips t where t.id = trip_id and t.owner_id = auth.uid())) with check (exists (select 1 from public.trips t where t.id = trip_id and t.owner_id = auth.uid()));
create policy "trip versions owner read" on public.trip_versions for select using (exists (select 1 from public.trips t where t.id = trip_id and t.owner_id = auth.uid()));

create policy "activities public read" on public.activities for select using (status <> 'draft' or organizer_id = auth.uid());
create policy "activities eligible organizer insert" on public.activities for insert with check (organizer_id = auth.uid() and exists (select 1 from public.profiles p where p.id = auth.uid() and p.companion_eligible));
create policy "activities organizer update" on public.activities for update using (organizer_id = auth.uid()) with check (organizer_id = auth.uid());
create policy "activities organizer delete" on public.activities for delete using (organizer_id = auth.uid());

create policy "private activity details members read" on public.activity_private_details for select using (
  exists (select 1 from public.activities a where a.id = activity_id and a.organizer_id = auth.uid())
  or exists (select 1 from public.teams t where t.activity_id = activity_id and public.is_active_team_member(t.id))
);
create policy "private activity details organizer write" on public.activity_private_details for all using (exists (select 1 from public.activities a where a.id = activity_id and a.organizer_id = auth.uid())) with check (exists (select 1 from public.activities a where a.id = activity_id and a.organizer_id = auth.uid()));

create policy "applications participant read" on public.activity_applications for select using (applicant_id = auth.uid() or exists (select 1 from public.activities a where a.id = activity_id and a.organizer_id = auth.uid()));

create policy "teams members read" on public.teams for select using (leader_id = auth.uid() or public.is_active_team_member(id));
create policy "team members members read" on public.team_members for select using (public.is_active_team_member(team_id));
create policy "team messages members read" on public.team_messages for select using (public.is_active_team_member(team_id));
create policy "team messages members insert" on public.team_messages for insert with check (sender_id = auth.uid() and public.is_active_team_member(team_id));
create policy "team proposals members read" on public.team_proposals for select using (public.is_active_team_member(team_id));
create policy "team proposals members insert" on public.team_proposals for insert with check (proposer_id = auth.uid() and public.is_active_team_member(team_id));

create policy "posts public or author read" on public.posts for select using (status = 'published' or author_id = auth.uid());
create policy "posts author insert" on public.posts for insert with check (author_id = auth.uid());
create policy "posts author update" on public.posts for update using (author_id = auth.uid()) with check (author_id = auth.uid());
create policy "posts author delete" on public.posts for delete using (author_id = auth.uid());
create policy "post places visible post read" on public.post_places for select using (exists (select 1 from public.posts p where p.id = post_id and (p.status = 'published' or p.author_id = auth.uid())));
create policy "post places author write" on public.post_places for all using (exists (select 1 from public.posts p where p.id = post_id and p.author_id = auth.uid())) with check (exists (select 1 from public.posts p where p.id = post_id and p.author_id = auth.uid()));
create policy "bookmarks self access" on public.post_bookmarks for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "blocks self access" on public.blocks for all using (blocker_id = auth.uid()) with check (blocker_id = auth.uid());
create policy "reports self create" on public.reports for insert with check (reporter_id = auth.uid());
create policy "reports self read" on public.reports for select using (reporter_id = auth.uid());
create policy "notifications self read" on public.notifications for select using (user_id = auth.uid());
create policy "notifications self update" on public.notifications for update using (user_id = auth.uid()) with check (user_id = auth.uid());

drop view if exists public.public_profiles;
create view public.public_profiles with (security_invoker = true) as
select id, display_name, avatar_path, about, interest_tags, travel_pace, created_at
from public.profiles
where companion_eligible;

grant usage on schema public to anon, authenticated;
grant select on public.public_profiles, public.activities, public.posts, public.post_places to anon, authenticated;
grant select, insert, update, delete on public.profiles, public.travel_intents, public.trips, public.trip_items, public.activity_private_details, public.post_bookmarks, public.blocks to authenticated;
grant select, insert, update, delete on public.activities, public.posts, public.post_places to authenticated;
grant select on public.trip_versions, public.activity_applications, public.teams, public.team_members, public.notifications to authenticated;
grant select, insert on public.team_messages, public.team_proposals, public.reports to authenticated;
revoke all on function public.apply_for_activity(uuid, text) from public, anon;
revoke all on function public.review_application(uuid, text) from public, anon;
revoke all on function public.confirm_application(uuid) from public, anon;
revoke all on function public.resolve_team_proposal(uuid, text) from public, anon;
grant execute on function public.apply_for_activity(uuid, text) to authenticated;
grant execute on function public.review_application(uuid, text) to authenticated;
grant execute on function public.confirm_application(uuid) to authenticated;
grant execute on function public.resolve_team_proposal(uuid, text) to authenticated;
revoke all on function public.are_users_blocked(uuid, uuid) from public;
grant execute on function public.are_users_blocked(uuid, uuid) to anon, authenticated;

commit;
