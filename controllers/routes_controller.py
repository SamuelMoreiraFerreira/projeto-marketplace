import os
import importlib.util as imp

def getBlueprints (routes_path):

    routes = []

    for filename in os.listdir(routes_path):

        filepath = os.path.join(routes_path, filename)

        if os.path.isfile(filepath) and filename.endswith('.py'):

            # module spec -> Especificação, um objeto que contém informações necessárias para o interpretador do Python carregar e executar um módulo

            spec = imp.spec_from_file_location('routes.' + filename[:-3], filepath)
            module = imp.module_from_spec(spec)
            spec.loader.exec_module(module)

            # hasattr -> Verifica atributos do módulo

            if hasattr(module, 'blueprint'):

                # getattr -> Resgata atributos do módulo

                routes.append({

                    'blueprint': getattr(module, 'blueprint'),
                    'prefix': getattr(module, 'prefix') if hasattr(module, 'prefix') else ''

                })

            else:

                print('Erro ao carregar o arquivo: ' + filename)

    return routes