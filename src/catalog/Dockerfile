# Stage 1: build
FROM golang:1.26-alpine AS builder
# go-sqlite3 requiere CGO (codigo C), necesitamos gcc y las librerias de sqlite
RUN apk add --no-cache gcc musl-dev sqlite-dev
WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY . .
# CGO_ENABLED=1 necesario porque go-sqlite3 usa codigo C
RUN CGO_ENABLED=1 go build -o catalog .

# Stage 2: imagen final minima
FROM alpine:3.21
RUN apk add --no-cache sqlite-libs
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=builder /app/catalog .
USER appuser
EXPOSE 8080
CMD ["./catalog"]
