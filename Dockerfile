FROM python:3.11-slim

# System deps (git for editable installs; build tools for wheels)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates git build-essential \
  && rm -rf /var/lib/apt/lists/*

# Install uv (https://github.com/astral-sh/uv)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh -s -- --yes
ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app

# Pre-copy lockfiles to leverage Docker layer caching for deps
COPY pyproject.toml uv.lock ./
# Install deps into a managed .venv (without project files yet)
RUN uv sync --frozen --no-install-project || true

# Copy the rest of the project
COPY . .

# Finalize dependency install (in case extras/plugins referenced in src)
RUN uv sync --frozen

# Default command can be overridden by docker-compose
CMD ["uv", "run", "python", "main.py"]
