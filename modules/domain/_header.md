# Email Communication Service Domain

This submodule deploys a single `Microsoft.Communication/emailServices/domains` resource into an existing Email Communication Service.

A domain is either Azure-managed (a shared, pre-verified test domain named `AzureManagedDomain`) or customer-managed (your own domain, which you must verify by publishing the DNS records exposed through the `verification_records` output).

Use the `resource_id` output to associate the domain with an Azure Communication Services resource.

> [!NOTE]
> This submodule deploys exactly one domain. Cardinality is the caller's responsibility: use `for_each` on the module call, as the parent module does through its `email_communication_service_domains` variable.
