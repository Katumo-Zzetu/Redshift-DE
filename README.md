# Redshift-DE
# Redshift Data Engineering Assignment

## Overview
This project focuses on analyzing two key business processes using Amazon Redshift:
1. Identifying the most common **frequency of purchases** per season.
2. Finding **products with high review ratings**.

## Redshift Schema Design
The schema consists of **three dimension tables** and **one fact table**:

### **1. Dimension Tables**
- `dimCustomer`
  - CustomerID (Primary Key)
  - Age
  - Gender
  - Location
  - SubscriptionStatus
  - PreferredPaymentMethod

- `dimProduct`
  - Category (Primary Key)
  - DiscountApplied
  - PromoCodeUsed

- `dimTransaction`
  - TransactionID (Primary Key)
  - CustomerID (Foreign Key)
  - PaymentMethod
  - ShippingType
  - Season
  - FrequencyOfPurchases

### **2. Fact Table**
- `factPurchases`
  - CustomerID (Foreign Key)
  - Age
  - ReviewRating
  - PreviousPurchases

## Data Ingestion
After loading data from an **S3 bucket** into Redshift, the following SQL scripts were used to insert data:
```sql
-- Insert data into dimCustomer
INSERT INTO dimCustomer (CustomerID, Age, Gender, Location, SubscriptionStatus, PreferredPaymentMethod)
SELECT DISTINCT CustomerID, Age, Gender, Location, SubscriptionStatus, PreferredPaymentMethod FROM shopping;

-- Insert data into dimProduct
INSERT INTO dimProduct (Category, DiscountApplied, PromoCodeUsed)
SELECT DISTINCT Category, DiscountApplied, PromoCodeUsed FROM shopping;

-- Insert data into dimTransaction
INSERT INTO dimTransaction (CustomerID, PaymentMethod, ShippingType, Season, FrequencyOfPurchases)
SELECT CustomerID, PaymentMethod, ShippingType, Season, FrequencyOfPurchases FROM shopping;

-- Insert data into factPurchases
INSERT INTO factPurchases (CustomerID, Age, ReviewRating, PreviousPurchases)
SELECT CustomerID, Age, ReviewRating, PreviousPurchases FROM shopping;
```

## Business Queries
### **1. Most Used Frequency of Purchase per Season**
```sql
SELECT t.Season, t.FrequencyOfPurchases, COUNT(*) AS PurchaseCount
FROM factPurchases f
JOIN dimTransaction t ON f.CustomerID = t.CustomerID
GROUP BY t.Season, t.FrequencyOfPurchases
ORDER BY t.Season, PurchaseCount DESC;
```

### **2. Products with High Review Ratings**
```sql
SELECT AVG(f.ReviewRating) AS AvgRating
FROM factPurchases f
ORDER BY AvgRating DESC;
```



## Setup Guide
1. **Create Redshift Cluster** and configure IAM roles.
2. **Load Data from S3** into Redshift tables.
3. **Run the SQL scripts** for creating tables and inserting data.
4. **Execute business queries** to generate insights.


## Repository Link
[GitHub Repository](https://github.com/Katumo-Zzetu/Redshift-DE-Assignment)




