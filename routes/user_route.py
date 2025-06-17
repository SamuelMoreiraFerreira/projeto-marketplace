from flask import Blueprint, request, jsonify
from controllers.user_controller import User
from controllers.routes_controller import Routes

blueprint = Blueprint('user_route', __name__)
prefix = '/api/users'

@blueprint.route('/validate/', methods=['POST'])
def user_validate():

    email = request.form.get('email')
    password = request.form.get('senha')
    
    # Sucesso - Usuário Encontrado

    if User.validate(email, password):

        return Routes.default_response(200)
    
    # Erro

    else:

        return Routes.default_response(500)
    
@blueprint.route('/delete/<email>')
def user_delete(email):

    # Sucesso - Usuário Excluído

    if User.delete(email):

        return Routes.default_response(200)
    
    # Erro

    else:

        return Routes.default_response(500)
    
@blueprint.route('/create/', methods=['POST'])
def user_create():

    email = request.form.get('email')
    password = request.form.get('password')

    first_name = request.form.get('first_name')
    last_name = request.form.get('last_name')

    phone_number = request.form.get('phone_number')
    address = request.form.get('address')

    # Sucesso - Usuário Criado

    if User.create({

        email, password, 
        first_name, last_name, 
        phone_number, address

    }):

        return Routes.default_response(200)
    
    # Erro

    else:

        return Routes.default_response(500)
    
@blueprint.route('/login/<email>')
def user_login(email):
    
    if User.login(email):
        
        return Routes.default_response(200)
    
    else:
        
        return Routes.default_response(500)

@blueprint.route('/logout')
def user_logout():
    
    if User.logout():
        
        return Routes.default_response(200)
    
    else:
        
        return Routes.default_response(500)

@blueprint.route('/get-data/<email>')
def user_getdata(email):

    data = User.get_data(email)

    # Sucesso - Usuário Encontrado

    if data:

        return Routes.default_response(200, { 'user-data': data })
    
    # Erro

    else:

        return Routes.default_response(500)