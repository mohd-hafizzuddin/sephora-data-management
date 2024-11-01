# **Table Normalization Process**

Table normalization technique is apply to reduce data redundacy, improve data integrity and make data much more efficient by reducing it into smaller table. It help to avoid data from duplicate and ensure the insert, update and deletion process more accurate. In this project we normalize the original table product_info into few other table. We also normalize reviews1 table into smaller table. All table normalization process follow all the table normalization rules.

**Original 'product_info' Table**

### `product_info`
| Column Name         | Data Type        | Description                                      |
|---------------------|------------------|--------------------------------------------------|
| product_id          | nvarchar(50)      | The unique identifier for the product from the site |
| product_name        | nvarchar(150)     | The full name of the product                    |
| brand_id            | smallint          | The unique identifier for the product brand from the site |
| brand_name          | nvarchar(50)      | The full name of the product brand              |
| loves_count         | int               | The number of people who have marked this product as a favorite |
| rating              | numeric(5, 2)     | The average rating of the product based on user reviews |
| reviews             | smallint          | The number of user reviews for the product      |
| size                | nvarchar(200)     | The size of the product, which may be in oz, ml, g, packs, or other units depending on the product type |
| variation_type      | nvarchar(200)     | The type of variation parameter for the product (e.g. Size, Color) |
| variation_value     | nvarchar(200)     | The specific value of the variation parameter for the product (e.g. 100 mL, Golden Sand) |
| variation_desc      | nvarchar(200)     | A description of the variation parameter for the product (e.g. tone for fairest skin) |
| ingredients         | nvarchar(MAX)     | A list of ingredients included in the product, for example: [‘Product variation 1:’, ‘Water, Glycerin’, ‘Product variation 2:’, ‘Talc, Mica’] or if no variations [‘Water, Glycerin’] |
| price_usd           | decimal(18, 2)    | The price of the product in US dollars          |
| value_price_usd     | decimal(18, 2)    | The potential cost savings of the product, presented on the site next to the regular price |
| sale_price_usd      | decimal(18, 2)    | The sale price of the product in US dollars     |
| limited_edition     | smallint          | Indicates whether the product is a limited edition or not (1-true, 0-false) |
| new                 | smallint          | Indicates whether the product is new or not (1-true, 0-false) |
| online_only         | smallint          | Indicates whether the product is only sold online or not (1-true, 0-false) |
| out_of_stock        | smallint          | Indicates whether the product is currently out of stock or not (1 if true, 0 if false) |
| sephora_exclusive   | smallint          | Indicates whether the product is exclusive to Sephora or not (1 if true, 0 if false) |
| highlights          | nvarchar(200)     | A list of tags or features that highlight the product's attributes (e.g. [‘Vegan’, ‘Matte Finish’]) |
| primary_category    | nvarchar(50)      | First category in the breadcrumb section         |
| secondary_category  | nvarchar(50)      | Second category in the breadcrumb section        |
| tertiary_category   | nvarchar(50)      | Third category in the breadcrumb section         |
| child_count         | tinyint           | The number of variations of the product available |
| child_max_price     | decimal(18, 2)    | The highest price among the variations of the product |
| child_min_price     | decimal(18, 2)    | The lowest price among the variations of the product |

Before we begin the normalization process, we first need to understand each of every column on what it represent. It make the table normalization much more easier and making sure the new table create is accurate. We normalize the product_info table into 6 new table. Below is the list of all table including it description and also it command to create the table.

### `product`
| Column Name  | Data Type      | Description                                           |
|--------------|----------------|-------------------------------------------------------|
| product_id   | nvarchar(50)    | Primary key, unique identifier for each product       |
| product_name | nvarchar(150)   | Name of the product                                   |
| brand_id     | int             | Foreign key referencing `brands(brand_id)`            |


```sql
CREATE TABLE product (
product_id nvarchar(50) NOT NULL,
product_name nvarchar(150) NOT NULL,
brand_id int NOT NULL
);
```

