# **List of all store procedure and its explaination**


**1. Store Procedure for Brands table data insertion**

- This stored procedure accepts a table as a parameter.
- It selects the necessary columns (brand_id and brand_name) from the parameter table.
- The procedure checks whether each brand_id from the @temptable exists in the brands table. Only non-existing brand_id will be inserted.
- If a brand_id already exists, the procedure updates the corresponding record in the brands table to reflect any changes in the brand name column.
- BEGIN TRANSaCTION ... COMMIT TRANSACTION are used to ensure atomicity, meaning that if any error occurs, all operations are ROLLBACK to avoid partial updates.
- The procedure uses a TRY...CATCH block to handle potential errors. If an error occurs during the insert or update process, the transaction is ROLLBACK to maintain data integrity.
- After the ROLLBACK, the THROW statement re-raises the error, allowing it to be detected and make the error handling possible.

```sql
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
```

**2. Store Procedure for product table data insertion**

- This stored procedure accepts a table as a parameter.
- It selects the necessary columns (product_id,product_name and brand_id) from the parameter table.
- The procedure checks whether each product_id from the @temptable exists in the product table. Only non-existing product_id in the product table will be inserted.
- If a product_id already exists, the procedure updates the corresponding record in the product table to reflect any changes in the product name and brand_id columns.
- BEGIN TRANSaCTION ... COMMIT TRANSACTION are used to ensure atomicity, meaning that if any error occurs, all operations are ROLLBACK to avoid partial updates.
- The procedure uses a BEGIN TRY... BEGIN CATCH block to handle potential errors. If an error occurs during the insert or update process, the transaction is ROLLBACK to maintain data integrity.
- After the ROLLBACK, the THROW statement will raises the error, allowing it to be detected and make the error handling possible.
  
```sql
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
```

**3. Store Procedure for product_pricing table data insertion**
- This stored procedure accepts a table as a parameter.
- It selects the necessary columns (product_id,price_usd,value_price_usd,sale_price_usd) from the parameter table.
- The procedure checks whether each product_id from the @temptable exists in the product table. Only non-existing product_id in the product table will be inserted.
- If a product_id already exists, the procedure updates the corresponding record in the product table to reflect any changes in the price_usd,value_price_usd and sale_price_usd columns.
- BEGIN TRANSaCTION ... COMMIT TRANSACTION are used to ensure atomicity, meaning that if any error occurs, all operations are ROLLBACK to avoid partial updates.
- The procedure uses a BEGIN TRY... BEGIN CATCH block to handle potential errors. If an error occurs during the insert or update process, the transaction is ROLLBACK to maintain data integrity.
- After the ROLLBACK, the THROW statement will raises the error, allowing it to be detected and make the error handling possible.
  
```sql
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
```

**4. Store Procedure for product_reviews table data insertion**
- This stored procedure accepts a table as a parameter.
- It selects the necessary columns (product_id,loves_count) from the parameter table.
- In this store procedure we only populate product_id and favourite_count. The other remaining 2 column will be populate later using another store procedure.
- The procedure checks whether each product_id from the @temptable exists in the product table. Only non-existing product_id in the product table will be inserted.
- If a product_id already exists, the procedure updates the corresponding record in the product table to reflect any changes in the loves_count column.
- BEGIN TRANSaCTION ... COMMIT TRANSACTION are used to ensure atomicity, meaning that if any error occurs, all operations are ROLLBACK to avoid partial updates.
- The procedure uses a BEGIN TRY... BEGIN CATCH block to handle potential errors. If an error occurs during the insert or update process, the transaction is ROLLBACK to maintain data integrity.
- After the ROLLBACK, the THROW statement will raises the error, allowing it to be detected and make the error handling possible.
  
```sql
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
```

**5. Store Procedure for product_status table data insertion**
- This stored procedure accepts a table as a parameter.
- It selects the necessary columns (product_id,limited_edition,new,online_only,out_of_stock,sephora_exclusive) from the parameter table.
- The procedure checks whether each product_id from the @temptable exists in the product table. Only non-existing product_id in the product table will be inserted.
- If a product_id already exists, the procedure updates the corresponding record in the product table to reflect any changes in the limited_edition,new,online_only,out_of_stock and sephora_exclusive columns.
- BEGIN TRANSaCTION ... COMMIT TRANSACTION are used to ensure atomicity, meaning that if any error occurs, all operations are ROLLBACK to avoid partial updates.
- The procedure uses a BEGIN TRY... BEGIN CATCH block to handle potential errors. If an error occurs during the insert or update process, the transaction is ROLLBACK to maintain data integrity.
- After the ROLLBACK, the THROW statement will raises the error, allowing it to be detected and make the error handling possible.
  
