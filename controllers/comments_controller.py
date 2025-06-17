from data.connection_controller import Connection
from mysql.connector import Error

class Comments:

    @staticmethod
    def create(user_email, product_id, message, rating):

        connection_db = Connection.create()
        cursor = connection_db.cursor()

        try:

            cursor.execute(
                
                """
                INSERT INTO tb_comments (user_email, product_id, message, rating) VALUES (%s, %s, %s, %s);
                """,
                
                (

                    user_email,
                    product_id,

                    message,
                    rating

                ), 
                
            )

            connection_db.commit()

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

            connection_db.commit()

            if cursor.rowcount > 0:

                return True
            
            else:

                return False

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

            cursor.execute(
                
                """
                SELECT 

                    tb_comments.comment_id, 

                    CONCAT(tb_users.first_name, ' ', tb_users.last_name) AS "user", 

                    tb_comments.message, 
                    tb_comments.date, 
                    tb_comments.rating 

                FROM tb_comments 

                INNER JOIN tb_users
                    ON tb_comments.user_email = tb_users.email

                WHERE tb_comments.product_id = %s;
                """, 
                
                (product_id, )
                
            )

            return cursor.fetchall()

        except Error as e:

            print(f'Error - Comments "get_all_by_product": {e}')
            
            return False

        finally:

            cursor.close()
            connection_db.close()