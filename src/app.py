#!/usr/bin/env python3

from flask import Flask

app = Flask(__name__)


@app.route("/")
def hello():
    return "<html><body><center><h1>Acme Company<h1><h2>The World Famous Anvil Support Portal</h2><h3>Is your anvil not working correctly? We can help you fix it or will replace it for free (certain exclusions apply to Wile E Coyote).</h3><img src='https://i.pinimg.com/736x/fb/f4/39/fbf439f72e30ed5924c78161e1b34589--bugs-bunny-bronze-sculpture.jpg'></center></body></html>  "


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)
