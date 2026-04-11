FROM python:3.9-slim
WORKDIR /app2
COPY app2/ .
RUN pip install -r requirements.txt
EXPOSE 5001
CMD ["python", "app2.py"]
