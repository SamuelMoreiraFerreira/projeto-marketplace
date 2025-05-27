from flask import Flask
import os
from src.controllers.routes_controller import getBlueprints

app = Flask(__name__)

#region Handler Routes

for route in getBlueprints(os.path.abspath('./src/routes/')):

    # blueprint -> opção para agrupar um conjunto de rotas, manipulação de formulários, templates, etc.

    app.register_blueprint(route['blueprint'], url_prefix=route['prefix'])

#endregion


if __name__ == '__main__':

    app.run(debug=True, host='0.0.0.0', port=8080)