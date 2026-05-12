# Registry Contract

All providers must expose:

- registry_url
- registry_username
- registry_password

Providers may internally use:
- Azure ACR
- AWS ECR

But operationally they must satisfy the same runtime contract.