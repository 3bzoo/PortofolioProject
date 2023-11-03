select *
from covidDeaths
where continent is not null
order by 3,4

-- Select Data that we are going to be using

select Location, date, total_cases, New_cases, total_deaths, population
from covidDeaths
order by 1,2



-- looking at Total Cases vs Total Deaths

ALTER TABLE [covidDeaths] ALTER COLUMN [total_deaths] [float]
ALTER TABLE [covidDeaths] ALTER COLUMN [total_cases] [float]

-- Shows likelihood of dying if you contract covid in your country

select location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covidDeaths
where location like '%states%'
where continent is not null
order by 1,2

--SELECT 
--TABLE_NAME, 
--COLUMN_NAME, 
--DATA_TYPE 
--FROM INFORMATION_SCHEMA.COLUMNS 
--where TABLE_NAME = 'covidDeaths' and COLUMN_NAME = 'total_cases'

-- Looking at Total Cases vs Populations
-- Shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentpopulationInfected
from covidDeaths
--where location like '%states%'
where continent is not null
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population



select location, population, max(total_cases) as HighestInfectionCountry, max((total_cases/population))*100 as PercentpopulationInfected
from covidDeaths
--where location like '%states%'
where continent is not null
Group by location, population
order by PercentpopulationInfected desc


-- Showing Countries with Highest Death Count per Population


select location, MAX(total_deaths) as TotalDeathCount
from covidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- let's break things down by continent

select continent, MAX(total_deaths) as TotalDeathCount
from covidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc



-- showing the contenint with the highest death count per population

select continent, MAX(total_deaths) as TotalDeathCount
from covidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc



-- global numbers


select  sum(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/nullif(SUM(new_cases),0)*100 as DeathPercentage
from covidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


-- looking at Total Popluation vs Vaccinations


-- use CTE

with Pop_Vs_Vac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from covidDeaths dea
join covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from Pop_Vs_Vac








-- TEMP TABLE

--drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from covidDeaths dea
join covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #percentpopulationvaccinated


-- Creating View to store data for later visualizations

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from covidDeaths dea
join covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from percentpopulationvaccinated