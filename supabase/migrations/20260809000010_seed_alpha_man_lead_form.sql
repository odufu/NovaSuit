-- ============================================================================
-- NOVASUITE SUPABASE MIGRATION: 20260809000010_seed_alpha_man_lead_form.sql
-- Seed "Alpha Man" Lead Form into public.lead_forms for Persistence Across App Restarts
-- ============================================================================

INSERT INTO public.lead_forms (
    id,
    company_id,
    title,
    digital_marketer_email,
    redirect_url,
    success_message,
    submit_button_text,
    quantity_display_mode,
    preset_country,
    description,
    product_category,
    status,
    offer_packages
) VALUES (
    'f0000000-0000-0000-0000-000000000003',
    'c0000000-0000-0000-0000-000000000001',
    'Alpha Man',
    'joelodufu@gmail.com',
    'https://detoxwithnova.xyz/thank-you-alpha-man/',
    'Thanks! Our concierge team will confirm your Alpha Man order shortly.',
    'Buy Alpha',
    'Radio buttons',
    'Nigeria',
    'Internal note or CTA shown above the form.',
    'Grazer Herbal Tea',
    'published',
    '[
        {"id": "pkg-1", "label": "1 Alpha Man", "amount": 23500, "discount": 0, "isDefault": true},
        {"id": "pkg-2", "label": "2 Alpha Man", "amount": 37000, "discount": 10000, "isDefault": false},
        {"id": "pkg-3", "label": "3 Alpha Man", "amount": 47000, "discount": 23500, "isDefault": false},
        {"id": "pkg-4", "label": "4 Alpha Man + 1 Free", "amount": 70000, "discount": 23500, "isDefault": false},
        {"id": "pkg-5", "label": "5 Alpha Man + 1 Respira Detox Free", "amount": 85000, "discount": 15000, "freeAddonProductName": "Respira Clear Detox", "freeAddonQty": 1, "isDefault": false}
    ]'::jsonb
) ON CONFLICT (title) DO UPDATE SET
    status = 'published',
    redirect_url = EXCLUDED.redirect_url,
    offer_packages = EXCLUDED.offer_packages,
    updated_at = now();
