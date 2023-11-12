/*
	Data Cleaning In SQL Quires
*/


select SaleDateConverted, CONVERT(date,saledate)
 from [Nashville Housing]

 update [Nashville Housing]
 set SaleDate = CONVERT(date,SaleDate)

alter table [Nashville Housing]
add SaleDateConverted date;

 update [Nashville Housing]
 set SaleDateConverted = CONVERT(date,SaleDate)

----------------------------------------------------------------------------------------------------

-- Populate Property Address Data



select *
 from [Nashville Housing]
-- where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
 from [Nashville Housing] a
 join [Nashville Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
 from [Nashville Housing] a
 join [Nashville Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from [Nashville Housing]


alter table [Nashville Housing]
add PropertySplitAddress nvarchar(255);

 update [Nashville Housing]
 set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


 
alter table [Nashville Housing]
add PropertySplitCity nvarchar(255);

 update [Nashville Housing]
 set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



select *
from [Nashville Housing]


select OwnerAddress
from [Nashville Housing]

select
PARSENAME(replace(OwnerAddress,',','.') ,3),
PARSENAME(replace(OwnerAddress,',','.') ,2),
PARSENAME(replace(OwnerAddress,',','.') ,1)
from [Nashville Housing]



alter table [Nashville Housing]
add OwnerSplitAddress nvarchar(255);

 update [Nashville Housing]
 set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.') ,3)

 
alter table [Nashville Housing]
add OwnerSplitCity nvarchar(255);

 update [Nashville Housing]
 set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.') ,2)

 alter table [Nashville Housing]
add OwnerSplitState nvarchar(255);

 update [Nashville Housing]
 set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.') ,1)

 
select *
from [Nashville Housing]

----------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from [Nashville Housing]
group by SoldAsVacant


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from [Nashville Housing]


update [Nashville Housing]
set SoldAsVacant = 
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

----------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID
				 ) row_num
from [Nashville Housing]
--order by ParcelID
)


select *
from RowNumCTE
where row_num > 1
order by PropertyAddress



----------------------------------------------------------------------------------------------------


-- Delete Unused Columns

select *
from [Nashville Housing]

alter table [Nashville Housing]
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table [Nashville Housing]
drop column SaleDate