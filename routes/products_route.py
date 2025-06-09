from flask import Blueprint, jsonify, render_template
from controllers.products_controller import Products


blueprint = Blueprint("products_route", __name__)
prefix = '/api/products'

#region Rota para Produtos em Destaques

@blueprint.route('/get-highlights')
def products_highlights ():

    return Products.get_highlights(4)

#endregion

@blueprint.route("/products")
def catalog_page():

    products = jsonify(Products.get_products())

    return  render_template("page_catalogo.html",products=products)

@blueprint.route("/product/<code>")
def product_page(code):

    product = jsonify(Products.get_product(code))
    images = jsonify(Products.get_product_images(code))

    return product
    # return  render_template("page_produto.html",product=product,images=images)

