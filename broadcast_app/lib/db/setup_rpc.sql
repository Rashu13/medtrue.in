-- Copy and run this SQL in your Supabase SQL Editor to install the helper function
-- This function allows the app to dynamically create tables with a configurable prefix.
-- It strictly checks if the table exists first. If it does, it DOES NOTHING (preserves existing data/policies).
create or replace function install_schema(prefix text) returns void language plpgsql security definer as $$
declare profile_tbl text := prefix || 'tbl_profiles';
message_tbl text := prefix || 'tbl_messages';
begin -- Ensure UUID extension is available
create extension if not exists "uuid-ossp";
-- 1. PROFILES
-- Check if table exists in public schema
if not exists (
    select 1
    from pg_tables
    where schemaname = 'public'
        and tablename = profile_tbl
) then -- Create Table
execute format(
    '
            create table public.%I (
                id text not null,
                email text,
                role text default ''user'' check (role in (''admin'', ''user'')),
                tenant_id text,
                primary key (id)
            );
        ',
    profile_tbl
);
-- Enable RLS
execute format(
    'alter table public.%I enable row level security;',
    profile_tbl
);
-- Create Policies
execute format(
    'create policy "Public profiles are viewable by everyone." on public.%I for select using (true);',
    profile_tbl
);
execute format(
    'create policy "Anyone can insert/update profiles" on public.%I for all using (true) with check (true);',
    profile_tbl
);
raise notice 'Created table %',
profile_tbl;
end if;
-- 2. MESSAGES
if not exists (
    select 1
    from pg_tables
    where schemaname = 'public'
        and tablename = message_tbl
) then -- Create Table
execute format(
    '
            create table public.%I (
                id uuid default gen_random_uuid() primary key,
                sender_id text not null,
                receiver_id text,
                content text,
                is_broadcast boolean default false,
                tenant_id text,
                created_at timestamp with time zone default timezone(''utc''::text, now()) not null
            );
        ',
    message_tbl
);
-- Enable RLS
execute format(
    'alter table public.%I enable row level security;',
    message_tbl
);
-- Create Policies
execute format(
    'create policy "Public access to messages" on public.%I for all using (true) with check (true);',
    message_tbl
);
-- Add to Realtime
begin execute format(
    'alter publication supabase_realtime add table public.%I;',
    message_tbl
);
exception
when others then null;
end;
raise notice 'Created table %',
message_tbl;
end if;
end;
$$;