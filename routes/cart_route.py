from flask import Blueprint, request
from controllers.cart_controller import Carts
from controllers.routes_controller import Routes

blueprint = Blueprint('cart_route', __name__)
prefix = '/api/carts'
 
@blueprint.route('/create/')
def cart_create():

    pass

# /add-item/<cart_id>?product_id=<product_id>&quantity=<quantity>

@blueprint.route('/add-item/<cart_id>')
def cart_add_item(cart_id):

    product_id = request.args.get('product_id', type=int)
    quantity = request.args.get('quantity', type=int)

    if Carts.add_item(cart_id, product_id, quantity):

        return Routes.default_response(200)
    
    else:

        return Routes.default_response(500)
    

@blueprint.route('/get/<cart_id>')
def cart_get(cart_id):

    data = Carts.get_by_id(cart_id)

    if data:

        return Routes.default_response(200, { 'data': data })
    
    else:

        return Routes.default_response(500)
    
@blueprint.route('/delete/<cart_id>')
def cart_delete(cart_id):

    if Carts.delete(cart_id):

        return Routes.default_response(200)

    else:

        return Routes.default_response(500)
    
@blueprint.route('/delete-product/<cart_id>/<cart_product_id>')
def cart_delete_product(cart_id, cart_product_id):

    if Carts.delete_product(cart_id, cart_product_id):

        return Routes.default_response(200)

    else:

        return Routes.default_response(500)