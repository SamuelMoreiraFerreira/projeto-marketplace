from flask import Blueprint, request, jsonify
from controllers.cart_controller import Carts
from controllers.routes_controller import Routes

blueprint = Blueprint('cart_route', __name__)
prefix = '/api/carts'
 
@blueprint.route('/get/<cart_id>')
def cart_get(cart_id):

    data = Carts.get_by_id(cart_id)

    if data:

        return Routes.default_response(200, { 'data': data })
    
    else:

        return Routes.default_response(500)