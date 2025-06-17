from flask import Blueprint, request, session
from controllers.user_controller import User
from controllers.routes_controller import Routes

blueprint = Blueprint('user_route', __name__)
prefix = '/api/users'

@blueprint.route('/logged')
def user_logged():
    
    if 'user' in session:
        
        return Routes.default_response(200, { 'is_logged': True, 'user_data': session['user'] })
    
    else:
        
        return Routes.default_response(200, { 'is_logged': False })

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
    password = request.form.get('senha')

    name = (request.form.get('nome') or []).split(' ')

    phone_number = request.form.get('telefone')
    address = request.form.get('endereco')

    # Sucesso - Usuário Criado

    if len(name) >= 2 and User.create(

        email, password, 
        name[0], ' '.join(name[1:]), 
        phone_number, address

    ):

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