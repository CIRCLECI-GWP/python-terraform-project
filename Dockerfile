FROM python:3.9-slim

WORKDIR /opt/hello_world/

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY hello_world.py .

EXPOSE 5000

CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "hello_world:app"]