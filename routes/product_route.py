from flask import Blueprint, jsonify, Response
import json
from controllers.product_controller import Product

blueprint = Blueprint("product_route", __name__)
prefix = '/api/product'

#region Rota para Get Produto

@blueprint.route('/get/<id>')
def product_get (id):

    product = Product.get_by_id(id)

    return jsonify(product)

#endregion