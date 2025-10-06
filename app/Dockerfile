# ------------------------------
# Stage 1: Build dependencies
# ------------------------------
FROM python:3.11-slim AS builder

WORKDIR /app

# Install build tools (only in builder image)
RUN apt-get update && apt-get install -y --no-install-recommends gcc

# Copy requirements and install dependencies into a clean virtual environment
COPY requirements.txt .
RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip \
    && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

# ------------------------------
# Stage 2: Runtime image
# ------------------------------
FROM python:3.11-slim AS runtime

# Copy only virtual environment from builder
COPY --from=builder /opt/venv /opt/venv

# Set PATH so we use venv by default
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /app

# Copy application code
COPY . .

# Create non-root user
RUN useradd -m appuser
USER appuser

EXPOSE 8080

# Healthcheck (optional but professional)
HEALTHCHECK CMD curl --fail http://localhost:8080/healthz || exit 1

# Use Gunicorn as production WSGI server
CMD ["gunicorn", "-b", "0.0.0.0:8080", "app:app", "--workers", "2", "--threads", "4"]
