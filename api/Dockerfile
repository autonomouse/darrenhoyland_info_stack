FROM python:3.7.5
RUN mkdir /app
WORKDIR /app

RUN adduser -h /home/service -D -g "" -s /bin/bash service
USER service
RUN pip install poetry
RUN poetry config settings.virtualenvs.create false
COPY poetry.lock pyproject.toml README.md /app/

# to prevent poetry from installing my actual app,
# and keep docker able to cache layers
RUN mkdir -p /api/api
RUN touch /api/api/__init__.py

RUN poetry install -n

# now actually copy the real contents of my app
COPY app /api/api

EXPOSE 8000

CMD ["gunicorn", "--config", "gunicorn.conf", "--bind", ":8000", "api.App:app"]
