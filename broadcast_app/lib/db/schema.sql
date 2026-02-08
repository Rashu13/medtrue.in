-- Enable UUID extension
create extension if not exists "uuid-ossp";
-- Create Profiles Table (tbl_profiles)
create table public.tbl_profiles (
    id uuid references auth.users not null,
    email text,
    role text default 'user' check (role in ('admin', 'user')),
    primary key (id)
);
-- Turn on RLS
alter table public.tbl_profiles enable row level security;
-- Policy: Everyone can read profiles
create policy "Public profiles are viewable by everyone." on tbl_profiles for
select using (true);
-- Policy: Users can update own profile
create policy "Users can update own profile." on tbl_profiles for
update using (auth.uid() = id);
-- Create Messages Table (tbl_messages)
create table public.tbl_messages (
    id uuid default uuid_generate_v4() primary key,
    sender_id uuid references auth.users not null,
    receiver_id uuid references auth.users,
    -- Null (empty) means Broadcast
    content text,
    is_broadcast boolean default false,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
-- Turn on RLS
alter table public.tbl_messages enable row level security;
-- Policy: Users see their own messages AND broadcasts
create policy "Users see own messages and broadcasts" on tbl_messages for
select using (
        auth.uid() = sender_id
        or auth.uid() = receiver_id
        or is_broadcast = true
    );
-- Policy: Users can insert messages
create policy "Users can insert messages" on tbl_messages for
insert with check (auth.uid() = sender_id);
-- Trigger to create profile on signup
create or replace function public.handle_new_user() returns trigger as $$ begin
insert into public.tbl_profiles (id, email, role)
values (new.id, new.email, 'user');
return new;
end;
$$ language plpgsql security definer;
-- Drop trigger if exists to avoid duplication errors on re-run
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after
insert on auth.users for each row execute procedure public.handle_new_user();