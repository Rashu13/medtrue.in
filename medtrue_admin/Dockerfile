# Stage 1: Build
FROM mirror.gcr.io/library/node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Serve
FROM mirror.gcr.io/library/nginx:1.27-alpine

# Set working directory
WORKDIR /usr/share/nginx/html

# Copy build output and config
COPY --from=build /app/dist .
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Install curl for health check
RUN apk add --no-cache curl

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -f http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
