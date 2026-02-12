-- Enable UUID extension
create extension if not exists "uuid-ossp";
-- RESET: Drop existing tables to apply new schema (WARNING: DELETES DATA)
drop policy if exists "Public profiles are viewable by everyone." on tbl_profiles;
drop policy if exists "Anyone can insert/update profiles" on tbl_profiles;
drop policy if exists "Users can update own profile." on tbl_profiles;
drop table if exists public.tbl_messages;
drop table if exists public.tbl_profiles;
-- Create Profiles Table (tbl_profiles)
create table public.tbl_profiles (
    id text not null,
    email text,
    role text default 'user' check (role in ('admin', 'user')),
    primary key (id)
);
-- Turn on RLS
alter table public.tbl_profiles enable row level security;
-- Policy: Everyone can read profiles
create policy "Public profiles are viewable by everyone." on tbl_profiles for
select using (true);
-- Policy: Anyone can update their own profile (based on ID match)
-- Note: Without auth, we rely on the client passing the correct ID. 
-- In a real app, we'd need a better security model for guests, but for now we allow upserts.
create policy "Anyone can insert/update profiles" on tbl_profiles for all using (true) with check (true);
-- Create Messages Table (tbl_messages)
create table public.tbl_messages (
    id uuid default uuid_generate_v4() primary key,
    sender_id text not null,
    receiver_id text,
    -- Null (empty) means Broadcast
    content text,
    is_broadcast boolean default false,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
-- Turn on RLS
alter table public.tbl_messages enable row level security;
-- Policy: Public access for now to allow guest messaging
create policy "Public access to messages" on tbl_messages for all using (true) with check (true);
-- Trigger to create profile on signup (Keep this if we still have true admins signing up via Auth)
create or replace function public.handle_new_user() returns trigger as $$ begin
insert into public.tbl_profiles (id, email, role)
values (new.id::text, new.email, 'user');
return new;
end;
$$ language plpgsql security definer;
-- Drop trigger if exists to avoid duplication errors on re-run
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after
insert on auth.users for each row execute procedure public.handle_new_user();
-- Enable Realtime for Messages
alter publication supabase_realtime
add table tbl_messages;