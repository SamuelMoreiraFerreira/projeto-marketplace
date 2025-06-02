from flask import Blueprint
from controllers.users_controllers import Users

blueprint = Blueprint('api_route', __name__)
prefix = '/api'

@blueprint.route('/users/validate/')
def main_page():

    cuzin = Users().validate('samuel.mferreira205@gmail.com', 'yu241958')

    print(cuzin)

    return 'HOLA'