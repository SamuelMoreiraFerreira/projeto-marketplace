from data.connection_controller import Connection
from mysql.connector import Error

class Products:

    def get_products():

        con = Connection.create()
        cursor = con.cursor(dictionary=True)

        sql = "SELECT name,description,price, image_url FROM tb_products INNER JOIN tb_products_images ON tb_products.product_id=tb_products_images.product_id;"

        cursor.execute(sql)

        result=cursor.fetchall()

        cursor.close()
        con.close()
        
        return result
    
    # def get_product(code):

    #     con = Connection.create()
    #     cursor = con.cursor(dictionary=True)

    #     sql = """SELECT name,description,price,tb_products_types.type,rating FROM tb_products  
    #             INNER JOIN tb_products_types ON tb_products.type =tb_products_types.type_id 
    #             WHERE tb_products.product_id = %s;"""
    #     values = (code,)

    #     cursor.execute(sql,values)

    #     result=cursor.fetchone()

    #     cursor.close()
    #     con.close()
        
    #     return result
    
    def get_product_images(code):
        con = Connection.create()
        cursor = con.cursor(dictionary=True)

        sql = """SELECT image_url FROM tb_products 
                INNER JOIN tb_products_images ON tb_products.product_id=tb_products_images.product_id  
                WHERE tb_products.product_id = %s;"""
        values = (code,)

        cursor.execute(sql,values)

        result=cursor.fetchall()

        cursor.close()
        con.close()
        
        return result
    
    def get_product(code):

        con = Connection.create()
        cursor = con.cursor(dictionary=True)

        sql = """SELECT type_id FROM tb_products 
                WHERE tb_products.product_id = %s;"""
        values = (code,)

        cursor.execute(sql,values)

        result=cursor.fetchone()

        if result==1:
            sql = """SELECT name,description,price,tb_products_types.type,rating FROM tb_products  
                INNER JOIN tb_products_types ON tb_products.type =tb_products_types.type_id 
                WHERE tb_products.product_id = %s;"""
        else:
            sql = """SELECT name,description,price,tb_products_types.type,rating FROM tb_products  
                INNER JOIN tb_products_types ON tb_products.type =tb_products_types.type_id 
                WHERE tb_products.product_id = %s;"""
            
        values = (code,)

        cursor.execute(sql,values)

        result=cursor.fetchone()

        cursor.close()
        con.close()
        
        return result
    
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