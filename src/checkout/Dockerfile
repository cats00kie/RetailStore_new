# Stage 1: build
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn
RUN yarn install
COPY . .
RUN yarn build

# Stage 2: imagen final
FROM node:22-alpine
RUN apk upgrade --no-cache && npm install -g npm@latest
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
USER appuser
EXPOSE 8080
CMD ["node", "dist/main.js"]
