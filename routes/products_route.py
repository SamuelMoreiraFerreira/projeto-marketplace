from flask import Blueprint, jsonify, render_template
from controllers.products_controller import Products
from controllers.product_controller import Product


blueprint = Blueprint("products_route", __name__)
prefix = '/api/products'

#region Rota para Produtos em Destaques

@blueprint.route('/get-highlights/<length>')
def products_highlights (length):

    data = []

    for highlight in Products.get_highlights(length):

        data.append(

            Product.get_by_id(highlight['product_id'])

        )

    return data

#endregion

@blueprint.route("/get-all")
def catalog_page():

    products = jsonify(Products.get_all())

    return products