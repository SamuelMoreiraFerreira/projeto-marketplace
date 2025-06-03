from flask import Blueprint

blueprint = Blueprint('main_route', __name__)

@blueprint.route('/')
def main_page():

    return 'Hello World'