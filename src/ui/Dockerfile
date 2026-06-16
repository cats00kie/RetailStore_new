# Stage 1: build
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: imagen final minima
FROM node:22-alpine
RUN apk upgrade --no-cache && npm install -g npm@latest
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/public ./public
USER appuser
ENV PORT=8080
EXPOSE 8080
CMD ["node", "dist/app.js"]
