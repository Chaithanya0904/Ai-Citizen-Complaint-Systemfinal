FROM python:3.10-slim

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
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

# Changed to gthread worker class and added thread count
# --worker-class gthread: Better compatibility with C-extensions like OpenCV
# --threads 4: Allows the single worker to handle multiple concurrent requests
CMD ["sh", "-c", "gunicorn --worker-class gthread --threads 4 -w 1 app:app --bind 0.0.0.0:$PORT --timeout 120"]
