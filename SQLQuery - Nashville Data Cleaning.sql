--- limpieza de datos SQL Server

select *
from NashvilleHouse

--- cambio de la columna 'SaleDate' de DATETIME a Date

select SaleDate, CONVERT(DATE, SaleDate)
from NashvilleHouse

UPDATE NashvilleHouse
set SaleDate = CONVERT(DATE, SaleDate)

alter TABLE NashvilleHouse
add SaleDateFixed DATE

Update NashvilleHouse
set SaleDateFixed = CONVERT(DATE, SaleDate)

--- Cambio de los NUll en PropertyAdress
--- Checkeo de que null existen

select tablaA.ParcelID, tablaA.PropertyAddress,tablaB.ParcelID, tablaB.PropertyAddress, ISNULL(tablaA.PropertyAddress, tablaB.PropertyAddress) as PropertyAdressFixed
from NashvilleHouse tablaA
join NashvilleHouse tablaB
	-- uno la tabla donde los id coincidan
	on tablaA.ParcelID = tablaB.ParcelID
	-- uso una columna donde los datos no coincidan 
	and tablaA.SaleDateFixed <> tablaB.SaleDateFixed
where tablaA.PropertyAddress is null

-- Arreglo de los Null
Update TablaA
set PropertyAddress = ISNULL(tablaA.PropertyAddress, tablaB.PropertyAddress)
from NashvilleHouse TablaA
join NashvilleHouse TablaB
	on TablaA.ParcelID = TablaB.ParcelID
	and TablaA.SaleDateFixed <> TablaB.SaleDateFixed
where TablaA.PropertyAddress is null

 
-- separar la ciudad de la calle en PropertyAddress y en OwnerAddress

--select top(50) PropertyAddress, OwnerAddress
--from NashvilleHouse

-- Prueba
select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Calle,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress)) as Ciudad
from NashvilleHouse


--Columnas Nuevas
alter TABLE NashvilleHouse
add Calle Nvarchar(255)

alter Table NashvilleHouse
add Ciudad Nvarchar(255)

-- poner los valos en las columnas
Update NashvilleHouse
set Calle = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

update NashvilleHouse
set Ciudad = SUBSTRING(PropertyAddress, Charindex(',',PropertyAddress) + 1, len(PropertyAddress))

-- OwnerAddress
select PARSENAME(replace(OwnerAddress, ',', '.'), 1) as estado,
PARSENAME(replace(OwnerAddress, ',', '.'), 2) as ciudad,
PARSENAME(replace(OwnerAddress, ',', '.'), 3) as calle
from NashvilleHouse

-- Columnas Dueño
alter table NashvilleHouse
add DueñoEstado Nvarchar(255),
DueñoCiudad Nvarchar(255),
DueñoCalle Nvarchar(255)
-- alter
Update NashvilleHouse
set DueñoEstado = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

Update NashvilleHouse
set DueñoCiudad = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

Update NashvilleHouse
set DueñoCalle = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

select DueñoEstado, DueñoCiudad, DueñoCalle
from NashvilleHouse

-- 
select distinct SoldAsVacant, count(SoldAsVacant)
from NashvilleHouse
group by SoldAsVacant

-- Arreglo
update NashvilleHouse
set SoldAsVacant = CASE when SoldasVacant = 'Y' then 'Yes'
						  when SoldasVacant = 'N' then 'No'
						  else SoldAsVacant END

-- Quitar lo Duplicados
with Duplicados as(
select *, ROW_NUMBER() OVER (
	Partition by ParcelID, SaleDateFixed, SalePrice, PropertyAddress, LegalReference
	order by ParcelID
) as Row_Num
from NashvilleHouse
)
--DELETE 
--from Duplicados
--where Row_Num > 1

-- Quitar las columnas sin limpiar
--ALTER table NashvilleHouse
--DROP column PropertyAddress, SaleDate, OwnerAddress
