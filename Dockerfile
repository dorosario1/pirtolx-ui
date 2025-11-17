# ------------------------------------------------
# 1) BUILDER - compile Next.js
# ------------------------------------------------
FROM node:20-alpine AS builder
WORKDIR /app

# Install system deps
RUN apk add --no-cache libc6-compat

# Install only production deps needed for the build
COPY package.json package-lock.json ./
RUN npm ci --legacy-peer-deps

# Copy project
COPY . .

# Build Next.js
RUN npm run build

# ------------------------------------------------
# 2) RUNNER - ultra light
# ------------------------------------------------
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000

# Copy only necessary build output
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Install ONLY production dependencies
RUN npm ci --omit=dev --legacy-peer-deps

EXPOSE 3000

CMD ["node", "node_modules/next/dist/bin/next", "start", "-p", "3000"]
