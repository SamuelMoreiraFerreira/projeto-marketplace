from flask import Blueprint, render_template, session
from controllers.product_controller import Product
from controllers.comments_controller import Comments

blueprint = Blueprint('main_route', __name__)

@blueprint.route('/')
def main_page():

    return render_template('page_inicial.html')

@blueprint.route('/catalog')
def catalog_page():

    return render_template('page_catalogo.html')

@blueprint.route('/product/<product_id>')
def product_page(product_id):

    product_data = Product.get_by_id(product_id)
    comments_data = Comments.get_all_by_product(product_id)

    product_data['rate_quantity'] = len(comments_data)

    return render_template('page_produto.html', is_login=('user' in session), product=product_data, comments=comments_data)

@blueprint.route('/register')
def register_page():

    return render_template('page_cadastro.html')

@blueprint.route('/login')
def login_page():

    return render_template('page_login.html')

@blueprint.route('/cart')
def cart_page():

    return render_template('page_carrinho.html')