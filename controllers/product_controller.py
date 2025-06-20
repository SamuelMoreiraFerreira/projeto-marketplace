from data.connection_controller import Connection
from mysql.connector import Error

class Product:

    @staticmethod
    def get_by_id (id):

        connection_db = Connection.create()
        cursor = connection_db.cursor(dictionary=True)

        try:

            # obj-1 | obj-2 -> Metódo para mesclagem de dicionários (|= é equivalente)

            data = {}

            cursor.execute(
                
                """
                SELECT

                tb_products.product_id AS "id",

                tb_products.name,
                tb_products.description,

                REPLACE(CAST(tb_products.price AS CHAR), '.', ',') AS "price",
                tb_products.quantity,
                tb_products.rating,

                tb_products_types.type AS "product_type",
                tb_monkeys_classes.class AS "monkey_class",
                GROUP_CONCAT(tb_bloons_types.type) AS "bloon_types",

                tb_products_images.image_url AS "images"

                FROM tb_products

                JOIN tb_products_types 
                    ON tb_products.type = tb_products_types.type_id

                LEFT JOIN tb_monkeys 
                    ON tb_products.product_id = tb_monkeys.product_id
                LEFT JOIN tb_monkeys_classes 
                    ON tb_monkeys.class = tb_monkeys_classes.class_id

                LEFT JOIN tb_bloons 
                    ON tb_products.product_id = tb_bloons.product_id
                LEFT JOIN tb_bloons_types 
                    ON tb_bloons.type_id = tb_bloons_types.type_id

                LEFT JOIN tb_products_images 
                    ON tb_products.product_id = tb_products_images.product_id
                
                WHERE tb_products.product_id = %s

                GROUP BY tb_products.product_id, tb_products.name, tb_products.description, tb_products.price, tb_products.quantity, tb_products.rating, tb_products_types.type, tb_monkeys_classes.class;
                """,

                (id, )
                
            )

            data = cursor.fetchone()

            return data

        except Error as e:

            print(f'Erro - Product "get_by_id": {e}')

            return False
        
        finally:

            cursor.close()
            connection_db.close()

    @staticmethod
    def get_images (id):

        connection_db = Connection.create()
        cursor = connection_db.cursor(dictionary=True)

        try:

            cursor.execute(

                """
                SELECT 

                tb_products.product_id AS "id",
                GROUP_CONCAT(tb_product s_images.image_url) AS "images"

                FROM tb_products_images

                WHERE tb_products_images.image_id = %s;
                """,

                (id, )

            )

            return cursor.fetchone()
        
        except Error as e:

            print(f'Erro - Product "get_images": {e}')

            return []
        
        finally:

            cursor.close()
            connection_db.close()