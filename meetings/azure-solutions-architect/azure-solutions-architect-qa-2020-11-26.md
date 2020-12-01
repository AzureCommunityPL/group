# #azure-solutions-architect Wykorzystanie Azure AD w aplikacjach

Date: 2020-11-26


[Add to calendar](https://evt.mx/g5eQsKRs)

[Meeting link](https://bit.ly/3mI0gm0)

[Recording](https://www.youtube.com/watch?v=Wa81cuppsdg&feature=youtu.be&fbclid=IwAR1goGX_TP9rpd9LoN-U7tr7Zoap0d3A5yLy0VSRQ9tp-jmYX12pKWUzHfA)

[Prezentacja](https://www2.slideshare.net/secret/lgU9qapOYBWwEf)

# Agenda
1. Dyskusja o AAD i AD

## Zadanie
Połącz w bezpieczny sposób aplikację web z bazą danych (np. Cosmos DB) i pobierz informacje korzystając z tokenu użytkownika.

Elementy który warto wziąć pod uwagę to:
- App Service
- Cosmos DB
- Azure AD
- Private Endpoint (dla BARDZO chętnych)

## Linki

### Ogólne linki architektoniczne
- Cloud Design Patterns: https://docs.microsoft.com/en-us/azure/architecture/patterns/
- Webinar z Chmurowiska z trzema przykładami architektur: https://bit.ly/39x8qKG

### Infrastruktura & private endpoints
- Projektowanie sieci w chmurze z perspektywy bezpieczeństwa: https://www.youtube.com/watch?v=7EJtmX1Vcmc

### Active Directory
- Autoryzacja vs uwierzytelnianie: https://www.youtube.com/watch?v=xBG076ablpg
- Microsoft identity platform documentation: https://docs.microsoft.com/en-us/azure/active-directory/develop/
- Application and service principal objects in Azure Active Directory: https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals#application-object
- Application types for Microsoft identity platform: https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-app-types
- Authentication flows and application scenarios: https://docs.microsoft.com/en-us/azure/active-directory/develop/authentication-flows-app-scenarios
- Use system-assigned managed identities to access Azure Cosmos DB data: https://docs.microsoft.com/en-us/azure/cosmos-db/managed-identity-based-authentication
- Azure AD DS: https://docs.microsoft.com/en-us/azure/active-directory-domain-services/overview#:~:text=Azure%20Active%20Directory%20Domain%20Services%20(AD%20DS)%20provides%20managed%20domain,(DCs)%20in%20the%20cloud
- Porównanie Azure AD DS i Self-managed AD DS: https://docs.microsoft.com/en-us/azure/active-directory-domain-services/compare-identity-solutions