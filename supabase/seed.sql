-- Seed file for development and testing
-- This file is safe to run multiple times (uses upserts/checks)

-- ============================================
-- SEED USERS (via auth.users)
-- ============================================
-- Note: In production, users sign up via the API
-- For development, we insert directly into auth.users

-- Clear existing seed data (optional - comment out if you want to keep data)
-- TRUNCATE auth.users CASCADE;

-- Insert test users into auth.users
-- Password for all test users: "password123"
-- Hashed with bcrypt: $2a$10$XOPbrlUPQdwdJUpSrIF6X.LbE14qsMmKGhM1A8W9iqaG1vv..mRyS

INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    role,
    aud
) VALUES
    -- User 1: Alice
    (
        'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        'alice@example.com',
        '$2a$10$XOPbrlUPQdwdJUpSrIF6X.LbE14qsMmKGhM1A8W9iqaG1vv..mRyS',
        NOW(),
        '{"full_name": "Alice Johnson", "avatar_url": "https://api.dicebear.com/7.x/avataaars/svg?seed=Alice"}',
        NOW(),
        NOW(),
        '',
        'authenticated',
        'authenticated'
    ),
    -- User 2: Bob
    (
        'b1ffbc99-9c0b-4ef8-bb6d-6bb9bd380a22'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        'bob@example.com',
        '$2a$10$XOPbrlUPQdwdJUpSrIF6X.LbE14qsMmKGhM1A8W9iqaG1vv..mRyS',
        NOW(),
        '{"full_name": "Bob Smith", "avatar_url": "https://api.dicebear.com/7.x/avataaars/svg?seed=Bob"}',
        NOW(),
        NOW(),
        '',
        'authenticated',
        'authenticated'
    ),
    -- User 3: Carol
    (
        'c2ffbc99-9c0b-4ef8-bb6d-6bb9bd380a33'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid,
        'carol@example.com',
        '$2a$10$XOPbrlUPQdwdJUpSrIF6X.LbE14qsMmKGhM1A8W9iqaG1vv..mRyS',
        NOW(),
        '{"full_name": "Carol Williams", "avatar_url": "https://api.dicebear.com/7.x/avataaars/svg?seed=Carol"}',
        NOW(),
        NOW(),
        '',
        'authenticated',
        'authenticated'
    )
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- UPDATE PROFILES
-- ============================================
-- Profiles should be auto-created by trigger, but we'll update them with more data

UPDATE public.profiles SET
    username = 'alice',
    bio = 'Software engineer passionate about web development',
    website = 'https://alice.dev',
    social_links = '{"github": "alice", "twitter": "alice_dev"}',
    is_verified = true,
    is_admin = true  -- Alice is an admin for testing
WHERE id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';

UPDATE public.profiles SET
    username = 'bob',
    bio = 'Designer & creative developer',
    website = 'https://bobdesigns.com',
    social_links = '{"github": "bobsmith", "twitter": "bob_designs"}',
    is_verified = true
WHERE id = 'b1ffbc99-9c0b-4ef8-bb6d-6bb9bd380a22';

UPDATE public.profiles SET
    username = 'carol',
    bio = 'Tech writer and content creator',
    website = 'https://carolwrites.io',
    social_links = '{"github": "carolw", "twitter": "carol_writes"}',
    is_verified = false
WHERE id = 'c2ffbc99-9c0b-4ef8-bb6d-6bb9bd380a33';

-- ============================================
-- SEED POSTS
-- ============================================

INSERT INTO public.posts (
    id,
    user_id,
    title,
    content,
    slug,
    published,
    tags,
    view_count,
    published_at
) VALUES
    -- Alice's posts
    (
        'd0000001-0000-0000-0000-000000000001'::uuid,
        'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
        'Getting Started with Supabase',
        'Supabase is an amazing open-source Firebase alternative. In this post, we''ll explore how to get started...',
        'getting-started-with-supabase',
        true,
        ARRAY['supabase', 'tutorial', 'backend'],
        142,
        NOW() - INTERVAL '7 days'
    ),
    (
        'd0000002-0000-0000-0000-000000000002'::uuid,
        'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
        'Building Real-time Apps',
        'Real-time features are essential for modern applications. Here''s how to implement them...',
        'building-realtime-apps',
        true,
        ARRAY['realtime', 'websockets', 'tutorial'],
        89,
        NOW() - INTERVAL '3 days'
    ),
    -- Bob's posts
    (
        'd0000003-0000-0000-0000-000000000003'::uuid,
        'b1ffbc99-9c0b-4ef8-bb6d-6bb9bd380a22',
        'Design Systems 101',
        'Creating consistent design systems is crucial for scaling products...',
        'design-systems-101',
        true,
        ARRAY['design', 'ui', 'systems'],
        256,
        NOW() - INTERVAL '10 days'
    ),
    (
        'd0000004-0000-0000-0000-000000000004'::uuid,
        'b1ffbc99-9c0b-4ef8-bb6d-6bb9bd380a22',
        'Color Theory for Developers',
        'Understanding color theory can help developers make better design decisions...',
        'color-theory-for-developers',
        true,
        ARRAY['design', 'development', 'colors'],
        178,
        NOW() - INTERVAL '5 days'
    ),
    -- Carol's posts
    (
        'd0000005-0000-0000-0000-000000000005'::uuid,
        'c2ffbc99-9c0b-4ef8-bb6d-6bb9bd380a33',
        'Technical Writing Best Practices',
        'Good technical documentation can make or break a product. Here are some best practices...',
        'technical-writing-best-practices',
        true,
        ARRAY['writing', 'documentation', 'technical'],
        321,
        NOW() - INTERVAL '14 days'
    ),
    (
        'd0000006-0000-0000-0000-000000000006'::uuid,
        'c2ffbc99-9c0b-4ef8-bb6d-6bb9bd380a33',
        'Draft: My Next Article',
        'This is a draft post that hasn''t been published yet...',
        'draft-my-next-article',
        false,
        ARRAY['draft'],
        0,
        NULL
    )
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- SEED FOLLOWS
-- ============================================

INSERT INTO public.follows (follower_id, following_id) VALUES
    -- Alice follows Bob and Carol
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1ffbc99-9c0b-4ef8-bb6d-6bb9bd380a22'),
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c2ffbc99-9c0b-4ef8-bb6d-6bb9bd380a33'),
    -- Bob follows Alice
    ('b1ffbc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'),
    -- Carol follows Alice and Bob
    ('c2ffbc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'),
    ('c2ffbc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'b1ffbc99-9c0b-4ef8-bb6d-6bb9bd380a22')
ON CONFLICT (follower_id, following_id) DO NOTHING;

-- ============================================
-- VERIFICATION
-- ============================================

-- Show what was created
DO $$
BEGIN
    RAISE NOTICE '✅ Seed completed!';
    RAISE NOTICE '📊 Users created: %', (SELECT COUNT(*) FROM auth.users WHERE email LIKE '%@example.com');
    RAISE NOTICE '📊 Profiles created: %', (SELECT COUNT(*) FROM public.profiles);
    RAISE NOTICE '📊 Posts created: %', (SELECT COUNT(*) FROM public.posts);
    RAISE NOTICE '📊 Follows created: %', (SELECT COUNT(*) FROM public.follows);
    RAISE NOTICE '';
    RAISE NOTICE '🔑 Test Credentials:';
    RAISE NOTICE '   Email: alice@example.com | Password: password123';
    RAISE NOTICE '   Email: bob@example.com   | Password: password123';
    RAISE NOTICE '   Email: carol@example.com | Password: password123';
END $$;
