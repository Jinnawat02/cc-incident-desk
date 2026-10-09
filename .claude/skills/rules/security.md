# Security rules
 
- Never hardcode secrets, credentials or tokens. Use Rails credentials or environment variables.

- If you find a hardcoded secret in the code or commit history, tell the user immediately. They must purge it from the history and rotate the credential.

- Do not put real customer or employee data in seeds, fixtures or tests.

- Use `has_secure_password` for authentication and strong parameters for all input.

- Scope customer queries by owner (`current_user.tickets`); never `Ticket.find(params[:id])` for customers.

- Never use `html_safe` or `raw` on user content.

- Whitelist `severity` and `status` values; never trust role or `assignee_id` from a customer.

- Broadcast channels must authorize the subscriber for that ticket.

 