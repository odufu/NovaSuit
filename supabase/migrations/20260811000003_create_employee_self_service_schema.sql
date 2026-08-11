-- ============================================================================
-- NOVASUITE SUPABASE MIGRATION: 20260811000003_create_employee_self_service_schema.sql
-- Employee Self-Service (ESS) Full Schema: Profiles, Leaves, Expense Claims & Salary Slips
-- ============================================================================

-- 1. Employee Profiles Table
CREATE TABLE IF NOT EXISTS public.employee_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    employee_code TEXT UNIQUE NOT NULL DEFAULT ('HR-EMP-' || LPAD((FLOOR(RANDOM() * 90000) + 10000)::TEXT, 5, '0')),
    series TEXT NOT NULL DEFAULT 'HR-EMP-',
    first_name TEXT NOT NULL,
    middle_name TEXT,
    last_name TEXT NOT NULL,
    full_name TEXT GENERATED ALWAYS AS (first_name || ' ' || COALESCE(middle_name || ' ', '') || last_name) STORED,
    gender TEXT DEFAULT 'Male',
    date_of_birth DATE DEFAULT '1993-03-13',
    salutation TEXT DEFAULT 'Mr',
    date_of_joining DATE DEFAULT '2026-06-26',
    status TEXT NOT NULL DEFAULT 'Active',
    department TEXT DEFAULT 'Digital Marketing - NL',
    role TEXT DEFAULT 'Digital Marketer',
    user_id_email TEXT NOT NULL,
    phone_number TEXT,
    address TEXT DEFAULT '12 Allen Avenue, Ikeja, Lagos State',
    create_user_permission BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Leave Balances Table
CREATE TABLE IF NOT EXISTS public.leave_balances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID NOT NULL REFERENCES public.employee_profiles(id) ON DELETE CASCADE,
    leave_type TEXT NOT NULL, -- 'Annual Leave', 'Casual Leave', 'Sick Leave', 'Maternity Leave', 'Unpaid Leave'
    total_allocated INT NOT NULL DEFAULT 20,
    taken_days INT NOT NULL DEFAULT 0,
    remaining_days INT GENERATED ALWAYS AS (total_allocated - taken_days) STORED,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Leave Applications Table
CREATE TABLE IF NOT EXISTS public.leave_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID NOT NULL REFERENCES public.employee_profiles(id) ON DELETE CASCADE,
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    leave_type TEXT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    is_half_day BOOLEAN DEFAULT false,
    total_days INT NOT NULL DEFAULT 1,
    reason TEXT,
    status TEXT NOT NULL DEFAULT 'Pending', -- 'Pending', 'Approved', 'Rejected', 'Cancelled'
    approved_by TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Expense Claims Table
