SELECT * FROM NILAKSHIDB.`HousingDataForETL`;
SELECT REPLACE(PropertyAddress," ",null)FROM NILAKSHIDB.`HousingDataForETL` ;

#Cleaning data in SQL Queries

#Standardize Sales Date format

Update HousingDataForETL SET SaleDate = date_format(str_to_date(saledate, '%M %d,%Y'), '%d/%m/%Y %H:%i:%s')

Select saledate FROM NILAKSHIDB.`HousingDataForETL`;
 
#Populate Property Address
#Doing self join on  NILAKSHIDB.`HousingDataForETL`
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress 
FROM NILAKSHIDB.`HousingDataForETL` a
JOIN NILAKSHIDB.`HousingDataForETL` b
ON a.ParcelID = b.ParcelID and 
a.UniqueID != b.UniqueID
where a.PropertyAddress IS NULL


