
create table shopping(
CustomerID INT,	
Age INT	,
Gender varchar(50),
Category varchar(50),
Location varchar(50),
Season varchar(50),
ReviewRating REAL,	
SubscriptionStatus varchar(50),
PaymentMethod varchar(50),
ShippingType varchar(50),
DiscountApplied varchar(50),
PromoCodeUsed varchar(50),
PreviousPurchases int,	
PreferredPaymentMethod	varchar(50),
FrequencyofPurchases varchar(50)

);    
    

COPY dev.public.shopping FROM 's3://zzetu/shopping.csv' IAM_ROLE 'arn:aws:iam::your-account-id:role/your-redshift-role' FORMAT AS CSV DELIMITER ',' QUOTE '"' IGNOREHEADER 1 REGION AS 'us-east-1';


create table dim_customer (
    CustomerID integer primary key,
    Age integer,
    Gender varchar(50),
    Location varchar(50),
    SubscriptionStatus varchar(50),
    PreferredPaymentMethod varchar(50)
);


-- Create the product dimension table

create table dim_product (
    Category varchar(50) primary key,
    DiscountApplied varchar(50),
    PromoCodeUsed varchar(50)
);

-- Create the transaction dimension table

create table dim_transaction (
    Transaction_ID integer identity(1,1) primary key,
    CustomerID integer references dim_customer(CustomerID),
    PaymentMethod varchar(50),
    ShippingType varchar(50),
    Season varchar(50),
    FrequencyofPurchases varchar(50)
);

-- Create the fact table

create table fact_purchases (
    CustomerID integer references dim_customer(CustomerID),
    Age integer,
    ReviewRating real,
    PreviousPurchases integer
);

-- Insert data into dim_customer
insert into dim_customer (CustomerID, Age, Gender, Location, SubscriptionStatus, PreferredPaymentMethod)
select distinct CustomerID, Age, Gender, Location, SubscriptionStatus, PreferredPaymentMethod from shopping;

-- Insert data into dim_product
insert into dim_product (Category, DiscountApplied, PromoCodeUsed)
select distinct Category, DiscountApplied, PromoCodeUsed from shopping;

-- Insert data into dim_transaction
insert into dim_transaction (CustomerID, PaymentMethod, ShippingType, Season, FrequencyofPurchases)
select CustomerID, PaymentMethod, ShippingType, Season, FrequencyofPurchases from shopping;

-- Insert data into fact_purchases
insert into fact_purchases (CustomerID, Age, ReviewRating, PreviousPurchases)
select CustomerID, Age, ReviewRating, PreviousPurchases from shopping;

-- Query to find the most used frequency of purchase per season
select t.Season, t.FrequencyofPurchases, count(*) as PurchaseCount
from fact_purchases f
join dim_transaction t on f.CustomerID = t.CustomerID
group by t.Season, t.FrequencyofPurchases
order by t.Season, PurchaseCount desc;

-- Query to find products with high review ratings
select avg(f.ReviewRating) as Avg_Rating
from fact_purchases f
order by Avg_Rating desc;
