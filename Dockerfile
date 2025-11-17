# ------------------------------
# 1) BUILDER – compile Next.js
# ------------------------------
FROM node:20-alpine AS builder

# Build dependencies (needed for Next.js + sharp + swc)
RUN apk add --no-cache \
    libc6-compat \
    python3 \
    make \
    g++ 

WORKDIR /app

# Copy minimal files for deterministic caching
COPY package.json package-lock.json ./

# Install ALL dependencies (prod + dev)
RUN npm ci --legacy-peer-deps

# Copy app source
COPY . .

# Build the production bundle
RUN npm run build


# ------------------------------
# 2) RUNNER – ultra-light image
# ------------------------------
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000

# Copy only the necessary output from build stage
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

EXPOSE 3000

CMD ["node", "node_modules/next/dist/bin/next", "start", "-p", "3000"]
