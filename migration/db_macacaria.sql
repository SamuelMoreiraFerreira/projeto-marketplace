CREATE DATABASE IF NOT EXISTS db_macacaria;
USE db_macacaria;

-- TABELA LOGS

CREATE TABLE IF NOT EXISTS tb_logs (

    log_id INT AUTO_INCREMENT PRIMARY KEY,

    user_email TEXT NOT NULL,
    date DATETIME DEFAULT NOW(),
    log_description TEXT,
    changed_table VARCHAR(20) NOT NULL

);

-- TABELA ENDEREÇOS

CREATE TABLE IF NOT EXISTS tb_address (

    address_id INT AUTO_INCREMENT PRIMARY KEY,

    cep VARCHAR(10) NOT NULL,

    city VARCHAR(60) NOT NULL,
    state VARCHAR(3) NOT NULL,

         TEXT NOT NULl

);

-- TABELA USUÁRIOS

CREATE TABLE IF NOT EXISTS tb_users (

    email VARCHAR(255) PRIMARY KEY,

    first_name VARCHAR(250) NOT NULL,
    last_name VARCHAR(250) NOT NULL,

    phone_number VARCHAR(20),
    address INT NOT NULL,

    password TEXT NOT NULL,
    salt_password VARCHAR(255) NOT NULL,

    CONSTRAINT ct_tbAddress_tbUsers
    FOREIGN KEY (address)
    REFERENCES tb_address(address_id),

    CHECK( LENGTH( password ) >= 8)

);

-- TABELA TIPOS PRODUTOS

CREATE TABLE tb_products_types (

    type_id INT AUTO_INCREMENT PRIMARY KEY,

    type VARCHAR(10) NOT NULL

);

-- TABELA PRODUTOS

CREATE TABLE tb_products (

    product_id INT AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(250) NOT NULL,
    description TEXT,

    price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    rating TINYINT(10) DEFAULT 10,
    
    type INT NOT NULL,

    CONSTRAINT ct_tbProductsTypes_tbProducts
    FOREIGN KEY (type) 
    REFERENCES tb_products_types(type_id),

    CHECK( QUANTITY > 0 )

);

-- TABELA IMAGENS PROUTOS

CREATE TABLE tb_products_images (

    image_id INT AUTO_INCREMENT PRIMARY KEY,

    image_url TEXT NOT NULL,
    product_id INT NOT NULL,

    CONSTRAINT ct_tbProducts_tbProductsImages
    FOREIGN KEY (product_id) 
    REFERENCES tb_products(product_id)

);

-- TABELA CLASSE MACACOS

CREATE TABLE tb_monkeys_classes (

    class_id INT AUTO_INCREMENT PRIMARY KEY,

    class VARCHAR(250) NOT NULL,
    description TEXT

);

-- TABELA MACACOS

CREATE TABLE tb_monkeys (

    monkey_id INT AUTO_INCREMENT PRIMARY KEY,

    product_id INT NOT NULL,
    class INT NOT NULL,

    CONSTRAINT ct_tbProducts_tbMonkeys
    FOREIGN KEY (product_id) 
    REFERENCES tb_products(product_id),

    CONSTRAINT ct_tbMonkeysClasses_tbMonkeys
    FOREIGN KEY (class) 
    REFERENCES tb_monkeys_classes(class_id)

);

-- TABELA TIPOS BLOONS

CREATE TABLE tb_bloons_types (

    type_id INT AUTO_INCREMENT PRIMARY KEY,

    type VARCHAR(250) NOT NULL

);

-- TABELA BLOONS

CREATE TABLE tb_bloons (

    bloon_id INT AUTO_INCREMENT PRIMARY KEY,
    
    tier TINYINT(5) NOT NULL,

    product_id INT NOT NULL,
    type INT NOT NULL,

    CONSTRAINT ct_tbProducts_tbBloons
    FOREIGN KEY (product_id) 
    REFERENCES tb_products(product_id),

    CONSTRAINT ct_tbBloonsTypes_tbBloons
    FOREIGN KEY (type) 
    REFERENCES tb_bloons_types(type_id)

);

-- TABELA CARRINHO DE COMPRAS

CREATE TABLE tb_shopping_cart (

    cart_id INT NOT NULL PRIMARY KEY,

    user_email VARCHAR(250) NOT NULL,

    CONSTRAINT ct_tbUsers_tbShoppingCart
    FOREIGN KEY (user_email) 
    REFERENCES tb_users(email)

);

-- TABELA PRODUTOS CARRINHO DE COMPRAS

CREATE TABLE tb_cart_products (

    cart_product_id INT AUTO_INCREMENT PRIMARY KEY,

    product_id INT NOT NULL,
    cart_id INT NOT NULL,

    quantity INT NOT NULL,

    CONSTRAINT ct_tbProducts_tbCartProducts
    FOREIGN KEY (product_id) 
    REFERENCES tb_products(product_id),

    CONSTRAINT ct_tbShoppingCart_tbCartProducts
    FOREIGN KEY (cart_id) 
    REFERENCES tb_shopping_cart(cart_id),

    CHECK ( quantity > 0 )

);

-- TABELA COMENTÁRIOS

CREATE TABLE tb_comments (

    comment_id INT AUTO_INCREMENT PRIMARY KEY,

    user_email VARCHAR(250) NOT NULL,
    product_id INT NOT NULL,

    message TEXT NOT NULL,
    date DATETIME DEFAULT NOW(),
    rating TINYINT(10) NOT NULL,

    CONSTRAINT ct_tbUsers_tbComments
    FOREIGN KEY (user_email) 
    REFERENCES tb_users(email),

    CONSTRAINT ct_tbProducts_tbComments
    FOREIGN KEY (product_id) 
    REFERENCES tb_products(product_id)

);

-- TRIGGER USUÁRIO

DELIMITER $$

CREATE TRIGGER tg_tbUsers_Insert
BEFORE INSERT
ON tb_users
FOR EACH ROW
BEGIN

    SET NEW.salt_password = UUID();
    SET NEW.password = SHA2( CONCAT( NEW.password, NEW.salt_password ), 256 );

END $$

DELIMITER ;

-- PROCEDURE VALIDAÇÃO SENHA

DELIMITER $$

CREATE PROCEDURE checkPassword (

    IN c_email TEXT, 
    IN c_password TEXT, 
    OUT c_result BOOL

)

BEGIN

    DECLARE user_salt VARCHAR(255);
    DECLARE user_password TEXT;

    SELECT password, salt_password INTO user_password, user_salt FROM tb_users
    WHERE tb_users.email = c_email;

    IF SHA2( CONCAT( c_password, user_salt), 256 ) = user_password THEN

        SET c_result = TRUE;

    ELSE

        SET c_result = FALSE;
        
    END IF;

END $$

DELIMITER ;

-- TRIGGER COMENTÁRIOS

DELIMITER $$

CREATE TRIGGER tg_tbComments_Insert
AFTER INSERT
ON tb_comments
FOR EACH ROW
BEGIN

    -- NOTA DO PRODUTO

    DECLARE product_rating TINYINT(10);

    SELECT AVG(rating) INTO product_rating FROM tb_comemnts
    WHERE tb_comemnts.product_id = NEW.product_id
    GROUP BY NEW.product_id;

    UPDATE tb_products
    SET tb_products.rating = product_rating
    WHERE tb_products.product_id = NEW.product_id;

END $$

DELIMITER ;