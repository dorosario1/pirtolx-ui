# ---------- BUILDER ----------
FROM node:20-slim AS builder

WORKDIR /app

# Install OS deps for sharp
RUN apt-get update && apt-get install -y \
    libc6-dev \
    libvips-dev \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy critical files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy all sources
COPY . .

# Production build
RUN npm run build


# ---------- RUNNER ----------
FROM node:20-slim AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000

# Copy only what is needed for runtime
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Install only prod deps
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

EXPOSE 3000

CMD ["npm", "start"]
