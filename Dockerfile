# syntax=docker/dockerfile:1

FROM python:3.12-slim AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir --user -r requirements.txt

COPY app.py .


FROM python:3.12-slim

LABEL org.opencontainers.image.authors="Martyna Nowaczek"
LABEL org.opencontainers.image.title="Weather App"
LABEL org.opencontainers.image.description="Aplikacja webowa pokazująca aktualną pogodę"
LABEL org.opencontainers.image.version="1.0"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="local-project"

WORKDIR /app

COPY --from=builder /root/.local /root/.local
COPY --from=builder /app/app.py .

ENV PATH=/root/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

RUN adduser --disabled-password --gecos "" appuser && \
    chown -R appuser:appuser /app /root/.local

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1

CMD ["python", "app.py"]