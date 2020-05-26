
CREATE DATABASE BikeStores
GO

USE BikeStores
GO

CREATE SCHEMA production;
GO

CREATE SCHEMA sales;
GO

-- create tables
CREATE TABLE production.categories (
	category_id INT IDENTITY (1, 1),
	category_name VARCHAR (255) NOT NULL,
	CONSTRAINT PK_CATEGORIES_ID PRIMARY KEY (category_id) 
);

CREATE TABLE production.brands (
	brand_id INT IDENTITY (1, 1),
	brand_name VARCHAR (255) NOT NULL,
	CONSTRAINT PK_BRANDS_ID PRIMARY KEY (brand_id)
);

CREATE TABLE production.products (
	product_id INT IDENTITY (1, 1),
	product_name VARCHAR (255) NOT NULL,
	brand_id INT NOT NULL,
	category_id INT NOT NULL,
	model_year SMALLINT NOT NULL,
	list_price DECIMAL (10, 2) NOT NULL,
	CONSTRAINT PK_PRODUCTS_ID PRIMARY KEY (product_id),
	CONSTRAINT FK_PRODUCTS_CID FOREIGN KEY (category_id) REFERENCES production.categories (category_id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT FK_PRODUCTS_BID FOREIGN KEY (brand_id) REFERENCES production.brands (brand_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE sales.customers (
	customer_id INT IDENTITY (1, 1),
	first_name VARCHAR (255) NOT NULL,
	last_name VARCHAR (255) NOT NULL,
	phone VARCHAR (25),
	email VARCHAR (255) NOT NULL,
	street VARCHAR (255),
	city VARCHAR (50),
	state VARCHAR (25),
	zip_code VARCHAR (5),
	CONSTRAINT PK_CUSTOMERS_ID PRIMARY KEY (customer_id)
);

CREATE TABLE sales.stores (
	store_id INT IDENTITY (1, 1),
	store_name VARCHAR (255) NOT NULL,
	phone VARCHAR (25),
	email VARCHAR (255),
	street VARCHAR (255),
	city VARCHAR (255),
	state VARCHAR (10),
	zip_code VARCHAR (5),
	CONSTRAINT PK_STORES_ID PRIMARY KEY (store_id)
);

CREATE TABLE sales.staffs (
	staff_id INT IDENTITY (1, 1),
	first_name VARCHAR (50) NOT NULL,
	last_name VARCHAR (50) NOT NULL,
	email VARCHAR (255) NOT NULL UNIQUE,
	phone VARCHAR (25),
	active tinyint NOT NULL,
	store_id INT NOT NULL,
	manager_id INT,
	CONSTRAINT PK_STAFFS_ID PRIMARY KEY (staff_id),
	CONSTRAINT FK_STAFFS_STOREID FOREIGN KEY (store_id) REFERENCES sales.stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT FK_STAFFS_STAFFID FOREIGN KEY (manager_id) REFERENCES sales.staffs (staff_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE sales.orders (
	order_id INT IDENTITY (1, 1),
	customer_id INT,
	order_status tinyint NOT NULL,
	-- Order status: 1 = Pending; 2 = Processing; 3 = Rejected; 4 = Completed
	order_date DATE NOT NULL,
	required_date DATE NOT NULL,
	shipped_date DATE,
	store_id INT NOT NULL,
	staff_id INT NOT NULL,
	CONSTRAINT PK_ORDERS_ID PRIMARY KEY (order_id),
	CONSTRAINT FK_ORDERS_CID FOREIGN KEY (customer_id) REFERENCES sales.customers (customer_id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT FK_ORDERS_STOREID FOREIGN KEY (store_id) REFERENCES sales.stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT FK_ORDERS_STAFFCID FOREIGN KEY (staff_id) REFERENCES sales.staffs (staff_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE sales.order_items (
	orderitems_id INT IDENTITY (1, 1),
	order_id INT,
	item_id INT,
	product_id INT NOT NULL,
	quantity INT NOT NULL,
	list_price DECIMAL (10, 2) NOT NULL,
	discount DECIMAL (4, 2) NOT NULL DEFAULT 0,
	CONSTRAINT PK_ORDERITEMS_ID PRIMARY KEY (orderitems_id),
	CONSTRAINT FK_ORDERITEMS_OID FOREIGN KEY (order_id) REFERENCES sales.orders (order_id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT FK_ORDERITEMS_PID FOREIGN KEY (product_id) REFERENCES production.products (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE production.stocks (
	stock_id INT IDENTITY (1, 1),
	store_id INT,
	product_id INT,
	quantity INT,
	CONSTRAINT PK_STOCKS_ID PRIMARY KEY (stock_id),
	FOREIGN KEY (store_id) REFERENCES sales.stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product_id) REFERENCES production.products (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);