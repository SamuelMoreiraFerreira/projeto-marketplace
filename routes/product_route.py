from flask import Blueprint, jsonify, render_template
from controllers.product_controller import Product


blueprint = Blueprint("product_route", __name__)

@blueprint.route("/products")
def catalog_page():

    products = jsonify(Product.get_products())

    return  render_template("page_catalogo.html",products=products)

@blueprint.route("/product/<code>")
def product_page(code):

    product = jsonify(Product.get_product(code))
    images = jsonify(Product.get_product_images(code))

    return product
    # return  render_template("page_produto.html",product=product,images=images)

