from data.connection_controller import Connection
from mysql.connector import Error

class Users:

    @staticmethod
    def validate(user, password):

        connection_db = Connection.create()
        cursor = connection_db.cursor()

        try:

            # 'multi=True' -> Permite múltiplas intruções SQL

            cursor.execute('CALL checkPassword(%s, %s, @result); SELECT @result;', (user, password), multi=True)

            result = cursor.fetchone()

            print(result)

            return result

        except Error as e:

            print(f'Error Validação de Usuários: {e}')

            return False
        
        finally:

            cursor.close()
            connection_db.close()
