
/*
Nashville Housing: Data Cleaning

Skills used: Joins, Alter Table, Update, Substrings, Parsename, Case Statements, Drop Column

*/

SELECT *
FROM PortfolioProjectSQL.dbo.NashvilleHousing


-- Standardize Date Format


ALTER TABLE PortfolioProjectSQL.dbo.NashvilleHousing
ADD ConvertedSaleDate Date;

UPDATE PortfolioProjectSQL.dbo.NashvilleHousing
SET ConvertedSaleDate = CONVERT(Date, SaleDate)

SELECT ConvertedSaleDate
FROM PortfolioProjectSQL.dbo.NashvilleHousing


-- Property Address Data (Fill Null Property Address)


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjectSQL.dbo.NashvilleHousing a
JOIN PortfolioProjectSQL.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjectSQL.dbo.NashvilleHousing a
JOIN PortfolioProjectSQL.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- Separate Address into Columns


SELECT PropertyAddress
FROM PortfolioProjectSQL.dbo.NashvilleHousing

SELECT *
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
FROM PortfolioProjectSQL.dbo.NashvilleHousing

UPDATE PortfolioProjectSQL.dbo.NashvilleHousing
SET PropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


-- Owner Address Separation (alternate EASY method)


SELECT *
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProjectSQL.dbo.NashvilleHousing

ALTER TABLE PortfolioProjectSQL.dbo.NashvilleHousing
ADD OwnerStreetAddress NVARCHAR(255);

UPDATE PortfolioProjectSQL.dbo.NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProjectSQL.dbo.NashvilleHousing
ADD OwnerCity NVARCHAR(255);

UPDATE PortfolioProjectSQL.dbo.NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProjectSQL.dbo.NashvilleHousing
ADD OwnerState NVARCHAR(255);

UPDATE PortfolioProjectSQL.dbo.NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Standardize 'Sold as Vacant' Field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProjectSQL.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProjectSQL.dbo.NashvilleHousing

UPDATE PortfolioProjectSQL.dbo.NashvilleHousing
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


-- Remove Duplicates (USUALLY DONE IN TEMP TABLES AS TO NOT DELETE INFORMATION)


-- Delete Unused Columns


SELECT *
FROM PortfolioProjectSQL.dbo.NashvilleHousing

ALTER TABLE PortfolioProjectSQL.dbo.NashvilleHousing
DROP COLUMN PropertyCity, TaxDistrict, OwnerAddress, SaleDate

ALTER TABLE PortfolioProjectSQL.dbo.NashvilleHousing
DROP COLUMN SaleDate