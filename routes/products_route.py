from flask import Blueprint, jsonify
from controllers.products_controller import Products


blueprint = Blueprint("products_route", __name__)
prefix = '/api/products'

#region Rota para Produtos em Destaques

@blueprint.route('/get-highlights/<length>')
def products_highlights (length):

    return Products.get_highlights(length)

#endregion

@blueprint.route("/get-all")
def catalog_page():

    products = jsonify(Products.get_all())

    return products