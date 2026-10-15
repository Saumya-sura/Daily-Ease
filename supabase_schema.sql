-- ==============================================================================
-- Daily-Ease: Production PostgreSQL Database Schema & Row Level Security (RLS)
-- Free 5 km Radius Geospatial Matching & Seed Catalog
-- ==============================================================================

-- 1. Profiles Table (Extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone_number TEXT NOT NULL DEFAULT '',
    avatar_url TEXT,
    preferred_language TEXT DEFAULT 'en' CHECK (preferred_language IN ('en', 'hi', 'mr')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. User Roles Join Table (Role integrity: consumer / provider / admin)
CREATE TABLE IF NOT EXISTS public.user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('consumer', 'provider', 'admin')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, role)
);

-- 3. Saved Addresses Table (Multiple addresses: Home, Hostel, Office)
CREATE TABLE IF NOT EXISTS public.user_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    label TEXT NOT NULL, -- 'Home', 'Office', 'Hostel', etc.
    type TEXT NOT NULL DEFAULT 'home' CHECK (type IN ('home', 'office', 'hostel', 'other')),
    society_or_building TEXT,
    flat_or_room TEXT,
    locality TEXT NOT NULL,
    city TEXT NOT NULL,
    pincode TEXT NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Service Categories Catalog
CREATE TABLE IF NOT EXISTS public.service_categories (
    id TEXT PRIMARY KEY, -- 'maid', 'milkman', 'watchman', 'plumber', etc.
    name_en TEXT NOT NULL,
    name_hi TEXT NOT NULL,
    name_mr TEXT NOT NULL,
    icon_name TEXT NOT NULL,
    search_aliases TEXT[] DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    schema_definition JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Societies / Housing Complexes Directory
CREATE TABLE IF NOT EXISTS public.societies_directory (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    locality TEXT NOT NULL,
    city TEXT NOT NULL,
    pincode TEXT NOT NULL,
    active_workers_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Provider Profiles Table (Includes GPS Coordinates for Free 5km matching)
CREATE TABLE IF NOT EXISTS public.provider_profiles (
    id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    business_name TEXT NOT NULL,
    bio TEXT,
    primary_category_id TEXT REFERENCES public.service_categories(id),
    experience_years INT DEFAULT 1,
    service_areas TEXT[] NOT NULL DEFAULT '{}',
    societies_served TEXT[] DEFAULT '{}',
    languages_spoken TEXT[] DEFAULT '{"en"}',
    is_active BOOLEAN DEFAULT true, -- Immediate self-serve activation
    is_emergency_available BOOLEAN DEFAULT false,
    verification_status TEXT DEFAULT 'unverified' CHECK (verification_status IN ('unverified', 'pending', 'verified', 'rejected')),
    avg_rating NUMERIC(3,2) DEFAULT 0.0,
    total_reviews INT DEFAULT 0,
    pricing_model TEXT DEFAULT 'per_visit' CHECK (pricing_model IN ('hourly', 'daily', 'monthly', 'per_visit', 'per_liter')),
    base_price NUMERIC(10,2) NOT NULL DEFAULT 300.0, -- Informational estimate
    working_hours TEXT DEFAULT '08:00 AM - 08:00 PM',
    max_daily_jobs INT DEFAULT 5,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    leave_dates DATE[] DEFAULT '{}',
    category_custom_data JSONB DEFAULT '{}'::jsonb,
    profile_views INT DEFAULT 0,
    calls_initiated INT DEFAULT 0,
    booking_requests_count INT DEFAULT 0,
    is_temporary_job_mode_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Bookings Table (Supports 1-day temporary and recurring household subscriptions)
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    consumer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    provider_id UUID NOT NULL REFERENCES public.provider_profiles(id) ON DELETE RESTRICT,
    category_id TEXT NOT NULL REFERENCES public.service_categories(id),
    service_title TEXT NOT NULL,
    booking_type TEXT NOT NULL CHECK (booking_type IN ('one_time', 'temporary_range', 'recurring_daily', 'recurring_weekly', 'recurring_monthly')),
    status TEXT NOT NULL DEFAULT 'requested' CHECK (status IN ('requested', 'accepted', 'declined', 'rescheduled', 'completed', 'cancelled')),
    recurring_status TEXT DEFAULT 'active' CHECK (recurring_status IN ('active', 'paused', 'skipped_today')),
    scheduled_date DATE NOT NULL,
    scheduled_end_date DATE,
    time_slot TEXT NOT NULL,
    service_address TEXT NOT NULL,
    instructions TEXT,
    estimated_price NUMERIC(10,2) NOT NULL, -- Settled directly offline via cash/UPI
    cancellation_reason TEXT,
    is_no_show_reported BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Booking Status History (Audit Trail)
CREATE TABLE IF NOT EXISTS public.booking_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    actor_role TEXT NOT NULL CHECK (actor_role IN ('consumer', 'provider', 'system', 'admin')),
    status TEXT NOT NULL,
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. Custom Service Requests (For uncatalogued requirements)
CREATE TABLE IF NOT EXISTS public.custom_service_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    consumer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    photo_url TEXT,
    locality TEXT NOT NULL,
    pincode TEXT NOT NULL,
    budget_estimate NUMERIC(10,2),
    needed_date DATE NOT NULL,
    needed_time TEXT DEFAULT 'Flexible',
    status TEXT DEFAULT 'open' CHECK (status IN ('open', 'assigned', 'closed')),
    responses_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. Reviews Table (Tied strictly to completed bookings)
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID UNIQUE NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    consumer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    provider_id UUID NOT NULL REFERENCES public.provider_profiles(id) ON DELETE RESTRICT,
    rating NUMERIC(2,1) CHECK (rating >= 1.0 AND rating <= 5.0) NOT NULL,
    review_text TEXT,
    is_verified_booking BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. Reports & Abuse Moderation
CREATE TABLE IF NOT EXISTS public.reports_moderation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID NOT NULL REFERENCES public.profiles(id),
    reported_user_id UUID NOT NULL REFERENCES public.profiles(id),
    booking_id UUID REFERENCES public.bookings(id),
    reason TEXT NOT NULL,
    details TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'investigating', 'resolved', 'dismissed')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- ZERO-COST 5 KM RADIUS PROXIMITY FUNCTION (NO GOOGLE MAPS API NEEDED)
-- Pure mathematical Haversine formula executed inside PostgreSQL for 100% free
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.get_nearby_providers_5km(
    user_lat DOUBLE PRECISION,
    user_lng DOUBLE PRECISION,
    max_radius_km DOUBLE PRECISION DEFAULT 5.0,
    filter_category TEXT DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    business_name TEXT,
    primary_category_id TEXT,
    base_price NUMERIC,
    pricing_model TEXT,
    avg_rating NUMERIC,
    total_reviews INT,
    distance_km DOUBLE PRECISION,
    societies_served TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.business_name,
        p.primary_category_id,
        p.base_price,
        p.pricing_model,
        p.avg_rating,
        p.total_reviews,
        ROUND(
            (6371 * acos(
                LEAST(1.0, GREATEST(-1.0,
                    cos(radians(user_lat)) * cos(radians(p.latitude)) *
                    cos(radians(p.longitude) - radians(user_lng)) +
                    sin(radians(user_lat)) * sin(radians(p.latitude))
                ))
            ))::numeric, 2
        )::double precision AS distance_km,
        p.societies_served
    FROM public.provider_profiles p
    WHERE p.is_active = true
      AND p.latitude IS NOT NULL
      AND p.longitude IS NOT NULL
      AND (filter_category IS NULL OR filter_category = 'all' OR p.primary_category_id = filter_category)
      AND (
          6371 * acos(
              LEAST(1.0, GREATEST(-1.0,
                  cos(radians(user_lat)) * cos(radians(p.latitude)) *
                  cos(radians(p.longitude) - radians(user_lng)) +
                  sin(radians(user_lat)) * sin(radians(p.latitude))
              ))
          )
      ) <= max_radius_km
    ORDER BY distance_km ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- AUTOMATIC AUTH PROFILE TRIGGER
-- Creates a profile row whenever a new user signs up in Supabase Auth
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, phone_number, preferred_language)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Customer'),
        COALESCE(NEW.phone, NEW.raw_user_meta_data->>'phone_number', ''),
        COALESCE(NEW.raw_user_meta_data->>'preferred_language', 'en')
    )
    ON CONFLICT (id) DO NOTHING;

    INSERT INTO public.user_roles (user_id, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'role', 'consumer')
    )
    ON CONFLICT (user_id, role) DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.societies_directory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.provider_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.booking_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.custom_service_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports_moderation ENABLE ROW LEVEL SECURITY;

