from flask import Blueprint, request
from controllers.products_controller import Products
from controllers.routes_controller import Routes

blueprint = Blueprint("products_route", __name__)
prefix = '/api/products'

#region Rota para Produtos em Destaques

@blueprint.route('/get-highlights/<length>')
def products_highlights (length):

    highlights = Products.get_highlights(length)

    if highlights:

        return Routes.default_response(200, highlights)

    else:

        return Routes.default_response(500)

#endregion

@blueprint.route("/get-all")
def catalog_page():

    f_type = request.args.get('type', type=int) or 0
    f_class_id = request.args.get('class_id', type=int) or 0
    f_bloon_type_id = request.args.get('bloon_type_id', type=int) or 0
    
    f_order = request.args.get('order', type=int) or 0

    filters = {

        'type': f_type,

        'class_id': f_class_id,
        'bloon_type_id': f_bloon_type_id,

    }

    products = Products.get_all(filters, f_order)

    if products:

        return Routes.default_response(200, products)

    else:

        return Routes.default_response(500)