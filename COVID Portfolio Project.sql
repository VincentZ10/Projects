SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

-- Select data that is going to be used
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- % chance of dying if you contract COVID in your country
SELECT Location, date, total_cases, total_deaths
, ((CAST(total_deaths as decimal))/(CAST(total_cases as int))*100) as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--total cases vs population
SELECT Location, date, total_cases, Population
, ((CAST(total_cases as decimal))/(CAST(population as int))*100) as COVIDContractedPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- % of Country's population that has contracted COVID
SELECT Location, Population, MAX(total_cases) as InfectionCount
, MAX((CAST(total_cases as bigint))/(CAST(population as decimal)))*100 as PercentPopInfected
FROM PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopInfected desc

-- Highest COVID death count per country
SELECT Location, MAX(CAST(Total_deaths as int)) as DeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by DeathCount desc

-- COVID death by continent
SELECT continent, MAX(CAST(Total_deaths as int)) as DeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by DeathCount desc

-- Global numbers
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths
, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null AND new_cases != 0
Group by date
order by 1,2


-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
( 
-- Total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(225),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccination numeric,
	RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for visualiztions
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated
