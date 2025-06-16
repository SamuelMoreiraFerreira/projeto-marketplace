from flask import Blueprint
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

    products = Products.get_all()

    if products:

        return Routes.default_response(200, products)

    else:

        return Routes.default_response(500)