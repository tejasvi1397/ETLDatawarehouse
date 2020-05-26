CREATE DATABASE BikeStWW;
GO
USE BikeStWW;
GO

CREATE TABLE dbo.DimCustomers(
CustomerKey INT NOT NULL,
CustomerFirstName VARCHAR(255) NULL,
CustomerLastName VARCHAR(255) NULL,
CustomerPhoneNumber VARCHAR(25) NULL,
CustomerEmail VARCHAR(255) NULL,
CustomerCity   VARCHAR(50) NULL,
CustomerState   VARCHAR(50) NULL,
CustomerZipCode VARCHAR(50) NULL,
StartDate DATE NOT NULL,
EndDate DATE NULL,
CONSTRAINT PK_DimCustomers PRIMARY KEY CLUSTERED ( CustomerKey )
);

CREATE TABLE dbo.DimCities(
CityKey INT IDENTITY (1,1) NOT NULL,
CityName VARCHAR(50) NULL,
ZipCode VARCHAR(50) NULL,
StateName VARCHAR(50) NULL,
CONSTRAINT PK_DimCities PRIMARY KEY CLUSTERED ( CityKey )
);

CREATE TABLE dbo.DimProducts(
ProductKey INT NOT NULL,
ProductName VARCHAR(255) NULL,
CategoryName VARCHAR(255) NULL,
BrandName VARCHAR(255) NULL,
ModelYear SMALLINT NULL,
StoreName VARCHAR(255) NULL,
Price INT NOT NULL,
StockQuantity INT NULL,
StartDate DATE NOT NULL,
EndDate DATE NULL,
CONSTRAINT PK_DimProducts PRIMARY KEY CLUSTERED ( ProductKey )
);

CREATE TABLE dbo.DimStaff(
StaffKey INT NOT NULL,
StaffFirstName VARCHAR(50) NULL,
StaffLastName VARCHAR(50) NULL,
StaffEmail VARCHAR(255) NULL,
StaffPhoneNumber VARCHAR(25) NULL,
CONSTRAINT PK_DimStaff PRIMARY KEY CLUSTERED ( StaffKey )
);

CREATE TABLE dbo.DimStores(
StoreKey INT IDENTITY (1,1) NOT NULL,
StoreName VARCHAR(255) NULL,
StorePhoneNumber VARCHAR(25) NULL,
StoreEmail VARCHAR(255) NULL,
StartDate DATE NOT NULL,
EndDate DATE NULL,
CONSTRAINT PK_DimSuppliers PRIMARY KEY CLUSTERED ( StoreKey )
);

CREATE TABLE dbo.DimDate(
DateKey INT NOT NULL,
DateValue DATE NOT NULL,
CYear SMALLINT NOT NULL,
CQtr TINYINT NOT NULL,
CMonth TINYINT NOT NULL,
Day TINYINT NOT NULL,
StartOfMonth DATE NOT NULL,
EndOfMonth DATE NOT NULL,
MonthName VARCHAR(9) NOT NULL,
DayOfWeekName VARCHAR(9) NOT NULL,
CONSTRAINT PK_DimDate PRIMARY KEY CLUSTERED ( DateKey )
);


CREATE TABLE dbo.FactOrders(
CustomerKey INT NOT NULL,
CityKey INT NOT NULL,
ProductKey INT NOT NULL,
StaffKey INT NOT NULL,
StoreKey INT NOT NULL,
DateKey INT NOT NULL,
Quantity INT NOT NULL,
Price DECIMAL(10, 2) NOT NULL,
Discount DECIMAL(4, 2) NOT NULL,
Price_After_Discount DECIMAL(10, 2) NOT NULL,
CONSTRAINT FK_FactOrders_DimCities FOREIGN KEY(CityKey) REFERENCES dbo.DimCities (CityKey),
CONSTRAINT FK_FactOrders_DimCustomers FOREIGN KEY(CustomerKey) REFERENCES dbo.DimCustomers (CustomerKey),
CONSTRAINT FK_FactOrders_DimDate FOREIGN KEY(DateKey) REFERENCES dbo.DimDate (DateKey),
CONSTRAINT FK_FactOrders_DimProducts FOREIGN KEY(ProductKey) REFERENCES dbo.DimProducts (ProductKey),
CONSTRAINT FK_FactOrders_DimStaff FOREIGN KEY(StaffKey) REFERENCES dbo.DimStaff (StaffKey),
CONSTRAINT FK_FactOrders_DimSuppliers FOREIGN KEY(StoreKey) REFERENCES dbo.DimStores (StoreKey)
);


