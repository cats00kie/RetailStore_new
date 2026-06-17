# Stage 1: instalar dependencias
FROM python:3.12-alpine AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --require-hashes --no-cache-dir --only-binary=:all: -r requirements.txt

# Stage 2: imagen final minima
FROM python:3.12-alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin/uvicorn /usr/local/bin/uvicorn
COPY app/ ./app/
ENV CART_PERSISTENCE_PROVIDER=in-memory
ENV PORT=8080
USER appuser
EXPOSE 8080
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port $PORT"]
