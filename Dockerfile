# ---------- BUILDER ----------
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package.json package-lock.json ./
RUN npm ci --legacy-peer-deps

# Copy source
COPY . .

# Build NEXT in production mode
RUN npm run build


# ---------- RUNNER ----------
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000

# Only copy necessary build output
COPY --from=builder /app/package.json .
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Install ONLY production dependencies
RUN npm ci --omit=dev --legacy-peer-deps

EXPOSE 3000

CMD ["npm", "start"]