CREATE INDEX IX_FactOrders_CustomerKey ON dbo.FactOrders(CustomerKey);
CREATE INDEX IX_FactOrders_CityKey ON dbo.FactOrders(CityKey);
CREATE INDEX IX_FactOrders_ProductKey ON dbo.FactOrders(ProductKey);
CREATE INDEX IX_FactOrders_StaffKey ON dbo.FactOrders(StaffKey);
CREATE INDEX IX_FactOrders_DateKey ON dbo.FactOrders(DateKey);
CREATE INDEX IX_FactOrders_SupplierKey ON dbo.FactOrders(StoreKey);

--CUSTOMER STAGE
CREATE TABLE dbo.Customers_Stage (
CustomerFirstName VARCHAR(255),
CustomerLastName VARCHAR(255),
CustomerPhoneNumber VARCHAR(25),
CustomerEmail VARCHAR(255),
CustomerCity  VARCHAR(50),
CustomerState  VARCHAR(50),
CustomerZipCode VARCHAR(50) 
);

GO



--PRODUCT STAGE
CREATE TABLE dbo.Products_Stage (
ProductName VARCHAR(255),
CategoryName VARCHAR(255),
BrandName VARCHAR(255),
ModelYear SMALLINT,
StoreName VARCHAR(255),
Price INT,
StockQuantity INT,
);

--STAFF STAGE
CREATE TABLE dbo.Staff_Stage(
StaffFirstName VARCHAR(50),
StaffLastName VARCHAR(50),
StaffEmail VARCHAR(255),
StaffPhoneNumber VARCHAR(25) 
)

GO


Create PROCEDURE dbo.Customers_Extract
AS
BEGIN;
SET NOCOUNT ON;
SET XACT_ABORT ON;
DECLARE @RowCt INT;
TRUNCATE TABLE dbo.Customers_Stage;
print 'Hello';
WITH CityDetails AS (
SELECT ci.CityID,ci.CityName,sp.StateID,sp.StateName,ci.ZipCode
FROM BikeStores.sales.CITIES ci,
BikeStores.sales.States sp
WHERE ci.StateID = sp.StateID
)

INSERT INTO dbo.Customers_Stage (CustomerFirstName,CustomerLastName,CustomerPhoneNumber,CustomerEmail,
CustomerZipCode,CustomerCity,CustomerState)

SELECT cust.first_name,cust.last_name,cust.phone,cust.email,cityCTE.ZipCode,cityCTE.CityName,cityCTE.StateName
FROM BikeStores.sales.Customers cust,
CityDetails cityCTE 
where cust.CityID = cityCTE.CityID

SET @RowCt = @@ROWCOUNT;
print @RowCt
IF @RowCt = 0
BEGIN;
THROW 50001, 'No records found. Check with source system.', 1;
END;
END;
GO

EXECUTE dbo.Customers_Extract;
SELECT * FROM dbo.Customers_Stage;
GO
SELECT * FROM BikeStores.sales.Customers;
Go

