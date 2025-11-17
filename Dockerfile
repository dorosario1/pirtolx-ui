# --------------------------
# 1. Builder
# --------------------------
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package manifests
COPY package.json package-lock.json ./

# Install deps (safe)
RUN npm install

# Copy all project files
COPY . .

# Build Next.js
RUN npm run build


# --------------------------
# 2. Production Runner
# --------------------------
FROM node:20-alpine AS runner

WORKDIR /app
ENV NODE_ENV=production

# Only keep what is needed
COPY --from=builder /app/package.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Install ONLY production dependencies
RUN npm install --omit=dev

EXPOSE 3000

CMD ["npm", "start"]
