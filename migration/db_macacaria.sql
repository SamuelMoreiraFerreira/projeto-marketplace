CREATE TABLE tb_users (
    email VARCHAR(10) NOT NULL PRIMARY KEY,
    first_name VARCHAR(10) NOT NULL,
    last_name VARCHAR(10) NOT NULL,
    phone_number VARCHAR(20),
    address VARCHAR(10) NOT NULL,
    password VARCHAR(10) NOT NULL,
    salt_password VARCHAR(255) NOT NULL
);

CREATE TABLE tb_products_types (
    type_id INT NOT NULL PRIMARY KEY,
    type VARCHAR(10) NOT NULL
);

CREATE TABLE tb_products (
    product_id INT NOT NULL PRIMARY KEY,
    name VARCHAR(10) NOT NULL,
    description VARCHAR(10),
    price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    type INT NOT NULL,
    FOREIGN KEY (type) REFERENCES tb_products_types(type_id)
);

CREATE TABLE tb_monkeys_classes (
    class_id INT NOT NULL PRIMARY KEY,
    class VARCHAR(10) NOT NULL,
    description VARCHAR(10)
);

CREATE TABLE tb_monkeys (
    monkey_id INT NOT NULL PRIMARY KEY,
    product_id INT NOT NULL,
    class INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES tb_products(product_id),
    FOREIGN KEY (class) REFERENCES tb_monkeys_classes(class_id)
);

CREATE TABLE tb_bloons_types (
    type_id INT NOT NULL PRIMARY KEY,
    type VARCHAR(10) NOT NULL
);

CREATE TABLE tb_bloons (
    bloon_id INT NOT NULL PRIMARY KEY,
    product_id INT NOT NULL,
    tier INT NOT NULL,
    type INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES tb_products(product_id),
    FOREIGN KEY (type) REFERENCES tb_bloons_types(type_id)
);

CREATE TABLE tb_products_images (
    image_id INT NOT NULL PRIMARY KEY,
    image_url VARCHAR(10) NOT NULL,
    product_id INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES tb_products(product_id)
);

CREATE TABLE tb_shopping_cart (
    cart_id INT NOT NULL PRIMARY KEY,
    user VARCHAR(10) NOT NULL,
    FOREIGN KEY (user) REFERENCES tb_users(email)
);

CREATE TABLE tb_cart_products (
    cart_product_id INT NOT NULL PRIMARY KEY,
    product_id INT NOT NULL,
    cart_id INT NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES tb_products(product_id),
    FOREIGN KEY (cart_id) REFERENCES tb_shopping_cart(cart_id)
);

CREATE TABLE tb_comments (
    comment_id INT NOT NULL PRIMARY KEY,
    user VARCHAR(10) NOT NULL,
    product_id INT NOT NULL,
    message VARCHAR(10) NOT NULL,
    date DATE NOT NULL,
    rating SMALLINT NOT NULL,
    FOREIGN KEY (user) REFERENCES tb_users(email),
    FOREIGN KEY (product_id) REFERENCES tb_products(product_id)
);

CREATE TABLE tb_logs (
    log_id CHAR(10) NOT NULL PRIMARY KEY,
    user VARCHAR(10) NOT NULL,
    date DATE NOT NULL,
    log_description VARCHAR(10) NOT NULL,
    changed_table VARCHAR(10) NOT NULL,
    FOREIGN KEY (user) REFERENCES tb_users(email)
);