--PRODUCTS EXTRACT
create PROCEDURE dbo.Products_Extract
AS
BEGIN;
SET NOCOUNT ON;
SET XACT_ABORT ON;
DECLARE @Row_Ct INT;
TRUNCATE TABLE dbo.Products_Stage
INSERT INTO dbo.Products_Stage(ProductName,CategoryName,BrandName,ModelYear,StoreName,Price,StockQuantity)
SELECT prod.product_name, cat.category_name,bra.brand_name, prod.model_year,store.store_name, prod.list_price,sto.quantity
FROM BikeStores.production.products prod,BikeStores.production.categories cat, BikeStores.production.stocks 
sto,BikeStores.production.brands bra, BikeStores.sales.stores store
WHERE prod.category_id = cat.category_id
AND prod.product_id=sto.product_id
AND prod.brand_id=bra.brand_id
AND sto.store_id = store.store_id

SET @Row_Ct = @@ROWCOUNT
IF @Row_Ct = 0
BEGIN;
	THROW 50001, 'No records found. Check with source system.', 1;
END;
END;
GO

EXECUTE dbo.Products_Extract;
SELECT * FROM dbo.Products_Stage;
GO
select * from BikeStores.production.products;
Go


--STAFF EXTRACT
Create PROCEDURE dbo.Staff_Extract
AS
BEGIN;
SET NOCOUNT ON;
SET XACT_ABORT ON;
DECLARE @Row_Ct INT;
TRUNCATE TABLE dbo.Staff_Stage
INSERT INTO dbo.Staff_Stage(StaffFirstName,StaffLastName,StaffEmail,
StaffPhoneNumber) 

SELECT first_name,last_name,email,phone
FROM BikeStores.sales.staffs
SET @Row_Ct = @@ROWCOUNT
IF @Row_Ct = 0
BEGIN;
	THROW 50001, 'No records found. Check with source system.', 1;
END;
END;
GO

EXECUTE dbo.Staff_Extract;
SELECT * FROM dbo.Staff_Stage;
GO
SELECT * FROM BikeStores.sales.staffs;


--CUSTOMERS PRELOAD 
CREATE TABLE dbo.Customers_Preload (
CustomerKey INT NOT NULL,
CustomerFirstName VARCHAR(255) NULL,
CustomerLastName VARCHAR(255) NULL,
CustomerPhoneNumber VARCHAR(25) NULL,
CustomerEmail VARCHAR(255) NULL,
CustomerCity   VARCHAR(50) NULL,
CustomerState   VARCHAR(50) NULL,
CustomerZipCode VARCHAR(50) NULL,
StartDate DATE NOT NULL,
EndDate DATE NULL,
CONSTRAINT PK_Customers_Preload PRIMARY KEY CLUSTERED (CustomerKey)
);
GO


--PRODUCTS PRELOAD 
CREATE TABLE dbo.Products_Preload (
ProductKey INT NOT NULL,
ProductName VARCHAR(255) NULL,
CategoryName VARCHAR(255) NULL,
BrandName VARCHAR(255) NULL,
ModelYear SMALLINT NULL,
StoreName VARCHAR(255) NULL,
Price INT NOT NULL,
StockQuantity INT NULL,
StartDate DATE NOT NULL,
EndDate DATE NULL,
CONSTRAINT PK_Products_Preload PRIMARY KEY CLUSTERED ( ProductKey )
);
GO

--STAFF PRELOAD 
CREATE TABLE dbo.Staff_Preload (
StaffKey INT NOT NULL,
StaffFirstName VARCHAR(50) NULL,
StaffLastName VARCHAR(50) NULL,
StaffEmail VARCHAR(255) NULL,
StaffPhoneNumber VARCHAR(25) NULL,
CONSTRAINT PK_Staff_Preload PRIMARY KEY CLUSTERED ( StaffKey )
);
GO

--SEQUENCE
CREATE SEQUENCE dbo.CustomerKey START WITH 1;
CREATE SEQUENCE dbo.ProductKey START WITH 1;
CREATE SEQUENCE dbo.StaffKey START WITH 1;
GO


