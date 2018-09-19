FROM python:3.6-alpine

WORKDIR /app

# Install dependencies.
ADD requirements.txt /app
RUN cd /app && \
    pip install -r requirements.txt
    pip install requests
# Add actual source code.
ADD blockchain.py /app

EXPOSE 5000

CMD ["python", "blockchain.py", "--port", "5000"]
