SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT * 
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total cases vs total deaths in Netherlands
-- Shows chances of dying after covid infection in a particular country
SELECT Location, date, total_cases, new_cases, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Netherlands%'
ORDER BY 1,2

-- Total cases vs population
-- Percentage of population infected with Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Netherlands%'
ORDER BY 1,2

-- Countries with Highest Infection Rate as compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%Netherlands%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

-- Countries with highest death count compared to population

SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Breakdown by Continents
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC
 
-- Breakdown by continents
-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Netherlands%'
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1 DESC

-- Total Population vs Vaccinations

WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location Order by dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Temporary table
Drop Table If exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location Order by dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating data for Visulaization

Drop View If Exists PercentPopulationVaccinated
--
Create View PercentPopulationVaccinated
As
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location Order by dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--Order By 2,3

Select * 
From PercentPopulationVaccinated