create PROCEDURE dbo.Customers_Transform
AS
BEGIN;
SET NOCOUNT ON;
SET XACT_ABORT ON;
TRUNCATE TABLE dbo.Customers_Preload;
DECLARE @StartDate DATE = GETDATE();
DECLARE @EndDate DATE = DATEADD(dd,-1,GETDATE());
BEGIN TRANSACTION;
-- Add updated records
INSERT INTO dbo.Customers_Preload /* Column list excluded for brevity */
SELECT NEXT VALUE FOR dbo.CustomerKey AS CustomerKey,stg.CustomerFirstName,
stg.CustomerLastName,stg.CustomerPhoneNumber,stg.CustomerEmail,
stg.CustomerCity,stg.CustomerState,stg.CustomerZipCode,
@StartDate,NULL
FROM dbo.Customers_Stage stg
JOIN dbo.DimCustomers cust
ON stg.CustomerFirstName = cust.CustomerFirstName AND cust.EndDate IS NULL
WHERE stg.CustomerLastName <> cust.CustomerLastName
OR stg.CustomerPhoneNumber <> cust.CustomerPhoneNumber
OR stg.CustomerEmail <> cust.CustomerEmail
OR stg.CustomerCity <> cust.CustomerCity
OR stg.CustomerState <> cust.CustomerState
OR stg.CustomerZipCode <> cust.CustomerZipCode
-- Add existing records, and expire as necessary
INSERT INTO dbo.Customers_Preload /* Column list excluded for brevity */
SELECT cust.CustomerKey,cust.CustomerFirstName,cust.CustomerLastName,cust.CustomerPhoneNumber,
cust.CustomerEmail,cust.CustomerCity,cust.CustomerState,
cust.CustomerZipCode,cust.StartDate,
CASE
WHEN pre.CustomerFirstName IS NULL THEN NULL
ELSE @EndDate
END AS EndDate
FROM dbo.DimCustomers cust
LEFT JOIN dbo.Customers_Preload pre
ON pre.CustomerFirstName = cust.CustomerFirstName
AND cust.EndDate IS NULL;

-- Create new records
INSERT INTO dbo.Customers_Preload /* Column list excluded for brevity */
SELECT NEXT VALUE FOR dbo.CustomerKey AS CustomerKey,
stg.CustomerFirstName,
stg.CustomerLastName,
stg.CustomerPhoneNumber,
stg.CustomerEmail,
stg.CustomerCity,
stg.CustomerState,
stg.CustomerZipCode,

@StartDate,
NULL
FROM dbo.Customers_Stage stg
WHERE NOT EXISTS ( SELECT 1 FROM dbo.DimCustomers cust WHERE stg.CustomerFirstName = cust.CustomerFirstName );
-- Expire missing records
INSERT INTO dbo.Customers_Preload /* Column list excluded for brevity */
SELECT cust.CustomerKey,cust.CustomerFirstName,cust.CustomerLastName,cust.CustomerPhoneNumber,
cust.CustomerEmail,cust.CustomerCity,cust.CustomerState,cust.CustomerZipCode,cust.StartDate,@EndDate
FROM dbo.DimCustomers cust
WHERE NOT EXISTS ( SELECT 1 FROM dbo.Customers_Stage stg WHERE stg.CustomerFirstName = cust.CustomerFirstName )
AND cust.EndDate IS NULL;
COMMIT TRANSACTION;
END;
GO

EXECUTE dbo.Customers_Transform;
GO
Select * from Customers_Preload;
Go


