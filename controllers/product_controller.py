from data.connection_controller import Connection

class Product:

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