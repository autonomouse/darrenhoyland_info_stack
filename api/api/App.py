#!/usr/bin/env python3
# encoding: UTF-8

import json
from pathlib import Path
from flask import Flask, jsonify


app = Flask(__name__)
app.config['JSONIFY_PRETTYPRINT_REGULAR'] = False

def getJSON(filename):
    with open(f"{Path(__file__).parent}/{filename}.json", 'r') as f:
        return json.loads(f.read())

@app.route('/resume')
def resume():
    return_value = getJSON('data/resume-data')
    response = jsonify(return_value)
    response.status_code = 200
    return response
