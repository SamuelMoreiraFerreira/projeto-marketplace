from flask import Blueprint, request, jsonify
from controllers.comments_controller import Comments
from controllers.routes_controller import Routes

blueprint = Blueprint('commetnsapi_route', __name__)
prefix = '/api/comments'

@blueprint.route('/get-all/<product_id>')
def comments_by_product(product_id):

    comments = Comments.get_all_by_product(product_id)

    if comments:

        return Routes.default_response(200, { 

            'product_id': product_id,
            'comments': comments

        })

    else:

        return Routes.default_response(500)
    
@blueprint.route('/create/', methods=['POST'])
def comments_create():

    pass