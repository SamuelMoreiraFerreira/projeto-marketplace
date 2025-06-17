from data.connection_controller import Connection
from mysql.connector import Error

class Carts:

    @staticmethod
    def get_cart_user(email):
        
        connection_db = Connection.create()
        cursor = connection_db.cursor(dictionary=True)
        
        try:
            
            cursor.execute(
                
                """
                SELECT tb_shopping_cart.cart_id AS "id" FROM tb_shopping_cart
                INNER JOIN tb_users
                    ON tb_shopping_cart.user_email = %s
                WHERE tb_shopping_cart.finished = FALSE
                ORDER BY tb_shopping_cart.cart_id ASC;
                """,
            
                (email, )
                
            )
            
            cart_id = cursor.fetchone()

            print(cart_id)
            
            return cart_id
            
        except Error as e:
            
            print(f'Erro - Cart "get_cart_user": {e}')
            
            return False

        finally:

            cursor.close()
            connection_db.close()
            

    @staticmethod
    def create(**cart_data):

        # cart_data:
        #
        # - user_email
        # - products: [{ 'product_id': '', 'quantity': '' }, ...]

        connection_db = Connection.create()
        cursor = connection_db.cursor()

        try:

            cursor.execute('INSERT INTO tb_shopping_cart (user_email) VALUES (%s);', (cart_data.get('user'), ))

            cart_id = cursor.lastrowid

            for product in cart_data.get('products'):

                cursor.execute(
                    
                    """
                    INSERT INTO tb_cart_products (cart_id, product_id, quantity)
                    VALUES (%s, %s, %s);
                    """, 
                    
                    (
                        cart_id, 
                        product.id,
                        product.quantity
                    )
                    
                )   

            connection_db.commit()

            return True

        except Error as e:

            print(f'Erro - Cart "create": {e}')
            
            return False

        finally:

            cursor.close()
            connection_db.close()

    @staticmethod
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
                            tb_cart_products.cart_product_id, ':',
                            tb_cart_products.product_id, ':',
                            tb_products.name, ':',
                            tb_cart_products.quantity                       
                        ) SEPARATOR '|'
                    ) AS 'products'
                FROM tb_shopping_cart
                INNER JOIN tb_cart_products
                    ON tb_shopping_cart.cart_id = tb_cart_products.cart_id
                INNER JOIN tb_products
                    ON tb_cart_products.product_id = tb_products.product_id
                WHERE tb_shopping_cart.cart_id = %s;
                """,

                (id, )

            )

            response = cursor.fetchone()

            if response['user_email'] is not None:

                data = {

                    'cart_id': id,
                    'user': response['user_email'],

                    'products': []

                }

                keys = ('cart_product_id', 'product_id', 'product', 'quantity')

                for product in (response['products'].split('|')):

                    data['products'].append(

                        # 'zip()' -> Agrupa itens em pares correspondendo por posição

                        dict(zip(
                            keys,
                            tuple(product.split(':'))
                        ))

                    )

                return data

            else:
            
                return False
        
        except Error as e:

            print(f'Erro - Cart "get_by_id": {e}')

            return False
        
        finally:

            cursor.close()
            connection_db.close()

    @staticmethod
    def add_item(cart_id, product_id, quantity):

        connection_db = Connection.create()
        cursor = connection_db.cursor()

        try:

            cursor.callproc('addItemCart', (cart_id, product_id, quantity))

            connection_db.commit()

            return True
        
        except Error as e:

            print(f'Erro - Cart "add_item": {e}')

            return False
        
        finally:

            cursor.close()
            connection_db.close()

    @staticmethod
    def delete (id):

        connection_db = Connection.create()
        cursor = connection_db.cursor()

        try:

            cursor.execute('DELETE FROM tb_cart_products WHERE tb_cart_products.cart_id = %s', (id, ))

            connection_db.commit()

            if cursor.rowcount > 0:

                return True
            
            else:

                return False
        
        except Error as e:

            print(f'Erro - Cart "delete": {e}')

            return False
        
        finally:

            cursor.close()
            connection_db.close()

    @staticmethod
    def delete_product (cart_id, cart_product_id):

        connection_db = Connection.create()
        cursor = connection_db.cursor()

        try:

            cursor.execute('DELETE FROM tb_cart_products WHERE tb_cart_products.cart_product_id = %s AND tb_cart_products.cart_id = %s', (cart_product_id, cart_id))

            connection_db.commit()

            if cursor.rowcount > 0:

                return True
            
            else:

                return False
        
        except Error as e:

            print(f'Erro - Cart "delete_product": {e}')

            return False
        
        finally:

            cursor.close()
            connection_db.close()