```sql
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
```

**6. Store Procedure for product_variation table data insertion**
- This stored procedure accepts a table as a parameter.
- It selects the necessary columns (product_id, size, variation_type, variation_value, variation_desc, ingredients, highlights, primary_category, secondary_category, ertiary_category, child_count, child_max_price, child_min_price) from the parameter table.
- The procedure checks whether each product_id from the temporary table exists in the product table. Only non-existing product_id in the product table will be inserted.
- If a product_id already exists, the procedure updates the corresponding record in the product table to reflect any changes in the size, variation_type, variation_value, variation_desc, ingredients, highlights, primary_category, secondary_category, ertiary_category, child_count, child_max_price and child_min_price columns.
- BEGIN TRANSaCTION ... COMMIT TRANSACTION are used to ensure atomicity, meaning that if any error occurs, all operations are ROLLBACK to avoid partial updates.
- The procedure uses a BEGIN TRY... BEGIN CATCH block to handle potential errors. If an error occurs during the insert or update process, the transaction is ROLLBACK to maintain data integrity.
- After the ROLLBACK, the THROW statement will raises the error, allowing it to be detected and make the error handling possible.
  
```sql
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
```

**7.Store Procedure for author table**
- This stored procedure accepts a table as a parameter.
- It selects the necessary column (author_id) from the parameter table.
- The procedure checks whether each author_id from the @temptable exists in the author table. Only non-existing author_id in the author table will be inserted.
- If a author_id already exists, the procedure updates the corresponding record in the author table to reflect any changes in the author_id column.
- BEGIN TRANSaCTION ... COMMIT TRANSACTION are used to ensure atomicity, meaning that if any error occurs, all operations are ROLLBACK to avoid partial updates.
- The procedure uses a BEGIN TRY... BEGIN CATCH block to handle potential errors. If an error occurs during the insert or update process, the transaction is ROLLBACK to maintain data integrity.
- After the ROLLBACK, the THROW statement will raises the error, allowing it to be detected and make the error handling possible.
  
```sql
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
```

**8.Store Procedure for author_characteristic table**
- This stored procedure accepts a table as a parameter.
- It selects the necessary column (author_id,skin_tone,eye_color,skin_type,hair_color) from the parameter table.
- The procedure checks whether each author_id from the @temptable exists in the author table. Only non-existing author_id in the author table will be inserted.
- If a author_id already exists, the procedure updates the corresponding record in the author table to reflect any changes in the skin_tone,eye_color,skin_type and hair_color column.
- BEGIN TRANSaCTION ... COMMIT TRANSACTION are used to ensure atomicity, meaning that if any error occurs, all operations are ROLLBACK to avoid partial updates.
- The procedure uses a BEGIN TRY... BEGIN CATCH block to handle potential errors. If an error occurs during the insert or update process, the transaction is ROLLBACK to maintain data integrity.
- After the ROLLBACK, the THROW statement will raises the error, allowing it to be detected and make the error handling possible.
  
```sql
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
```

**9.Store Procedure for author_rating table**
- This stored procedure accepts a table as a parameter.
- It selects the necessary column (author_id,skin_tone,eye_color,skin_type,hair_color) from the parameter table.
- The procedure checks whether each author_id from the @temptable exists in the author table. Only non-existing author_id in the author table will be inserted.
- If a author_id already exists, the procedure updates the corresponding record in the author table to reflect any changes in the skin_tone,eye_color,skin_type and hair_color column.
- BEGIN TRANSaCTION ... COMMIT TRANSACTION are used to ensure atomicity, meaning that if any error occurs, all operations are ROLLBACK to avoid partial updates.
- The procedure uses a BEGIN TRY... BEGIN CATCH block to handle potential errors. If an error occurs during the insert or update process, the transaction is ROLLBACK to maintain data integrity.
- After the ROLLBACK, the THROW statement will raises the error, allowing it to be detected and make the error handling possible.

```sql


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
```
**10.Store Procedure for author_reviewtext**

```sql
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
```

**11.Store Procedure for calculating average rating and count of review for product_review table**

```sql
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
```
