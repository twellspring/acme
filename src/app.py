#!/usr/bin/env python3

from flask import Flask

app = Flask(__name__)


@app.route("/")
def hello():
    return "<h1>Acme Company Anvil Support Portal</h1><h2>If your anvil is not working correctly, we can help you fix it.</h2><img src='https://i.pinimg.com/736x/fb/f4/39/fbf439f72e30ed5924c78161e1b34589--bugs-bunny-bronze-sculpture.jpg'>  "


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)
