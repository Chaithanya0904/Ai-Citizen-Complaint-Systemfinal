FROM python:3.10-slim

# Prevent Python from writing .pyc files and enable real-time logging
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=8080

# Install system dependencies for OpenCV/X11/GL
RUN apt-get update && apt-get install -y \
    libxcb1 \
    libxkbcommon0 \
    libxkbcommon-x11-0 \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install dependencies first to leverage Docker cache
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Final Command: Using gthread to avoid the eventlet deprecation/errors
# -w 1: One worker process (good for memory-heavy OpenCV apps)
# --threads 4: Allows 4 concurrent requests within that worker
CMD ["sh", "-c", "gunicorn --worker-class gthread --threads 4 --workers 1 --bind 0.0.0.0:$PORT --timeout 120 app:app"]
