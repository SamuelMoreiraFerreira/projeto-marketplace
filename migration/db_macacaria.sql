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
    rating TINYINT(5) UNSIGNED DEFAULT 5,
    
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

    type_id INT NOT NULL,
    tier INT NOT NULL,
    
    CONSTRAINT ct_tbProducts_tbBloons
    FOREIGN KEY (product_id) 
    REFERENCES tb_products(product_id),

    CONSTRAINT ct_tbBloonsTypes_tbBloons
    FOREIGN KEY (type_id) 
    REFERENCES tb_bloons_types(type_id)
    
);

-- TABELA CARRINHO DE COMPRAS

CREATE TABLE IF NOT EXISTS tb_shopping_cart (

    cart_id INT AUTO_INCREMENT PRIMARY KEY,

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
    rating TINYINT(5) UNSIGNED DEFAULT 5,

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
    VALUES (p_cart_id, p_product_id, p_quantity);

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

    DECLARE product_rating TINYINT(5);

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

-- CATEGORIAS DE BLOONS

INSERT INTO tb_bloons_types (type_id, type) VALUES
  (1, 'Normal'),
  (2, 'Moab');

-- RED BLOON

INSERT INTO tb_products (product_id, name, description, price, quantity, type) VALUES
  (21, 'Red Bloon', 
   'O lendário Bloon vermelho – rápido como o vento e implacável no pop!', 
   500.00, 1000, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (21, 'https://static.wikia.nocookie.net/bloons/images/0/0c/RedBloon.png', 21);
INSERT INTO tb_bloons (bloon_id, product_id, type_id, tier) VALUES
  (21, 21, 1, 1);

-- BLUE BLOON

INSERT INTO tb_products (product_id, name, description, price, quantity, type) VALUES
  (22, 'Blue Bloon', 
   'O Bloon azul – mais resistente e veloz que o vermelho, um verdadeiro desafio!', 
   500.00, 1000, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (22, 'https://static.wikia.nocookie.net/bloons/images/7/7c/BlueBloon.png', 22);
INSERT INTO tb_bloons (bloon_id, product_id, type_id, tier) VALUES
  (22, 22, 1, 2);

-- GREEN BLOON

INSERT INTO tb_products (product_id, name, description, price, quantity, type) VALUES
  (23, 'Green Bloon', 
   'O Bloon verde – durão e persistente, não cai com qualquer estourada!', 
   500.00, 1000, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (23, 'https://static.wikia.nocookie.net/bloons/images/3/34/GreenBloon.png', 23);
INSERT INTO tb_bloons (bloon_id, product_id, type_id, tier) VALUES
  (23, 23, 1, 3);

-- YELLOW BLOON

INSERT INTO tb_products (product_id, name, description, price, quantity, type) VALUES
  (24, 'Yellow Bloon', 
   'O Bloon amarelo – veloz como um raio, exige reflexos afiados!', 
   500.00, 1000, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (24, 'https://static.wikia.nocookie.net/bloons/images/5/5f/YellowBloon.png', 24);
INSERT INTO tb_bloons (bloon_id, product_id, type_id, tier) VALUES
  (24, 24, 1, 4);

-- PINK BLOON

INSERT INTO tb_products (product_id, name, description, price, quantity, type) VALUES
  (25, 'Pink Bloon', 
   'O Bloon rosa – mais rápido que todos, só os melhores caçadores o alcançam!', 
   500.00, 1000, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (25, 'https://static.wikia.nocookie.net/bloons/images/b/bd/PinkBloon.png', 25);
INSERT INTO tb_bloons (bloon_id, product_id, type_id, tier) VALUES
  (25, 25, 1, 5);

-- BLACK BLOON

INSERT INTO tb_products (product_id, name, description, price, quantity, type) VALUES
  (26, 'Black Bloon', 
   'O Bloon preto – imune a ataques explosivos, um verdadeiro fantasma voador!', 
   500.00, 1000, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (26, 'https://static.wikia.nocookie.net/bloons/images/1/14/BlackBloon.png', 26);
INSERT INTO tb_bloons (bloon_id, product_id, type_id, tier) VALUES
  (26, 26, 1, 6);

-- WHITE BLOON

INSERT INTO tb_products (product_id, name, description, price, quantity, type) VALUES
  (27, 'White Bloon', 
   'O Bloon branco – imune a efeitos de gelo, desliza pelos campos gelados!', 
   500.00, 1000, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (27, 'https://static.wikia.nocookie.net/bloons/images/c/c8/WhiteBloon.png', 27);
INSERT INTO tb_bloons (bloon_id, product_id, type_id, tier) VALUES
  (27, 27, 1, 7);

-- LEAD BLOON

INSERT INTO tb_products (product_id, name, description, price, quantity, type) VALUES
  (28, 'Lead Bloon', 
   'O Bloon de chumbo – indestrutível por projéteis simples, um verdadeiro tanque voador!', 
   500.00, 1000, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (28, 'https://static.wikia.nocookie.net/bloons/images/2/22/LeadBloon.png', 28);
INSERT INTO tb_bloons (bloon_id, product_id, type_id, tier) VALUES
  (28, 28, 1, 8);

-- ZEBRA BLOON

INSERT INTO tb_products (product_id, name, description, price, quantity, type) VALUES
  (29, 'Zebra Bloon', 
   'O Bloon zebra – combinação fatal de chumbo e gelo, pura diversidade destruidora!', 
   500.00, 1000, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (29, 'https://static.wikia.nocookie.net/bloons/images/6/67/ZebraBloon.png', 29);
INSERT INTO tb_bloons (bloon_id, product_id, type_id, tier) VALUES
  (29, 29, 1, 9);

-- RAINBOW BLOON

INSERT INTO tb_products (product_id, name, description, price, quantity, type) VALUES
  (30, 'Rainbow Bloon', 
   'O Bloon arco-íris – multi-camadas brilhantes, um verdadeiro arco-íris de desafios!', 
   500.00, 1000, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (30, 'https://static.wikia.nocookie.net/bloons/images/4/4a/RainbowBloon.png', 30);
INSERT INTO tb_bloons (bloon_id, product_id, type_id, tier) VALUES
  (30, 30, 1, 10);

-- CERAMIC BLOON

INSERT INTO tb_products (product_id, name, description, price, quantity, type) VALUES
  (31, 'Ceramic Bloon', 
   'O Bloon cerâmico – camadas após camadas de pura resistência, difícil de estourar!', 
   500.00, 1000, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (31, 'https://static.wikia.nocookie.net/bloons/images/9/9d/CeramicBloon.png', 31);
INSERT INTO tb_bloons (bloon_id, product_id, type_id, tier) VALUES
  (31, 31, 1, 11);

-- MOAB

INSERT INTO tb_products (product_id, name, description, price, quantity, type) VALUES
  (32, 'MOAB', 
   'O colosso voador – centenas de tiros para trazê-lo abaixo. Se escapar, prepare-se para o caos!', 
   1500.00, 100, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (32, 'https://static.wikia.nocookie.net/bloons/images/9/99/BTD6_MOAB.png', 32);
INSERT INTO tb_bloons (bloon_id, product_id, type_id, tier) VALUES
  (32, 32, 2, 12);

-- BFB

INSERT INTO tb_products (product_id, name, description, price, quantity, type) VALUES
  (33, 'BFB', 
   'O Brutal Flying Behemoth – destruição em massa em forma de dirigível. Segure a linha de defesa!', 
   1500.00, 100, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (33, 'https://static.wikia.nocookie.net/bloons/images/2/2b/BTD6_BFB.png', 33);
INSERT INTO tb_bloons (bloon_id, product_id, type_id, tier) VALUES
  (33, 33, 2, 13);

-- ZOMG

INSERT INTO tb_products (product_id, name, description, price, quantity, type) VALUES
  (34, 'ZOMG', 
   'O Terrível ZOMG – monstrosidade blindada que desafia todos os limites da defesa!', 
   1500.00, 100, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (34, 'https://static.wikia.nocookie.net/bloons/images/3/3e/BTD6_ZOMG.png', 34);
INSERT INTO tb_bloons (bloon_id, product_id, type_id, tier) VALUES
  (34, 34, 2, 14);

-- DDT

INSERT INTO tb_products (product_id, name, description, price, quantity, type) VALUES
  (35, 'DDT', 
   'Fast and Stealthy DDT – veloz e quase invisível, um pesadelo furtivo nos céus!', 
   1500.00, 100, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (35, 'https://static.wikia.nocookie.net/bloons/images/5/5a/BTD6_DDT.png', 35);
INSERT INTO tb_bloons (bloon_id, product_id, type_id, tier) VALUES
  (35, 35, 2, 15);

-- BAD

INSERT INTO tb_products (product_id, name, description, price, quantity, type) VALUES
  (36, 'BAD', 
   'The Biggest And Darkest – o ápice da destruição aérea. Apenas os mais poderosos resistem!', 
   1500.00, 100, 2);
INSERT INTO tb_products_images (image_id, image_url, product_id) VALUES
  (36, 'https://static.wikia.nocookie.net/bloons/images/8/8d/BTD6_BAD.png', 36);
INSERT INTO tb_bloons (bloon_id, product_id, type_id, tier) VALUES
  (36, 36, 2, 16);
  
  -- Usuário 1
INSERT INTO tb_users (email, first_name, last_name, phone_number, address, password, salt_password)
VALUES ('mario@example.com', 'Mario', 'Verde', '11999999999', 'Rua Cogumelo 1', 'senha1234', '');

-- Usuário 2
INSERT INTO tb_users (email, first_name, last_name, phone_number, address, password, salt_password)
VALUES ('luigi@example.com', 'Luigi', 'Verde', '11988888888', 'Rua Cogumelo 2', 'senha5678', '');

-- Usuário 3
INSERT INTO tb_users (email, first_name, last_name, phone_number, address, password, salt_password)
VALUES ('peach@example.com', 'Peach', 'Princesa', '11977777777', 'Castelo Real', 'senha91011', '');

-- Carrinho do Mario
INSERT INTO tb_shopping_cart (cart_id, user_email, finished)
VALUES (1, 'mario@example.com', FALSE);

-- Carrinho do Luigi
INSERT INTO tb_shopping_cart (cart_id, user_email, finished)
VALUES (2, 'luigi@example.com', TRUE);

-- Carrinho da Peach
INSERT INTO tb_shopping_cart (cart_id, user_email, finished)
VALUES (3, 'peach@example.com', FALSE);

-- Carrinho do Mario (cart_id = 1)
INSERT INTO tb_cart_products (product_id, cart_id, quantity)
VALUES 
  (5, 1, 2),   -- 2x produto 5
  (12, 1, 1);  -- 1x produto 12

-- Carrinho do Luigi (cart_id = 2)
INSERT INTO tb_cart_products (product_id, cart_id, quantity)
VALUES 
  (7, 2, 1),   -- 1x produto 7
  (20, 2, 3);  -- 3x produto 20

-- Carrinho da Peach (cart_id = 3)
INSERT INTO tb_cart_products (product_id, cart_id, quantity)
VALUES 
  (3, 3, 2),   -- 2x produto 3
  (33, 3, 1);  -- 1x produto 33

-- Comentário do Mario para o produto 5
INSERT INTO tb_comments (user_email, product_id, message, rating)
VALUES ('mario@example.com', 5, 'Excelente macaco atirador!', 2);

-- Comentário do Luigi para o produto 7
INSERT INTO tb_comments (user_email, product_id, message, rating)
VALUES ('luigi@example.com', 7, 'Bom contra bloons camuflados.', 3);

-- Comentário da Peach para o produto 33
INSERT INTO tb_comments (user_email, product_id, message, rating)
VALUES ('peach@example.com', 33, 'Muito fofo e eficaz!', 5);

-- 1) Aponta todas as imagens de produtos do tipo "Macacos" (type = 1)
UPDATE tb_products_images AS img
JOIN tb_products AS p
  ON img.product_id = p.product_id
SET img.image_url = 'https://s2-g1.glbimg.com/MVIpOVDJgHL5JQkPIkh6NbAtkzw=/0x0:620x794/984x0/smart/filters:strip_icc()/s.glbimg.com/jo/g1/f/original/2012/03/06/caters_monkey_snapper_03.jpg'
WHERE p.type = 1;

-- 2) Aponta todas as imagens de produtos do tipo "Bloons" (type = 2)
UPDATE tb_products_images AS img
JOIN tb_products AS p
  ON img.product_id = p.product_id
SET img.image_url = 'https://ih1.redbubble.net/image.4903694855.8053/bg,f8f8f8-flat,750x,075,f-pad,750x1000,f8f8f8.u10.jpg'
WHERE p.type = 2;