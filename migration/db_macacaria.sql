CREATE DATABASE IF NOT EXISTS db_macacaria;
USE db_macacaria;

SET SQL_SAFE_UPDATES = 0;

-- TABELA LOGS

CREATE TABLE IF NOT EXISTS tb_logs (

    log_id INT AUTO_INCREMENT PRIMARY KEY,

    user_email VARCHAR(255) NOT NULL,
    date DATETIME DEFAULT NOW(),
    log_description TEXT,
    changed_table VARCHAR(20) NOT NULL

);

-- TABELA USUÁRIOS

CREATE TABLE IF NOT EXISTS tb_users (

    email VARCHAR(255) PRIMARY KEY,

    first_name VARCHAR(250) NOT NULL,
    last_name VARCHAR(250) NOT NULL,

    phone_number VARCHAR(20),
    address VARCHAR(250) NOT NULL,

    password TEXT NOT NULL,
    salt_password VARCHAR(255) NOT NULL,

    CHECK( LENGTH( password ) >= 8)

);

-- TABELA TIPOS PRODUTOS

CREATE TABLE IF NOT EXISTS tb_products_types (

    type_id INT AUTO_INCREMENT PRIMARY KEY,

    type VARCHAR(10) NOT NULL

);

-- TABELA PRODUTOS

CREATE TABLE IF NOT EXISTS tb_products (

    product_id INT AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(250) NOT NULL,
    description TEXT,

    price DECIMAL(10,2) NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    rating TINYINT(10) UNSIGNED DEFAULT 10,
    
    type INT NOT NULL,

    CONSTRAINT ct_tbProductsTypes_tbProducts
    FOREIGN KEY (type) 
    REFERENCES tb_products_types(type_id)

);

-- TABELA IMAGENS PROUTOS

CREATE TABLE IF NOT EXISTS tb_products_images (

    image_id INT AUTO_INCREMENT PRIMARY KEY,

    image_url TEXT NOT NULL,
    product_id INT NOT NULL,

    CONSTRAINT ct_tbProducts_tbProductsImages
    FOREIGN KEY (product_id) 
    REFERENCES tb_products(product_id)

);

-- TABELA CLASSE MACACOS

CREATE TABLE IF NOT EXISTS tb_monkeys_classes (

    class_id INT AUTO_INCREMENT PRIMARY KEY,

    class VARCHAR(250) NOT NULL,
    description TEXT

);

-- TABELA MACACOS

