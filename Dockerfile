# -------------------------------------------------
# BUILDER — compile Next.js en production
# -------------------------------------------------
FROM node:20-alpine AS builder

WORKDIR /app

# Copier les fichiers de dépendances (sans erreur si lockfile absent)
COPY package.json ./
COPY package-lock.json* ./
COPY yarn.lock* ./
COPY pnpm-lock.yaml* ./

# Installer les dépendances
RUN npm ci || npm install

# Copier le reste du code
COPY . .

# Build Next.js
RUN npm run build

# -------------------------------------------------
# RUNNER — image finale ultra légère
# -------------------------------------------------
FROM node:20-alpine AS runner

WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000

# Copier seulement les fichiers nécessaires
COPY --from=builder /app/package.json ./
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Installer uniquement les dépendances prod
RUN npm ci --omit=dev || npm install --omit=dev

EXPOSE 3000
CMD ["npm", "start"]
