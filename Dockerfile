# ---------- BUILDER ----------
FROM node:20-alpine AS builder

WORKDIR /app

# Install system deps
RUN apk add --no-cache libc6-compat

# Install deps (production + build tools)
COPY package.json package-lock.json ./
RUN npm ci

# Copy full project
COPY . .

# Build Next.js
RUN npm run build


# ---------- RUNNER ----------
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000

# Only copy necessary build output
COPY --from=builder /app/package.json ./ 
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Install ONLY production deps
RUN npm ci --omit=dev

EXPOSE 3000

CMD ["npm", "start"]
