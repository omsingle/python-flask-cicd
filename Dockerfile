FROM python:3.13-slim

WORKDIR /app

COPY app/requirements.txt .

RUN pip install -r requirements.txt

COPY app/app.py .

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
