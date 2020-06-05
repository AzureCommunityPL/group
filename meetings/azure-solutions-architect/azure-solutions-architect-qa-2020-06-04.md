# #azure-solutions-architect Q&A #1

Date: 2020-06-04

[Add to calendar](https://evt.mx/Rm12eTAB)

[Meeting link](https://teams.microsoft.com/l/meetup-join/19%3ameeting_ZWYyNTg3N2UtZjA4NC00ZTQ1LTljMzQtODhmZTA0MTI0YzUz%40thread.v2/0?context=%7b%22Tid%22%3a%22cc58971a-0481-4ec0-bf8d-bb2e265db003%22%2c%22Oid%22%3a%22f907c950-2a9a-4012-b163-af67be63b5d6%22%7d)

[Recording](https://youtu.be/PwWhQFa8Ekg)

# Agenda

Proponowane wątki:
1. Praktyczne podejście do adresacji sieci w większej skali:
- Czy stosuje się w praktyce mniejsze podsieci niż VNET /16 i Subnet /24 
- Adresować inaczej niż od 10.0.0.0? Łatwo o nachodzenie przy spinaniu z kimś, jednak stosnkowo łatwiej niż w on-prem o readresację

2. Mozna jakoś oskryptować stworzenie Organizacji DevOps albo tenanta B2C? Głebiej już się coś daje, a ich (chyba) nie

3. Ile jest pisania kodu w pracy Solution Architect, a ile klepania YAML np. pod AKS?


4. Jakaś dobra praktyka kiedy już nie rozpatrywać smaego ACI i pora przejść na AKS?
   Wybór między SF, SF Mesh, AKS dla super prostego mikroserwisu


5. Jak praktycznie zacząć projektowanie rozwiązania w Azure (dokumentacja, wybór usług, PoC)?

6. Jak podejść do tematu architektury dla startupu, który nie wiadomo jak pójdzie i nie do konca da się przewidzieć które funkcjonalności będą kluczowe (= nie mamy liczb, ale zazwyczaj mamy mało hajsu i malo czasu)?

7. Jaką przyjąc strategię dla serwisów multinenant: kontrola podziału na poziomie bazy danych, tworzenie osobnych kopii serwisu per tenant , inne ?

# Discussion

## 1. Praktyczne podejście do adresacji sieci w większej skali:
- W przypadku rozwiązania bez przewidywanych interakcji z innymi sieciami bez znaczenia
- W przypadku koniecznych interakcji: decyzja administratorów sieci
- Bywają przypadki, gdzie VNet musiał być większy niż /16
- Konieczne jest nauczenie się korzystania z notacji [CIDR](https://pl.wikipedia.org/wiki/Classless_Inter-Domain_Routing)
Kalkulatory podsieci:
http://42.pl/
http://www.subnet-calculator.com/

## 2. Czy można oskryptować tworzenie Organizacji DevOps lub tenanta B2C
- Nie ma takiej potrzeby ze względu, że to pojedyńcze elementy, których się nie powiela
- Możliwość bezpośredniego utworzenia nowego tenanta AzureAD bez potrzeby autoryzacji i podpinania karty: https://account.azure.com/organization

## 3. Charakterystyka pracy Solution Architecta
- Stosunkowo mało pracy z kodem
- Większość pracy na etapie tworzenia środowisk i migracji
- Tylko 10-20% to praca na środowiskach produkcyjnych - raczej tylko w przypadku dużych problemów

Najistotniejsze aspekty, o które należy zadbać:
- Uśrednianie projektu do poziomu zespołu tworzącego i utrzymującego
- Budowanie zastępowalności poprzez przekazywanie wiedzy
- Umiejętność przekazywanie do analizy poszczególnych aspektów rozwiązania innym
- Rozwijanie umiejętności miękkich

[KISS](https://en.wikipedia.org/wiki/KISS_principle)

[Occam's Razor](https://en.wikipedia.org/wiki/Occam%27s_razor)



## 4. Jakaś dobra praktyka kiedy już nie rozpatrywać smaego ACI i pora przejść na AKS? Wybór między SF, SF Mesh, AKS dla super prostego mikroserwisu
- Jak coś super prostego to po prostu Azure Functions albo AppService (łatwy Continuous Deployment, masa języków programowania, taniość)
- ACI i AppService'y otrzymają sporo nowych funkcjonalności od strony sieci rozwiązujących wcześniejsze problemy z łącznością prywatną
- Service Fabric jest cudowny, jednak ma wysoki próg wejścia by wykorzystać pełnię możliwości - konieczny C# i architektura systemów rozproszonych
- AKS wymaga pilnowania bezstanowości service'ów i minimalizacja użytych elementów (branie gotowych od dostawcy)
- Kluczowe jest nie nastawianie się na konkretną technologię, tylko problemy jakie należy rozwiązać - niekoniecznie mikroserwisy są lepsze od monolitu. Na przykładzie [MongoDB](https://www.youtube.com/watch?v=b2F-DItXtZs) i [Dilberta](https://i.redd.it/8v9fopt6wlx31.jpg)



## 5. Jak praktycznie zacząć projektowanie rozwiązania w Azure (dokumentacja, wybór usług, PoC)?
- Zacząć od porzadnego rozpoznania wymagań, ale z naciskiem na kontekst biznesowy a nie techniczny
- Jeśli nie jest wymagany multicloud/agnostyczność to optymalizować pod Azure (prościej przepisać w razie potrzeby zmiany niż utrzymywać neutralność kosztem optymalizacji)
- Jeśli jest wymagana przenośność to najprościej IaaS
- Uwzględniać w projekcie permanentny stan awarii (tworzyć pętle reconnect itd.)
- VM w Azure są droższe tylko na pierwszy rzut oka, jednak po uwzględnieniu wszystkiego co daje Public Cloud jest on tańszy (wiele replik danych, self-healing, disaster recovery, network, security). TCO chmury powinno być korzystniejsze niż on-prem.
- Korzystanie na produkcji z funkcjonalności, a tym bardziej usług w Preview niewskazanane, chyba, że jesteśmy w stanie uzyskać wsparcie produkcyjne - zawsze najbezpieczniej trzymać się sprawdzonych wersji. 
- Optymalizować koszty, chyba że możemy je uzasadnić i wybronić chociażby mniejszym obciążeniem administracyjnym
- Pamiętanie o backupach (i odtwarzaniu), compliance i security
- [Jim Keller: Most People Don't Think Simple Enough](https://www.youtube.com/watch?v=1CSeY10zbqo)


## 6. Jak podejść do tematu architektury dla startupu, który nie wiadomo jak pójdzie i nie do konca da się przewidzieć które funkcjonalności będą kluczowe (= nie mamy liczb, ale zazwyczaj mamy mało hajsu i malo czasu)?
- Najlepiej zacząć tanio/prosto od Azure Functions (lub AppService), Service Bus (jeśli potrzebny), jakiś Storage i najtańszy SQL odpowiednio izolowany. jak wypali to potem najwyżej przepisać
- Mentoring stał na GitHub Pages (static + JS + Python) podpietym do Azure Storage Tables 


## 7. Jaką przyjąc strategię dla serwisów multinenant B2B: kontrola podziału na poziomie bazy danych, tworzenie osobnych kopii serwisu per tenant , inne ?
- Separacja storage (osobne konta) i DB (SQL Elastic Pool, [Citus](https://github.com/citusdata/citus))
- Appy wspólne (żeby nie zabić rentowności), ale dbając o odpowiednią uwagę na przepływ wrazliwych danych pod kątem compliance 

## 8. Opinie na temat Azure AD B2C
- Dobre pod kątem compliance i dostepnych providerów w porównaniu do realizowania tego samodzielnie
- Im bardziej Business tym przyjemniej, im bardziej Customer tym zdarzają się konieczne rzeźby

# Links

- [Most People Don't Think Simple Enough](https://www.youtube.com/watch?v=1CSeY10zbqo)
- [Migrate your IaaS resources to Azure Resource Manager by March 1, 2023](https://docs.microsoft.com/en-us/azure/virtual-machines/classic-vm-deprecation)
- [Episode 1 - Mongo DB Is Web Scale](https://www.youtube.com/watch?v=b2F-DItXtZs&feature=youtu.be)
- [Occam's razor](https://en.wikipedia.org/wiki/Occam%27s_razor)
- [KISS](https://en.wikipedia.org/wiki/KISS_principle)
- [Nie do końca udokomentowane zakładanie nowego AAD bez konta w Azure](https://account.azure.com/organization)
