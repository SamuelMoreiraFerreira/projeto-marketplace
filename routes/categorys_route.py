from flask import Blueprint
from controllers.categorys_controller import Categorys
from controllers.routes_controller import Routes

blueprint = Blueprint("categorys_route", __name__)
prefix = '/api/categorys'

#region Rota Get Categorys Bloons

@blueprint.route('/bloons')
def category_bloons ():

    categorys_bloons = Categorys.bloons()

    if categorys_bloons:

        return Routes.default_response(200, category_bloons)
    
    else:

        return Routes.default_response(500)

#endregion

#region Rota Get Categorys Monkeys

@blueprint.route('/monkeys')
def category_monkeys ():

    categorys_monkeys = Categorys.monkeys()

    if categorys_monkeys:

        return Routes.default_response(200, category_monkeys)
    
    else:

        return Routes.default_response(500)

#endregion