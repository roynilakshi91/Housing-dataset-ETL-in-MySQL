SELECT * FROM NILAKSHIDB.housingdataseforetl

#Cleaning data in SQL Queries

#Standardize Sales Date format
USE NILAKSHIDB;
SET SQL_SAFE_UPDATES = 0;
Update housingdataseforetl SET SaleDate = date_format(str_to_date(saledate, '%M %d,%Y'), '%d/%m/%Y %H:%i:%s')
Select saledate FROM NILAKSHIDB.housingdataseforetl

#Populate Property Address
#Doing self join on  NILAKSHIDB.`HousingDataForETL`
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress ,IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM NILAKSHIDB.`housingdataseforetl` a
JOIN NILAKSHIDB.`housingdataseforetl` b
ON a.ParcelID = b.ParcelID and 
a.UniqueID != b.UniqueID
where a.PropertyAddress IS NULL


# Updating it in the Database

UPDATE housingdataseforetl as a JOIN housingdataseforetl as b 
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

#Separating the Address into adress, city, state

Select PropertyAddress from NILAKSHIDB.housingdataseforetl
#USE CHARINDEX insteasd of LOCATE in SQL SERVER
#USE LEN insteasd of CHAR_LENGTH in SQL SERVER

Select SUBSTRING(PropertyAddress,1, LOCATE(",",PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, LOCATE(",",PropertyAddress)+1, CHAR_LENGTH(PropertyAddress)) AS Address
from NILAKSHIDB.housingdataseforetl

#Creating a new column as Street_Address

ALTER TABLE housingdataseforetl
ADD Street_Address varchar(255);
Update housingdataseforetl SET Street_Address = SUBSTRING(PropertyAddress,1, LOCATE(",",PropertyAddress)-1)


#Creating a new column as City_new

ALTER TABLE housingdataseforetl
ADD City_new varchar(255);
Update housingdataseforetl SET City_new = SUBSTRING(PropertyAddress, LOCATE(",",PropertyAddress)+1, CHAR_LENGTH(PropertyAddress))

#Checking table with two new updated column
Select * FROM NILAKSHIDB.housingdataseforetl



#Doing the same with Owner Address

Select
SUBSTRING_INDEX(REPLACE(OwnerAddress, ",","."),".",-1),
SUBSTRING_INDEX(REPLACE(OwnerAddress, ",","."),".",-2),
SUBSTRING_INDEX(REPLACE(OwnerAddress, ",","."),".",1)
FROM NILAKSHIDB.housingdataseforetl

#Creating New State column in the table from Owner Address
ALTER TABLE housingdataseforetl
ADD ownerAddress_state varchar(255);
Update housingdataseforetl SET ownerAddress_state = SUBSTRING_INDEX(REPLACE(OwnerAddress, ",","."),".",-1)

#Creating New City column in the table from Owner Address
ALTER TABLE housingdataseforetl
ADD ownerAddress_city varchar(255);
Update housingdataseforetl SET ownerAddress_city = SUBSTRING_INDEX(REPLACE(OwnerAddress, ",","."),".",-2)


#Creating New Street column in the table from Owner Address
ALTER TABLE housingdataseforetl
ADD ownerAddress_street varchar(255);
Update housingdataseforetl SET ownerAddress_street = SUBSTRING_INDEX(REPLACE(OwnerAddress, ",","."),".",1)

# Look at the table
Select * FROM NILAKSHIDB.housingdataseforetl

# Change Y and N to Yes and No to "Sold as Vacant" field

#Finding the count and unique label of yes and no in "sold as vacant" field
Select Distinct(SoldASvacant), count(soldasvacant)
FROM NILAKSHIDB.housingdataseforetl
group by soldasvacant
order by 2

Select soldasvacant,
CASE WHEN soldasvacant = "Y" THEN "YES"
     WHEN soldasvacant = "N" THEN "NO"
     ELSE Soldasvacant
     END
     FROM NILAKSHIDB.housingdataseforetl
 #Updating it in the table    
Update housingdataseforetl SET soldasvacant = CASE WHEN soldasvacant = "Y" THEN "YES"
     WHEN soldasvacant = "N" THEN "NO"
     ELSE Soldasvacant
     END

#Changes have been made    
Select Distinct(SoldASvacant)
FROM NILAKSHIDB.housingdataseforetl
group by soldasvacant
order by 2


#Remove the duplicates

#Finding duplicate rows using CTE (Common Table Expression) and Row_Number
WITH CTE AS(Select * ,
ROW_NUMBER() OVER(PARTITION BY ParcelID, propertyaddress, saleprice, saledate,legalreference ORDER BY parcelId) AS rownum
FROM NILAKSHIDB.housingdataseforetl)

Select * from CTE
where rownum>1

#Delete this duplicate rows from the table
WITH CTE AS(Select * ,
ROW_NUMBER() OVER(PARTITION BY ParcelID, propertyaddress, saleprice, saledate,legalreference ORDER BY parcelId) AS rownum
FROM NILAKSHIDB.housingdataseforetl)


DELETE FROM housingdataseforetl USING housingdataseforetl JOIN CTE ON housingdataseforetl.uniqueid = CTE.uniqueid
where CTE.rownum>1


#Removing unused columns from table
#Deleting OwnerAddress and PropertyAddress and TaxDistrict from the table


ALTER TABLE housingdataseforetl
DROP COLUMN OwnerAddress

ALTER TABLE housingdataseforetl
DROP COLUMN PropertyAddress

ALTER TABLE housingdataseforetl
DROP COLUMN TaxDistrict


SELECT * FROM NILAKSHIDB.housingdataseforetl


