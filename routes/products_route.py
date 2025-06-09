from flask import Blueprint, jsonify, render_template
from controllers.products_controller import Products
from controllers.product_controller import Product


blueprint = Blueprint("products_route", __name__)
prefix = '/api/products'

#region Rota para Produtos em Destaques

@blueprint.route('/get-highlights')
def products_highlights ():

    data = []

    for i in Products.get_highlights(4):

        data.append(

            Product.get_by_id(i['product_id'])

        )

    return data

#endregion

@blueprint.route("/products")
def catalog_page():

    products = jsonify(Products.get_products())

    return  render_template("page_catalogo.html",products=products)