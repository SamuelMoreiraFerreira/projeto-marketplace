from flask import Blueprint, request, jsonify
from controllers.comments_controller import Comments
from controllers.routes_controller import Routes

blueprint = Blueprint('comments_route', __name__)
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
    
@blueprint.route('/create/<product_id>', methods=['POST'])
def comments_create(product_id):

    data = request.get_json()

    user_email = data.get('user_email')

    message = data.get('message')
    rating = data.get('rating')

    if Comments.create(

        user_email, product_id,
        message, rating

    ):
        
        return Routes.default_response(200)
    
    else:

        return Routes.default_response(500)
    
@blueprint.route('/delete/<comment_id>')
def comments_delete(comment_id):

    if Comments.delete(comment_id):
        
        return Routes.default_response(200)
    
    else:

        return Routes.default_response(500)