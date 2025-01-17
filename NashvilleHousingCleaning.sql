--Cleaning Data in SQL

Select *
FROM PortfolioProject.dbo.NashvilleHousing



-- --------------------------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

Select SaleDateConverted, CONVERT(date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date; 

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)



------------------------------------------------------------------------------------------------------
-- Populate Property Address Data
Select *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

------------------------------------------------------------------------------------------------------
-- Breaking out address into individual columns (address, city, state)




Select PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) AS City

FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255); 

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)



ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255); 

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))




SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)
, PARSENAME(REPLACE(OwnerAddress,',', '.') ,2)
, PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)
FROM PortfolioProject.dbo.NashvilleHousing




ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255); 

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)



ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255); 

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.') ,2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255); 

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)



SELECT *
FROM PortfolioProject.dbo.NashvilleHousing




------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
Order by 2



select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN  SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END AS NewSoldAsVacant
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN  SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing




------------------------------------------------------------------------------------------------------
-- Remove Duplicates 


WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress, 
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num


FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)


SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


------------------------------------------------------------------------------------------------------
--Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate