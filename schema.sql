-- Sales CRM database for Supabase
-- Run this entire file in Supabase SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role text not null default 'agent' check (role in ('agent','manager')),
  active boolean not null default true,
  daily_target integer not null default 10,
  created_at timestamptz not null default now()
);

create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null,
  mobile text not null,
  email text,
  membership text,
  source text,
  priority text not null default 'Warm',
  status text not null default 'New',
  next_followup date,
  remarks text,
  agent_id uuid not null references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.sales (
  id uuid primary key default gen_random_uuid(),
  lead_id uuid references public.leads(id) on delete set null,
  agent_id uuid not null references public.profiles(id),
  customer_name text not null,
  membership text,
  mrp numeric(12,2) not null default 0,
  discount_amount numeric(12,2) not null default 0,
  discount_pct numeric(7,2) not null default 0,
  final_price numeric(12,2) not null default 0,
  payment_status text not null default 'Paid',
  payment_mode text,
  sold_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.leads enable row level security;
alter table public.sales enable row level security;

create or replace function public.is_manager()
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='manager' and p.active=true); $$;

create policy "profiles own or manager read" on public.profiles
for select to authenticated using (id=auth.uid() or public.is_manager());

create policy "agents read own leads managers read all" on public.leads
for select to authenticated using (agent_id=auth.uid() or public.is_manager());

create policy "agents insert own leads managers insert all" on public.leads
for insert to authenticated with check (agent_id=auth.uid() or public.is_manager());

create policy "agents update own leads managers update all" on public.leads
for update to authenticated using (agent_id=auth.uid() or public.is_manager())
with check (agent_id=auth.uid() or public.is_manager());

create policy "agents read own sales managers read all" on public.sales
for select to authenticated using (agent_id=auth.uid() or public.is_manager());

create policy "agents insert own sales managers insert all" on public.sales
for insert to authenticated with check (agent_id=auth.uid() or public.is_manager());

-- IMPORTANT:
-- After creating the manager's Auth user in Supabase Authentication,
-- insert/update that user's profile:
--
-- insert into public.profiles(id, full_name, role)
-- values ('AUTH-USER-UUID-HERE', 'Your Name', 'manager');
--
-- For each agent, create the Auth user first, then insert a profile row
-- with role='agent'. Agents can then log in from the same GitHub Pages URL.
