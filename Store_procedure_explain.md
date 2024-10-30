# **List of all store procedure and its explaination**


Stored Procedure for Brands Table Data Insertion/Update
This stored procedure handles the insertion and updating of records in the Brands table.

**1. CTE for Unique Brands:**

The procedure uses a Common Table Expression (CTE) named brand_unique to select brand_id and brand_name from the product_info table. ROW_NUMBER() function is use to assigns a unique number to each row per brand_id allowing for filtering of duplicates.

**2. MERGE Statement:**

The MERGE statement is use to perform the UPSERT(UPDATE and INSERT) of records in the brands table. The MERGE use brands table as it target and use the unique_brand table as it source on brand_id. When the brand_id from brands table and CTE table(unique_brand) match, it will update the brand_name. When a brand_id are not match between brands table and CTE table(unique_brand), it will insert the new value from CTE table(unique_brand) into brand table.

**3. Transaction Management:**

The use of BEGIN TRANSACTION, COMMIT TRANSACTION, and error handling via TRY...CATCH ensures that if any part of the operation fails, all changes are rolled back to maintain data integrity.

**4. Error Handling:**

If an error occurs during the merge process, the transaction is rolled back. The error details are captured in local variables (@ErrorMessage, @ErrorSeverity, @ErrorState), and the RAISERROR statement is used to re-throw the error, allowing for effective error reporting.

```sql
CREATE OR ALTER PROCEDURE insertupdateBrands
AS
BEGIN   
	BEGIN TRANSACTION;

	BEGIN TRY
	    
		WITH brand_unique AS (
		SELECT brand_id, 
		       brand_name, 
			   ROW_NUMBER() OVER(PARTITION BY brand_id ORDER BY brand_id) AS row_num
	    FROM product_info)

		MERGE INTO brands AS b
		USING (SELECT brand_id,brand_name FROM brand_unique WHERE row_num = 1) AS t
		ON b.brand_id = t.brand_id

		WHEN MATCHED THEN
			UPDATE
			SET b.brand_name = t.brand_name

		WHEN NOT MATCHED BY TARGET THEN
			INSERT (brand_id,brand_name)
			VALUES (t.brand_id,t.brand_name);

		COMMIT TRANSACTION;

	END TRY
	
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
		       @ErrorState = ERROR_STATE()

		RAISERROR(@ERRORMESSAGE,@ERRORSEVERITY,@ERRORSTATE);
	END CATCH
END; 
```

## **Stored Procedure for product Table Data Insertion/Update**

**1. CTE for Unique Product:**

The procedure uses a Common Table Expression (CTE) named **unique_product** to select **product_id, product_name and brand_id** from the **product_info** table. **ROW_NUMBER()** function is use to assigns a unique number to each row per product_id allowing for filtering of duplicates.

**2. MERGE Statement:**

The MERGE statement is use to perform the **UPSERT(UPDATE and INSERT)** of records in the product table. The MERGE use **product table** as it **TARGET** and the **unique_product** table as it **SOURCE** on **product_id**. When the **product_id** from **product** table and CTE table(unique_brand) match, it will update the product_name and brand_id. When a product_id are not match between product table and CTE table(unique_product), it will insert the new value from CTE table(unique_product) into product table.

**3. Transaction Management:**

The use of BEGIN TRANSACTION, COMMIT TRANSACTION, and error handling via TRY...CATCH ensures that if any part of the operation fails, all changes are rolled back to maintain data integrity.

**4. Error Handling:**

If an error occurs during the merge process, the transaction is rolled back. The error details are captured in local variables (@ErrorMessage, @ErrorSeverity, @ErrorState), and the RAISERROR statement is used to re-throw the error, allowing for effective error reporting.
  
