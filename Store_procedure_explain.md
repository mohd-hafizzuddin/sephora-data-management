# **List of all store procedure and all its explaination**


**1. Store Procedure for Brands table data insertion**

- This stored procedure accepts a table name as a parameter.
- It selects the necessary columns (brand_id and brand_name) from the parameter table.
- The procedure checks whether each brand_id from the temporary table exists in the brands table. Only new brand_ids (non-existing in the brands table) will be inserted.
- If a brand_id already exists, the procedure updates the corresponding record in the brands table to reflect any changes in the brand_name.
- Transactions are used to ensure atomicity, meaning that if any error occurs, all operations are rolled back to avoid partial updates.
- The procedure uses a TRY...CATCH block to handle potential errors. If an error occurs during the insert or update process, the transaction is rolled back to maintain data integrity.
- After the rollback, the THROW statement re-raises the error, allowing it to be caught or logged by higher-level error handling mechanisms.

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

```sql
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
```


```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

