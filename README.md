# Redshift-DE
# Redshift Data Engineering Assignment

## Overview
This project focuses on analyzing two key business processes using Amazon Redshift:
1. Identifying the most common **frequency of purchases** per season.
2. Finding **products with high review ratings**.

## Step 1: Setting Up Amazon Redshift
1. **Create a Redshift Cluster**
   - Navigate to AWS Redshift Console.
   - Click **Create Cluster**.
   - Choose a **single-node** cluster.
   - Select an appropriate **node type** (e.g., `dc2.large`).
   - Set the **database name, username, and password**.
   - Click **Create cluster**.

2. **Create an IAM Role**
   - Go to the **IAM Console**.
   - Create a new role with **AmazonS3ReadOnlyAccess**.
   - Attach the role to your Redshift cluster.

3. **Create an S3 Bucket and Upload Data**
   - Navigate to **Amazon S3**.
   - Create a new bucket (e.g., `shopping-data-bucket`).
   - Upload `shopping_data.csv` to this bucket.

## Step 2: Loading Data into Redshift
1. **Use the Amazon Redshift Query Editor** to run SQL commands.
2. **Create a table to store raw data**:
```sql
CREATE TABLE shopping (
    CustomerID INTEGER,
    Age INTEGER,
    Gender VARCHAR(50),
    Category VARCHAR(50),
    Location VARCHAR(50),
    Season VARCHAR(50),
    ReviewRating REAL,
    SubscriptionStatus VARCHAR(50),
    PaymentMethod VARCHAR(50),
    ShippingType VARCHAR(50),
    DiscountApplied VARCHAR(50),
    PromoCodeUsed VARCHAR(50),
    PreviousPurchases INTEGER,
    PreferredPaymentMethod VARCHAR(50),
    FrequencyOfPurchases VARCHAR(50)
);
```
3. **Copy data from S3 into Redshift**:
```sql
COPY shopping
FROM 's3://shopping-data-bucket/shopping_data.csv'
IAM_ROLE 'arn:aws:iam::your-account-id:role/your-redshift-role'
FORMAT AS CSV
IGNOREHEADER 1;
```

## Step 3: Schema Design
We are using a star schema with 1 fact table and 3 dimension tables:

### **1. Dimension Tables**
```sql
CREATE TABLE dimCustomer (
    CustomerID INTEGER PRIMARY KEY,
    Age INTEGER,
    Gender VARCHAR(50),
    Location VARCHAR(50),
    SubscriptionStatus VARCHAR(50),
    PreferredPaymentMethod VARCHAR(50)
);

CREATE TABLE dimProduct (
    Category VARCHAR(50) PRIMARY KEY,
    DiscountApplied VARCHAR(50),
    PromoCodeUsed VARCHAR(50)
);

CREATE TABLE dimTransaction (
    TransactionID INTEGER IDENTITY(1,1) PRIMARY KEY,
    CustomerID INTEGER,
    PaymentMethod VARCHAR(50),
    ShippingType VARCHAR(50),
    Season VARCHAR(50),
    FrequencyOfPurchases VARCHAR(50),
    FOREIGN KEY (CustomerID) REFERENCES dimCustomer(CustomerID)
);
```

### **2. Fact Table**
```sql
CREATE TABLE factPurchases (
    CustomerID INTEGER,
    Age INTEGER,
    ReviewRating REAL,
    PreviousPurchases INTEGER,
    FOREIGN KEY (CustomerID) REFERENCES dimCustomer(CustomerID)
);
```

## Step 4: Data Insertion
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

## Step 5: Business Queries
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



