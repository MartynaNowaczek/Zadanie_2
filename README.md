\# ZADANIE 2



\## Opis rozwiązania



W ramach zadania przygotowano pipeline GitHub Actions, który buduje obraz kontenera aplikacji z Zadania 1 na podstawie pliku `Dockerfile`, wykonuje test CVE oraz publikuje obraz do GitHub Container Registry.



Plik workflow:



```txt

.github/workflows/build-ghcr.yml

```



Workflow uruchamia się automatycznie po wykonaniu `push` na gałąź `main`. Można go również uruchomić ręcznie dzięki `workflow\_dispatch`.



\## Repozytoria obrazów



\### Obraz finalny GHCR



```txt

ghcr.io/martynanowaczek/weather-app:alpine

```



\### Cache BuildKit DockerHub



```txt

martynanowaczek/weather-app:buildcache-alpine

```



\## Obsługiwane architektury



Finalny obraz wspiera wymagane architektury:



```txt

linux/amd64

linux/arm64

```



W workflow obraz multiarch publikowany jest w kroku:



```txt

Publish multiarch image to GHCR

```



Weryfikacja obrazu:



```bash

docker buildx imagetools inspect ghcr.io/martynanowaczek/weather-app:alpine

```



\## Cache BuildKit



W pipeline wykorzystano cache BuildKit przechowywany w DockerHub. Dane cache są pobierane i wysyłane z użyciem backendu `registry` w trybie `mode=max`.



Fragment konfiguracji:



```yaml

cache-from: type=registry,ref=martynanowaczek/weather-app:buildcache-alpine

cache-to: type=registry,ref=martynanowaczek/weather-app:buildcache-alpine,mode=max

```



\## Test CVE



Do testu CVE wykorzystano skaner Trivy.



Skan wykonywany jest przed publikacją obrazu do GHCR. Pipeline blokuje publikację obrazu, jeżeli zostaną wykryte podatności sklasyfikowane jako:



```txt

HIGH

CRITICAL

```



Fragment konfiguracji Trivy:



```yaml

vuln-type: os,library

severity: HIGH,CRITICAL

exit-code: 1

```



W workflow skan wykonywany jest osobno dla obu architektur:



```txt

Scan amd64 image with Trivy

Scan arm64 image with Trivy

```



Dopiero po pozytywnym wyniku obu skanów wykonywany jest push obrazu do GHCR.



\## Schemat tagowania



| Element                    | Tag                                                       |

| -------------------------- | --------------------------------------------------------- |

| Finalny obraz GHCR         | `ghcr.io/martynanowaczek/weather-app:alpine`              |

| Obraz powiązany z commitem | `ghcr.io/martynanowaczek/weather-app:alpine-sha-<commit>` |

| Cache BuildKit DockerHub   | `martynanowaczek/weather-app:buildcache-alpine`           |



Tag `alpine` oznacza aktualny finalny obraz aplikacji.

Tag `alpine-sha-<commit>` pozwala powiązać obraz z konkretną wersją kodu.

Tag `buildcache-alpine` jest używany wyłącznie do przechowywania cache BuildKit.



\## Uzasadnienie wyboru



Do skanowania CVE wybrano Trivy, ponieważ łatwo integruje się z GitHub Actions i pozwala zatrzymać pipeline przez `exit-code: 1`, jeżeli wykryte zostaną podatności o wskazanym poziomie ważności.



Do cache BuildKit zastosowano backend `registry` z trybem `mode=max`, ponieważ pozwala przechowywać cache w zewnętrznym rejestrze DockerHub i wykorzystywać go pomiędzy kolejnymi uruchomieniami workflow.



Zastosowano tag `alpine` jako czytelny tag obrazu finalnego oraz tag `alpine-sha-<commit>`, aby możliwe było jednoznaczne powiązanie obrazu z konkretną wersją kodu.



\## Potwierdzenie działania



Workflow został uruchomiony i zakończył się sukcesem.



W udanym uruchomieniu wykonano kroki:



```txt

Build amd64 image archive for CVE scan

Scan amd64 image with Trivy

Build arm64 image archive for CVE scan

Scan arm64 image with Trivy

Publish multiarch image to GHCR

Verify published multiarch image

```



\## Zrzuty ekranu z realizacji



\### 1. Dodanie sekretów GitHub Actions



<img src="./screenshots/01\_sekrety\_github\_actions.png" alt="Sekrety GitHub Actions" width="900">



\### 2. Utworzenie workflow



<img src="./screenshots/02\_utworzenie\_workflow\_1.png" alt="Utworzenie workflow" width="900">



\### 3. Commit i push workflow



<img src="./screenshots/03\_commit\_push\_workflow.png" alt="Commit i push workflow" width="900">



\### 4. Udane wykonanie pipeline



<img src="./screenshots/04\_udany\_run\_pipeline.png" alt="Udany run pipeline" width="900">



\### 5. Weryfikacja obrazu multiarch



<img src="./screenshots/05\_weryfikacja\_multiarch.png" alt="Weryfikacja obrazu multiarch" width="900">



