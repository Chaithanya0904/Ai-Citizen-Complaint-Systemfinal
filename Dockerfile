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

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

# IMPORTANT for SocketIO + Gunicorn + Gevent:
# We use -k gevent to support WebSockets. 
# We use --worker-connections 1000 to handle many concurrent SocketIO clients.
CMD ["sh", "-c", "gunicorn -k gevent --worker-connections 1000 --workers 1 --bind 0.0.0.0:$PORT --timeout 120 app:app"]
