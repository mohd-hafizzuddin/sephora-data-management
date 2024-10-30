**List of Primary Key and Foreign Key**

**1. Primary Key**

```sql

--Assign Primary Key for product_id in product table
ALTER TABLE product
ADD CONSTRAINT pk_product PRIMARY KEY (product_id);

--Assign Primary Key for brand_id in brand table
ALTER TABLE brands
ADD CONSTRAINT pk_brands PRIMARY KEY (brand_id);

--Assign primary key on author_table
ALTER TABLE author
ADD CONSTRAINT pk_author PRIMARY KEY (author_id);

```

**2. Foreign Key**

```sql

--Assign foreign key in product_pricing table
ALTER TABLE product_pricing
ADD CONSTRAINT fk_ppricning FOREIGN KEY (product_id) REFERENCES product(product_id);

--Assign foreign key in product_reviews table
ALTER TABLE product_reviews
ADD CONSTRAINT fk_previews FOREIGN KEY (product_id) REFERENCES product(product_id);

--Assign foreign key in product_status table
ALTER TABLE product_status
ADD CONSTRAINT fk_pstatus FOREIGN KEY (product_id) REFERENCES product(product_id);

--Assign foreign key in product_variation table
ALTER TABLE product_variation
ADD CONSTRAINT fk_pvariation FOREIGN KEY (product_id) REFERENCES product(product_id);

--Assign foreign key in product table
ALTER TABLE product
ADD CONSTRAINT fk_product FOREIGN KEY (brand_id) REFERENCES brands(brand_id);

--assign foreign key on author_reviewtext table
ALTER TABLE author_reviewtext
ADD CONSTRAINT fk_authorid FOREIGN KEY (author_id) REFERENCES author(author_id); 

ALTER TABLE author_reviewtext
ADD CONSTRAINT fk_productid FOREIGN KEY (product_id) REFERENCES product(product_id); 

--assign foreign key on author_rating table
ALTER TABLE author_rating
ADD CONSTRAINT fk_RID FOREIGN KEY (author_id) REFERENCES author(author_id); 

ALTER TABLE author_rating
ADD CONSTRAINT fk_PID FOREIGN KEY (product_id) REFERENCES product(product_id);

```