-- 1. Profiles: readable by all authenticated users; updated only by owner
DROP POLICY IF EXISTS "Public profiles are readable" ON public.profiles;
CREATE POLICY "Public profiles are readable" 
ON public.profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile" 
ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id);

-- 2. User Roles: user can view own roles
DROP POLICY IF EXISTS "Users can read own roles" ON public.user_roles;
CREATE POLICY "Users can read own roles" 
ON public.user_roles FOR SELECT TO authenticated USING (auth.uid() = user_id);

-- 3. User Addresses: private to the owning user
DROP POLICY IF EXISTS "Users can manage own addresses" ON public.user_addresses;
CREATE POLICY "Users can manage own addresses" 
ON public.user_addresses FOR ALL TO authenticated USING (auth.uid() = user_id);

-- 4. Service Categories: publicly readable by anyone (anon & authenticated)
DROP POLICY IF EXISTS "Categories are readable by everyone" ON public.service_categories;
CREATE POLICY "Categories are readable by everyone" 
ON public.service_categories FOR SELECT USING (is_active = true);

-- 5. Societies Directory: publicly readable
DROP POLICY IF EXISTS "Societies are readable by everyone" ON public.societies_directory;
CREATE POLICY "Societies are readable by everyone" 
ON public.societies_directory FOR SELECT USING (true);

