from data.connection_controller import Connection
from mysql.connector import Error

class Categorys:

    @staticmethod
    def bloons():

        connection_db = Connection.create()
        cursor = connection_db.cursor(dictionary=True)

        try:

            cursor.execute('SELECT tb_bloons_types.type AS "name", tb_bloons_types.type_id AS "id" FROM tb_bloons_types;')

            return cursor.fetchall()

        except Error as e:

            print(f'Erro - Categorys "bloons": {e}')
            
            return False

        finally:

            cursor.close()
            connection_db.close()

    @staticmethod
    def monkeys():

        connection_db = Connection.create()
        cursor = connection_db.cursor(dictionary=True)

        try:

            cursor.execute('SELECT tb_monkeys_classes.class AS "name", tb_monkeys_classes.description, tb_monkeys_classes.class_id AS "id" FROM tb_monkeys_classes;')

            return cursor.fetchall()

        except Error as e:

            print(f'Erro - Categorys "monkeys": {e}')
            
            return False

        finally:

            cursor.close()
            connection_db.close()