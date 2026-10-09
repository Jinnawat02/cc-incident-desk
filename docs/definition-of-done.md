# Definition of Done

A ticket is done when every item that applies to it is checked. Functionality and Access Control items apply only when the ticket touches that feature; every other category applies to every ticket.

Items marked _(optional)_ are guesses: they don't come from [requirements.md](requirements.md), [user-stories.md](user-stories.md) or existing config. Adopt each one or delete it.

Commands come from `config/ci.rb`. `bin/ci` runs all of them in order.

## Functionality

- [ ] Every acceptance criterion of the ticket's story in [user-stories.md](user-stories.md) is covered by at least one passing test.
- [ ] A ticket created without a status is saved as `Open`, and a model test asserts it.
- [ ] Severity saves only as `Low`, `Medium`, `High` or `Urgent`, and status only as `Open`, `In Progress` or `Resolved`. A model test rejects any other value.
- [ ] A title shorter than 5 characters and a description shorter than 10 characters are rejected with a validation error (Story 2).
- [ ] Creating a ticket redirects to that ticket's detail page (Story 2).
- [ ] The agent ticket list shows the columns ID, Title, Customer, Severity, Status and Created At, has `All` / `Open` / `In Progress` / `Resolved` filters, and highlights `High` and `Urgent` rows (Story 3).
- [ ] A status change and a new comment each broadcast a Turbo Stream to the ticket's stream. A test asserts the broadcast, e.g. with `assert_turbo_stream_broadcasts`.
- [ ] Submitting a comment clears the comment input (Story 5).
- [ ] Each status change creates exactly one audit event, and a test asserts the count goes up by 1 (§3.5).
- [ ] The overdue job flags a `High` or `Urgent` ticket that is still `Open` and unassigned 15 minutes after creation, and writes a notification log line. Job tests also prove it leaves assigned, non-`Open` and `Low`/`Medium` tickets untouched (§3.4).
- [ ] The diff adds nothing from §4 Out of Scope: no SMTP password reset, attachments, roles other than `customer`/`agent`, or WYSIWYG editor.

## Access Control

- [ ] Every action except sign-in redirects unauthenticated requests to sign-in. An integration test covers each new action.
- [ ] Signing in with a bad email or password shows "Invalid email or password" (Story 1).
- [ ] Log out works from the top navigation bar (Story 1).
- [ ] When a customer requests another customer's ticket (show, edit, update, comment), the response is not 2xx and the ticket is unchanged. An integration test asserts both.
- [ ] A customer's request to change status or assignee leaves both unchanged. An integration test asserts it.
- [ ] An agent can view, assign and update any ticket. An integration test covers each.
- [ ] A user's role saves only as `customer` or `agent`.
- [ ] Live updates subscribe with `turbo_stream_from <record>`, which uses signed stream names, never a hand-built stream string.

## Code Quality

- [ ] `bin/rubocop` reports no offenses.
- [ ] `yarn build` and `yarn build:css` both exit 0.
- [ ] Every new `# rubocop:disable` has a comment on the same line giving the reason. _(optional)_
- [ ] New class and method names use the terms in `GLOSSARY.md`, once that file exists. _(optional)_

## Testing

- [ ] `bin/rails test` passes.
- [ ] `env RAILS_ENV=test bin/rails db:seed:replant` passes.
- [ ] Every new model, controller action and job has at least one test.
- [ ] `bin/rails test:system` passes for changed screens. _(optional: commented out in `config/ci.rb`)_
- [ ] Each new test fails when the production change it covers is reverted. _(optional)_

## Security

- [ ] `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error` passes.
- [ ] `bin/bundler-audit` passes, and every entry in `config/bundler-audit.yml` `ignore:` has a comment explaining why it doesn't apply.
- [ ] `yarn audit` passes.
- [ ] `git diff main...HEAD` adds no literal passwords, tokens or keys. Secrets go in `config/credentials.yml.enc` (`bin/rails credentials:edit`) or environment variables.
- [ ] `git ls-files config/master.key` prints nothing.
- [ ] `db/schema.rb` has no plaintext password column, only a digest such as `password_digest`.
- [ ] New sensitive params are added to `config/initializers/filter_parameter_logging.rb`. _(optional)_
- [ ] `config.force_ssl = true` in `config/environments/production.rb`. _(optional: currently commented out)_

## Operations

- [ ] `bin/setup --skip-server` succeeds on a fresh clone.
- [ ] After `bin/rails db:migrate`, `git status db/` shows no uncommitted changes to the schema files.
- [ ] Each new migration runs `bin/rails db:rollback` and then `bin/rails db:migrate` again without errors. _(optional)_
- [ ] Jobs use Active Job on Solid Queue (`config/queue.yml`), not a new queue backend.
- [ ] `bin/dev` boots, and the changed screens render with no errors in `log/development.log`. _(optional)_

## Documentation

- [ ] New domain terms are added to `GLOSSARY.md` via the `domain-modeling` skill.
- [ ] A decision that is hard to reverse gets an ADR in `docs/adr/`.
- [ ] Changed screens match their mockup in [design/](design/), or the PR description lists each difference.
- [ ] [README.md](README.md) is updated when a doc, mockup or skill is added, renamed or removed.
- [ ] The root `README.md` explains setup, `bin/dev` and `bin/ci` instead of the Rails boilerplate. _(optional)_

## Delivery

- [ ] `bin/ci` exits 0. There is no hosted CI workflow, so this local run is the gate.
- [ ] The work is on a branch, not `main`, and the PR body contains `Closes #<issue>`.
- [ ] The PR description lists which acceptance criteria it covers.
- [ ] The `code-review` skill has been run against `main`, and each finding is fixed or answered in the PR. _(optional)_
- [ ] `gh signoff` sets a green commit status. _(optional: commented out in `config/ci.rb`)_
