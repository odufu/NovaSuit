-- Migration: Add Vast Custom Questions Schema and Response Handling
-- Supports 10 Field Types: Text, Paragraph, Phone, Dropdown, Checkbox Group, Radio Group, Date, Time, Number, File Upload

ALTER TABLE public.lead_forms
ADD COLUMN IF NOT EXISTS field_types_supported text[] DEFAULT ARRAY[
  'Text', 'Paragraph', 'Phone', 'Dropdown', 'Checkbox Group', 
  'Radio Group', 'Date', 'Time', 'Number', 'File Upload'
];

-- Ensure form_submissions table has additional_responses JSONB column for vast responses
ALTER TABLE public.form_submissions
ADD COLUMN IF NOT EXISTS additional_responses jsonb DEFAULT '{}'::jsonb;

-- Comment on column
COMMENT ON COLUMN public.form_submissions.additional_responses IS 'JSON map of custom question responses (Text, Paragraph, Phone, Dropdown, Checkbox Group, Radio Group, Date, Time, Number, File Upload URLs)';
