from flask import Blueprint, render_template

blueprint = Blueprint('main_route', __name__)

@blueprint.route('/')
def main_page():

    return render_template('page_inicial.html')

@blueprint.route('/catalogo')
def catalogo_page():

    return render_template('page_catalogo.html')