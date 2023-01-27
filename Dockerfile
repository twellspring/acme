FROM python:3.12-rc-slim-buster

WORKDIR /

COPY src/* ./
RUN pip3 install -r requirements.txt

EXPOSE 8080
CMD [ "python3", "./app.py"]