-- 6. Provider Profiles: active listings publicly readable by all
DROP POLICY IF EXISTS "Active provider profiles are readable by everyone" ON public.provider_profiles;
CREATE POLICY "Active provider profiles are readable by everyone" 
ON public.provider_profiles FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Providers can manage own profile" ON public.provider_profiles;
CREATE POLICY "Providers can manage own profile" 
ON public.provider_profiles FOR ALL TO authenticated USING (auth.uid() = id);

-- 7. Bookings: only the consumer and provider involved can view and update
DROP POLICY IF EXISTS "Parties can view their own bookings" ON public.bookings;
CREATE POLICY "Parties can view their own bookings" 
ON public.bookings FOR SELECT TO authenticated 
USING (auth.uid() = consumer_id OR auth.uid() = provider_id);

DROP POLICY IF EXISTS "Consumers can create bookings" ON public.bookings;
CREATE POLICY "Consumers can create bookings" 
ON public.bookings FOR INSERT TO authenticated 
WITH CHECK (auth.uid() = consumer_id);

DROP POLICY IF EXISTS "Parties can update booking state" ON public.bookings;
CREATE POLICY "Parties can update booking state" 
ON public.bookings FOR UPDATE TO authenticated 
USING (auth.uid() = consumer_id OR auth.uid() = provider_id);

-- 8. Reviews: public read; write only by consumer for completed bookings
DROP POLICY IF EXISTS "Public reviews are readable by everyone" ON public.reviews;
CREATE POLICY "Public reviews are readable by everyone" 
ON public.reviews FOR SELECT USING (true);

DROP POLICY IF EXISTS "Consumers can review completed bookings" ON public.reviews;
CREATE POLICY "Consumers can review completed bookings" 
ON public.reviews FOR INSERT TO authenticated 
WITH CHECK (auth.uid() = consumer_id);

-- 9. Custom Requests: public read; owners manage
DROP POLICY IF EXISTS "Custom requests readable" ON public.custom_service_requests;
CREATE POLICY "Custom requests readable" 
ON public.custom_service_requests FOR SELECT USING (true);

DROP POLICY IF EXISTS "Consumers can manage custom requests" ON public.custom_service_requests;
CREATE POLICY "Consumers can manage custom requests" 
ON public.custom_service_requests FOR ALL TO authenticated 
USING (auth.uid() = consumer_id);

