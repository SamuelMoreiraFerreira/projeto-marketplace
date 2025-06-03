from flask import Flask
import os
from controllers.routes_controller import Routes

app = Flask(__name__)

#region Handler Routes

# '.path.abspath(path)' -> Converte o caminho relativo à um caminho absoluto

for route in Routes.get_blueprints(os.path.abspath('./routes/')):

    # blueprint -> Opção do Flask para agrupar um conjunto de rotas, manipulação de formulários, templates, etc.

    app.register_blueprint(route['blueprint'], url_prefix=route['prefix'])

#endregion

if __name__ == '__main__':

    app.run(debug=True, host='0.0.0.0', port=8080)