from data.connection_controller import Connection
from mysql.connector import Error

class Product:

    @staticmethod
    def get_by_id (id, fulldata:bool=False):

        connection_db = Connection.create()
        cursor = connection_db.cursor(dictionary=True)

        try:

            # obj-1 | obj-2 -> Metódo para mesclagem de dicionários (|= é equivalente)

            data = {}

            cursor.execute(
                
                """
                SELECT tb_products.name, tb_products.description, tb_products.price, tb_products.quantity, tb_products.rating, tb_products.type FROM tb_products 
                WHERE tb_products.product_id = %s;
                """,

                (id, )
                
            )

            product_data = cursor.fetchone()

            if product_data:

                data |= product_data
            
            #region Full Data
    
            if fulldata:

                # Macacos

                if data['type'] == 1:

                    cursor.execute(

                        """
                        SELECT tb_monkeys_classes.class, tb_monkeys_classes.description AS 'class-description' FROM tb_monkeys_classes
                        INNER JOIN tb_monkeys 
                            ON tb_monkeys.monkey_id = tb_monkeys_classes.class_id
                        WHERE tb_monkeys.product_id = %s;
                        """,

                        (id, )

                    )

                    monkey_data = cursor.fetchone()

                    if monkey_data:

                        data |= monkey_data

                # Bloons

                else:

                    cursor.execute(

                        """
                        SELECT tb_bloons_types.type FROM tb_bloons_types
                        INNER JOIN tb_bloon_type_relation
                            ON tb_bloon_type_relation.type_id = tb_bloons_types.type_id
                        WHERE tb_bloons.product_id = %s;
                        """,

                        (id, )

                    )

                    bloon_data = cursor.fetchone()

                    if bloon_data:

                        data |= bloon_data

            #endregion

            # Imagens

            images = Product.get_images(id)

            if images:

                data['images'] = images

            return data

        except Error as e:

            print(f'Erro - Products "get_by_id": {e}')

            return False
        
        finally:

            cursor.close()
            connection_db.close()

    @staticmethod
    def get_images (id):

        connection_db = Connection.create()
        cursor = connection_db.cursor(dictionary=True)

        try:

            data = []

            cursor.execute(

                """
                SELECT tb_products_images.image_url FROM tb_products_images
                WHERE tb_products_images.image_id = %s;
                """,

                (id, )

            )

            for product_image in cursor.fetchall():

                data.append(product_image['image_url'])

            return data
        
        except Error as e:

            print(f'Erro - Products "get_images": {e}')

            return []
        
        finally:

            cursor.close()
            connection_db.close()