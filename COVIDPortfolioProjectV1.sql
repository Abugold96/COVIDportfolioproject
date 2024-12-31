Select * 
from PortfolioProject..CovidDeaths1
WHERE continent is not null
order by 3,4

--Select * 
--from PortfolioProject..CovidVaccinations1
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths1
WHERE continent is not null
order by 1, 2

-- Total Cases vs Total Deaths
-- shows likelihood of Dying from Covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths1
WHERE continent is not null
-- where location like '%states%'
order by 1, 2

-- Looking at total cases VS Population
-- Shows what percentage of population
Select location, date, Population, total_cases, (total_cases/Population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths1
WHERE continent is not null
-- Where location like '%nigeria%'
order by 1, 2

-- Looking at Countries with highest Infection Rate compared to Population
Select location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/Population))*100 
as PercentagePopulationInfected
from PortfolioProject..CovidDeaths1
-- Where location like '%nigeria%'
Group by continent, Population
order by PercentagePopulationInfected desc



-- Showing countries with highest Death Count Per popukation

Select location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/Population))*100 
as PercentagePopulationInfected
from PortfolioProject..CovidDeaths1
WHERE continent is not null
-- Where location like '%nigeria%'
Group by continent, Population
order by PercentagePopulationInfected desc

-- Showing Countries with highest Death Count Per Population
Select location, MAX (cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths1
WHERE continent is not null
-- Where location like '%nigeria%'
Group by continent
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENTS

Select continent, MAX (cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths1
WHERE continent is not null
-- Where location like '%nigeria%'
Group by continent
order by TotalDeathCount desc

-- Showing continents with the highest death count per population

Select continent, MAX (cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths1
WHERE continent is not null
-- Where location like '%nigeria%'
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select SUM(new_cases) as 'TotalCases' , SUM(cast(new_deaths as int)) as 'TotalDeaths' , SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as 'DeathPercentage'
--, Population, total_cases, (total_cases/Population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths1
WHERE continent is not null
-- Where location like '%nigeria%'
-- Group by date
order by 1, 2

-- Looking at Total Populatiob VS Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT( int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as 
RollingPeopleVaccinated
from PortfolioProject..CovidDeaths1 dea
join PortfolioProject..CovidVaccinations1 vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Using CTE 
With PopvsVac (Continent,Location, Date, Population,New_Vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT( int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as 
RollingPeopleVaccinated
from PortfolioProject..CovidDeaths1 dea
join PortfolioProject..CovidVaccinations1 vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) * 100
from PopvsVac

-- TEMP TABLE

DROP Table If exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,

)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT( int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as 
RollingPeopleVaccinated
from PortfolioProject..CovidDeaths1 dea
join PortfolioProject..CovidVaccinations1 vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3
Select *, (RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated

-- CREATING VIEW TO STORE DATA FOR BETTER VISUALIZATION
Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT( int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as 
RollingPeopleVaccinated
from PortfolioProject..CovidDeaths1 dea
join PortfolioProject..CovidVaccinations1 vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3

Select * 
from PercentPopulationVaccinated