CREATE TABLE IF NOT EXISTS tb_monkeys (

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

CREATE TABLE IF NOT EXISTS tb_bloons_types (

    type_id INT AUTO_INCREMENT PRIMARY KEY,

    type VARCHAR(250) NOT NULL

);

-- TABELA BLOONS

CREATE TABLE IF NOT EXISTS tb_bloons (

    bloon_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    
    CONSTRAINT ct_tbProducts_tbBloons
    FOREIGN KEY (product_id) 
    REFERENCES tb_products(product_id)

);

-- TABELA RELAÇÃO BLOON E TIPOS

CREATE TABLE IF NOT EXISTS tb_bloon_type_relation (

	relation_id INT AUTO_INCREMENT PRIMARY KEY,

	bloon_id INT NOT NULL,
    type_id INT NOT NULL,
    
    CONSTRAINT ct_tbBloons_tbBloonTypeRelation
    FOREIGN KEY (bloon_id)
    REFERENCES tb_bloons(bloon_id),
    
    CONSTRAINT ct_tbBloonsTypes_tbBloonTypeRelation
    FOREIGN KEY (type_id)
    REFERENCES tb_bloons_types(type_id)

);

-- TABELA CARRINHO DE COMPRAS

CREATE TABLE IF NOT EXISTS tb_shopping_cart (

    cart_id INT NOT NULL PRIMARY KEY,

    user_email VARCHAR(255) NOT NULL,
    finished BOOL NOT NULL DEFAULT FALSE,

    CONSTRAINT ct_tbUsers_tbShoppingCart
    FOREIGN KEY (user_email) 
    REFERENCES tb_users(email)

);

-- TABELA PRODUTOS CARRINHO DE COMPRAS

CREATE TABLE IF NOT EXISTS tb_cart_products (

    cart_product_id INT AUTO_INCREMENT PRIMARY KEY,

    product_id INT NOT NULL,
    cart_id INT NOT NULL,

    quantity INT UNSIGNED NOT NULL,

    CONSTRAINT ct_tbProducts_tbCartProducts
    FOREIGN KEY (product_id) 
    REFERENCES tb_products(product_id),

    CONSTRAINT ct_tbShoppingCart_tbCartProducts
    FOREIGN KEY (cart_id) 
    REFERENCES tb_shopping_cart(cart_id)

);

-- TABELA COMENTÁRIOS

CREATE TABLE IF NOT EXISTS tb_comments (

    comment_id INT AUTO_INCREMENT PRIMARY KEY,

    user_email VARCHAR(255) NOT NULL,
    product_id INT NOT NULL,

    message TEXT NOT NULL,
    date DATETIME DEFAULT NOW(),
    rating TINYINT(10) UNSIGNED NOT NULL,

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

-- PROCEDURE ADD ITEM

DELIMITER $$

CREATE PROCEDURE addItemCart (

  IN p_cart_id INT, 
  IN p_product_id INT, 
  IN p_quantity INT

)

BEGIN

  DECLARE existing_product_cart INT;

  SELECT tb_cart_products.cart_product_id INTO existing_product_cart FROM tb_cart_products
  WHERE tb_cart_products.cart_id = p_cart_id AND tb_cart_products.product_id = p_product_id;

  -- CASO JÁ EXISTA O PRODUTO NO CARRINHO, APENAS SOMA AS QUANTIDADES

  IF existing_product_cart IS NOT NULL THEN

    UPDATE tb_cart_products
    SET tb_cart_products.quantity = p_quantity + tb_cart_products.quantity
    WHERE tb_cart_products.cart_product_id = existing_product_cart;

  ELSE

    INSERT INTO tb_cart_products (cart_id, product_id, quantity)
    VALUES (p_cart_id, product_id, quantity);

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

    SELECT AVG(rating) INTO product_rating FROM tb_comments
    WHERE tb_comments.product_id = NEW.product_id
    GROUP BY NEW.product_id;

    UPDATE tb_products
    SET tb_products.rating = product_rating
    WHERE tb_products.product_id = NEW.product_id;

END $$

DELIMITER ;

-- TIPO PRODUTOS

INSERT INTO tb_products_types (type_id, type) VALUES
    (1, 'Macacos'),
    (2, 'Bloons');

-- CLASSES MACACOS

INSERT INTO tb_monkeys_classes (class_id, class, description) VALUES
  (1, 'Primário', 'Macacos com habilidades básicas e custo acessível.'),
  (2, 'Militar', 'Macacos especializados em armamentos militares.'),
  (3, 'Mágico', 'Macacos que utilizam poderes mágicos para atacar.'),
  (4, 'Suporte', 'Macacos que auxiliam outros com habilidades de suporte.'),
  (5, 'Heróis', '');

-- Dart Monkey

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (1, 'Dart Monkey', 'Atira dardos simples em bloons próximos.', 170.00, 100, 10, 1);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (1, 'https://static.wikia.nocookie.net/bloonswiki/images/7/7d/Dart_Monkey_BTD6.png', 1);
INSERT INTO tb_monkeys         (monkey_id, product_id, class) VALUES
  (1, 1, 1);

-- Boomerang Monkey

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (2, 'Boomerang Monkey', 'Lança bumerangues que seguem um caminho curvo e atingem múltiplos bloons.', 320.00, 100, 10, 1);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (2, 'https://static.wikia.nocookie.net/bloonswiki/images/3/3a/Boomerang_Monkey_BTD6.png', 2);
INSERT INTO tb_monkeys         (monkey_id, product_id, class) VALUES
  (2, 2, 1);

-- Bomb Shooter

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (3, 'Bomb Shooter', 'Dispõe minas peçonhentas que explodem e danificam vários bloons ao redor.', 350.00, 100, 10, 1);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (3, 'https://static.wikia.nocookie.net/bloonswiki/images/8/84/Bomb_Shooter_BTD6.png', 3);
INSERT INTO tb_monkeys         (monkey_id, product_id, class) VALUES
  (3, 3, 1);

-- Tack Shooter

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (4, 'Tack Shooter', 'Arremessa tacks em círculo curto, ótima cobertura para bloons que passam por múltiplos pontos.', 250.00, 100, 10, 1);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (4, 'https://static.wikia.nocookie.net/bloonswiki/images/4/4b/Tack_Shooter_BTD6.png', 4);
INSERT INTO tb_monkeys         (monkey_id, product_id, class) VALUES
  (4, 4, 1);

-- Ice Monkey

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (5, 'Ice Monkey', 'Congela bloons, retardando seu avanço; pode levar a atrasos em grandes grupos.', 350.00, 100, 10, 1);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (5, 'https://static.wikia.nocookie.net/bloonswiki/images/9/9b/Ice_Monkey_BTD6.png', 5);
INSERT INTO tb_monkeys         (monkey_id, product_id, class) VALUES
  (5, 5, 1);

-- Glue Gunner

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (6, 'Glue Gunner', 'Bate nos bloons com cola, retardando-os e tornando-os suscetíveis a danos aumentados.', 300.00, 100, 10, 1);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (6, 'https://static.wikia.nocookie.net/bloonswiki/images/5/5f/Glue_Gunner_BTD6.png', 6);
INSERT INTO tb_monkeys         (monkey_id, product_id, class) VALUES
  (6, 6, 1);

-- Sniper Monkey

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (7, 'Sniper Monkey', 'Atira em bloons de qualquer local no mapa, com mira de longo alcance.', 350.00, 100, 10, 1);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (7, 'https://static.wikia.nocookie.net/bloonswiki/images/0/0e/Sniper_Monkey_BTD6.png', 7);
INSERT INTO tb_monkeys         (monkey_id, product_id, class) VALUES
  (7, 7, 2);

-- Monkey Sub

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (8, 'Monkey Sub', 'Torre subaquática que atira dardos em bloons aquáticos e não aquáticos próximas.', 325.00, 100, 10, 1);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (8, 'https://static.wikia.nocookie.net/bloonswiki/images/2/22/Monkey_Sub_BTD6.png', 8);
INSERT INTO tb_monkeys         (monkey_id, product_id, class) VALUES
  (8, 8, 2);

-- Monkey Buccaneer

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (9, 'Monkey Buccaneer', 'Navio que dispara tiros de canhão e detecta bloons camuflados.', 350.00, 100, 10, 1);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (9, 'https://static.wikia.nocookie.net/bloonswiki/images/6/6e/Monkey_Buccaneer_BTD6.png', 9);
INSERT INTO tb_monkeys         (monkey_id, product_id, class) VALUES
  (9, 9, 2);

-- Monkey Ace

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (10, 'Monkey Ace', 'Avião que lança tempestade de lâminas, bombas e lança-chamas em bloons abaixo.', 350.00, 100, 10, 1);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (10, 'https://static.wikia.nocookie.net/bloonswiki/images/7/70/Monkey_Ace_BTD6.png', 10);
INSERT INTO tb_monkeys          (monkey_id, product_id, class) VALUES
  (10, 10, 2);

-- Heli Pilot

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (11, 'Heli Pilot', 'Helicóptero móvel que causa dano contínuo e pode patrulhar áreas.', 350.00, 100, 10, 1);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (11, 'https://static.wikia.nocookie.net/bloonswiki/images/4/4f/Heli_Pilot_BTD6.png', 11);
INSERT INTO tb_monkeys          (monkey_id, product_id, class) VALUES
  (11, 11, 2);

-- Mortar Monkey

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (12, 'Mortar Monkey', 'Dispara projéteis de longo alcance que explodem em área.', 400.00, 100, 10, 1);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (12, 'https://static.wikia.nocookie.net/bloonswiki/images/9/9f/Mortar_Monkey_BTD6.png', 12);
INSERT INTO tb_monkeys          (monkey_id, product_id, class) VALUES
  (12, 12, 2);

-- Dartling Gunner

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (13, 'Dartling Gunner', 'Canhão fixo que dispara rajadas de dardos em direção ao cursor.', 400.00, 100, 10, 1);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (13, 'https://static.wikia.nocookie.net/bloonswiki/images/2/2c/Dartling_Gunner_BTD6.png', 13);
INSERT INTO tb_monkeys          (monkey_id, product_id, class) VALUES
  (13, 13, 2);

-- Wizard Monkey

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (14, 'Wizard Monkey', 'Lança magias que atingem múltiplos bloons e gera bombas flutuantes.', 500.00, 100, 10, 1);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (14, 'https://static.wikia.nocookie.net/bloonswiki/images/2/27/Wizard_Monkey_BTD6.png', 14);
INSERT INTO tb_monkeys          (monkey_id, product_id, class) VALUES
  (14, 14, 3);

-- Super Monkey

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (15, 'Super Monkey', 'Torre de altíssimo poder de fogo que dispara lasers de longo alcance.', 3000.00, 100, 10, 1);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (15, 'https://static.wikia.nocookie.net/bloonswiki/images/a/a1/Super_Monkey_BTD6.png', 15);
INSERT INTO tb_monkeys          (monkey_id, product_id, class) VALUES
  (15, 15, 3);

-- Ninja Monkey

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES 
  (16, 'Ninja Monkey', 'Ataca silenciosamente bloons camuflados com shurikens rápidos.', 650.00, 100, 10, 1);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES 
  (16, 'https://static.wikia.nocookie.net/bloonswiki/images/f/f4/Ninja_Monkey_BTD6.png', 16);
INSERT INTO tb_monkeys (monkey_id, product_id, class) VALUES 
  (16, 16, 3);

-- Alchemist

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (17, 'Alchemist', 'Lança poções que fortalecem aliados e enfraquecem bloons próximos.', 800.00, 100, 10, 1);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (17, 'https://static.wikia.nocookie.net/bloonswiki/images/6/6f/Alchemist_BTD6.png', 17);
INSERT INTO tb_monkeys          (monkey_id, product_id, class) VALUES
  (17, 17, 3);

-- Druid

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (18, 'Druid', 'Convoca tornados e raizes para imobilizar e danificar bloons.', 650.00, 100, 10, 1);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (18, 'https://static.wikia.nocookie.net/bloonswiki/images/0/05/Druid_BTD6.png', 18);
INSERT INTO tb_monkeys          (monkey_id, product_id, class) VALUES
  (18, 18, 3);

-- Monkey Village

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (19, 'Monkey Village', 'Proporciona buffs de área aos macacos e detecta bloons camuflados.', 625.00, 100, 10, 1);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (19, 'https://static.wikia.nocookie.net/bloonswiki/images/5/59/Monkey_Village_BTD6.png', 19);
INSERT INTO tb_monkeys          (monkey_id, product_id, class) VALUES
  (19, 19, 4);

-- Engineer Monkey

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (20, 'Engineer Monkey', 'Constrói torres fixas de minas e lança granadas teleguiadas.', 900.00, 100, 10, 1);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (20, 'https://static.wikia.nocookie.net/bloonswiki/images/4/49/Engineer_Monkey_BTD6.png', 20);
INSERT INTO tb_monkeys          (monkey_id, product_id, class) VALUES
  (20, 20, 4);

-- TIPOS BLOONS

INSERT INTO tb_bloons_types (type_id, type) VALUES
  (1, 'Vermelho'),
  (2, 'Azul'),
  (3, 'Verde'),
  (4, 'Amarelo'),
  (5, 'Rosa'),
  (6, 'Roxo'),
  (7, 'Preto'),
  (8, 'Branco'),
  (9, 'Zebra'),
  (10, 'Chumbo'),
  (11, 'Cerâmico'),
  (12, 'Camo'),
  (13, 'Regrow'),
  (14, 'Fortificado'),
  (15, 'MOAB'),
  (16, 'BFB'),
  (17, 'ZOMG'),
  (18, 'DDT'),
  (19, 'BAD');
  
-- Red Bloon

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (21, 'Red Bloon',
   'Bloon básico de tier 1, lento e sem resistência extra.',
   10.00, 1000, 1, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (21, 'https://static.wikia.nocookie.net/bloonswiki/images/1/1d/Red_Bloon_BTD6.png', 21);
INSERT INTO tb_bloons (bloon_id, product_id) VALUES
  (1, 21);
INSERT INTO tb_bloon_type_relation (relation_id, bloon_id, type_id) VALUES
  (1, 1, 1);

-- Blue Bloon

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (22, 'Blue Bloon',
   'Bloon de tier 2, mais rápido que o Red Bloon e contém um Red Bloon dentro.',
   15.00, 1000, 1, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (22, 'https://static.wikia.nocookie.net/bloonswiki/images/2/2d/Blue_Bloon_BTD6.png', 22);
INSERT INTO tb_bloons (bloon_id, product_id) VALUES
  (2, 22);
INSERT INTO tb_bloon_type_relation (relation_id, bloon_id, type_id) VALUES
  (2, 2, 2);

-- Green Bloon

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (23, 'Green Bloon',
   'Bloon de tier 3, mais rápido que o Blue Bloon e contém um Blue Bloon dentro.',
   20.00, 1000, 1, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (23, 'https://static.wikia.nocookie.net/bloonswiki/images/0/0a/Green_Bloon_BTD6.png', 23);
INSERT INTO tb_bloons (bloon_id, product_id) VALUES
  (3, 23);
INSERT INTO tb_bloon_type_relation (relation_id, bloon_id, type_id) VALUES
  (3, 3, 3);

-- Yellow Bloon

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (24, 'Yellow Bloon',
   'Bloon de tier 4, muito rápido e contém um Green Bloon dentro.',
   25.00, 1000, 1, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (24, 'https://static.wikia.nocookie.net/bloonswiki/images/5/5b/Yellow_Bloon_BTD6.png', 24);
INSERT INTO tb_bloons (bloon_id, product_id) VALUES
  (4, 24);
INSERT INTO tb_bloon_type_relation (relation_id, bloon_id, type_id) VALUES
  (4, 4, 4);

-- Pink Bloon

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (25, 'Pink Bloon',
   'Bloon de tier 5, extremamente rápido e contém um Yellow Bloon dentro.',
   30.00, 1000, 1, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (25, 'https://static.wikia.nocookie.net/bloonswiki/images/3/31/Pink_Bloon_BTD6.png', 25);
INSERT INTO tb_bloons (bloon_id, product_id) VALUES
  (5, 25);
INSERT INTO tb_bloon_type_relation (relation_id, bloon_id, type_id) VALUES
  (5, 5, 5);

-- Purple Bloon

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (26, 'Purple Bloon',
   'Bloon de tier 6, carrega dois Pink Bloons e é resistente ao gelo.',
   35.00, 1000, 1, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (26, 'https://static.wikia.nocookie.net/bloonswiki/images/a/a2/Purple_Bloon_BTD6.png', 26);
INSERT INTO tb_bloons (bloon_id, product_id) VALUES
  (6, 26);
INSERT INTO tb_bloon_type_relation (relation_id, bloon_id, type_id) VALUES
  (6, 6, 6);

-- Black Bloon

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (27, 'Black Bloon',
   'Bloon de tier 7, carrega dois Purple Bloons e é imune a explosões.',
   40.00, 1000, 1, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (27, 'https://static.wikia.nocookie.net/bloonswiki/images/5/50/Black_Bloon_BTD6.png', 27);
INSERT INTO tb_bloons (bloon_id, product_id) VALUES
  (7, 27);
INSERT INTO tb_bloon_type_relation (relation_id, bloon_id, type_id) VALUES
  (7, 7, 7);

-- White Bloon

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (28, 'White Bloon',
   'Bloon de tier 8, carrega dois Black Bloons e é imune a gelo.',
   40.00, 1000, 1, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (28, 'https://static.wikia.nocookie.net/bloonswiki/images/7/70/White_Bloon_BTD6.png', 28);
INSERT INTO tb_bloons (bloon_id, product_id) VALUES
  (8, 28);
INSERT INTO tb_bloon_type_relation (relation_id, bloon_id, type_id) VALUES
  (8, 8, 8);

-- Zebra Bloon

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (29, 'Zebra Bloon',
   'Bloon de tier 9, combinação de Black e White, imune a gelo e explosões.',
   45.00, 1000, 1, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (29, 'https://static.wikia.nocookie.net/bloonswiki/images/9/98/Zebra_Bloon_BTD6.png', 29);
INSERT INTO tb_bloons (bloon_id, product_id) VALUES
  (9, 29);
INSERT INTO tb_bloon_type_relation (relation_id, bloon_id, type_id) VALUES
  (9, 9, 9);

-- Lead Bloon (Chumbo)

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (30, 'Lead Bloon',
   'Bloon de tier 10, pesado e imune a lâminas, apenas projéteis explosivos afetam.',
   50.00, 1000, 1, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (30, 'https://static.wikia.nocookie.net/bloonswiki/images/3/3c/Lead_Bloon_BTD6.png', 30);
INSERT INTO tb_bloons (bloon_id, product_id) VALUES
  (10, 30);
INSERT INTO tb_bloon_type_relation (relation_id, bloon_id, type_id) VALUES
  (10, 10, 10);

-- Ceramic Bloon (Cerâmico)

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (31, 'Ceramic Bloon',
   'Bloon de tier 11, extremamente resistente; ao estourar, libera quatro Lead Bloons.',
   60.00, 1000, 1, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (31, 'https://static.wikia.nocookie.net/bloonswiki/images/7/7f/Ceramic_Bloon_BTD6.png', 31);
INSERT INTO tb_bloons (bloon_id, product_id) VALUES
  (11, 31);
INSERT INTO tb_bloon_type_relation (relation_id, bloon_id, type_id) VALUES
  (11, 11, 11);

-- Camo Bloon

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (32, 'Camo Bloon',
   'Bloon de tier 12, invisível para torres sem detecção e contém um Pink Bloon ao estourar.',
   70.00, 1000, 1, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (32, 'https://static.wikia.nocookie.net/bloonswiki/images/0/05/Camo_Bloon_BTD6.png', 32);
INSERT INTO tb_bloons (bloon_id, product_id) VALUES
  (12, 32);
INSERT INTO tb_bloon_type_relation (relation_id, bloon_id, type_id) VALUES
  (12, 12, 12);

-- Regrow Bloon

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (33, 'Regrow Bloon',
   'Bloon de tier 13, regenera camadas com o tempo e contém um Camo Bloon ao estourar.',
   80.00, 1000, 1, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (33, 'https://static.wikia.nocookie.net/bloonswiki/images/8/8b/Regrow_Bloon_BTD6.png', 33);
INSERT INTO tb_bloons (bloon_id, product_id) VALUES
  (13, 33);
INSERT INTO tb_bloon_type_relation (relation_id, bloon_id, type_id) VALUES
  (13, 13, 13);

-- Fortified Bloon (Fortificado)

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (34, 'Fortified Bloon',
   'Bloon de tier 14, camada metálica extra resistente que envolve outro bloon principal.',
   90.00, 1000, 1, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (34, 'https://static.wikia.nocookie.net/bloonswiki/images/9/9e/Fortified_Bloon_BTD6.png', 34);
INSERT INTO tb_bloons (bloon_id, product_id) VALUES
  (14, 34);
INSERT INTO tb_bloon_type_relation (relation_id, bloon_id, type_id) VALUES
  (14, 14, 14);

-- MOAB

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (35, 'MOAB',
   'Mother Of All Bloons, grande bloon de tier 15 com alta durabilidade; ao estourar, libera quatro Ceramic Bloons.',
   100.00, 1000, 1, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (35, 'https://static.wikia.nocookie.net/bloonswiki/images/6/6a/MOAB_BTD6.png', 35);
INSERT INTO tb_bloons (bloon_id, product_id) VALUES
  (15, 35);
INSERT INTO tb_bloon_type_relation (relation_id, bloon_id, type_id) VALUES
  (15, 15, 15);

-- BFB

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (36, 'BFB',
   'Brutal Flying Behemoth, tier 16, explode em quatro ZOMGs ao ser destruída; muito resistente.',
   150.00, 1000, 1, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (36, 'https://static.wikia.nocookie.net/bloonswiki/images/4/43/BFB_BTD6.png', 36);
INSERT INTO tb_bloons (bloon_id, product_id) VALUES
  (16, 36);
INSERT INTO tb_bloon_type_relation (relation_id, bloon_id, type_id) VALUES
  (16, 16, 16);

-- ZOMG

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (37, 'ZOMG',
   'Zeppelin Of Mighty Gargantuaness, tier 17, extremamente resistente e grande; explode em quatro DDTs ao ser destruída.',
   200.00, 1000, 1, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (37, 'https://static.wikia.nocookie.net/bloonswiki/images/c/c7/ZOMG_BTD6.png', 37);
INSERT INTO tb_bloons (bloon_id, product_id) VALUES
  (17, 37);
INSERT INTO tb_bloon_type_relation (relation_id, bloon_id, type_id) VALUES
  (17, 17, 17);

-- 18 DDT

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (38, 'DDT',
   'Bloon rápido de tier 18, imune a gelo e incendiário; carrega atributos de Black e Camo Bloons.',
   250.00, 1000, 1, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (38, 'https://static.wikia.nocookie.net/bloonswiki/images/a/ad/DDT_Bloon_BTD6.png', 38);
INSERT INTO tb_bloons (bloon_id, product_id) VALUES
  (18, 38);
INSERT INTO tb_bloon_type_relation (relation_id, bloon_id, type_id) VALUES
  (18, 18, 18);

-- BAD

INSERT INTO tb_products (product_id, name, description, price, quantity, rating, type) VALUES
  (39, 'BAD',
   'Big Airship of Doom, tier 19, o inimigo final; extremamente resistente, ao estourar libera BFBs, ZOMGs e muitos outros bloons.',
   500.00, 1000, 1, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (39, 'https://static.wikia.nocookie.net/bloonswiki/images/1/13/BAD_Bloon_BTD6.png', 39);
INSERT INTO tb_bloons (bloon_id, product_id) VALUES
  (19, 39);
INSERT INTO tb_bloon_type_relation (relation_id, bloon_id, type_id) VALUES
  (19, 19, 19);