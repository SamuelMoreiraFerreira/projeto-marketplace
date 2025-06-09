from data.connection_controller import Connection
from controllers.product_controller import Product
from mysql.connector import Error

class Products:

    @staticmethod
    def get_all():

        connection_db = Connection.create()
        cursor = connection_db.cursor(dictionary=True)

        try:

            cursor.execute('SELECT MAX(tb_products.product_id) AS "max_id" FROM tb_products;')

            data = []

            max_id = cursor.fetchone()['max_id'] or 0

            if max_id > 0:

                for i in range(max_id):

                    data.append(

                        Product.get_by_id(i)

                    )

            return data

        except Error as e:

            print(f'Erro - Products "get_all": {e}')

            return False
        
        finally:

            cursor.close()
            connection_db.close()
    
    @staticmethod
    def get_highlights (length):

        connection_db = Connection.create()
        cursor = connection_db.cursor(dictionary=True)

        try:

            cursor.execute(
                
                """
                SELECT tb_products.product_id, COALESCE(SUM(tb_cart_products.quantity), 0) AS 'sold' FROM tb_products 
                LEFT JOIN tb_cart_products 
                    ON tb_cart_products.product_id = tb_products.product_id
                LEFT JOIN tb_shopping_cart
                    ON tb_shopping_cart.cart_id = tb_cart_products.cart_id
                    AND tb_shopping_cart.finished = TRUE
                GROUP BY 
                    tb_products.product_id
                ORDER BY 
                    sold DESC,
                    tb_products.product_id ASC
                LIMIT %s;
                """,

                (int(length), )
                
            )

            return cursor.fetchall()

        except Error as e:

            print(f'Erro Products Higlights: {e}')

            return False
        
        finally:

            cursor.close()
            connection_db.close()
    

#     SELECT name,description,price,tb_products_types.type,rating,tb_bloons_types.type FROM tb_products  
#                 INNER JOIN tb_products_types ON tb_products.type =tb_products_types.type_id 
#                 INNER JOIN tb_bloons ON tb_products.product_id=tb_bloons.product_id
#                 INNER JOIN tb_bloons_types ON tb_bloons.type=tb_bloons_types.type_id
#                 WHERE tb_products.product_id = 2;
                
# SELECT name,tb_products.description,price,tb_products_types.type,rating,tb_monkeys_classes.class FROM tb_products  
#                 INNER JOIN tb_products_types ON tb_products.type =tb_products_types.type_id 
#                 INNER JOIN tb_monkeys ON tb_products.product_id=tb_monkeys.product_id
#                 INNER JOIN tb_monkeys_classes ON tb_monkeys.class=tb_monkeys_classes.class_id
#                 WHERE tb_products.product_id = 2;