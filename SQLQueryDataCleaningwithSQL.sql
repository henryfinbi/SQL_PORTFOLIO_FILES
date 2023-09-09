SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject_DataCleaning].[dbo].[NashvilleHousing]

  --CLEANING DATA SERIES
   
   select *
  from PortfolioProject_DataCleaning..NashvilleHousing
  
  
  
  
  
  
  
  --Standardize Date Format
  
  select SaleDateConverted, (cast(SaleDate as DATE))
  from PortfolioProject_DataCleaning..NashvilleHousing

  alter table NashvilleHousing
  add SaleDateConverted date;

 UPDATE NashvilleHousing
  SET SaleDateConverted = cast(SaleDate as DATE)

 
 
 
 
 
 
 --Populate PropertyAddress

  select *
  from PortfolioProject_DataCleaning..NashvilleHousing
  where PropertyAddress is null
  order by ParcelID

  select a.ParcelID, A.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  from PortfolioProject_DataCleaning..NashvilleHousing a
  join PortfolioProject_DataCleaning..NashvilleHousing b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null
  /*OR*/
  select  a.ParcelID, A.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  from PortfolioProject_DataCleaning..NashvilleHousing a, PortfolioProject_DataCleaning..NashvilleHousing b
  where a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID AND a.PropertyAddress is null


  update a
  set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
  from PortfolioProject_DataCleaning..NashvilleHousing a
  join PortfolioProject_DataCleaning..NashvilleHousing b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ]<> b.[UniqueID ]
  where a.PropertyAddress is null


 
 
 
 
 
 
 --Breaking out Address Into Individual Columns (Address, City, State)

  select PropertyAddress
  from PortfolioProject_DataCleaning..NashvilleHousing

 select substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
  substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address2 
   from PortfolioProject_DataCleaning..NashvilleHousing


 alter table NashvilleHousing
  add PropertySplitAddress nvarchar(255);

  alter table NashvilleHousing
  add PropertySplitCity nvarchar(255);

  
 UPDATE NashvilleHousing
  SET PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

  UPDATE NashvilleHousing
  SET PropertySplitCity =substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


    
	/*Another Method of separating the addresses but in this case it's the OwnerAddress*/
	

 select OwnerAddress
  from PortfolioProject_DataCleaning..NashvilleHousing

 select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
 from PortfolioProject_DataCleaning..NashvilleHousing

  
  alter table NashvilleHousing
  add OwnerSplitAddress nvarchar(255);

    alter table NashvilleHousing
  add OwnerSplitCity nvarchar(255);

     alter table NashvilleHousing
  add OwnerSplitState nvarchar(255);


 UPDATE NashvilleHousing
  SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


  UPDATE NashvilleHousing
  SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


  UPDATE NashvilleHousing
  SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



  --Change Y and N to Yes and No in "Sold as Vacant" field

  /*using case statement*/

    
  select distinct(SoldAsVacant)
  from PortfolioProject_DataCleaning..NashvilleHousing

  select SoldAsVacant,
  case 
  when SoldAsVacant = 'Y' then 'Yes'
  when SoldAsVacant = 'N' then 'No'
  else SoldAsVacant
  end
    from PortfolioProject_DataCleaning..NashvilleHousing

	/*Using Replace*/


  select replace(SoldAsVacant, 'N','No')
  from PortfolioProject_DataCleaning..NashvilleHousing
  where SoldAsVacant = 'N'

  update NashvilleHousing
  set SoldAsVacant = replace(SoldAsVacant, 'N','No')
   where SoldAsVacant = 'N'
   
  select replace(SoldAsVacant, 'Y','Yes')
  from PortfolioProject_DataCleaning..NashvilleHousing
  where SoldAsVacant = 'Y'

    update NashvilleHousing
  set SoldAsVacant = replace(SoldAsVacant, 'Y','Yes')
   where SoldAsVacant = 'Y'



   --Remove Duplicates

    select *
  from PortfolioProject_DataCleaning..NashvilleHousing



  
  WITH RowNumCTE AS(
  select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
                 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				  UniqueID
				  ) row_num
  from PortfolioProject_DataCleaning..NashvilleHousing
  --ORDER BY ParcelID
  )
  delete
  FROM RowNumCTE
  WHERE row_num > 1


  --Delete Unused Columns

   select *
  from PortfolioProject_DataCleaning..NashvilleHousing


  alter table PortfolioProject_DataCleaning..NashvilleHousing
  drop column OwnerAddress, TaxDistrict, PropertyAddress

    alter table PortfolioProject_DataCleaning..NashvilleHousing
  drop column SaleDate




  