CREATE TABLE IF NOT EXISTS public.expense_claims (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID NOT NULL REFERENCES public.employee_profiles(id) ON DELETE CASCADE,
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    claim_code TEXT UNIQUE NOT NULL DEFAULT ('EXP-CLAIM-' || LPAD((FLOOR(RANDOM() * 90000) + 10000)::TEXT, 5, '0')),
    posting_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_claimed NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    total_sanctioned NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    approval_status TEXT NOT NULL DEFAULT 'Draft', -- 'Draft', 'Submitted', 'Approved', 'Rejected'
    status TEXT NOT NULL DEFAULT 'Draft',
    narration TEXT,
    attachment_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. Expense Claim Items (Line items for claim breakdown)
CREATE TABLE IF NOT EXISTS public.expense_claim_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    claim_id UUID NOT NULL REFERENCES public.expense_claims(id) ON DELETE CASCADE,
    expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
    expense_type TEXT NOT NULL, -- 'Travel & Transport', 'Marketing & Ads', 'Client Entertainment', 'Office Supplies', 'Internet & Airtime'
    description TEXT,
    amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. Salary Slips Table
CREATE TABLE IF NOT EXISTS public.salary_slips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID NOT NULL REFERENCES public.employee_profiles(id) ON DELETE CASCADE,
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    slip_code TEXT UNIQUE NOT NULL DEFAULT ('SAL-SLIP-' || LPAD((FLOOR(RANDOM() * 90000) + 10000)::TEXT, 5, '0')),
    period_label TEXT NOT NULL, -- 'July 2026', 'August 2026'
    posting_date DATE NOT NULL DEFAULT CURRENT_DATE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    basic_salary NUMERIC(12, 2) NOT NULL DEFAULT 350000.00,
    housing_allowance NUMERIC(12, 2) NOT NULL DEFAULT 120000.00,
    transport_allowance NUMERIC(12, 2) NOT NULL DEFAULT 80000.00,
    gross_pay NUMERIC(12, 2) GENERATED ALWAYS AS (basic_salary + housing_allowance + transport_allowance) STORED,
    tax_deduction NUMERIC(12, 2) NOT NULL DEFAULT 35000.00,
    pension_deduction NUMERIC(12, 2) NOT NULL DEFAULT 28000.00,
    total_deductions NUMERIC(12, 2) GENERATED ALWAYS AS (tax_deduction + pension_deduction) STORED,
    net_pay NUMERIC(12, 2) GENERATED ALWAYS AS ((basic_salary + housing_allowance + transport_allowance) - (tax_deduction + pension_deduction)) STORED,
    status TEXT NOT NULL DEFAULT 'Submitted', -- 'Draft', 'Submitted', 'Paid'
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for Speed
CREATE INDEX IF NOT EXISTS idx_emp_profile_user ON public.employee_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_leave_app_employee ON public.leave_applications(employee_id);
CREATE INDEX IF NOT EXISTS idx_expense_claim_employee ON public.expense_claims(employee_id);
CREATE INDEX IF NOT EXISTS idx_salary_slip_employee ON public.salary_slips(employee_id);

-- RLS Security Policies
ALTER TABLE public.employee_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leave_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expense_claims ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.salary_slips ENABLE ROW LEVEL SECURITY;

CREATE POLICY emp_profile_self_policy ON public.employee_profiles FOR ALL USING (true);
CREATE POLICY leave_app_self_policy ON public.leave_applications FOR ALL USING (true);
CREATE POLICY expense_claim_self_policy ON public.expense_claims FOR ALL USING (true);
CREATE POLICY salary_slips_self_policy ON public.salary_slips FOR ALL USING (true);

-- Seed Initial Default Employee Profile for NovaCare Digital Marketers / Employees
INSERT INTO public.employee_profiles (
    id,
    company_id,
    employee_code,
    series,
    first_name,
    middle_name,
    last_name,
    gender,
    date_of_birth,
    salutation,
    date_of_joining,
    status,
    department,
    role,
    user_id_email
) VALUES (
    'e0000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000001',
    'HR-EMP-00246',
    'HR-EMP-',
    'Joel',
    'Ekowoicho',
    'Odufu',
    'Male',
    '1993-03-13',
    'Mr',
    '2026-06-26',
    'Active',
    'Digital Marketing - NL',
    'Digital Marketer',
    'joeledufu@gmail.com'
) ON CONFLICT (employee_code) DO NOTHING;

-- Seed Leave Balances for Joel Odufu
INSERT INTO public.leave_balances (employee_id, leave_type, total_allocated, taken_days)
VALUES
    ('e0000000-0000-0000-0000-000000000001', 'Annual Leave', 20, 4),
    ('e0000000-0000-0000-0000-000000000001', 'Casual Leave', 7, 1),
    ('e0000000-0000-0000-0000-000000000001', 'Sick Leave', 10, 0),
    ('e0000000-0000-0000-0000-000000000001', 'Unpaid Leave', 15, 0)
ON CONFLICT DO NOTHING;

-- Seed Sample Salary Slips
INSERT INTO public.salary_slips (
    id,
    employee_id,
    company_id,
    slip_code,
    period_label,
    posting_date,
    start_date,
    end_date,
    basic_salary,
    housing_allowance,
    transport_allowance,
    tax_deduction,
    pension_deduction,
    status
) VALUES 
(
    's0000000-0000-0000-0000-000000000001',
    'e0000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000001',
    'SAL-SLIP-00812',
    'July 2026',
    '2026-07-31',
    '2026-07-01',
    '2026-07-31',
    350000.00,
    120000.00,
    80000.00,
    35000.00,
    28000.00,
    'Submitted'
),
(
    's0000000-0000-0000-0000-000000000002',
    'e0000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000001',
    'SAL-SLIP-00813',
    'June 2026',
    '2026-06-30',
    '2026-06-01',
    '2026-06-30',
    350000.00,
    120000.00,
    80000.00,
    35000.00,
    28000.00,
    'Paid'
) ON CONFLICT DO NOTHING;

-- RPC Function to submit leave application
CREATE OR REPLACE FUNCTION public.submit_leave_application(
    p_employee_id UUID,
    p_company_id UUID,
    p_leave_type TEXT,
    p_from_date DATE,
    p_to_date DATE,
    p_is_half_day BOOLEAN,
    p_reason TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_days INT;
    v_app_id UUID;
    v_remaining INT;
BEGIN
    v_days := (p_to_date - p_from_date) + 1;
    IF p_is_half_day THEN
        v_days := 1;
    END IF;

    -- Check Leave Balance
    SELECT remaining_days INTO v_remaining
    FROM public.leave_balances
    WHERE employee_id = p_employee_id AND leave_type = p_leave_type;

    IF v_remaining IS NOT NULL AND v_remaining < v_days THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Insufficient leave balance! You have ' || v_remaining || ' days remaining for ' || p_leave_type
        );
    END IF;

    -- Insert Application
    INSERT INTO public.leave_applications (
        employee_id,
        company_id,
        leave_type,
        from_date,
        to_date,
        is_half_day,
        total_days,
        reason,
        status
    ) VALUES (
        p_employee_id,
        p_company_id,
        p_leave_type,
        p_from_date,
        p_to_date,
        p_is_half_day,
        v_days,
        p_reason,
        'Pending'
    ) RETURNING id INTO v_app_id;

    RETURN jsonb_build_object(
        'success', true,
        'application_id', v_app_id,
        'total_days', v_days,
        'message', 'Leave application submitted successfully for review'
    );
END;
$$;
