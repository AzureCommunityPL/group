# #azure-solutions-architect Mentoring tech stack

Date: 2020-06-18

[Add to calendar](https://evt.mx/uUMzNr9T)

[Meeting link](https://teams.microsoft.com/l/meetup-join/19%3ameeting_MjhiZmE3ZjEtMDliNy00OTQwLTg5ZmMtYTQ2NDhlMzJhMTkw%40thread.v2/0?context=%7b%22Tid%22%3a%22cc58971a-0481-4ec0-bf8d-bb2e265db003%22%2c%22Oid%22%3a%22f907c950-2a9a-4012-b163-af67be63b5d6%22%7d)

[Recording](https://www.youtube.com/watch?v=ydag3Z4oWk0)

# Agenda

1. Analiza stosu technologicznego aplikacji obsługującej Program Mentoringowy.
2. Q&A.

# Discussion

## Analiza stosu technologicznego aplikacji obsługującej Program Mentoringowy.

1. Stos mentoringowy
    * Quick and dirty, w niektórych miejscach good enough, w niektórych bardzo dirty ;)
2. Strona
    * Fork [DevConf-Theme](https://github.com/xriley/DevConf-Theme)
        * Miał jedną wadę, był całkowicie statyczny.
    * Przerzucono go na [Jekyll](https://jekyllrb.com/), a całość hostowano na [GitHub Pages](https://pages.github.com/).
    * Dane na strone, np. lista mentorów były generowane z listy w YAML przez Jekyll.
    * Aplikowanie ze strony - przez Microsoft Forms
        * Przy takich szybkich rozwiązania dobrze korzystać z gotowców.
        * Forms miał tylko zbierać dane, ale nie miał być docelowym miejscem gdzie miały być one przechowywane.
3. Logic App
    * Na każde zgłoszenie odpalała się Logic Apka
    * Dodawała dane do MailerLite, żeby potem wysyłać emailing do uczestników.
    * Klucz wyciągała z Key Vault  
        * Zrobione ręcznie przez HTTP Request z MSI Logic App, bo Logic App nie ma dobrej integracji z KV używając MSI.
    * Kroku, gdzie wyciągany jest klucz do MailerLite, skonfigurowany jest w taki sposób, że dane wrażliwe nie są pokazywane w logach.
    * Do Forms nie ma porządnego API.
    * Następnie było tworzone Issue na GitHub z danymi z formularza.
    * Potem Issue było przypisywane do tworzonej karty w projekcie.
    * Dalej zgłoszenie było zapisywane do Table na Azure Storage.
    * Przy tej ilości zgłoszeń API GH było bardzo wolne, dlatego też te zgłoszenia trafiały do Table.
    * Dalej poprzez przenoszenie kart w projekcie na GitHub wstępnie sortowano uczestników, którzy mieli być przekazani mentorom. Były zdefiniowane odpowiednie tagi i proces.
4. Kod
    * W Pythonie, napisane quick and dirty, bo po prostu miało działać :)
    * Jeżeli któraś karta w projekcie na GitHub miała +4, to leciała już do mentora.
    * Dla każdej karty jak wyżej robiono request do API GitHub żeby wyciągnąć karty z +4 i zapisywano w odpowiedniej tabeli na Storage, gdzie był tylko partition key i row key.
5. Strona dla mentorów
    * Kolejna [prosta stronka](https://github.com/AzureCommunityPL/azurecommunitypl.github.io/blob/master/mentoring.html) w czystym JSie.
    * Pod spodem Function App, która po uwierzytelnieniu się kluczem (każdy mentor miał swój klucz), pokazywała kandydatów dla niego.
    * Mentor był jako partition key, żeby można było wyciągnąć całego mentora w jednym zapytaniu.
    * Kiedy mentor wybrał swoich podopiecznych, to było wykonywane zapytanie, które zapisywało wybranych do odpowiedniej tabeli na Storage.
    * Przy okazji była wysyłana wiadomość na Slacka przez kolejkę.
6. Po wybraniu
    * Kiedy kandydat był jako wybrany, to odpowiednim zapytaniem był przesuwany z +4 na Selected w projekcie na GitHub.
    * Aktualizowanie danych na MailerLite
    * Analogicznie dla mastermind - wszyscy z +4 i +3 - odpowiedni update w MailerLite.


## Q&A
* Coś byś zmienił?
    * Przerzucić na darmowe CosmosDB, żeby nie latać po tylu tabelach.
    * Sprzątanie przy dostępie danych dla mentora - ładniejsze załadowanie i przechowanie struktury z ACL
    * Link z dostępem i kluczem ważnym np. godzinę.
    * W niektórych miejscach bardziej zdarzeniowo.
    * Mógłby być kawałek panelu administracyjnego, żeby np. jak mentor chciał jeszcze raz wybrać, to żeby nie czyścić ręcznie tego z palca.
    * Poprawienie UX aplikacji. 
* Jak pracować z LogicApp w wiele osób - branche itd.
    * Niedługo będzie można pisać [kod do LogicApp w C#](https://github.com/Azure/logicapps/tree/master/preview)!
    * Do merge conflict dochodzi, kiedy scope zadań się przecinają - może trzeba tutaj zobaczyć co tu nie działa? Albo pull requesty za długo leżą.
* Application Gateway Ingress Controller
    * Jest w preview, ma parę raków pod spodem, nieprodukcyjnie, dopóki nie będzie GA (support). Ma słabszą konfigurację niż NGINX Ingress Controller albo Traefik.
    * Najlepiej zwykły, klasyczny Ingress Controller NGINX. Ewentualnie Traefik.