# #azure-solutions-architect Review proposed solutions

Date: 2020-07-02


[Add to calendar](https://evt.mx/KuVfnCVp)

[Meeting link](https://teams.microsoft.com/l/meetup-join/19%3ameeting_MGNjMTU5MTktN2QxMi00YTRhLThkYmUtYzZkZTM0MGUyYjY5%40thread.v2/0?context=%7b%22Tid%22%3a%22cc58971a-0481-4ec0-bf8d-bb2e265db003%22%2c%22Oid%22%3a%22f907c950-2a9a-4012-b163-af67be63b5d6%22%7d)

[Recording](https://youtu.be/2H8VoSQAw1c)

# Agenda

1. Review przygotowany rozwiązań.
2. Jak przygotowany projekt przełożyć na stawiane przez biznes SLA.
3. Jak dobrze przełożyć [Overview of the reliability pillar](https://docs.microsoft.com/en-us/azure/architecture/framework/resiliency/overview) na nasz projekt architektury?
4. Q&A.

# Discussion

## Review projektu architektury

Zadanie dla was to zaprojektować usługę, do której będą trafiać zdjęcia współdzielone przez kilka systemów.

Założenia:
- Usługa wspólna dla innych systemów
- Usługa musi być redundantna pomiędzy regionami (najlepiej active-active)
- Zawartość zdjęcia musi być automatycznie tagowana/opisywana
- Usługa musi pozwalać na wgranie i pobranie bezpośrednio zdjęć (najlepiej 2 – 3 call rest z perspektywy aplikacji klienckiej)
- Usługa musi puszczać notyfikację, że nowe zdjęcie zostało wgrane, jest otagowane itp.
- Jeśli coś będzie nie tak z zawartością zdjęcia (zwartość +18) powinna iść notyfikacja do działu prawnego/ compliance
- Usługa musi umożliwiać na wyszukanie wszystkich zdjęć po użytkowniku, systemie, tagach, w zakresie czasu
- Jeśli mam ID zdjęcia to api musi zwracać url z bezpośrednim dostępem do zdjęcia
- Skala to 100k zdjęć miesięcznie zapisywanych, odczyt 2M razy, średni rozmiar 1 mb
- Zdjęcie jest czytane najczęściej przez pierwsze 45 dni
- Ile będzie kosztować system na przestrzeni 1, 12 i 24 miesięcy?

### Poglądowy schemat architektury:
![Schemat architektury](images/architektura02072020.jpg)

### Opis
- `Azure Blob Storage` geo-redundant 
    - pozwala automatycznie zreplikować dane do drugiego regionu
    - może odczytywać z zapasowego storage
    - dzięki drugiemu kontu storage'owemu możemy replikować się w drugą stronę (do drugiego regionu)
    - przenoszenie danych po 45 do cold storage dzięki [retention policy](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-lifecycle-management-concepts?tabs=azure-portal)
    - [wysoka dostępność](https://docs.microsoft.com/en-us/azure/storage/common/storage-disaster-recovery-guidance)
    - replikacja asynchroniczna (do 15 min zanim plik będzie w drugim regionie)
- Na wejściu do systemu i rozdzielania requestów między regionami `Azure Traffic Manager` lub `Azure Front Door` (dużo usług w Azure zbudowane jest na Traffic Managerze)
- Pierwszym komponentem jest `Azure Functions` lub `Azure API Management`
    - płacimy tylko za requesty
    - uzyskujemy klucz dostępowy do uploadu pliku (user dostaje SAS token i bezpośrednio uploaduje plik do storage)
    - zapisujemy request upload'u w CosmosDB
- `CosmosDb` przechowuje informacje o uploadowanych plikach
    - CosmosDB w trybie multi-master
    - dokument zawiera Id, User, System, Tagi, Storage name, Storage region
    - Tagi są tablicą i dzięki temu możemy użyć [range index lub ARRAY_CONTAINS](https://docs.microsoft.com/en-us/azure/cosmos-db/index-overview) do przeszukiwania
    - Storage name, Storage region służą do uzyskania wysokiej dostępności (uzyskanie SAS tokena do pliku w storage read-access) 
- Blob storage produkuje event do `Event Grid` po zuploadowaniu pliku. Wykorzystujemy event w trzech Azure Functions:
    - pierwsza AF updatuje CosmosDb informacją, że plik został zapisany
    - druga AF pobiera tagi z `Cognitive Services` i zapisuje je do CosmosDb
    - trzecia AF sprawdza plik przez `Content Moderator`
    
Zalety architektury: można napisać w tydzień i puścić na produkcję
Wady architektury: regiony są sparowane - żeby nie być zmuszonym do parowania regionów trzeba napisać kod do replikacji na event gridze lub azure function  


## Q&A
1.Czy CosmosDb może zabić kosztami?

CosmosDb karze głupotę. Sprawdza się przy średnich i dużych rozwiązaniach (np. replikacja danych między regionami)
Żeby wyliczyć dla zaprojektowanej architektury koszty CosmosDb: 
- 100tys nowych rekordów x 4 akcje (stworzenie rekordu, update że plik został wgrany, Cognitive Services, Content Moderator)
- Łukasz stworzył przykładowego JSONa żeby sprawdzić jego wielkość
- wykorzystaliśmy [kalkulator](https://cosmos.azure.com/capacitycalculator/)

2.Różnice między Service Bus, Event Grid, Event Hub

- Event Grid to usługa działająca na Webhookach (rzecz integracyjna dla Azure)
- Service Bus to Publisher-Subscriber (zapewnia większość wzorców kolejkowych i można użyć MassTransit jako warstwę abstrakcji)
- Event Hub to usługa do streamingu eventów
- są jeszcze Queue Storage

3.SLA

Dobrze zdefiniowane SLA mówi że jestem w stanie przetworzyć jakiś proces. Wartość SLA powinna zostać ustalona z biznesem, innymi słowy należy ustalić jak długa przerwa w działaniu aplikacji/systemu jest dopuszczalna.

Jeśli mamy dwie zależne od siebie usługi to mnożymy ich avaiability. Dla dwóch regionów korzystamy z [rachunku prawdopodobieństwa i matematyki dyskretnej](https://devops.stackexchange.com/questions/711/how-do-you-calculate-the-compound-service-level-agreement-sla-for-cloud-servic)
