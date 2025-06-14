import os
import importlib.util as imp
from flask import jsonify

class Routes:

    @staticmethod
    def default_response(status_code, data=None):

        if not status_code:

            return ''

        # '**' -> Nesse contexto, desempacotamento de dicionário

        return jsonify({

            'status_code': status_code,
            'data': data

        })

    @staticmethod
    def get_blueprints (routes_path):

        routes = []

        # '.listdir(path)' -> Lista todos os arquivos em pasta de um diretório

        for filename in os.listdir(routes_path):

            # '.path.join()' -> União de partes de diretórios de forma segura (Portabilidade entre sistemas)

            filepath = os.path.join(routes_path, filename)

            if os.path.isfile(filepath) and filename.endswith('.py'):

                #region Importação Dinâmica de Módulos
            
                # spec -> Especificação, um objeto que contém informações necessárias para o interpretador do Python carregar e executar um módulo

                # '.spec_from_file_location(module_name, path)' -> Cria uma spec do módulo a partir do diretório do arquivo

                spec = imp.spec_from_file_location('routes.' + filename[:-3], filepath)

                # '.module_from_spec(spec)' -> Instanciamos um objeto de módulo vazio com base na spec - preparando o local para receber o conteúdo

                module = imp.module_from_spec(spec)

                # '.loader.exec_module(module)' -> Executa o conteúdo dentro do módulo criado (Realiza de fato o import)

                spec.loader.exec_module(module)

                #endregion

                # 'hasattr(obj, atr)' -> Verifica atributos de um objeto

                if hasattr(module, 'blueprint'):

                    # 'getattr(obj, atr)' -> Resgata atributos de um objeto

                    routes.append({

                        'blueprint': getattr(module, 'blueprint'),
                        'prefix': getattr(module, 'prefix') if hasattr(module, 'prefix') else ''

                    })

                else:

                    print('Erro ao carregar o arquivo: ' + filename)

        return routes