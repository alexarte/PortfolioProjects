/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProject.dbo.NashvilleHousing

------- Standardize Date Format


Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

Select *
From PortfolioProject.dbo.NashvilleHousing
-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 ------- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

Select *
From PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

-- Remove the empty unique IDs
DELETE FROM NashvilleHousing WHERE PropertyAddress is null

-- Check again
Select *
From PortfolioProject.dbo.NashvilleHousing


------- Breaking out Address into Individual Columns (Address, City, State)
 

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING (PropertyAddress, 1, (CHARINDEX(',', PropertyAddress)) -1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing


------- Updating data
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, (CHARINDEX(',', PropertyAddress)) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing

------- CHECK
SELECT PropertyAddress, SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address,
CHARINDEX(',', PropertyAddress) as Num
From PortfolioProject.dbo.NashvilleHousing
Order by Num

DELETE FROM NashvilleHousing WHERE PropertyAddress = '78000'
------- CHECK



Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME (REPLACE(OwnerAddress,',','.'),3),
PARSENAME (REPLACE(OwnerAddress,',','.'),2),
PARSENAME (REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress,',','.'),1)

Select *
From NashvilleHousing



------- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant

--Create new column
ALTER TABLE NashvilleHousing
Add SoldAsVacantt Nvarchar(255);

UPDATE NashvilleHousing SET SoldAsVacantt = 'No' where SoldAsVacant=0
UPDATE NashvilleHousing SET SoldAsVacantt = 'Yes' where SoldAsVacant=1

Select *
from NashvilleHousing
------- Remove Duplicates

WITH RowNumCTE as (
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

From NashvilleHousing
)
SELECT *
from RowNumCTE
Where row_num > 1


Select *
From NashvilleHousing




------- Delete Unused Columns


Select *
from NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SoldAsVacant

ALTER TABLE NashvilleHousing
DROP COLUMN SoldAsVacant