FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Numeric UID so Kubernetes runAsNonRoot can verify it
RUN useradd --system --uid 10001 app
USER 10001

EXPOSE 5000

# gunicorn, not the Flask development server; the DB is retried per request (503 until it is up)
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
