# syntax=docker/dockerfile:1.7

# =========================
# Etap 1: budowanie zależności
# =========================
FROM python:3.12-alpine AS builder

WORKDIR /app

# Zmienne środowiskowe ograniczające tworzenie zbędnych plików
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH"

# Instalacja minimalnych narzędzi potrzebnych do budowania zależności.
# Pakiety są usuwane razem z etapem builder, więc nie trafią do obrazu końcowego.
RUN python -m venv /opt/venv

# Najpierw kopiowany jest tylko plik requirements.txt,
# aby Docker mógł wykorzystać cache przy kolejnych buildach.
COPY requirements.txt .

# Wykorzystanie cache BuildKit dla pip przyspiesza kolejne budowanie obrazu.
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip && \
    pip install -r requirements.txt

# Skopiowanie kodu aplikacji dopiero po instalacji zależności
COPY app.py .


# =========================
# Etap 2: obraz uruchomieniowy
# =========================
FROM python:3.12-alpine AS runtime

# Etykiety zgodne ze standardem OCI
LABEL org.opencontainers.image.authors="Martyna Nowaczek" \
      org.opencontainers.image.title="Weather App" \
      org.opencontainers.image.description="Aplikacja webowa pokazująca aktualną pogodę" \
      org.opencontainers.image.version="1.0" \
      org.opencontainers.image.created="2026-05-04" \
      org.opencontainers.image.licenses="MIT"

WORKDIR /app

# Zmienne środowiskowe dla Pythona i środowiska wirtualnego
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH"

# Skopiowanie wyłącznie gotowego środowiska wirtualnego i kodu aplikacji
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app/app.py .

# Utworzenie nieuprzywilejowanego użytkownika.
# Aplikacja nie będzie działała jako root, co poprawia bezpieczeństwo kontenera.
RUN adduser --disabled-password --gecos "" --home /nonexistent appuser && \
    chown -R appuser:appuser /app /opt/venv

USER appuser

# Informacja o porcie, na którym działa aplikacja
EXPOSE 8080

# Healthcheck sprawdzający, czy aplikacja odpowiada na endpoint /health
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1

# Uruchomienie aplikacji
CMD ["python", "app.py"]