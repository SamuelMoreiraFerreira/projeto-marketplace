from data.connection_controller import Connection
from mysql.connector import Error

class Comments:

    @staticmethod
    def create(**comment_data):

        connection_db = Connection.create()
        cursor = connection_db.cursor()

        try:

            cursor.execute(
                
                """
                INSERT INTO tb_comments (user_email, product_id, message, rating) VALUES (%s, %s, %s, %s);
                """,
                
                (

                    comment_data.get('user_email'),
                    comment_data.get('product_id'),

                    comment_data.get('message'),
                    comment_data.get('rating')

                ), 
                
            )

            cursor.commit()

            return True

        except Error as e:

            print(f'Error - Comments "create": {e}')
            
            return False

        finally:

            cursor.close()
            connection_db.close()

    @staticmethod
    def delete(id):

        connection_db = Connection.create()
        cursor = connection_db.cursor()

        try:

            cursor.execute('DELETE FROM tb_comments WHERE tb_comments.comment_id = %s;', (id, ))

            cursor.commit()

            return True

        except Error as e:

            print(f'Error - Comments "delete": {e}')
            
            return False

        finally:

            cursor.close()
            connection_db.close()

    @staticmethod
    def get_all_by_product(product_id):

        connection_db = Connection.create()
        cursor = connection_db.cursor(dictionary=True)

        try:

            cursor.execute('SELECT tb_comments.comment_id, tb_comments.user_email, tb_comments.message, tb_comments.date, tb_comments.rating FROM tb_comments WHERE tb_comments.product_id = %s;', (product_id, ))

            return cursor.fetchall()

        except Error as e:

            print(f'Error - Comments "get_all_by_product": {e}')
            
            return False

        finally:

            cursor.close()
            connection_db.close()