--PRODUCTS TRANSFORM
CREATE PROCEDURE dbo.Products_Transform
AS
BEGIN;
SET NOCOUNT ON;
SET XACT_ABORT ON;
TRUNCATE TABLE dbo.Products_Preload;
DECLARE @StartDate DATE = GETDATE();
DECLARE @EndDate DATE = DATEADD(dd,-1,GETDATE());
BEGIN TRANSACTION;
-- Add updated records
INSERT INTO dbo.Products_Preload /* Column list excluded for brevity */
SELECT NEXT VALUE FOR dbo.ProductKey AS ProductKey,prstg.ProductName,prstg.CategoryName,prstg.BrandName,
prstg.ModelYear,prstg.StoreName,prstg.Price,prstg.StockQuantity,@StartDate,NULL
FROM dbo.Products_Stage prstg
JOIN dbo.DimProducts pre
ON prstg.ProductName = pre.ProductName AND prstg.CategoryName = pre.CategoryName
AND prstg.StoreName = pre.StoreName AND pre.EndDate IS NULL
WHERE prstg.BrandName<>pre.BrandName
OR prstg.ModelYear <> pre.ModelYear
OR prstg.Price <> pre.Price
OR prstg.StockQuantity <> pre.StockQuantity;
-- Add existing records, and expire as necessary
INSERT INTO dbo.Products_Preload /* Column list excluded for brevity */
SELECT pre.ProductKey,pre.ProductName,pre.CategoryName,pre.BrandName,pre.ModelYear,pre.StoreName,
pre.Price,pre.StockQuantity,pre.StartDate,
CASE
WHEN propre.ProductName IS NULL THEN NULL
ELSE @EndDate
END AS EndDate
FROM dbo.DimProducts pre
LEFT JOIN dbo.Products_Preload propre
ON propre.ProductName = pre.ProductName AND propre.CategoryName = pre.CategoryName
AND propre.StoreName = pre.StoreName
AND pre.EndDate IS NULL;
-- Create new records
INSERT INTO dbo.Products_Preload /* Column list excluded for brevity */
SELECT NEXT VALUE FOR dbo.ProductKey AS ProductKey,prstg.ProductName,prstg.CategoryName,prstg.BrandName,
prstg.ModelYear,prstg.StoreName, prstg.Price,prstg.StockQuantity,@StartDate,NULL
FROM dbo.Products_Stage prstg
WHERE NOT EXISTS ( SELECT 1 FROM dbo.DimProducts pre WHERE prstg.ProductName = pre.ProductName 
AND prstg.CategoryName = pre.CategoryName AND prstg.StoreName = pre.StoreName);
-- Expire missing records
INSERT INTO dbo.Products_Preload /* Column list excluded for brevity */
SELECT pre.ProductKey,pre.ProductName,pre.CategoryName,pre.BrandName,pre.ModelYear,pre.StoreName,pre.Price,
pre.StockQuantity,pre.StartDate,@EndDate
FROM dbo.DimProducts pre
WHERE NOT EXISTS ( SELECT 1 FROM dbo.Products_Stage prstg WHERE prstg.ProductName = pre.ProductName 
AND prstg.CategoryName = pre.CategoryName AND prstg.StoreName = pre.StoreName)
AND pre.EndDate IS NULL;
COMMIT TRANSACTION;
END;
GO

EXECUTE dbo.Products_Transform;
GO
select * from Products_Preload;
GO



--STAFF TRANSFORM
CREATE PROCEDURE dbo.Staff_Transform
AS
BEGIN;
SET NOCOUNT ON;
SET XACT_ABORT ON;
TRUNCATE TABLE dbo.Staff_Preload;
BEGIN TRANSACTION;
-- Use Sequence to create new surrogate keys (Create new records)
INSERT INTO dbo.Staff_Preload /* Column list excluded for brevity */
SELECT NEXT VALUE FOR dbo.StaffKey AS StaffKey,
sp.StaffFirstName,sp.StaffLastName,
sp.StaffEmail,sp.StaffPhoneNumber
FROM dbo.Staff_Stage sp
WHERE NOT EXISTS ( SELECT 1
FROM dbo.DimStaff sa
WHERE sp.StaffFirstName = sa.StaffFirstName
AND sp.StaffPhoneNumber = sa.StaffPhoneNumber );
-- Use existing surrogate key if one exists (Add updated records)
INSERT INTO dbo.Staff_Preload /* Column list excluded for brevity */
SELECT sa.StaffKey,
sp.StaffFirstName,sp.StaffLastName,
sp.StaffEmail,sp.StaffPhoneNumber
FROM dbo.Staff_Stage sp
JOIN dbo.DimStaff sa
ON sp.StaffFirstName = sa.StaffFirstName
AND sp.StaffPhoneNumber = sa.StaffPhoneNumber;
COMMIT TRANSACTION;
END;
GO

