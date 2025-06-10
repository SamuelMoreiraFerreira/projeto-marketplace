from flask import Blueprint, jsonify
from controllers.categorys_controller import Categorys

blueprint = Blueprint("categorys_route", __name__)
prefix = '/api/categorys'

#region Rota Get Categorys Bloons

@blueprint.route('/bloons')
def category_bloons ():

    categorys_bloons = Categorys.bloons()

    # Sucesso

    if categorys_bloons:

        return jsonify(categorys_bloons)

#endregion

#region Rota Get Categorys Monkeys

@blueprint.route('/monkeys')
def category_monkeys ():

    categorys_monkeys = Categorys.monkeys()

    # Sucesso

    if categorys_monkeys:

        return jsonify(categorys_monkeys)

#endregion