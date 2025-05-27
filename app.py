from flask import Flask
from controllers.routes_controller import getBlueprints

app = Flask(__name__)

@app.route('/')
def main_page():

    return 'Hello World'

#region Handler Routes

#endregion

app.run(host='0.0.0.0', port=8080)