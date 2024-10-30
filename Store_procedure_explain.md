# **List of all store procedure and its explanation**


## **Stored Procedure for Brands Table Data Insertion/Update**

**1. CTE for Unique Brands:**

The procedure uses a Common Table Expression (CTE) named **brand_unique** to select **brand_id and brand_name** from the **product_info** table. **ROW_NUMBER()** function is use to assigns a unique number to each row per brand_id allowing for filtering of duplicates.

**2. MERGE Statement:**

The MERGE statement is use to perform the **UPSERT(UPDATE and INSERT)** of records in the brands table. The MERGE use **brands table** as it **TARGET** and use the **brand_unique** CTE table as it **SOURCE** on **brand_id**. When the **brand_id** from **brands table** and CTE table(unique_brand) match, it will update the brand_name. When a brand_id are not match between brands table and CTE table(unique_brand), it will insert the new value from CTE table(unique_brand) into brand table.

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

The MERGE statement is use to perform the **UPSERT(UPDATE and INSERT)** of records in the author_rating table. The MERGE use **author_rating table** as it **TARGET** and the **unique_rat** CTE table as it **SOURCE** on **author_id** and **product_id**. When the **author_id** and **product_id** from **author_rating** table and CTE table(unique_rat) match, it will update the rating,is_recommended, total_pos_feedback_count,
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
**Stored Procedure for author_reviewtext**

**1. CTE for Unique Review:**

The procedure uses a Common Table Expression (CTE) named **unique_review** to select **author_id,product_id,review_title,review_text and submission_time** from the **reviews1** table. **ROW_NUMBER()** function is use to assigns a unique number to each row per author_id,product_id with the latest submission_time allowing for filtering of duplicates and choose the latest review submitted.

**2. MERGE Statement:**

The MERGE statement is use to perform the **UPSERT(UPDATE and INSERT)** of records in the author_reviewtext table. The MERGE use **author_reviewtext table** as it **TARGET** and the **unique_review** CTE table as it **SOURCE** on **author_id** and **product_id**. When the **author_id** and **product_id** from **author_reviewtext** table and CTE table(unique_review) match, it will update the review_title, review_text and submission_time column. When a author_id and product_id are not match between author_review table and CTE table(unique_review), it will insert the new value from CTE table(unique_review) into author_review table.

**3. Transaction Management:**

The use of BEGIN TRANSACTION, COMMIT TRANSACTION, and error handling via TRY...CATCH ensures that if any part of the operation fails, all changes are rolled back to maintain data integrity.

**4. Error Handling:**

If an error occurs during the merge process, the transaction is rolled back. The error details are captured in local variables (@ErrorMessage, @ErrorSeverity, @ErrorState), and the RAISERROR statement is used to re-throw the error, allowing for effective error reporting.

```sql
CREATE OR ALTER PROCEDURE insertupdateAuthorReviewText
AS
BEGIN
	BEGIN TRANSACTION;

		BEGIN TRY
			WITH unique_review AS (
				SELECT author_id,
				       product_id,
					   review_title,
					   review_text,
					   submission_time, 
					   ROW_NUMBER() OVER (PARTITION BY author_id,product_id ORDER BY submission_time DESC) AS rn
                FROM reviews1)

			MERGE INTO author_reviewtext AS art
			USING (SELECT author_id,product_id,review_title,review_text,submission_time FROM unique_review WHERE rn = 1) AS ur
			ON art.author_id = ur.author_id AND art.product_id = ur.product_id

			WHEN MATCHED THEN
				UPDATE
					SET art.review_title = ur.review_title,
						art.review_text = ur.review_text,
						art.submission_time = ur.submission_time

			WHEN NOT MATCHED BY TARGET THEN
				INSERT (author_id,product_id,review_title,review_text,submission_time)
				VALUES (ur.author_id,ur.product_id,ur.review_title,ur.review_text,ur.submission_time);

	COMMIT TRANSACTION;
		END TRY

		BEGIN CATCH
			ROLLBACK TRANSACTION ;

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

**Stored Procedure for calculating average rating, count of review and count of recommended(recommended =1 , not recommended =0) for product_review table**

**1. CTE for Is Recommended, Not recommended, Average Rating and Count Review:**

The procedure uses  Common Table Expression (CTE) named **is_recomm, is_not_recomm,avg_rat and count_review** to calculate count of recommended and count of not recommended and average rating from the **author_rating** table. Meanwhile, Common Table Expression (CTE) **count_review** use to calculate count of review from **author_reviewtext** table.

**2. MERGE Statement:**

The MERGE statement is use to perform the **UPSERT(UPDATE and INSERT)** of records in the product_reviews table. The MERGE use **product_review table** as it **TARGET** and the **is_recomm, is_not_recomm,avg_rat and count_review** CTE table as it **SOURCE** on **product_id**. When **product_id** from **product_review** table and CTE table(is_recomm, is_not_recomm,avg_rat and count_review) match, it will update the avg_rating,count_review,count_recomm and count_not_recomm column. When a product_id are not match between product_review table and all the CTE table, it will insert the new product_id and new calculation from all CTE table into product_review table.

**3. Transaction Management:**

The use of BEGIN TRANSACTION, COMMIT TRANSACTION, and error handling via TRY...CATCH ensures that if any part of the operation fails, all changes are rolled back to maintain data integrity.

**4. Error Handling:**

If an error occurs during the merge process, the transaction is rolled back. The error details are captured in local variables (@ErrorMessage, @ErrorSeverity, @ErrorState), and the RAISERROR statement is used to re-throw the error, allowing for effective error reporting.

```sql

CREATE OR ALTER PROCEDURE calculateproductReviews
 AS
 BEGIN

	BEGIN TRANSACTION;

		BEGIN TRY
			WITH is_recomm AS (
			SELECT DISTINCT product_id, 
				COUNT(is_recommended) AS count_recomm
			FROM author_rating
			WHERE is_recommended = 1
			GROUP BY product_id),

			is_not_recomm AS (
			SELECT product_id, 
				COUNT(is_recommended) AS count_not_recomm
			FROM author_rating
			WHERE is_recommended = 0
			GROUP BY product_id),

			avg_rat AS (
			SELECT product_id,
				AVG(rating) AS avg_rating
			FROM author_rating
			GROUP BY product_id),

			count_review AS (
			SELECT product_id,
				COUNT(review_title) AS count_review
			FROM author_reviewtext
			GROUP BY product_id)
			
			MERGE INTO product_reviews AS pr
			USING (SELECT ir.product_id,
					ar.avg_rating,
					cr.count_review,
					ir.count_recomm,
					inr.count_not_recomm
			FROM is_recomm ir
			LEFT JOIN is_not_recomm inr
			ON ir.product_id = inr.product_id
			LEFT JOIN avg_rat ar
			ON ir.product_id = ar.product_id
			LEFT JOIN count_review cr
			ON ir.product_id = cr.product_id
			) AS review_cal
			ON pr.product_id = review_cal.product_id

			WHEN MATCHED THEN
				UPDATE
				SET pr.average_rating = review_cal.avg_rating,
				    pr.reviews_count = review_cal.count_review,
					pr.count_recommended = review_cal.count_recomm,
					pr.count_not_recommended = review_cal.count_not_recomm

			WHEN NOT MATCHED BY TARGET THEN
			INSERT (product_id,average_rating,reviews_count,count_recommended,count_not_recommended)
			VALUES (review_cal.product_id,review_cal.avg_rating,review_cal.count_review,review_cal.count_recomm,review_cal.count_not_recomm);

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
