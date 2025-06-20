from data.connection_controller import Connection
from controllers.product_controller import Product
from mysql.connector import Error

class Products:

    @staticmethod
    def get_all(filters = None, order = None):

        print(filters)
        print(order)

        # Filters:
        #
        # type: 1 (Macaco) ou 2 (Bloon)
        #
        # class_id: ID da Classe do Macaco
        # bloon_type_id: ID do Tipo de Bloon
        #
        # order: 1 (ASC - Menor Preço) ou 2 (DESC - Maior Preço)

        connection_db = Connection.create()
        cursor = connection_db.cursor(dictionary=True)

        try:

            # 'GROUP_CONCAT()' -> Concatena valores de várias linhas em uma única coluna

            base_sql = [

                'SELECT',

                'tb_products.product_id,',

                'tb_products.name,',
                'tb_products.description,',

                'REPLACE(CAST(tb_products.price AS CHAR), \'.\', \',\') AS "price",',
                'tb_products.quantity,',
                'tb_products.rating,',

                'tb_products_types.type AS "product_type",',
                'tb_monkeys_classes.class AS "monkey_class",',
                'GROUP_CONCAT(tb_bloons_types.type) AS "bloon_types",',

                'GROUP_CONCAT(tb_products_images.image_url) AS "images"',

                'FROM tb_products',

                'JOIN tb_products_types ON tb_products.type = tb_products_types.type_id',

                'LEFT JOIN tb_monkeys ON tb_products.product_id = tb_monkeys.product_id',
                'LEFT JOIN tb_monkeys_classes ON tb_monkeys.class = tb_monkeys_classes.class_id',

                'LEFT JOIN tb_bloons ON tb_products.product_id = tb_bloons.product_id',
                'LEFT JOIN tb_bloons_types ON tb_bloons.type_id = tb_bloons_types.type_id',

                'LEFT JOIN tb_products_images ON tb_products.product_id = tb_products_images.product_id'

            ]

            conditions = []
            values = []

            #region Filtrando

            if filters is not None:

                # 'atr in dict' -> Verifica se o atributo está presente no dicionário 

                # Tipo de Produto

                if 'type' in filters and filters['type'] != 0:

                    conditions.append("tb_products.type = %s")
                    values.append(filters['type'])

                # Classe do Macaco

                if 'class_id' in filters and filters['class_id'] != 0:

                    conditions.append("tb_monkeys_classes.class_id = %s")
                    values.append(filters['class_id'])

                # Tipo de Bloon

                if 'bloon_type_id' in filters and filters['bloon_type_id'] != 0:

                    conditions.append("tb_bloons_types.type_id = %s")
                    values.append(filters['bloon_type_id'])

            if len(conditions) > 0:

                # 'str.join(list)' -> Concatena a lista usando o separador (str) entre eles

                base_sql.append('WHERE ' + (' AND '.join(conditions)))

            #endregion

            base_sql.append('GROUP BY tb_products.product_id, tb_products.name, tb_products.description, tb_products.price, tb_products.quantity, tb_products.rating, tb_products_types.type, tb_monkeys_classes.class')

            #region Ordenar

            if order != 0:

                base_sql.append(f'ORDER BY tb_products.price { "ASC" if order == 1 else "DESC" };')

            else:

                base_sql.append('ORDER BY tb_products.product_id ASC;')

            #endregion

            cursor.execute(

                ' '.join(base_sql), 

                tuple(values)

            )

            data = cursor.fetchall()

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
                SELECT

                tb_products.product_id AS 'id',

                tb_products.name,
                tb_products.description,

                REPLACE(CAST(tb_products.price AS CHAR), \'.\', \',\') AS "price",
                tb_products.rating,

                COALESCE(SUM(tb_cart_products.quantity), 0) AS 'sold',

                GROUP_CONCAT(tb_products_images.image_url) AS 'images'

                FROM tb_products

                JOIN tb_cart_products 
                    ON tb_cart_products.product_id = tb_products.product_id

                LEFT JOIN tb_shopping_cart
                    ON tb_shopping_cart.cart_id = tb_cart_products.cart_id
                    AND tb_shopping_cart.finished = TRUE

                INNER JOIN tb_products_images
                    ON tb_products.product_id = tb_products_images.product_id

                GROUP BY tb_products.product_id

                ORDER BY
                    sold DESC,
                    tb_products.product_id ASC
                
                LIMIT %s;
                """,

                (int(length), )
                
            )

            data = cursor.fetchall()

            for highlight in data:

                highlight['images'] = highlight['images'].split(',')

            return data

        except Error as e:

            print(f'Erro - Products "get_highlights": {e}')

            return False
        
        finally:

            cursor.close()
            connection_db.close()