# #azure-solutions-architect Wykorzystanie Azure AD w aplikacjach - część 2

Date: 2020-12-10


[Add to calendar](https://bit.ly/3loHI9n)

[Meeting link](https://bit.ly/36jLuwk)

[Recording](#)

# Agenda
1. Omówienie zaproponowanego rozwiązania zadania
2. Application flows - czyli jak połączyć użytkowników AAD z aplikacją hostowaną w chmurze

## Zadanie
Połącz w bezpieczny sposób aplikację web z bazą danych (np. Cosmos DB) i pobierz informacje korzystając z tokenu użytkownika.

Elementy który warto wziąć pod uwagę to:
- App Service
- Cosmos DB
- Azure AD
- Private Endpoint (dla BARDZO chętnych)


## Linki
- OAuth 2.0 oraz OpenID Connect: https://docs.microsoft.com/en-us/azure/active-directory/develop/active-directory-v2-protocols
- Implicit flow: https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-implicit-grant-flow
- Authorization code flow: https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow
- On-Behalf-Of flow: https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-on-behalf-of-flow
- Ograniczanie dostępu do danych w CosmosDB: https://docs.microsoft.com/en-us/azure/cosmos-db/secure-access-to-data
- Autoryzacja i autentykacja w App Service: https://docs.microsoft.com/en-us/azure/app-service/app-service-authentication-how-to
- Konfiguracja App Service w Azure AD: https://docs.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad