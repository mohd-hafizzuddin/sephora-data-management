# **List of all store procedure and its explaination**


Stored Procedure for Brands Table Data Insertion/Update
This stored procedure handles the insertion and updating of records in the Brands table.

**1. CTE for Unique Brands:**

The procedure uses a Common Table Expression (CTE) named brand_unique to select brand_id and brand_name from the product_info table. ROW_NUMBER() function is use to assigns a unique number to each row per brand_id allowing for filtering of duplicates.

**2. MERGE Statement:**

The MERGE statement is use to perform the UPSERT(UPDATE and INSERT) of records in the brands table. The MERGE use brands table as it target and use the unique_brand CTE table as it source on brand_id. When the brand_id from brands table and CTE table(unique_brand) match, it will update the brand_name. When a brand_id are not match between brands table and CTE table(unique_brand), it will insert the new value from CTE table(unique_brand) into brand table.

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

The MERGE statement is use to perform the **UPSERT(UPDATE and INSERT)** of records in the product table. The MERGE use **product table** as it **TARGET** and the **unique_product** CTE table as it **SOURCE** on **product_id**. When the **product_id** from **product** table and CTE table(unique_brand) match, it will update the product_name and brand_id. When a product_id are not match between product table and CTE table(unique_product), it will insert the new value from CTE table(unique_product) into product table.

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

**Stored Procedure for product_pricing table data insertion**

**1. CTE for Unique Pricing:**

The procedure uses a Common Table Expression (CTE) named **unique_ppricing** to select **product_id, price_usd,value_price_usd and sale_price_usd** from the **product_info** table. **ROW_NUMBER()** function is use to assigns a unique number to each row per product_id allowing for filtering of duplicates.

**2. MERGE Statement:**

The MERGE statement is use to perform the **UPSERT(UPDATE and INSERT)** of records in the product_pricing table. The MERGE use **product_pricing table** as it **TARGET** and the **unique_ppricing** CTE table as it **SOURCE** on **product_id**. When the **product_id** from **product_pticing** table and CTE table(unique_ppricing) match, it will update the price_usd,value_price_usd and sale_price_usd. When a product_id are not match between product_pricing table and CTE table(unique_ppricing), it will insert the new value from CTE table(unique_ppricing) into product_pricing table.

**3. Transaction Management:**

The use of BEGIN TRANSACTION, COMMIT TRANSACTION, and error handling via TRY...CATCH ensures that if any part of the operation fails, all changes are rolled back to maintain data integrity.

**4. Error Handling:**

If an error occurs during the merge process, the transaction is rolled back. The error details are captured in local variables (@ErrorMessage, @ErrorSeverity, @ErrorState), and the RAISERROR statement is used to re-throw the error, allowing for effective error reporting.
  
```sql
CREATE OR ALTER PROCEDURE insertupdatePPricing
AS
BEGIN

	BEGIN TRANSACTION;

		BEGIN TRY
		WITH unique_ppricing AS (
		SELECT product_id,
		       price_usd,
			   value_price_usd,
			   sale_price_usd,
			   ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY product_id) AS row_num
		FROM product_info)
	    
		MERGE INTO product_pricing AS pp
		USING (SELECT product_id,price_usd,value_price_usd,sale_price_usd FROM unique_ppricing WHERE row_num = 1) AS t
		ON pp.product_id = t.product_id

		WHEN MATCHED THEN
			UPDATE
			SET pp.price_usd = t.price_usd,
			    pp.value_price_usd = t.value_price_usd,
				pp.sale_price_usd = t.sale_price_usd

		WHEN NOT MATCHED BY TARGET THEN
		    INSERT (product_id,price_usd,value_price_usd,sale_price_usd)
			VALUES (t.product_id,t.price_usd,t.value_price_usd,t.sale_price_usd);
	
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

**Stored Procedure for product_status table data insertion**
**1. CTE for Unique Status:**

The procedure uses a Common Table Expression (CTE) named **unique_status** to select **product_id, limited_edition, new,online_only,out_of_stock and sephora_exclusive** from the **product_info** table. **ROW_NUMBER()** function is use to assigns a unique number to each row per product_id allowing for filtering of duplicates.

**2. MERGE Statement:**

The MERGE statement is use to perform the **UPSERT(UPDATE and INSERT)** of records in the product_status table. The MERGE use **product_status table** as it **TARGET** and the **unique_status** CTE table as it **SOURCE** on **product_id**. When the **product_id** from **product_status** table and CTE table(unique_status) match, it will update the limited_edition, new,online_only,out_of_stock and sephora_exclusive column. When a product_id are not match between product_status table and CTE table(unique_status), it will insert the new value from CTE table(unique_status) into product_status table.

**3. Transaction Management:**

The use of BEGIN TRANSACTION, COMMIT TRANSACTION, and error handling via TRY...CATCH ensures that if any part of the operation fails, all changes are rolled back to maintain data integrity.

**4. Error Handling:**

If an error occurs during the merge process, the transaction is rolled back. The error details are captured in local variables (@ErrorMessage, @ErrorSeverity, @ErrorState), and the RAISERROR statement is used to re-throw the error, allowing for effective error reporting.
  
```sql
CREATE OR ALTER PROCEDURE insertupdateStatus
 AS
 BEGIN
	 
	BEGIN TRANSACTION;

		BEGIN TRY
			WITH unique_status AS (
				SELECT product_id,
				       limited_edition,
					   new,
					   online_only,
					   out_of_stock,
					   sephora_exclusive,
					   ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY product_id) AS row_num
			    FROM product_info)

		    MERGE INTO product_status AS ps
			USING (SELECT 
			      product_id,
				  limited_edition,
				  new,
				  online_only,
				  out_of_stock,
				  sephora_exclusive 
				  FROM unique_status 
				  WHERE row_num = 1) AS t
			ON ps.product_id = t.product_id

			WHEN MATCHED THEN
				UPDATE
				SET ps.limited_edition = t.limited_edition,
				    ps.new = t.new,
					ps.online_only = t.online_only,
					ps.out_of_stock = t.out_of_stock,
					ps.sephora_exclusive = t.sephora_exclusive

			WHEN NOT MATCHED BY TARGET THEN
				INSERT (product_id,limited_edition,new,online_only,out_of_stock,sephora_exclusive)
				VALUES (t.product_id,t.limited_edition,t.new,t.online_only, t.out_of_stock,t.sephora_exclusive);

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

**Stored Procedure for product_variation table data insertion**
**1. CTE for Unique Variation:**

The procedure uses a Common Table Expression (CTE) named **unique_variation** to select **size ,variation_type ,variation_value ,variation_desc ,ingredients ,highlights ,primary_category ,secondary_category ,tertiary_category, child_count, child_max_price and child_min_price** from the **product_info** table. **ROW_NUMBER()** function is use to assigns a unique number to each row per product_id allowing for filtering of duplicates.

**2. MERGE Statement:**

The MERGE statement is use to perform the **UPSERT(UPDATE and INSERT)** of records in the product_variation table. The MERGE use **product_variation table** as it **TARGET** and the **unique_variation** CTE table as it **SOURCE** on **product_id**. When the **product_id** from **product_variation** table and CTE table(unique_variation) match, it will update the size ,variation_type ,variation_value ,variation_desc ,ingredients ,highlights ,primary_category ,secondary_category ,tertiary_category, child_count, child_max_price and child_min_price column. When a product_id are not match between product_status table and CTE table(unique_variation), it will insert the new value from CTE table(unique_variation) into product_status table.

**3. Transaction Management:**

The use of BEGIN TRANSACTION, COMMIT TRANSACTION, and error handling via TRY...CATCH ensures that if any part of the operation fails, all changes are rolled back to maintain data integrity.

**4. Error Handling:**

If an error occurs during the merge process, the transaction is rolled back. The error details are captured in local variables (@ErrorMessage, @ErrorSeverity, @ErrorState), and the RAISERROR statement is used to re-throw the error, allowing for effective error reporting.
  
```sql
CREATE OR ALTER PROCEDURE insertupdateVariation
 AS
 BEGIN
	 
	BEGIN TRANSACTION;

	BEGIN TRY

		WITH unique_variation AS (
		SELECT product_id,
		       size ,
                   variation_type ,
                   variation_value ,
	           variation_desc ,
	           ingredients ,
	           highlights ,
	           primary_category ,
	           secondary_category ,
	           tertiary_category ,
	           child_count,
	           child_max_price,
	           child_min_price,
			   ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY product_id) AS row_num
		FROM product_info)

		MERGE INTO product_variation AS pv
		USING (SELECT product_id,
					  size ,
					  variation_type ,
					  variation_value ,
					  variation_desc ,
					  ingredients ,
					  highlights ,
					  primary_category ,
					  secondary_category ,
					  tertiary_category ,
					  child_count,
					  child_max_price,
					  child_min_price
					  FROM unique_variation WHERE row_num = 1) AS uv
		ON pv.product_id = uv.product_id

		WHEN MATCHED THEN
			UPDATE
				SET pv.size = uv.size,
					pv.variation_type = uv.variation_type,
					pv.variation_value = uv.variation_value,
					pv.variation_desc = uv.variation_desc,
					pv.ingredients = uv.ingredients,
					pv.highlights = uv.highlights,
					pv.primary_category = uv.primary_category,
					pv.secondary_category = uv.secondary_category,
					pv.tertiary_category = uv.tertiary_category,
					pv.variation_count = uv.child_count,
					pv.var_max_price = uv.child_max_price,
					pv.var_min_price = uv.child_min_price
		
		WHEN NOT MATCHED BY TARGET THEN
			INSERT ( product_id, size, variation_type, variation_value, variation_desc, ingredients, highlights, primary_category, 
                                secondary_category, tertiary_category,variation_count,var_max_price,var_min_price)
			VALUES ( uv.product_id, uv.size, uv.variation_type, uv.variation_value, uv.variation_desc, uv.ingredients, uv.highlights, 
                                 uv.primary_category,uv.secondary_category,uv.tertiary_category,uv.child_count,uv.child_max_price,uv.child_min_price);
               
	           
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

		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)
	END CATCH
 END;
```

**Stored Procedure for author table**
**1. CTE for Unique Charac:**

The procedure uses a Common Table Expression (CTE) named **unique_charac** to select **author_id,skin_tone,eye_color,skin_type and hair_color** from the **reviews1** table. **ROW_NUMBER()** function is use to assigns a unique number to each row per author_id allowing for filtering of duplicates.

**2. MERGE Statement:**

The MERGE statement is use to perform the **UPSERT(UPDATE and INSERT)** of records in the author table. The MERGE use **author table** as it **TARGET** and the **unique_charac** CTE table as it **SOURCE** on **author_id**. When the **author_id** from **author** table and CTE table(unique_charac) match, it will update the skin_tone,eye_color,skin_type and hair_color column. When a author_id are not match between author table and CTE table(unique_charac), it will insert the new value from CTE table(unique_charac) into author table.

**3. Transaction Management:**

The use of BEGIN TRANSACTION, COMMIT TRANSACTION, and error handling via TRY...CATCH ensures that if any part of the operation fails, all changes are rolled back to maintain data integrity.

**4. Error Handling:**

If an error occurs during the merge process, the transaction is rolled back. The error details are captured in local variables (@ErrorMessage, @ErrorSeverity, @ErrorState), and the RAISERROR statement is used to re-throw the error, allowing for effective error reporting.
  
```sql
CREATE OR ALTER PROCEDURE insertupdateAuthor
AS
BEGIN

	BEGIN TRANSACTION;

		BEGIN TRY
	    
			WITH unique_charac AS(
			SELECT author_id,
				   skin_tone,
			       eye_color,
			       skin_type,
			       hair_color,
			       ROW_NUMBER() OVER (PARTITION BY author_id ORDER BY submission_time DESC) AS rn
		    FROM reviews1)

			MERGE INTO author AS a
			USING (SELECT author_id,skin_tone,eye_color,skin_type,hair_color FROM unique_charac WHERE rn = 1) AS uc
			ON a.author_id = uc.author_id

			WHEN MATCHED THEN
				UPDATE
					SET a.skin_tone = uc.skin_tone,
					    a.eye_color = uc.eye_color,
						a.skin_type = uc.skin_type,
						a.hair_color = uc.hair_color

			WHEN NOT MATCHED BY TARGET THEN
				INSERT (author_id,skin_tone,eye_color,skin_type,hair_color)
				VALUES (uc.author_id,uc.skin_tone,uc.eye_color,uc.skin_type,uc.hair_color);

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

		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)

	END CATCH
END;
```

**Stored Procedure for author_rating table**
**1. CTE for Unique Rat:**

The procedure uses a Common Table Expression (CTE) named **unique_rat** to select **author_id,product_id,rating,is_recommended,total_pos_feedback_count,
total_neg_feedback_count,total_feedback_count,helpfulness,submission_time** from the **reviews1** table. **ROW_NUMBER()** function is use to assigns a unique number to each row per author_id,product_id with the latest submission_time allowing for filtering of duplicates and choose the latest review submitted.

**2. MERGE Statement:**

The MERGE statement is use to perform the **UPSERT(UPDATE and INSERT)** of records in the author_rating table. The MERGE use **author_rating table** as it **TARGET** and the **unique_rat** CTE table as it **SOURCE** on **author_id** and **product_id**. When the **author_id** and **product_id** from **author_rating** table and CTE table(unique_rat) match, it will update the product_id,rating,is_recommended, total_pos_feedback_count,
total_neg_feedback_count, total_feedback_count,helpfulness and submission_time column. When a author_id and product_id are not match between author_rating table and CTE table(unique_rat), it will insert the new value from CTE table(unique_rat) into author_rating table.

**3. Transaction Management:**

The use of BEGIN TRANSACTION, COMMIT TRANSACTION, and error handling via TRY...CATCH ensures that if any part of the operation fails, all changes are rolled back to maintain data integrity.

**4. Error Handling:**

If an error occurs during the merge process, the transaction is rolled back. The error details are captured in local variables (@ErrorMessage, @ErrorSeverity, @ErrorState), and the RAISERROR statement is used to re-throw the error, allowing for effective error reporting.

```sql
CREATE OR ALTER PROCEDURE insertupdateAuthorRat
AS
BEGIN

	BEGIN TRANSACTION;

		BEGIN TRY
			
			WITH unique_rat AS (
			SELECT author_id,
			product_id,
			rating,
			is_recommended,
			total_pos_feedback_count,
			total_neg_feedback_count,
			total_feedback_count,
			helpfulness,
			submission_time, 
			ROW_NUMBER() OVER (PARTITION BY author_id,product_id ORDER BY submission_time DESC) AS rn
			FROM reviews1)

			MERGE INTO author_rating AS ar
			USING ( SELECT author_id,product_id,rating,is_recommended,total_pos_feedback_count, 
                                 total_neg_feedback_count,total_feedback_count,helpfulness,submission_time
			        FROM unique_rat WHERE rn = 1) AS r
                        ON ar.author_id = r.author_id AND ar.product_id = r.product_id

			WHEN MATCHED THEN
				UPDATE
					SET ar.rating = r.rating,
						ar.is_recommended = r.is_recommended,
						ar.total_pos_feedback_count = r.total_pos_feedback_count,
						ar.total_neg_feedback_count = r.total_neg_feedback_count,
						ar.total_feedback_count = r.total_feedback_count,
						ar.helpfulness = r.helpfulness,
						ar.submission_time = r.submission_time

			WHEN NOT MATCHED BY TARGET THEN
				INSERT (author_id,product_id,rating,is_recommended,total_pos_feedback_count, 
                                        total_neg_feedback_count,total_feedback_count,helpfulness,submission_time)
				VALUES (r.author_id,r.product_id,r.rating,r.is_recommended,r.total_pos_feedback_count, 
                                        r.total_neg_feedback_count,r.total_feedback_count,r.helpfulness,r.submission_time);

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

			RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)
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
