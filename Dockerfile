# Stage 1: Build frontend
FROM node:22-alpine AS frontend-build
WORKDIR /app/frontend
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# Stage 2: Production image
FROM python:3.13-slim
WORKDIR /app

COPY pyproject.toml ./
COPY backend/ ./backend/

RUN pip install --no-cache-dir -e .

# Copy built frontend into backend static dir
COPY --from=frontend-build /app/frontend/dist/ ./backend/static/

ENV PORT=3001
EXPOSE ${PORT}

CMD hermes-hudui --host 0.0.0.0 --port ${PORT}
