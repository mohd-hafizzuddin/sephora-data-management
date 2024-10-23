USE sephora_data_management;
GO
/*
--import data

SELECT * FROM product_info; -- check after data import

--table normalization process
-- We create 6 new normalize table from the product_info table

CREATE TABLE product (
product_id nvarchar(50) NOT NULL,
product_name nvarchar(150) NOT NULL,
brand_id int NOT NULL
);

CREATE TABLE brands(
brand_id int NOT NULL,
brand_name nvarchar(150) NOT NULL
);

CREATE TABLE product_reviews(
product_id nvarchar(50) NOT NULL,
favourite_count int NOT NULL,
average_rating DECIMAL(5,4),
reviews_count int 
);

CREATE TABLE product_variation(
product_id nvarchar(50) NOT NULL,
size nvarchar(200),
variation_type nvarchar(200),
variation_value nvarchar(200),
variation_desc nvarchar(200),
ingredients nvarchar(MAX),
highlights nvarchar(200),
primary_category nvarchar(100) NOT NULL,
secondary_category nvarchar(100),
tertiary_category nvarchar(100),
variation_count int NOT NULL, --child_count
var_max_price decimal(18,2), --child min price
var_min_price decimal(18,2) -- child max price
);

CREATE TABLE product_status (
product_id nvarchar(50) NOT NULL,
limited_edition int NOT NULL,
new int NOT NULL,
online_only int NOT NULL,
out_of_stock int NOT NULL,
sephora_exclusive int NOT NULL
);

CREATE TABLE product_pricing(
product_id nvarchar(50) NOT NULL,
price_usd decimal(18,2) NOT NULL,
value_price_usd decimal(18,2),
sale_price_usd decimal(18,2)
);

--Assign Primary Key and Foreign Key Constraint for each normalize table.

--Assign Primary Key for product_id in product table
ALTER TABLE product
ADD CONSTRAINT pk_product PRIMARY KEY (product_id);

--Assign Primary Key for brand_id in brand table
ALTER TABLE brands
ADD CONSTRAINT pk_brands PRIMARY KEY (brand_id);

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



--Create a store procedure that will accept a data in form of a table 
--The store procedure will help in automated data insertion into existing table
--the store procedure will help to insert the new dataset into existing table(brands,product,product_pricing,product_reviews,product_status,product_variation)
--so we do not need to repeatly use INSERT INTO command everytime we want to insert new data. Just simply use the store procedure.
--we will also implement some filter to prevent any duplicate inserted into the table.

--creating store procedure for automated data insertion

--1. Store Procedure for Brands table data insertion

CREATE OR ALTER PROCEDURE insertupdateBrands
	@temptable nvarchar(128)
AS
BEGIN

	DECLARE @InsertSQL nvarchar(MAX);
	DECLARE @UpdateSQL nvarchar(MAX);
    
	BEGIN TRANSACTION;

	BEGIN TRY
		SET @InsertSQL = '
		INSERT INTO brands
		SELECT DISTINCT t.brand_id,t.brand_name 
		FROM' + QUOTENAME(@temptable) + 't
		WHERE NOT EXISTS ( 
			SELECT 1
			FROM brands b
			WHERE b.brand_id = t.brand_id
		);';

		EXECUTE sp_executesql @InsertSQL;

		SET @UpdateSQL = '
		UPDATE b                                   
		SET b.brand_id = t.brand_id,
		    b.brand_name = t.brand_name
		FROM brands b
		JOIN' + QUOTENAME(@temptable) + ' t
		ON b.brand_id = t.brand_id ;';

		EXECUTE sp_executesql @UpdateSQL;

		COMMIT TRANSACTION;

	END TRY
	
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH
END; 

EXECUTE insertupdateBrands @temptable = 'product_info';

--check the table
SELECT * FROM brands;


--2. SP for product table data insertion

CREATE OR ALTER PROCEDURE insertupdateProduct
     @temptable nvarchar(128)
AS
BEGIN
	DECLARE @InsertSQL nvarchar(MAX);
	DECLARE @UpdateSQL nvarchar(MAX);

	BEGIN TRANSACTION;

	BEGIN TRY
	    SET @InsertSQL = '
		INSERT INTO product
		SELECT t.product_id,t.product_name,t.brand_id
		FROM' + QUOTENAME(@temptable) + ' t
		WHERE NOT EXISTS(
			SELECT 1
			FROM product p
			WHERE p.product_id = t.product_id
			);';

		EXECUTE sp_executesql @InsertSQL;
		
		SET @UpdateSQL = '
		UPDATE p
		SET p.product_id = t.product_id,
		    p.product_name = t.product_name,
			p.brand_id = t.brand_id
		FROM product p
		JOIN' + QUOTENAME(@temptable) + 't
		ON p.product_id = t.product_id;';

		EXECUTE sp_executesql @UpdateSQL;

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION ;
		THROW;
	END CATCH
END;

EXEC insertupdateProduct @temptable = 'product_info';

--check the product table
SELECT * FROM product;


--3. SP for product_pricing table data insertion

CREATE OR ALTER PROCEDURE insertupdatePPricing
@temptable nvarchar(128)
AS
BEGIN
	DECLARE @InsertSQL nvarchar(MAX);
	DECLARE @UpdateSQL nvarchar(MAX);

	BEGIN TRANSACTION;

	BEGIN TRY

	SET @InsertSQL = '
	INSERT INTO product_pricing
	SELECT product_id,price_usd,value_price_usd,sale_price_usd
	FROM' + QUOTENAME(@temptable) + ' t
	WHERE NOT EXISTS (
		SELECT 1 
		FROM product_pricing pp
		WHERE pp.product_id = t.product_id
		);';

	EXECUTE sp_executesql @InsertSQL;
	
	SET @UpdateSQL = '
	Update pp
	SET pp.product_id = t.product_id,
	    pp.price_usd = t.price_usd,
		pp.value_price_usd = t.value_price_usd,
		pp.sale_price_usd = t.sale_price_usd
	FROM product_pricing pp
	JOIN' + QUOTENAME(@temptable) + 't
	ON pp.product_id = t.product_id;';

	EXECUTE sp_executesql @UpdateSQL;
	
	COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH
END;

EXECUTE insertupdatePPricing @temptable = 'product_info';
--check after table insertion
SELECT * FROM product_pricing;


--4. SP for product_reviews table data insertion
-- In this store procedure we only populate product_id and favourite_count.
-- The other remaining 2 column will be populate later

CREATE OR ALTER PROCEDURE insertupdateReviews
 @temptable nvarchar(128)
 AS
 BEGIN
	DECLARE @InsertSql nvarchar(MAX);
	DECLARE @UpdateSql nvarchar(MAX);

	BEGIN TRANSACTION;

	BEGIN TRY
		SET @InsertSql = '
		INSERT INTO product_reviews(product_id,favourite_count)
		SELECT t.product_id,t.loves_count
		FROM' + QUOTENAME(@temptable) + ' t
		WHERE NOT EXISTS(
			SELECT 1
			FROM product_reviews pr
			WHERE pr.product_id = t.product_id
			);';

		EXECUTE sp_executesql @InsertSql;

		SET @UpdateSql = '
		UPDATE pr
		SET pr.product_id = t.product_id,
		    pr.favourite_count = t.loves_count
		FROM product_reviews pr
		JOIN' + QUOTENAME(@temptable) + ' t
		ON pr.product_id = t.product_id;';

		EXECUTE sp_executesql @UpdateSql;

		COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH
 END;

EXECUTE insertupdateReviews @temptable = 'product_info'; 
 --check table 
 SELECT * FROM product_reviews;


--5. SP for product_status table data insertion

CREATE OR ALTER PROCEDURE insertupdateStatus
 @temptable nvarchar(128)
 AS
 BEGIN

	DECLARE @InsertSql nvarchar(MAX);
	DECLARE @UpdateSql nvarchar(MAX);
	 
	BEGIN TRANSACTION;

	BEGIN TRY
		SET @InsertSql = '
		INSERT INTO product_status
		SELECT t.product_id,t.limited_edition,t.new,t.online_only,t.out_of_stock,t.sephora_exclusive
		FROM' + QUOTENAME(@temptable) + 't
		WHERE NOT EXISTS(
			SELECT 1
			FROM product_status ps
			WHERE ps.product_id = t.product_id
			);';

		EXECUTE sp_executesql @InsertSql;

		SET @UpdateSql = '
		UPDATE ps
		SET ps.product_id = t.product_id,
		    ps.limited_edition = t.limited_edition,
			ps.new = t.new,
			ps.online_only = t.online_only,
			ps.out_of_stock = t.out_of_stock,
			ps.sephora_exclusive = t.sephora_exclusive
		FROM product_status ps
		JOIN' + QUOTENAME(@temptable) + 't
		ON ps.product_id = t.product_id;';

		EXECUTE sp_executesql @UpdateSql;

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH
 END;

 EXECUTE insertupdateStatus @temptable = 'product_info';

 --check table
 SELECT * FROM product_status;

--6. SP for product_variation table data insertion

CREATE OR ALTER PROCEDURE insertupdateVariation
 @temptable nvarchar(128)
 AS
 BEGIN

	DECLARE @InsertSql nvarchar(MAX);
	DECLARE @UpdateSql nvarchar(MAX);
	 
	BEGIN TRANSACTION;

	BEGIN TRY
		SET @InsertSql = '
		INSERT INTO product_variation
		SELECT t.product_id,
		       t.size ,
			   t.variation_type ,
               t.variation_value ,
	           t.variation_desc ,
	           t.ingredients ,
	           t.highlights ,
	           t.primary_category ,
	           t.secondary_category ,
	           t.tertiary_category ,
	           t.child_count,
	           t.child_max_price,
	           t.child_min_price
		FROM' + QUOTENAME(@temptable) + 't
		WHERE NOT EXISTS(
			SELECT 1
			FROM product_variation pv
			WHERE pv.product_id = t.product_id
			);';

		EXECUTE sp_executesql @InsertSql;

		SET @UpdateSql = '
		UPDATE pv
		SET pv.product_id = t.product_id,
		    pv.size = t.size,
            pv.variation_type = t.variation_type,
			pv.variation_value = t.variation_value,
			pv.variation_desc = t.variation_desc,
			pv.ingredients = t.ingredients,
			pv.highlights = t.highlights,
			pv.primary_category = t.primary_category,
			pv.secondary_category = t.secondary_category,
			pv.tertiary_category = t.tertiary_category,
			pv.variation_count = t.child_count,
			pv.var_max_price = t.child_max_price,
			pv.var_min_price = t.child_min_price
		FROM product_variation pv 
		JOIN' + QUOTENAME(@temptable) + 't
		ON pv.product_id = t.product_id;';

		EXECUTE sp_executesql @UpdateSql;

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH
 END;
 EXECUTE insertupdateVariation @temptable = 'product_info';


--import table reviews1;
--start table normalization process

SELECT * FROM reviews1; -- check the data umport

--Normalize the table


CREATE TABLE author (
author_id nvarchar(20) NOT NULL,
);


CREATE TABLE author_characteristic (
author_id nvarchar(20),
skin_tone nvarchar(50),
eye_color nvarchar(50),
skin_type nvarchar(50),
hair_color nvarchar(50)
);


CREATE TABLE author_reviewtext(
author_id nvarchar(20) NOT NULL,
product_id nvarchar(50) NOT NULL,
review_title nvarchar(500),
review_text nvarchar(MAX),
submission_time date NOT NULL
);


CREATE TABLE author_rating(
author_id nvarchar(20) NOT NULL,
product_id nvarchar(50) NOT NULL,
rating tinyint NOT NULL,
is_recommended int,
total_pos_feedback_count smallint NOT NULL,
total_neg_feedback_count smallint NOT NULL,
total_feedback_count smallint NOT NULL,
helpfulness decimal(4,2),
submission_time date NOT NULL
);


ALTER TABLE author
ADD CONSTRAINT pk_author PRIMARY KEY (author_id);

ALTER TABLE author_characteristic
ADD CONSTRAINT fk_authorcharac FOREIGN KEY (author_id) REFERENCES author(author_id); 

ALTER TABLE author_reviewtext
ADD CONSTRAINT fk_authorid FOREIGN KEY (author_id) REFERENCES author(author_id); 

ALTER TABLE author_reviewtext
ADD CONSTRAINT fk_productid FOREIGN KEY (product_id) REFERENCES product(product_id); 

ALTER TABLE author_rating
ADD CONSTRAINT fk_RID FOREIGN KEY (author_id) REFERENCES author(author_id); 

ALTER TABLE author_rating
ADD CONSTRAINT fk_PID FOREIGN KEY (product_id) REFERENCES product(product_id);


SELECT * FROM reviews1 WHERE author_id = 'dummyuser'

-- 1. sp procedure for author table 

CREATE OR ALTER PROCEDURE insertupdateAuthor
@temptable nvarchar(128)
AS
BEGIN
	DECLARE @InsertSql NVARCHAR(MAX);
	DECLARE @UpdateSql NVARCHAR(MAX);

	BEGIN TRANSACTION;

	BEGIN TRY
		SET @InsertSql = '
		INSERT INTO author
		SELECT DISTINCT author_id 
		FROM ' + QUOTENAME(@temptable) + ' t
		WHERE NOT EXISTS (
		                  SELECT 1
						  FROM author a
						  WHERE a.author_id = t.author_id);';

		EXECUTE sp_executesql @InsertSql;

		SET @UpdateSql = '
		UPDATE a
		SET a.author_id = t.author_id
		FROM author a
		JOIN' + QUOTENAME(@temptable) + 't
		ON a.author_id = t.author_id;'; --this maybe not necessary

		EXECUTE sp_executesql @UpdateSql;
	    
		COMMIT TRANSACTION;
 	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH
END;

SELECT DISTINCT author_id FROM author; --339017

-- 2. author characteristic 

CREATE OR ALTER PROCEDURE insertAuthorCharac
 @temptable nvarchar(128)
AS
BEGIN
	DECLARE @InsertSql nvarchar(MAX);

	BEGIN TRANSACTION;

	BEGIN TRY
		SET @InsertSql = '
		INSERT INTO author_characteristic
		SELECT DISTINCT author_id,skin_tone,eye_color,skin_type,hair_color
		FROM' + QUOTENAME(@temptable) + ' t
		WHERE NOT EXISTS (
		       SELECT 1 
			   FROM author_characteristic ac
			   WHERE ac.author_id = t.author_id AND
			         ac.skin_tone = t.skin_tone AND
					 ac.eye_color = t.eye_color AND
					 ac.skin_type = t.skin_type AND
					 ac.hair_color = t.hair_color);';

		EXECUTE sp_executesql @InsertSql;

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH
END;

-- 3. author rating

CREATE OR ALTER PROCEDURE insertAuthorRat
 @temptable nvarchar(128)
AS
BEGIN
	DECLARE @InsertSql nvarchar(MAX);
	DECLARE @UpdateSql nvarchar(MAX);

	BEGIN TRANSACTION;

	BEGIN TRY
		SET @InsertSql = '
		INSERT INTO author_rating
		SELECT DISTINCT author_id,product_id,rating,is_recommended,total_pos_feedback_count,total_neg_feedback_count,total_feedback_count,helpfulness,submission_time
		FROM' + QUOTENAME(@temptable) + ' t
		WHERE NOT EXISTS (
		       SELECT 1 
			   FROM author_rating ar
			   WHERE ar.author_id = t.author_id);';

		EXECUTE sp_executesql @InsertSql;

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH
END;

-- 4.author reviewtext

CREATE OR ALTER PROCEDURE insertAuthorRT
 @temptable nvarchar(128)
AS
BEGIN
	DECLARE @InsertSql nvarchar(MAX);
	DECLARE @UpdateSql nvarchar(MAX);

	BEGIN TRANSACTION;

	BEGIN TRY
		SET @InsertSql = '
		INSERT INTO author_reviewtext
		SELECT DISTINCT author_id,product_id,review_title,review_text,submission_time
		FROM' + QUOTENAME(@temptable) + ' t
		WHERE NOT EXISTS (
		       SELECT 1 
			   FROM author_reviewtext art
			   WHERE art.author_id = t.author_id AND
			         art.product_id = t.product_id AND
					 art.review_title = t.review_title AND
					 art.review_text = t.review_text AND
					 art.submission_time = t.submission_time);';

		EXECUTE sp_executesql @InsertSql;

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH
END;


-- SP execution

EXECUTE insertupdateAuthor @temptable = 'reviews1';
EXECUTE insertAuthorCharac @temptable = 'reviews1';
EXECUTE insertAuthorRat @temptable = 'reviews1';
EXECUTE insertAuthorRT @temptable = 'reviews1';

-- Store procedure to calculate product review and rating
CREATE OR ALTER PROCEDURE get_product_review_rating 
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		
		WITH average_r AS ( -- CTE to calculate average rating on author rating table
		SELECT product_id,
			AVG(rating) AS avg_rating
		FROM author_rating
		GROUP BY product_id),

		count_r AS ( -- CTE to calculate count of review on author_reviewtext
		SELECT product_id,
			COUNT(review_title) AS count_review
		FROM author_reviewtext
		GROUP BY product_id)

		MERGE INTO product_reviews AS pr
		USING average_r AS ar
		LEFT JOIN count_r AS cr
			ON ar.product_id = cr.product_id
		ON pr.product_id = ar.product_id

		WHEN MATCHED THEN
			UPDATE
				SET pr.average_rating = ar.avg_rating,
				    pr.reviews_count = cr.count_review

		WHEN NOT MATCHED BY Target THEN 
			INSERT (product_id,average_rating,reviews_count)
			VALUES (ar.product_id,ar.avg_rating,cr.count_review);

	    COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH
END;

EXECUTE get_product_review_rating;

*/
























