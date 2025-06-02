from flask import Blueprint
from controllers.user_controller import User

blueprint = Blueprint('api_route', __name__)
prefix = '/api'

@blueprint.route('/users/validate/')
def user_validate():

    cuzin = User().validate('samuel.mferreira205@gmail.com', 'yu241958')

    return str(cuzin)