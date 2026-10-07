# Incident Desk

Support ticket and incident tracker. Customers submit tickets; agents triage, assign, and resolve them. Updates appear live without full-page reloads.

## Stack

- Rails 8.1, Ruby 4.0 (`.ruby-version`), SQLite
- Hotwire (Turbo + Stimulus), esbuild, Tailwind CSS 4
- Solid Queue / Solid Cache / Solid Cable
- Minitest with fixtures, Capybara for system tests

## Commands

- `bin/setup` — install dependencies and prepare the database
- `bin/dev` — run the server with JS/CSS watchers
- `bin/rails test` — run the test suite
- `bin/rails test test/controllers/<name>_controller_test.rb` — run one file
- `bin/rubocop` — lint (rubocop-rails-omakase)
- `bin/ci` — full CI: lint, security audits, Brakeman, tests

Run `bin/rubocop` and `bin/rails test` before declaring work done.

## Source of truth

Read these before implementing anything:

- `docs/user-stories.md` — user stories and acceptance criteria. Each feature maps to a story; satisfy every acceptance criterion.
- `docs/requirements.md` — functional requirements, roles, and what is out of scope. Do not build out-of-scope items.
- `docs/design/` — static HTML/CSS mockups. Build views to match them:
  - `index.html` → sign in
  - `my-tickets.html` → customer ticket list
  - `new-ticket.html` → new ticket form
  - `customer-ticket.html` → customer ticket detail
  - `agent-tickets.html` → agent ticket list with filters
  - `agent-ticket.html` → agent ticket detail
  - `styles.css` → design tokens (colors, font, spacing). Port them into `app/assets/stylesheets/application.tailwind.css` as Tailwind theme values; do not link the mockup stylesheet directly.

If the docs and the design disagree, follow the docs and mention the conflict.

## Code style

- **No comments in code.** Express intent through clear names and small methods instead. Remove generator boilerplate comments in files you touch.
- **SOLID:**
  - Single responsibility: thin controllers. Move business logic into models, concerns, or service objects under `app/services/`.
  - Open/closed: extend behavior with new classes or concerns rather than growing conditionals.
  - Liskov: subclasses and role-specific objects must be usable wherever their parent is expected.
  - Interface segregation: small, focused concerns and modules; no god objects.
  - Dependency inversion: inject collaborators (e.g. notifiers, clocks) so they can be swapped in tests.
- **Maintainability:** short methods, descriptive names, no duplication, Rails conventions over custom patterns. Prefer enums for status and severity, scopes for queries, and `before_action` for authorization.
- Authorization lives in one place per concern (customers see only their own tickets; agents see all). Never rely on hiding UI alone.
- Real-time updates use Turbo Streams; background work uses Active Job on Solid Queue.

## Testing

- Write a controller test for every controller, in `test/controllers/`, using `ActionDispatch::IntegrationTest`.
- Cover each action's happy path, validation failures, unauthenticated access, and role-based access (customer vs agent).
- Use fixtures in `test/fixtures/`. Keep tests free of comments, like the app code.
- Add model and job tests when they hold business logic (validations, overdue escalation, status events).

## Git workflow

- `develop` is the integration branch; `main` is the release branch.
- Always branch from an up-to-date `develop`:
  - Features: `feature/implement-<short-description>` (e.g. `feature/implement-user-login`)
  - Fixes: `fix/<area>-<short-description>` (e.g. `fix/ticket-status-broadcast`)
- Open pull requests back into `develop`.
- One user story per feature branch where practical.

## Security

- Never hardcode secrets, credentials, or tokens. Use Rails credentials or environment variables.
- Never commit `config/master.key`.
- If you find a hardcoded secret, warn immediately: the commit history must be purged and the credential rotated.
