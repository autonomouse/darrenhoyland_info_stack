FROM python:3.7.5-alpine3.10
COPY ./gunicorn.conf /
COPY . /api/
WORKDIR /api
RUN adduser -h /home/service -D -g "" -s /bin/bash service && \
    apk update && apk --no-cache add curl
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python
RUN $HOME/.poetry/bin/poetry config virtualenvs.create false
RUN $HOME/.poetry/bin/poetry install -n
EXPOSE 8000
USER service
CMD ["gunicorn", "--config", "/gunicorn.conf", "--bind", ":8000", "api.App:app"]
