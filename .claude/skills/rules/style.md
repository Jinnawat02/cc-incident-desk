---
paths:
  - "app/**"
  - "lib/**"
  - "test/**"
---
 
# Style
 
Write code that is a pleasure to read: how it reads, how it looks, how it feels. Before writing new code, find similar code in the repo and follow it.
 
## Method order
 
In a class, order methods as:
 
1. `class` methods
2. `public` methods, with `initialize` at the top
3. `private` methods
 
## Invocation order
 
Order methods vertically by invocation order, so the code reads top to bottom.
 
```ruby
class SomeClass
  def some_method
    method_1
    method_2
  end
 
  private
    def method_1
      method_1_1
      method_1_2
    end
 
    def method_1_1
    end
 
    def method_1_2
    end
 
    def method_2
    end
end
```
 
## Bang methods
 
Use `!` only when a counterpart without `!` exists. Do not use `!` to flag destructive actions.
 
## Visibility modifiers
 
Follow rubocop-rails-omakase: no blank line after `private`, and indent the methods under it (see the example above). Do not disable cops to change this.
 
## Class definitions
 
Prefer compact syntax over nested modules. Nest only when defining several classes in one file or adding module-level code.
 
```ruby
# Bad
module My
  module Namespace
    class SomeClass
    end
  end
end
 
# Good
class My::Namespace::SomeClass
end
```
 
## Routing
 
Use `resources`. Custom actions go in `member` or `collection` blocks. Do not define standalone routes by hand.
 
```ruby
# Bad
post "articles/:id/publish", to: "articles#publish"
 
# Good
resources :articles do
  member do
    post :publish
  end
end
```
 
## Async work in jobs
 
Keep jobs shallow and delegate the logic to the domain model.
 
- Suffix `_later` on methods that enqueue a job.
- Suffix `_now` on the synchronous method the job calls.
 
```ruby
module Ticket::Overdue
  extend ActiveSupport::Concern
 
  included do
    after_create_commit :flag_overdue_later
  end
 
  def flag_overdue_later
    Ticket::FlagOverdueJob.set(wait: 15.minutes).perform_later(self)
  end
 
  def flag_overdue_now
    # ...
  end
end
 
class Ticket::FlagOverdueJob < ApplicationJob
  def perform(ticket)
    ticket.flag_overdue_now
  end
end
```
 
