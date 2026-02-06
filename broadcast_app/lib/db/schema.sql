-- Enable UUID extension
create extension if not exists "uuid-ossp";
-- Create Profiles Table
create table public.profiles (
    id uuid references auth.users not null,
    email text,
    role text default 'user' check (role in ('admin', 'user')),
    primary key (id)
);
-- Turn on RLS
alter table public.profiles enable row level security;
-- Policy: Everyone can read profiles (for checking roles)
create policy "Public profiles are viewable by everyone." on profiles for
select using (true);
-- Policy: Users can update their own profile
create policy "Users can update own profile." on profiles for
update using (auth.uid() = id);
-- Create Messages Table
create table public.messages (
    id uuid default uuid_generate_v4() primary key,
    sender_id uuid references auth.users not null,
    receiver_id uuid references auth.users,
    -- Nullable for broadcast
    content text,
    is_broadcast boolean default false,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
-- Turn on RLS
alter table public.messages enable row level security;
-- Policy: Admin can see all messages
-- We need a helper function to check if user is admin, or we just rely on the client for MVP? 
-- Let's stick to simple RLS for now. 
-- A user can see message if: they are sender, OR they are receiver, OR it is broadcast.
create policy "Users can see their own messages and broadcasts" on messages for
select using (
        auth.uid() = sender_id
        or auth.uid() = receiver_id
        or is_broadcast = true
    );
-- Policy: Users can insert messages
create policy "Users can insert messages" on messages for
insert with check (auth.uid() = sender_id);
-- Trigger to create profile on signup
create or replace function public.handle_new_user() returns trigger as $$ begin
insert into public.profiles (id, email, role)
values (new.id, new.email, 'user');
return new;
end;
$$ language plpgsql security definer;
create trigger on_auth_user_created
after
insert on auth.users for each row execute procedure public.handle_new_user();