from data.connection_controller import Connection
from mysql.connector import Error

class User:

    # '**' -> Indica para a função a presença de argumentos nomeados extras (Argumentos que você especifica o nome do parâmetro junto com seu valor)

    @staticmethod
    def create(**user_data):

        connection_db = Connection.create()
        cursor = connection_db.cursor()

        try:

            # 'multi=True' -> Permite múltiplas instruções SQL

            cursor.execute(
                
                """
                INSERT INTO tb_address (cep, city, state, full_address) VALUES (%s, %s, %s, %s); 
                
                INSERT INTO tb_users (email, first_name, last_name, phone_number, address, password) VALUES (%s, %s, %s, %s, LAST_INSERT_ID(), %s);
                """,
                
                (

                    user_data.get('cep'),
                    user_data.get('city'),
                    user_data.get('state'),
                    user_data.get('full_address'),

                    user_data.get('email'),
                    user_data.get('first_name'),
                    user_data.get('last_name'),
                    user_data.get('phone_number', None),
                    user_data.get('password')

                ), 
                
                multi=True
                
            )

            cursor.commit()

            return True

        except Error as e:

            print(f'Error Validação de Usuários: {e}')
            
            return False

        finally:

            cursor.close()
            connection_db.close()

    @staticmethod
    def delete(email):

        connection_db = Connection.create()
        cursor = connection_db.cursor()

        try:

            cursor.execute('DELETE FROM tb_users WHERE tb_users.email = %s;', (email, ))

            cursor.commit()

            return True

        except Error as e:

            print(f'Error Excluindo Usuário: {e}')
            
            return False

        finally:

            cursor.close()
            connection_db.close()

    @staticmethod
    def validate(email, password):

        connection_db = Connection.create()
        cursor = connection_db.cursor()

        try:

            # '.callproc(procedure_name, args)' -> Executa a procedure e retorna os valores dos parâmetros - incluindo o valor de retorno OUT que usamos para a verificação

            # Resume: "cursor.execute('CALL procedure_name; SELECT @valueOUT;', multi=TRUE)"

            response_procedure = cursor.callproc('checkPassword', (email, password, 0))

            return response_procedure[2] == 1

        except Error as e:

            print(f'Error Validação de Usuário: {e}')
            
            return False

        finally:

            cursor.close()
            connection_db.close()