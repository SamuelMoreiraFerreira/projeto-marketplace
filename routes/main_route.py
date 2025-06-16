from flask import Blueprint, render_template
from controllers.product_controller import Product
from controllers.comments_controller import Comments

blueprint = Blueprint('main_route', __name__)

@blueprint.route('/')
def main_page():

    return render_template('page_inicial.html')

@blueprint.route('/catalog')
def catalogo_page():

    return render_template('page_catalogo.html')

@blueprint.route('/product/<product_id>')
def produto_page(product_id):

    product_data = Product.get_by_id(product_id)
    comments_data = Comments.get_all_by_product(product_id)

    product_data['rate_quantity'] = len(comments_data)
    product_data['price'] = str(product_data['price']).replace('.', ',') 

    return render_template('page_produto.html', product=product_data, comments=comments_data)