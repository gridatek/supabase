-- Check if users exist in auth.users
SELECT id, email, created_at FROM auth.users;

-- Check if profiles exist
SELECT id, username, is_admin FROM public.profiles;

-- Check if Alice is an admin
SELECT id, email, (SELECT is_admin FROM public.profiles WHERE id = auth.users.id) as is_admin
FROM auth.users
WHERE email = 'alice@example.com';
