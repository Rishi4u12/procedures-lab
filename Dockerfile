FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -U pip \
    && pip install --no-cache-dir -r requirements.txt

COPY . .

# Default port
EXPOSE 8000

# Use PORT if provided by platform (Render/Heroku), else 8000
ENV FLASK_APP=app.server
CMD ["sh", "-c", "gunicorn -w 2 -b 0.0.0.0:${PORT:-8000} app.server:app"]
