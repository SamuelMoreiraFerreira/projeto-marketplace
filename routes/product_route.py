from flask import Blueprint
from controllers.product_controller import Product
from controllers.routes_controller import Routes

blueprint = Blueprint("product_route", __name__)
prefix = '/api/product'

#region Rota para Get Produto

@blueprint.route('/get/<id>')
def product_get (id):

    product = Product.get_by_id(id)

    if product:

        return Routes.default_response(200, product)
    
    else:

        return Routes.default_response(500)

#endregion