```sql
CREATE OR ALTER PROCEDURE insertupdateProduct
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY

	    WITH unique_product AS (
		SELECT product_id,
		       product_name,
			   brand_id,
			   ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY product_id) AS row_num
		FROM product_info)

        MERGE INTO product AS p
        USING (SELECT product_id,product_name,brand_id FROM unique_product WHERE row_num = 1) AS t
        ON p.product_id = t.product_id 

        WHEN MATCHED THEN
            UPDATE
            SET  p.product_name = t.product_name,
			     p.brand_id = t.brand_id

        WHEN NOT MATCHED BY TARGET THEN
            INSERT (product_id, product_name, brand_id)
            VALUES (t.product_id, t.product_name, t.brand_id);

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
		       @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
    END CATCH
END;
```

**3. Stored Procedure for product_pricing table data insertion**
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

**4. Stored Procedure for product_reviews table data insertion**
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

**5. Stored Procedure for product_status table data insertion**
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

**6. Stored Procedure for product_variation table data insertion**
- This stored procedure accepts a table as a parameter.
- It selects the necessary columns (product_id, size, variation_type, variation_value, variation_desc, ingredients, highlights, primary_category, secondary_category, ertiary_category, child_count, child_max_price, child_min_price) from the parameter table.
- The procedure checks whether each product_id from the temporary table exists in the product_variation. Only non-existing product_id in the product_variation table will be inserted.
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

**7.Stored Procedure for author table**
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

**8.Stored Procedure for author_characteristic table**
- This stored procedure accepts a table as a parameter.
- It selects the necessary column (author_id,skin_tone,eye_color,skin_type,hair_color) from the parameter table.
- The procedure checks whether each author_id from the @temptable exists in the author_characteristic table. Only non-existing author_id in the author_characteristic table will be inserted.
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

**9.Stored Procedure for author_rating table**
- This stored procedure accepts a table as a parameter.
- It selects the necessary column (author_id, product_id, rating, is_recommended, total_pos_feedback_count, total_neg_feedback_count, total_feedback_count, helpfulness, submission_time) from the parameter table.
- The procedure checks whether each author_id from the @temptable exists in the author_rating table. Only non-existing author_id in the author_rating table will be inserted.
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
		SELECT DISTINCT 
                author_id,product_id,rating,is_recommended,total_pos_feedback_count,total_neg_feedback_count,total_feedback_count,helpfulness,submission_time
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
**10.Stored Procedure for author_reviewtext**
- This stored procedure accepts a table as a parameter.
- It selects the necessary column (author_id,product_id,review_title,review_text,submission_time) from the parameter table.
- The procedure checks whether each author_id from the @temptable exists in the author_reviewtext table. Only non-existing author_id in the author_reviewtext table will be inserted.
- BEGIN TRANSaCTION ... COMMIT TRANSACTION are used to ensure atomicity, meaning that if any error occurs, all operations are ROLLBACK to avoid partial updates.
- The procedure uses a BEGIN TRY... BEGIN CATCH block to handle potential errors. If an error occurs during the insert or update process, the transaction is ROLLBACK to maintain data integrity.
- After the ROLLBACK, the THROW statement will raises the error, allowing it to be detected and make the error handling possible.
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

**11.Stored Procedure for calculating average rating and count of review for product_review table**

- This stored procedure, named get_product_review_rating, does not accept any parameters.
- It begins by calculating the average rating from the author_rating table, storing the result in a Common Table Expression (CTE) named average_r.
- Next, using another CTE, it calculates the count of reviews from the author_reviewtext table, stored in count_r.
- The procedure employs the MERGE INTO command to update the product_reviews table. This command is advantageous as it allows for both updating existing records and inserting new ones based on matching product_id.
- If a product_id in the product_reviews table matches one in the CTEs, the procedure updates the average rating and review count. If no match is found, it inserts a new record with the calculated values.
- The BEGIN TRANSACTION ... COMMIT TRANSACTION block ensures atomicity. If any error occurs during the process, all operations are rolled back to prevent partial updates.
- The procedure includes a BEGIN TRY ... BEGIN CATCH block to handle errors. If an error occurs, it rolls back the transaction and raises the error using the THROW statement, ensuring proper error handling. 
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
```
