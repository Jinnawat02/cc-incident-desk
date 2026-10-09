---
paths:
  - "app/**"
  - "config/**"
  - "db/**"
  - "test/**"
---
 
# Rails conventions
 
- Follow Rails conventions and match the style of surrounding code. Rubocop omakase is the style authority; never disable cops just to pass.
- Keep changes small and focused on the current story.
- Keep controllers thin: authorize, call, respond. Put multi-step business logic in `app/services`.
- Enforce data integrity in both models and the database (validations, null constraints, foreign keys, indexes).
- Write reversible migrations, never edit a merged migration, and keep `db/schema.rb` committed (see the `db-migrate-safe` skill).
- Tests are Minitest, written with the code: model, controller/integration, and job tests including boundary cases (use `travel_to`).
- Add an index for foreign keys and for columns used in filters or sorting (`status`, `severity`, `assignee_id`); avoid N+1 with `includes`.
 
 