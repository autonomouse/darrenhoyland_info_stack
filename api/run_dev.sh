#!/usr/bin/env bash

echo "*** Running app via gunicorn ***"

gunicorn3 App:app

echo "------------------------------------------------------------------------"
