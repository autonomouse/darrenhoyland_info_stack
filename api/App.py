#!/usr/bin/env python3
# encoding: UTF-8

import json
from flask import Flask, jsonify


app = Flask(__name__)

def getJSON(filename):
    with open(f"{filename}.json", 'r') as f:
        return json.loads(f.read())

@app.route('/resume')
def resume():
    return_value = getJSON('data/resume-data')
    response = jsonify(return_value)
    response.status_code = 200
    return response
