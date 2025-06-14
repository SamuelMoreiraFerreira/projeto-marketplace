from data.connection_controller import Connection
from mysql.connector import Error

class Carts:

    def get_by_id (id):

        connection_db = Connection.create()
        cursor = connection_db.cursor(dictionary=True)

        try:

            cursor.execute(

                """
                SELECT 
                    tb_shopping_cart.user_email,
                    GROUP_CONCAT(
                        CONCAT(
                            tb_cart_products.cart_product_id, ":",
                            tb_cart_products.product_id, ":",
                            tb_cart_products.quantity                       
                        ) SEPARATOR "|"
                    ) AS "products"
                FROM tb_shopping_cart
                INNER JOIN tb_cart_products
                    ON tb_shopping_cart.cart_id = tb_cart_products.cart_id
                WHERE tb_shopping_cart.cart_id = %s;
                """,

                (id, )

            )

            response = cursor.fetchone()

            data = {

                'user': response['user_email'],

                'products': []

            }

            keys = ('cart_product_id', 'product_id', 'quantity')

            for product in (response['products'].split('|')):

                data['products'].append(

                    dict.fromkeys(
                        keys,
                        tuple(product.split(':'))
                    )

                )

            print(data)

            return data
        
        except Error as e:

            print(f'Erro - Cart "get_by_id": {e}')

            return False
        
        finally:

            cursor.close()
            connection_db.close()

    def delete (id):

        connection_db = Connection.create()
        cursor = connection_db.cursor(dictionary=True)

        try:

            cursor.execute('DELETE FROM tb_cart_products WHERE tb_cart_products.cart_id = %s', (id, ))

            cursor.commit()

            return True
        
        except Error as e:

            print(f'Erro - Cart "delete": {e}')

            return False
        
        finally:

            cursor.close()
            connection_db.close()

    def delete_product (cart_id, product_id):

        connection_db = Connection.create()
        cursor = connection_db.cursor(dictionary=True)

        try:

            cursor.execute('DELETE FROM tb_cart_products WHERE tb_cart_products.product_id = %s AND tb_cart_products.cart_id = %s', (product_id, cart_id))

            cursor.commit()

            return True
        
        except Error as e:

            print(f'Erro - Cart "delete_product": {e}')

            return False
        
        finally:

            cursor.close()
            connection_db.close()