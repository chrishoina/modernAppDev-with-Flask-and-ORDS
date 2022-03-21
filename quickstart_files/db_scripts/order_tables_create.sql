/* Orders */

drop table orders;

drop table products;

drop table stores;

CREATE TABLE orders
(order_id NUMBER GENERATED ALWAYS AS IDENTITY,
product_id NUMBER(6) NOT NULL,
quantity NUMBER(8),
total_price NUMBER(8,2)
);

CREATE UNIQUE INDEX order_pk ON orders (order_id);

ALTER TABLE orders ADD (CONSTRAINT order_pk PRIMARY KEY (order_id));


/* Product */

CREATE TABLE products
(product_id NUMBER GENERATED ALWAYS AS IDENTITY,
product_name VARCHAR2(50),
product_description VARCHAR2(2000),
product_status VARCHAR2(20),
product_price NUMBER(8,2)
);

CREATE UNIQUE INDEX products_pk on products (product_id) ;

ALTER TABLE products ADD ( CONSTRAINT product_pk PRIMARY KEY (product_id));


/* Stores */

create table stores (
store_id NUMBER GENERATED ALWAYS AS IDENTITY,
store_name varchar2(500),
store_location varchar2(500),
store_latlong varchar2(500)
);

CREATE UNIQUE INDEX store_pk on stores (store_id) ;

ALTER TABLE stores ADD ( CONSTRAINT store_pk PRIMARY KEY (store_id));

commit;