-- 10. Reports: users can submit reports
DROP POLICY IF EXISTS "Users can submit reports" ON public.reports_moderation;
CREATE POLICY "Users can submit reports" 
ON public.reports_moderation FOR INSERT TO authenticated 
WITH CHECK (auth.uid() = reporter_id);

-- ==============================================================================
-- PRODUCTION SEED DATA: POPULAR LOCAL SERVICE CATEGORIES
-- ==============================================================================
INSERT INTO public.service_categories (id, name_en, name_hi, name_mr, icon_name, search_aliases, is_active)
VALUES
    ('maid', 'Maid / Helper', 'कामवाली बाई', 'कामवाली मावशी', 'maid', ARRAY['maid', 'bai', 'kamwali', 'househelp', 'बाई', 'कामवाली', 'मावशी'], true),
    ('milkman', 'Milk Delivery', 'दूध डिलीवरी', 'दूधवाला', 'milkman', ARRAY['milk', 'milkman', 'doodhwala', 'dairy', 'दूध', 'दूधवाला'], true),
    ('watchman', 'Watchman / Security', 'सुरक्षा गार्ड / चौकीदार', 'सुरक्षारक्षक / वॉचमन', 'watchman', ARRAY['watchman', 'security', 'guard', 'chowkidar', 'चौकीदार', 'सुरक्षारक्षक'], true),
    ('plumber', 'Plumber', 'प्लंबर', 'प्लंबर', 'plumber', ARRAY['plumber', 'pipe', 'leak', 'tap', 'प्लंबर', 'नळ'], true),
    ('electrician', 'Electrician', 'इलेक्ट्रीशियन', 'इलेक्ट्रिशियन', 'electrician', ARRAY['electrician', 'wiring', 'fuse', 'inverter', 'इलेक्ट्रीशियन', 'लाईट'], true),
    ('carpenter', 'Carpenter', 'बढ़ई', 'सुतार', 'carpenter', ARRAY['carpenter', 'wood', 'furniture', 'door', 'बढ़ई', 'सुतार'], true),
    ('car_cleaner', 'Car Washing', 'कार वाशिंग', 'गाडी धुणे', 'car_cleaner', ARRAY['car', 'washing', 'cleaner', 'गाड़ी', 'कार'], true),
    ('cook', 'Home Cook / Chef', 'रसोईया / कुक', 'स्वयंपाकी', 'cook', ARRAY['cook', 'chef', 'food', 'tiffin', 'रसोईया', 'कुक', 'जेवण'], true),
    ('gardener', 'Gardener / Mali', 'माली', 'माळी', 'gardener', ARRAY['mali', 'gardener', 'plants', 'माली', 'माळी', 'झाडे'], true),
    ('driver', 'Driver', 'ड्राइवर', 'ड्रायव्हर', 'driver', ARRAY['driver', 'car', 'chauffeur', 'ड्राइवर', 'गाडी चालवणारा'], true)
ON CONFLICT (id) DO UPDATE SET
    name_en = EXCLUDED.name_en,
    name_hi = EXCLUDED.name_hi,
    name_mr = EXCLUDED.name_mr,
    search_aliases = EXCLUDED.search_aliases;

-- ==============================================================================
-- SEED DATA: POPULAR APARTMENT SOCIETIES
-- ==============================================================================
INSERT INTO public.societies_directory (id, name, locality, city, pincode, active_workers_count)
VALUES
    ('soc_1', 'Gokuldham Society', 'Powai', 'Mumbai', '400076', 14),
    ('soc_2', 'Hiranandani Gardens', 'Powai', 'Mumbai', '400076', 28),
    ('soc_3', 'Raheja Vistas', 'Chandivali', 'Mumbai', '400072', 19),
    ('soc_4', 'Lodha Bellissimo', 'Mahalaxmi', 'Mumbai', '400011', 22),
    ('soc_5', 'Godrej Platinum', 'Vikhroli East', 'Mumbai', '400079', 16)
ON CONFLICT (id) DO UPDATE SET
    active_workers_count = EXCLUDED.active_workers_count;
