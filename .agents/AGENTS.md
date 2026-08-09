# NovaSuite Project Rules

## Documentation Guidelines
- **Always Include Mermaid Diagrams**: Every documentation file (`.md` in `Documentation/`, walkthroughs, architecture guides, and workflow docs) MUST feature rich, clear Mermaid diagrams (`mermaid` code blocks) to visualize sequence flows, architecture handshakes, entity relationships, and state transitions.

## Mandatory 3-Tier Full-Stack Integrity Rule
- **Full-Stack End-to-End Implementation**: Every implementation of a role or feature interface MUST be accompanied by its corresponding PostgreSQL database schema migration (`supabase/migrations/`), Row Level Security (RLS) policies, and Supabase Edge Functions (`supabase/functions/`). No feature will be left as UI-only or partially mock; all 3 tiers (UI + Edge Functions/RPC + Database Schema) must work together cohesively.
