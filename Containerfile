ARG ARG_PORT=5000
ARG ARG_MAX_REQUESTS=0
ARG ARG_MAX_REQUESTS_JITTER=0

# Prep everything
FROM docker.io/python:3.10-bullseye as build

# Create the memegen user
RUN useradd -md /opt/memegen -u 1000 memegen
USER memegen

# Set the Working Directory to /opt/memegen
WORKDIR /opt/memegen

# Copy Directories
COPY templates /opt/memegen/templates
COPY scripts /opt/memegen/scripts
COPY fonts /opt/memegen/fonts
COPY docs /opt/memegen/docs
COPY bin /opt/memegen/bin
COPY app /opt/memegen/app

# Copy Specific Files
COPY requirements.txt /opt/memegen
COPY pyproject.toml /opt/memegen/
COPY runtime.txt /opt/memegen/
COPY CHANGELOG.md /opt/memegen/CHANGELOG.md

# Install Python Requirements
RUN pip install wheel && \
    pip install -r /opt/memegen/requirements.txt

# Set the environment variables
ENV PATH="/opt/memegen/.local/bin:${PATH}"
ENV PORT="${ARG_PORT:-5000}"
ENV MAX_REQUESTS="${ARG_MAX_REQUESTS:-0}"
ENV MAX_REQUESTS_JITTER="${ARG_MAX_REQUESTS_JITTER:-0}"

# Set the entrypoint
ENTRYPOINT gunicorn --bind "0.0.0.0:$PORT" \
    --worker-class uvicorn.workers.UvicornWorker  \
    --max-requests="$MAX_REQUESTS" \
    --max-requests-jitter="$MAX_REQUESTS_JITTER" \
    --timeout=20  \
    app.main:app
