from flask import session
from data.connection_controller import Connection
from mysql.connector import Error

class User:

    @staticmethod
    def login(email):

        user_data = User.get_data(email)

        if user_data:

            session['user'] = user_data
            return True

        else:

            return False

    @staticmethod   
    def get_session():

        if 'user' in session:

            return session['user']
        
        else:

            return False

    @staticmethod
    def logout():

        session.clear()

        return True

    # '**' -> Indica para a função a presença de argumentos nomeados extras (Argumentos que você especifica o nome do parâmetro junto com seu valor)

    @staticmethod
    def create(email, password, first_name, last_name, phone_number, address):

        connection_db = Connection.create()
        cursor = connection_db.cursor()

        try:

            cursor.execute(
                
                """
                INSERT INTO tb_users (email, first_name, last_name, phone_number, address, password) VALUES (%s, %s, %s, %s, %s, %s);
                """,
                
                (

                    email,
                    first_name,
                    last_name,
                    phone_number or None,
                    address,
                    password

                ), 
                
            )

            connection_db.commit()

            return True

        except Error as e:

            print(f'Erro - User "create": {e}')
            
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

            connection_db.commit()

            if cursor.rowcount > 0:

                return True
            
            else:

                return False

        except Error as e:

            print(f'Erro - User "delete": {e}')
            
            return False

        finally:

            cursor.close()
            connection_db.close()

    @staticmethod
    def get_data(email):

        connection_db = Connection.create()
        cursor = connection_db.cursor(dictionary=True)

        try:

            cursor.execute('SELECT tb_users.email, tb_users.first_name, tb_users.last_name, tb_users.phone_number, tb_users.address FROM tb_users WHERE tb_users.email = %s;', (email, ))

            user = cursor.fetchone()

            if user:

                return user
            
            else:

                return False

        except Error as e:

            print(f'Erro - User "get_data": {e}')
            
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

            # 'multi=True' -> Permite múltiplas instruções SQL
            # Resume: "cursor.execute('CALL procedure_name; SELECT @valueOUT;', multi=TRUE)"

            response_procedure = cursor.callproc('checkPassword', (email, password, 0))

            return response_procedure[2] == 1

        except Error as e:

            print(f'Erro - User "validate": {e}')
            
            return False

        finally:

            cursor.close()
            connection_db.close()