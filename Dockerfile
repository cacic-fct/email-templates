# Build
FROM oven/bun:1-alpine AS base

WORKDIR /app

COPY package.json bun.lockb .

FROM base AS prod-deps
RUN bun install --omit=dev --frozen-lockfile

FROM base AS build-deps
RUN bun install --frozen-lockfile

FROM build-deps AS build
COPY . .
RUN bun run build

# Serve
FROM base AS serve

COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist

USER bun
ENV HOST=0.0.0.0
EXPOSE 4321
ENTRYPOINT bun run ./dist/server/entry.mjs
