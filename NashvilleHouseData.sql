/*

Cleaning Data in SQL Queries

*/


Select *
From PortProjects.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


SELECT SaleDate, CONVERT(Date, SaleDate) AS SaleDateConverted
FROM PortProjects.dbo.NashvilleHousing;


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

-- Add a new column to the table
ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

-- Update the new column with converted values
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate, 23); -- Adjust the style code as needed



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortProjects.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortProjects.dbo.NashvilleHousing a
JOIN PortProjects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortProjects.dbo.NashvilleHousing a
JOIN PortProjects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortProjects.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortProjects.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From PortProjects.dbo.NashvilleHousing

Select OwnerAddress
From PortProjects.dbo.NashvilleHousing



Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortProjects.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortProjects.dbo.NashvilleHousing


-- Change 1 and 0 to Yes and No in SoldAsVacant column

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortProjects.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
                    WHEN SoldAsVacant = 1 THEN 1
                    WHEN SoldAsVacant = 0 THEN 0
                    ELSE SoldAsVacant -- If there are other values, keep them unchanged
                END;

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

From PortProjects.dbo.NashvilleHousing
--order by ParcelID
)
Select * -- use DELETE to clear duplicates
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- Delete columns
ALTER TABLE PortProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Select *
From PortProjects.dbo.NashvilleHousing

ALTER TABLE PortProjects.dbo.NashvilleHousing
DROP COLUMN SaleDate



