FROM python:3.9-slim

WORKDIR /app

COPY . /app

RUN pip install --no-cache-dir flask psycopg2-binary

EXPOSE 5000

CMD ["python", "app.py"]
