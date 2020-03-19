FROM python:3.7.5-alpine3.10

COPY ./requirements.txt /
COPY ./gunicorn.conf /
COPY ./setup.py /
COPY ./README.md /
COPY ./requirements.txt /
COPY ./dev_requirements.txt /
COPY ./demo /demo/
WORKDIR /

RUN adduser -h /home/service -D -g "" -s /bin/bash service && \
    apk update && apk add postgresql-dev && \
    apk --no-cache add libc-dev && \
    apk add -t build-dependencies libffi-dev build-base && \
    pip install --upgrade pip && pip install -r requirements.txt && \
    python setup.py install && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/*

USER service
ENV GUNICORN_WORKERS=5

EXPOSE 8000
ENTRYPOINT ["/usr/local/bin/gunicorn", "--config", "/gunicorn.conf", "-b", ":8000", "demo.app:production"]
