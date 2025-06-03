import mysql.connector 
from os import getenv
from dotenv import load_dotenv

load_dotenv()

class Connection:

        def create():

                try:

                        connection = mysql.connector.connect(

                                host = getenv('DB_HOST'), 
                                port = getenv('DB_PORT'), 

                                user = getenv('DB_USER'), 
                                password = getenv('DB_PASSWORD'), 

                                database = getenv('DB_NAME')

                        )

                        return connection

                except mysql.connector.Error as e:

                        print(f'Erro ao criar conexão com a DB: {e}')

                        return False