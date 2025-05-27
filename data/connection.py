import mysql.connector 

class Connection:
        def create_connection():
                connection = mysql.connector.connect(
                host="lucas-mysql-service-ds-aluno-d374.i.aivencloud.com", 
                port=28179, 
                user="avnadmin", 
                password="AVNS_YoiuI6G-rpT4G7mGW3A", 
                database="db_macacaria"
                )
                return connection