### `brands`
| Column Name  | Data Type      | Description                                           |
|--------------|----------------|-------------------------------------------------------|
| brand_id     | int             | Primary key, unique identifier for each brand         |
| brand_name   | nvarchar(150)   | Name of the brand                                     |

```sql
CREATE TABLE brands(
brand_id int NOT NULL,
brand_name nvarchar(150) NOT NULL
);
```
### `product_reviews`
| Column Name      | Data Type      | Description                                           |
|------------------|----------------|-------------------------------------------------------|
| product_id       | nvarchar(50)    | Foreign key referencing `product(product_id)`         |
| average_rating   | DECIMAL(5,4)    | Average rating of the product                        |
| reviews_count    | int             | Total number of reviews for the product               |
| count_recommended  | int             | Count of recommended product by author    |
| count_not_recommended  | int             |  Count of not recommended product by author    |

```sql
CREATE TABLE product_reviews(
product_id nvarchar(50) NOT NULL,
favourite_count int NOT NULL,
average_rating DECIMAL(5,4),
reviews_count int 
);
```

### `product_variation`
| Column Name        | Data Type        | Description                                           |
|--------------------|------------------|-------------------------------------------------------|
| product_id         | nvarchar(50)      | Foreign key referencing `product(product_id)`         |
| size               | nvarchar(200)     | Size of the product variation                         |
| variation_type     | nvarchar(200)     | Type of the variation parameter (e.g., color, size)             |
| variation_value    | nvarchar(200)     | Specific Value of the variation parameter (e.g., 100 mL, Golden Sand)             |
| variation_desc     | nvarchar(200)     | Description of the variation                          |
| ingredients        | nvarchar(MAX)     | List of ingredients used                              |
| highlights         | nvarchar(200)     | A list of tags or features that highlights product's attributes        |
| primary_category   | nvarchar(100)     | Main category of the product                          |
| secondary_category | nvarchar(100)     | Secondary category of the product                     |
| tertiary_category  | nvarchar(100)     | Tertiary category of the product                      |
| variation_count    | int               | Number of variations available                        |
| var_max_price      | decimal(18,2)     | Maximum price among the variations                    |
| var_min_price      | decimal(18,2)     | Minimum price among the variations                    |

```sql
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
```

