FROM python:3.10-slim

# Prevent Python from writing .pyc files and enable real-time logging
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies for OpenCV/X11/GL
RUN apt-get update && apt-get install -y \
    libxcb1 \
    libxkbcommon0 \
    libxkbcommon-x11-0 \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy and install requirements
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# EXPLICITLY set the worker class to gevent to avoid the eventlet crash
# -k gevent: Required for flask-socketio support
# --worker-connections: Increases how many websocket clients you can handle
CMD ["sh", "-c", "gunicorn --worker-class gevent --workers 1 --worker-connections 1000 --bind 0.0.0.0:$PORT --timeout 120 app:app"]