EXECUTE dbo.Staff_Transform;
GO
Select * from Staff_Preload;
GO

--CUSTOMERS LOAD
CREATE PROCEDURE dbo.Customers_Load
AS
BEGIN;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION;
DELETE cust
FROM dbo.DimCustomers cust
JOIN dbo.Customers_Preload pl
ON cust.CustomerKey = pl.CustomerKey;
INSERT INTO dbo.DimCustomers /* Columns excluded for brevity */
SELECT * /* Columns excluded for brevity */
FROM dbo.Customers_Preload;
COMMIT TRANSACTION;
END;
GO

EXECUTE dbo.Customers_Load;
GO


--PRODUCTS LOAD
CREATE PROCEDURE dbo.Products_Load
AS
BEGIN;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION;
DELETE pr
FROM dbo.DimProducts pr
JOIN dbo.Products_Preload pp
ON pr.ProductKey = pp.ProductKey;
INSERT INTO dbo.DimProducts /* Columns excluded for brevity */
SELECT * /* Columns excluded for brevity */
FROM dbo.Products_Preload;
COMMIT TRANSACTION;
END;
GO

EXECUTE dbo.Products_Load;
GO

--SALESPEOPLE LOAD
CREATE PROCEDURE dbo.Staff_Load
AS
BEGIN;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION;
DELETE salpep
FROM dbo.DimStaff salpep
JOIN dbo.Staff_Preload salpre
ON salpep.StaffKey = salpre.StaffKey;
INSERT INTO dbo.DimStaff /* Columns excluded for brevity */
SELECT * /* Columns excluded for brevity */
FROM dbo.Staff_Preload;
COMMIT TRANSACTION;
END;
GO

EXECUTE dbo.Staff_Load;
GO
/*
select * from DimCustomers;
select * from BikeStores.sales.customers
select * from DimProducts;
select * from DimCities;
select * from DimStores;
select * from  BikeStores.production.products;
select * from DimStaff;
select * from BikeStores.sales.staffs;
*/

GO

CREATE TABLE dbo.Orders_Stage(
	Order_Date DATE,
	Customer_First_Name VARCHAR(255), 
	Customer_Last_Name VARCHAR(255),
	Customer_Email VARCHAR(255),
	Customer_City VARCHAR(50),
	Customer_State VARCHAR(50),
	Product_Name VARCHAR(255),
	Product_Category VARCHAR(255),
	Store_Name VARCHAR(255),
	Staff_First_Name VARCHAR(255), 
	Staff_Last_Name VARCHAR(255), 
	Quantity INT,
	Price DECIMAL(10, 2),
	Discount DECIMAL(4, 2) 
);

--DateDim Load

SELECT * FROM DimDate;
GO
CREATE PROCEDURE dbo.DimDate_Load
@DateValue DATE,
@EndDate DATE
AS
BEGIN
	WHILE @DateValue <= @EndDate
	BEGIN
		INSERT INTO dbo.DimDate
		SELECT CAST( YEAR(@DateValue) * 10000 + MONTH(@DateValue) * 100 + DAY(@DateValue) AS INT),
		@DateValue,
		YEAR(@DateValue),
		DATEPART(qq,@DateValue),
		MONTH(@DateValue),
		DAY(@DateValue),
		DATEADD(DAY,1,EOMONTH(@DateValue,-1)),
		EOMONTH(@DateValue),
		DATENAME(mm,@DateValue),
		DATENAME(dw,@DateValue);
		SET @DateValue = DATEADD(dd, 1, @DateValue)
	END
END

EXECUTE dbo.DimDate_Load '2016-01-01', '2018-12-28'
SELECT * from dbo.DimDate;

