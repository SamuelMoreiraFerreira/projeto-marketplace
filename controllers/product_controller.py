# -*- coding: utf-8 -*-

from data.connection_controller import Connection
from mysql.connector import Error

class Product:

    @staticmethod
    def get_by_id (id):

        connection_db = Connection.create()
        cursor = connection_db.cursor(dictionary=True)

        try:

            # obj-1 | obj-2 -> Metódo para mesclagem de dicionários

            data = {

                'images': []

            }

            cursor.execute(
                
                """
                SELECT tb_products.name, tb_products.description, tb_products.price, tb_products.quantity, tb_products.rating, tb_products.type FROM tb_products 
                WHERE tb_products.product_id = %s;
                """,

                (id, )
                
            )

            data = data | cursor.fetchone()
            
            # Macacos

            if data['type'] == 1:

                cursor.execute(

                    """
                    SELECT tb_monkeys_classes.class, tb_monkeys_classes.description FROM tb_monkeys_classes
                    INNER JOIN tb_monkeys ON tb_monkeys.monkey_id = tb_monkeys_classes.class_id
                    WHERE tb_monkeys.product_id = %s;
                    """,

                    (id, )

                )

                data = data | cursor.fetchone()

            # Bloons

            else:

                cursor.execute(

                    """
                    SELECT tb_bloons_types.type FROM tb_bloons_types
                    INNER JOIN tb_bloons ON tb_bloons.bloon_id = tb_bloons_types.type_id
                    WHERE tb_bloons.product_id = %s;
                    """,

                    (id, )

                )

                data = data | cursor.fetchone()

            # Images

            cursor.execute(

                """
                SELECT tb_products_images.image_url FROM tb_products_images
                WHERE tb_products_images.image_id = %s;
                """,

                (id, )

            )

            for product_image in cursor.fetchall():

                data['images'].append(product_image['image_url'])

            return data

        except Error as e:

            print(f'Erro - Products "get_by_id": {e}')

            return False
        
        finally:

            cursor.close()
            connection_db.close()