/*

Cleaning Data in SQL Queries

*/

SELECT *
From AdventureWorksDW2022.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDateConverted, CONVERT(Date,SaleDate)
From AdventureWorksDW2022.dbo.NashvilleHousing

Update AdventureWorksDW2022.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE AdventureWorksDW2022.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update AdventureWorksDW2022.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- If it doesn't Update properly






 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From AdventureWorksDW2022.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

--find rows with same parcel ID and property addresses because they are repeated
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From AdventureWorksDW2022.dbo.NashvilleHousing a
JOIN AdventureWorksDW2022.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
--ISNULL checks is a is null if yes, it'll populate it with a value 
From AdventureWorksDW2022.dbo.NashvilleHousing a
JOIN AdventureWorksDW2022.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
-- as we can see there are no rows that ahve null in it


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From AdventureWorksDW2022.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
--CHARINDEX searching for a specific character (, in our case)
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From AdventureWorksDW2022.dbo.NashvilleHousing


ALTER TABLE AdventureWorksDW2022.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update AdventureWorksDW2022.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE AdventureWorksDW2022.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update AdventureWorksDW2022.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From AdventureWorksDW2022.dbo.NashvilleHousing

--DO THE SAME FOR OWNER ADRESS 
Select OwnerAddress
From AdventureWorksDW2022.dbo.NashvilleHousing

--parsename 
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From AdventureWorksDW2022.dbo.NashvilleHousing



ALTER TABLE AdventureWorksDW2022.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update AdventureWorksDW2022.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE AdventureWorksDW2022.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update AdventureWorksDW2022.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE AdventureWorksDW2022.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update AdventureWorksDW2022.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


ALTER TABLE AdventureWorksDW2022.dbo.NashvilleHousing
DROP COLUMN SoldV;

Select *
From AdventureWorksDW2022.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From AdventureWorksDW2022.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

UPDATE AdventureWorksDW2022.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 1 THEN 'Yes' WHEN SoldAsVacant = 0 THEN 'No' ELSE CAST(SoldAsVacant AS VARCHAR(255)) END;


Select SoldAsVacant
, CASE When SoldAsVacant = 1 THEN 'Yes'
	   When SoldAsVacant = 0 THEN 'No'
	   ELSE CAST(SoldAsVacant AS VARCHAR(255))
	   END AS Soldvacant
From AdventureWorksDW2022.dbo.NashvilleHousing

ALTER TABLE AdventureWorksDW2022.dbo.NashvilleHousing
ADD Sold VARCHAR(255);

Update AdventureWorksDW2022.dbo.NashvilleHousing
SET Sold = CASE When SoldAsVacant = 1 THEN 'Yes'
	When SoldAsVacant = 0 THEN 'No'
	ELSE CAST(SoldAsvacant AS VARCHAR(255))
	END;

ALTER TABLE AdventureWorksDW2022.dbo.NashvilleHousing
DROP COLUMN SoldAsVacant;

EXEC sp_rename 'AdventureWorksDW2022.dbo.NashvilleHousing.SoldVacant', 'SoldAsVacant', 'COLUMN';


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From AdventureWorksDW2022.dbo.NashvilleHousing
--order by ParcelID
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress
--as we can see there are no duplicates anymore as we run the above code as we deleted them with the code below.

/*
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress
*/
-- to delete them we just have to use command DELETE

Select *
From AdventureWorksDW2022.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------



Select *
From AdventureWorksDW2022.dbo.NashvilleHousing

-- Remove leading and trailing spaces from PropertyAddress
UPDATE AdventureWorksDW2022.dbo.NashvilleHousing
SET PropertySplitAddress = LTRIM(RTRIM(PropertySplitAddress));

-- Remove leading and trailing spaces from OwnerAddress
UPDATE AdventureWorksDW2022.dbo.NashvilleHousing
SET OwnerSplitAddress = LTRIM(RTRIM(OwnerSplitAddress));

-- Delete Unused Columns

Select *
From AdventureWorksDW2022.dbo.NashvilleHousing

ALTER TABLE AdventureWorksDW2022.dbo.NashvilleHousing
DROP COLUMN OwnerSplitAddress, OwnerSplitCity, TaxDistrict, PropertyAddress

ALTER TABLE AdventureWorksDW2022.dbo.NashvilleHousing
DROP COLUMN SaleDateConverted


-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


USE AdventureWorksDW2022

GO 

EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

GO 

EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

GO 


---- Using BULK INSERT

USE AdventureWorksDW2022;
GO
--BULK INSERT nashvilleHousing FROM 'C:\OneDrive\Downloads\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO

















