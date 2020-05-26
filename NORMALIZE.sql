
CREATE TABLE [BikeStores].[sales].[CITIES]
(
	CityID INT IDENTITY (1,1) PRIMARY KEY,
	CityName VARCHAR(50),
	ZipCode VARCHAR(50)
)
GO

INSERT INTO [BikeStores].[sales].[CITIES]
SELECT DISTINCT([city]), [zip_code] FROM [BikeStores].[sales].[customers];
GO
--SELECT * FROM [BikeStores].[sales].[CITIES];

UPDATE CUST
SET CUST.city = CITY.CityID
FROM [BikeStores].[sales].[CITIES] CITY, [BikeStores].[sales].[customers] CUST
WHERE CUST.city = CITY.CityName;
GO
--SELECT * FROM [BikeStores].[sales].[customers] CUST;

sp_rename '[BikeStores].[sales].[customers].city', 'CityID', 'COLUMN';
GO

ALTER TABLE [BikeStores].[sales].[customers]
ALTER COLUMN CityID INT;
Go

--SELECT DISTINCT([state]) FROM [BikeStores].[sales].[customers];

CREATE TABLE [BikeStores].[sales].[States]
(
	StateID INT IDENTITY (1,1) PRIMARY KEY,
	StateName VARCHAR(50),
	StateCode VARCHAR(10)
)
GO

INSERT INTO [BikeStores].[sales].[States] VALUES ('Texas','TX');
INSERT INTO [BikeStores].[sales].[States] VALUES ('California','CA');
INSERT INTO [BikeStores].[sales].[States] VALUES ('New York','NY');
GO

--SELECT * FROM [BikeStores].[sales].[States];

ALTER TABLE [BikeStores].[sales].[CITIES]
ADD StateID INT;
GO

--SELECT * FROM [BikeStores].[sales].[CITIES]

WITH StateCTE AS
(
	SELECT DISTINCT(CITIES.CityID), CITIES.CityName, STATES.StateID
	FROM [BikeStores].[sales].[States] STATES, [BikeStores].[sales].[CITIES] CITIES, [BikeStores].[sales].[customers] CUST 
	WHERE CUST.state = STATES.StateCode AND CITIES.CityID = CUST.CityID 
)
UPDATE CITIES
SET StateID = StateCTE.StateID
FROM [BikeStores].[sales].[CITIES] CITIES, StateCTE
WHERE CITIES.CityID = StateCTE.CityID;
GO
ALTER TABLE [BikeStores].[sales].[customers] DROP COLUMN STATE
ALTER TABLE [BikeStores].[sales].[customers] DROP COLUMN ZIP_CODE
GO

--SELECT * FROM [BikeStores].[sales].STORES

ALTER TABLE [BikeStores].[sales].[STORES] DROP COLUMN STATE
ALTER TABLE [BikeStores].[sales].[STORES] DROP COLUMN ZIP_CODE
Go

UPDATE STORES
SET STORES.city = CITY.CityID
FROM [BikeStores].[sales].[CITIES] CITY, [BikeStores].[sales].[STORES] STORES
WHERE STORES.city = CITY.CityName;
Go

sp_rename '[BikeStores].[sales].[STORES].city', 'CityID', 'COLUMN';
Go

ALTER TABLE [BikeStores].[sales].[STORES]
ALTER COLUMN CityID INT;
Go
ALTER TABLE [BikeStores].[sales].[customers] ADD CONSTRAINT FK_CUST_CITYID FOREIGN KEY (CityID) 
REFERENCES [BikeStores].[sales].[CITIES] (CityID);
Go

ALTER TABLE [BikeStores].[sales].[STORES] ADD CONSTRAINT FK_STORES_CITYID FOREIGN KEY (CityID) 
REFERENCES [BikeStores].[sales].[CITIES] (CityID);
Go

ALTER TABLE [BikeStores].[sales].[CITIES] ADD CONSTRAINT FK_CITIES_STATEIDID FOREIGN KEY (StateID) 
REFERENCES [BikeStores].[sales].[States] (StateID);
Go

--SELECT * FROM [BikeStores].[sales].[orders]

ALTER TABLE [BikeStores].[sales].[orders]
ALTER COLUMN order_status VARCHAR(15);
Go

UPDATE [BikeStores].[sales].[orders] 
SET order_status = 'Pending' WHERE order_status = '1';
Go

UPDATE [BikeStores].[sales].[orders] 
SET order_status = 'Processing' WHERE order_status = '2';
Go

UPDATE [BikeStores].[sales].[orders] 
SET order_status = 'Rejected' WHERE order_status = '3';
Go
UPDATE [BikeStores].[sales].[orders] 
SET order_status = 'Completed' WHERE order_status = '4';
Go