### `product_status`
| Column Name         | Data Type      | Description                                           |
|---------------------|----------------|-------------------------------------------------------|
| product_id          | nvarchar(50)    | Foreign key referencing `product(product_id)`         |
| limited_edition     | int             | Indicate limmited edition or not ( 1-true 0-false      |
| new                 | int             | Indicate product is new or not( 1-true 0-false                  |
| online_only         | int             | Indicate product is sold online or not ( 1-true 0-false|
| out_of_stock        | int             | Indicate product is out of stock or not ( 1-true 0-false         |
| sephora_exclusive   | int             | Indicate whether the product is Sephora exclusive or not ( 1-true 0-false |

```sql
CREATE TABLE product_status (
product_id nvarchar(50) NOT NULL,
limited_edition int NOT NULL,
new int NOT NULL,
online_only int NOT NULL,
out_of_stock int NOT NULL,
sephora_exclusive int NOT NULL
);
```

### `product_pricing`
| Column Name      | Data Type      | Description                                           |
|------------------|----------------|-------------------------------------------------------|
| product_id       | nvarchar(50)    | Foreign key referencing `product(product_id)`         |
| price_usd        | decimal(18,2)   | Price of the product in US dollars                   |
| value_price_usd  | decimal(18,2)   | Potential cost savings of the product, presented on the site next to regular price                    |
| sale_price_usd   | decimal(18,2)   | Sale price of the product in US dollars                    |

```sql
CREATE TABLE product_pricing(
product_id nvarchar(50) NOT NULL,
price_usd decimal(18,2) NOT NULL,
value_price_usd decimal(18,2),
sale_price_usd decimal(18,2)
);
```

Next, we will normalize the reviews1 table.

**Original 'reviews1' Table**

### `reviews1`
| Column Name                 | Data Type        | Description                                      |
|-----------------------------|------------------|--------------------------------------------------|
| author_id                   | nvarchar(20)     | The unique identifier for the author of the review on the website |
| rating                      | tinyint          | The rating given by the author for the product on a scale of 1 to 5 |
| is_recommended               | int              | Indicates if the author recommends the product or not (1-true, 0-false) |
| helpfulness                 | decimal(4, 2)    | The ratio of all ratings to positive ratings for the review: helpfulness = total_pos_feedback_count / total_feedback_count |
| total_feedback_count        | smallint         | Total number of feedback (positive and negative ratings) left by users for the review |
| total_neg_feedback_count    | smallint         | The number of users who gave a negative rating for the review |
| total_pos_feedback_count    | smallint         | The number of users who gave a positive rating for the review |
| submission_time             | date             | Date the review was posted on the website in the 'yyyy-mm-dd' format |
| review_text                 | nvarchar(MAX)    | The main text of the review written by the author |
| review_title                | nvarchar(500)    | The title of the review written by the author   |
| skin_tone                   | nvarchar(50)     | Author's skin tone (e.g. fair, tan, etc.)      |
| eye_color                   | nvarchar(50)     | Author's eye color (e.g. brown, green, etc.)    |
| skin_type                   | nvarchar(50)     | Author's skin type (e.g. combination, oily, etc.) |
| hair_color                  | nvarchar(50)     | Author's hair color (e.g. brown, auburn, etc.)  |
| product_id                  | nvarchar(50)     | The unique identifier for the product on the website |
| product_name                | nvarchar(100)    | The full name of the product                     |
| brand_name                  | nvarchar(50)     | The full name of the product brand               |
| price_usd                   | decimal(18, 2)   | The price of the product in US dollars           |

Using table normalization technique and follow all it rules, we normalize above table into 3 new table



### `author`
| Column Name  | Data Type      | Description                              |
|--------------|----------------|------------------------------------------|
| author_id    | nvarchar(20)    | Primary key, unique identifier for each author |
| skin_tone    | nvarchar(50)    | Skin tone of the author                 |
| eye_color    | nvarchar(50)    | Eye color of the author                 |
| skin_type    | nvarchar(50)    | Skin type of the author                 |
| hair_color   | nvarchar(50)    | Hair color of the author                |


```sql
CREATE TABLE author_characteristic (
author_id nvarchar(20),
skin_tone nvarchar(50),
eye_color nvarchar(50),
skin_type nvarchar(50),
hair_color nvarchar(50)
);
```

### `author_reviewtext`
| Column Name      | Data Type      | Description                              |
|------------------|----------------|------------------------------------------|
| author_id        | nvarchar(20)    | Foreign key referencing `author(author_id)` |
| product_id       | nvarchar(50)    | Foreign key referencing `product(product_id)` |
| review_title     | nvarchar(500)   | Title of the review                      |
| review_text      | nvarchar(MAX)   | Text of the review                       |
| submission_time  | date            | Date when the review was submitted       |

```sql
CREATE TABLE author_reviewtext(
author_id nvarchar(20) NOT NULL,
product_id nvarchar(50) NOT NULL,
review_title nvarchar(500),
review_text nvarchar(MAX),
submission_time date NOT NULL
);
```

### `author_rating`
| Column Name              | Data Type      | Description                              |
|--------------------------|----------------|------------------------------------------|
| author_id                | nvarchar(20)    | Foreign key referencing `author(author_id)` |
| product_id               | nvarchar(50)    | Foreign key referencing `product(product_id)` |
| rating                   | tinyint         | Rating given by the author (Scale 1 to 5)               |
| is_recommended           | int             | Indicate is author recommends the product or not (1-true 0-false |
| total_pos_feedback_count | smallint        | The number of user who give positive rating      |
| total_neg_feedback_count | smallint        | The number of user who give negative rating        |
| total_feedback_count     | smallint        | Total number of feedbacks(positive and negative)                |
| helpfulness              | decimal(4,2)    | Ratio of all rating helpfulness = total_pos_feedback_count / total feedback_count        |
| submission_time          | date            | Date when the review was post was submitted       |

```sql
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
```









