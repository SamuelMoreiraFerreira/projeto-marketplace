from flask import Flask

app = Flask(__name__)

@app.route('/')
def main_page():

    return 'Hello World'

app.run(host='0.0.0.0', port=8080)