\# ZADANIE 2



\## GitHub Actions pipeline



Dla aplikacji z Zadania 1 przygotowano pipeline GitHub Actions budujący obraz kontenera, wykonujący skan CVE oraz publikujący obraz do GitHub Container Registry.



Plik workflow:



```txt

.github/workflows/build-ghcr.yml

```



Pipeline został uruchomiony i zakończył się sukcesem.



\---



\## Obraz finalny GHCR



Finalny obraz:



```txt

ghcr.io/martynanowaczek/weather-app:alpine

```



Tag powiązany z commitem:



```txt

ghcr.io/martynanowaczek/weather-app:alpine-sha-<commit>

```



Przykład:



```txt

ghcr.io/martynanowaczek/weather-app:alpine-sha-be87024

```



\---



\## Cache BuildKit



Cache BuildKit jest przechowywany w DockerHub:



```txt

martynanowaczek/weather-app:buildcache-alpine

```



W workflow użyto cache typu `registry` w trybie `mode=max`:



```yaml

cache-from: type=registry,ref=martynanowaczek/weather-app:buildcache-alpine

cache-to: type=registry,ref=martynanowaczek/weather-app:buildcache-alpine,mode=max

```



\---



\## Multiarch



Obraz wspiera dwie wymagane architektury:



```txt

linux/amd64

linux/arm64

```



Weryfikacja manifestu:



```bash

docker buildx imagetools inspect ghcr.io/martynanowaczek/weather-app:alpine

```



\---



\## Test CVE



Do skanowania obrazu wykorzystano Trivy.



Skan wykonywany jest przed publikacją obrazu do GHCR. Pipeline blokuje publikację obrazu w przypadku podatności:



```txt

HIGH

CRITICAL

```



Ustawienia w workflow:



```yaml

severity: HIGH,CRITICAL

exit-code: 1

```



Skan wykonywany jest osobno dla:



```txt

linux/amd64

linux/arm64

```



\---



\## Tagowanie



| Element          | Tag                                                       |

| ---------------- | --------------------------------------------------------- |

| Obraz finalny    | `ghcr.io/martynanowaczek/weather-app:alpine`              |

| Obraz z commitem | `ghcr.io/martynanowaczek/weather-app:alpine-sha-<commit>` |

| Cache BuildKit   | `martynanowaczek/weather-app:buildcache-alpine`           |



Tag `alpine` oznacza aktualny finalny obraz aplikacji.



Tag `alpine-sha-<commit>` pozwala powiązać obraz z konkretną wersją kodu.



Tag `buildcache-alpine` przechowuje cache BuildKit w DockerHub.



\---



\## Potwierdzenie wykonania



W udanym uruchomieniu pipeline wykonano kroki:



```txt

Build amd64 image archive for CVE scan

Scan amd64 image with Trivy

Build arm64 image archive for CVE scan

Scan arm64 image with Trivy

Publish multiarch image to GHCR

Verify published multiarch image

```



\---



\## Zrzuty ekranu z realizacji



\### 1. Dodanie sekretów GitHub Actions



!\[Sekrety GitHub Actions](screenshots/01\_sekrety\_github\_actions.png)



\---



\### 2. Utworzenie workflow



!\[Utworzenie workflow](screenshots/02\_utworzenie\_workflow\_1.png)



\---



\### 3. Commit i push workflow



!\[Commit i push workflow](screenshots/03\_commit\_push\_workflow.png)



\---



\### 4. Udane wykonanie pipeline



!\[Udany run pipeline](screenshots/04\_udany\_run\_pipeline.png)



\---



\### 5. Weryfikacja obrazu multiarch



!\[Weryfikacja multiarch](screenshots/05\_weryfikacja\_multiarch.png)



\---



