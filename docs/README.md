# Docs index

Start here. Find your task, read the files in its row, then work. Linked paths are relative to this folder; backticked paths are relative to the repo root; skills are invoked by name. Files marked _(created later)_ do not exist yet: skip them silently until they do.

## Task → files to read

| Task | Read |
| --- | --- |
| Understand the product and its scope | [requirements.md](requirements.md), [user-stories.md](user-stories.md) |
| Build or change a screen | The matching mockup in [design/](#ui-mockups), [design/styles.css](design/styles.css), its story in [user-stories.md](user-stories.md) |
| Write or change any code | The matching files in `.claude/rules/` _(created later)_; see [Reading the rules](#reading-the-rules) |
| Implement a ticket or feature | [definition-of-done.md](definition-of-done.md) (see [Reading the definition of done](#reading-the-definition-of-done)), the GitHub issue (see [agents/issue-tracker.md](agents/issue-tracker.md)), [user-stories.md](user-stories.md), [requirements.md](requirements.md), `GLOSSARY.md` _(created later)_, `docs/adr/` _(created later)_; skills `implement`, `tdd` |
| Break a plan or spec into tickets | [agents/issue-tracker.md](agents/issue-tracker.md), [agents/triage-labels.md](agents/triage-labels.md); skill `to-tickets` |
| Triage or label issues | [agents/triage-labels.md](agents/triage-labels.md), [agents/issue-tracker.md](agents/issue-tracker.md) |
| Review a branch or PR | [definition-of-done.md](definition-of-done.md), the originating issue, [requirements.md](requirements.md), [user-stories.md](user-stories.md); skill `code-review` |
| Name a domain concept or record a decision | [agents/domain.md](agents/domain.md), `GLOSSARY.md` _(created later)_, `docs/adr/` _(created later)_; skill `domain-modeling` |
| Design a module's interface | `GLOSSARY.md` _(created later)_; skill `codebase-design` |

## Reading the rules

`.claude/rules/` _(created later)_ holds one Markdown file per coding rule set. Rules say _how_ to write code; the definition of done says _when_ work is finished.

1. List `.claude/rules/`, recursing into subfolders.
2. Read each file's frontmatter. A file with a `paths:` list of globs applies only to files matching one of them; a file with no `paths:` applies to all work.
3. Read every rule file that applies to a file you will create or change, before editing it. Recheck when your change spreads to new paths.
4. Done when every applicable rule file has been read and your diff follows each one. When a rule conflicts with a doc here, follow the rule and name the conflict in your PR description.

## Reading the definition of done

[definition-of-done.md](definition-of-done.md) is the checklist a ticket must pass before merge.

1. **Before you start**, pick the items that apply. Functionality and Access Control items apply only when the ticket touches that feature; every other category applies to every ticket. Plan the tests and commands those items demand.
2. **Skip items marked _(optional)_.** They are proposals the team has not adopted.
3. **Before you call the work done**, check every applicable item: run each command it names and confirm it exits 0, and confirm each test it asks for exists and passes. `bin/ci` runs all the CI commands at once.
4. **In the PR description**, list each applicable item as checked, or as not checked with the reason. Mark items that don't apply as N/A with a one-line reason.

## Documents

| File | What it holds |
| --- | --- |
| [requirements.md](requirements.md) | Roles, functional requirements (auth, tickets, live updates, background jobs, events), out-of-scope list |
| [user-stories.md](user-stories.md) | Stories 1–6 with acceptance criteria |
| [definition-of-done.md](definition-of-done.md) | Checklist every ticket must pass before merge |
| [agents/issue-tracker.md](agents/issue-tracker.md) | `gh` commands for issues and PRs |
| [agents/triage-labels.md](agents/triage-labels.md) | Triage role → label string mapping |
| [agents/domain.md](agents/domain.md) | Where domain docs live and when to read them |
| `.claude/rules/` | Coding rules, optionally scoped by `paths:` globs _(created later)_ |
| `GLOSSARY.md` | Domain vocabulary _(created later)_ |
| `docs/adr/` | Architecture decision records _(created later)_ |

## UI mockups

Static HTML in `design/`, all styled by [design/styles.css](design/styles.css). Open in a browser.

| File | Screen | Role | Story |
| --- | --- | --- | --- |
| [design/index.html](design/index.html) | Sign in | Both | 1 |
| [design/my-tickets.html](design/my-tickets.html) | My tickets list | Customer | 2 |
| [design/new-ticket.html](design/new-ticket.html) | New ticket form | Customer | 2 |
| [design/customer-ticket.html](design/customer-ticket.html) | Ticket detail + comments | Customer | 5 |
| [design/agent-tickets.html](design/agent-tickets.html) | All tickets, status filters | Agent | 3 |
| [design/agent-ticket.html](design/agent-ticket.html) | Ticket detail, status change + comments | Agent | 4, 5 |

## Skills

Defined in `.agents/skills/<name>/SKILL.md` (symlinked into `.claude/skills/`).

| Skill | Use for |
| --- | --- |
| `implement` | Implementing work from a spec or tickets |
| `tdd` | Building features or fixing bugs test-first |
| `to-tickets` | Splitting a plan or spec into tracker tickets with blocking edges |
| `code-review` | Reviewing changes against repo standards and the originating spec |
| `domain-modeling` | Resolving terminology; writing `GLOSSARY.md` and ADRs |
| `codebase-design` | Designing deep modules and seams |
