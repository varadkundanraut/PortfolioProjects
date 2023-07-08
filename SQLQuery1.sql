Select *
from PortfolioProject..CovidDeaths
order by 3,4


--Select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Slect Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1, 2


-- Looking at Total Cases vs Population
-- Shows what perentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1, 2


-- Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Showing Contries with Highest Death Count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- Let's break things down by continent

-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers

Select SUM(new_cases) as Total_cases , Sum(cast(new_deaths as int)) as Total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
--Group by date
order by 1, 2


-- Loking at Total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert (int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- Use CTE

With PopvsVac (Continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert (int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
select*, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert (int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert (int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select * 
from PercentPopulationVaccinated