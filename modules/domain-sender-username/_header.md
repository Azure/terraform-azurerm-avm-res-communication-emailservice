# Email Communication Service Domain Sender Username

This submodule deploys a single `Microsoft.Communication/emailServices/domains/senderUsernames` resource into an existing Email Communication Service Domain.

A sender username is the local part of the `MailFrom` address used when sending email through the domain, for example the `donotreply` in `donotreply@contoso.com`.

> [!NOTE]
> This submodule deploys exactly one sender username. Cardinality is the caller's responsibility: use `for_each` on the module call, as the parent module does through its `email_communication_service_domain_sender_usernames` variable.
