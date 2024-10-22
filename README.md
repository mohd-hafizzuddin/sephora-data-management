# sephora-data-management

**Author:**  Mohamad Hafizzudin Bin Yahya

**Project Name:**  Sephora Data Management

**Email:**  hafizz.yahya01@gmail.com

**LinkedIn:**  http://www.linkedin.com/in/mohamad-hafizzuddin

**Project Overview:**

This project involve in managing data from Sephora. The goal of this project is to normalize raw data from Sephora to maintain the credibility and the integrity of the normalize table  by implementing primary key and foreign key. Data insertion in this project should be automated using store procedure. The project will showcase efficient data management during table update and insertion.

**Tool Use:**
SQL Server Management Studio (SSMS)
- Database Creation
- Data normalization
- Data Transformation
- Data cleaning

# **Database Structure**

**Database Name:** sephora_data_management

**Key Tables**

### `product`
| Column Name  | Data Type      | Description                                           |
|--------------|----------------|-------------------------------------------------------|
| product_id   | nvarchar(50)    | Primary key, unique identifier for each product       |
| product_name | nvarchar(150)   | Name of the product                                   |
| brand_id     | int             | Foreign key referencing `brands(brand_id)`            |

### `brands`
| Column Name  | Data Type      | Description                                           |
|--------------|----------------|-------------------------------------------------------|
| brand_id     | int             | Primary key, unique identifier for each brand         |
| brand_name   | nvarchar(150)   | Name of the brand                                     |

### `product_reviews`
| Column Name      | Data Type      | Description                                           |
|------------------|----------------|-------------------------------------------------------|
| product_id       | nvarchar(50)    | Foreign key referencing `product(product_id)`         |
| favourite_count  | int             | Number of times the product was marked as favorite    |
| average_rating   | DECIMAL(5,4)    | Average rating of the product                        |
| reviews_count    | int             | Total number of reviews for the product               |

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

### `product_status`
| Column Name         | Data Type      | Description                                           |
|---------------------|----------------|-------------------------------------------------------|
| product_id          | nvarchar(50)    | Foreign key referencing `product(product_id)`         |
| limited_edition     | int             | Indicate limmited edition or not ( 1-true 0-false      |
| new                 | int             | Indicate product is new or not( 1-true 0-false                  |
| online_only         | int             | Indicate product is sold online or not ( 1-true 0-false|
| out_of_stock        | int             | Indicate product is out of stock or not ( 1-true 0-false         |
| sephora_exclusive   | int             | Indicate whether the product is Sephora exclusive or not ( 1-true 0-false |

### `product_pricing`
| Column Name      | Data Type      | Description                                           |
|------------------|----------------|-------------------------------------------------------|
| product_id       | nvarchar(50)    | Foreign key referencing `product(product_id)`         |
| price_usd        | decimal(18,2)   | Price of the product in US dollars                   |
| value_price_usd  | decimal(18,2)   | Potential cost savings of the product, presented on the site next to regular price                    |
| sale_price_usd   | decimal(18,2)   | Sale price of the product in US dollars                    |
















