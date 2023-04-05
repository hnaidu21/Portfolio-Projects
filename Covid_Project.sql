Select * 
From PortfolioProject..CovidDeaths
Where Continent IS NOT NULL
Order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where Continent IS NOT NULL
Order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if one contracts Covid in one's country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS  DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like 'india'  
Where Continent IS NOT NULL
Order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population) * 100 AS  PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like 'india'
Where Continent IS NOT NULL
Order by 1, 2

-- Looking at Countries with Highest Infection Rates vs Population

Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like 'india'
Where Continent IS NOT NULL
Group By Location, population
Order by PercentPopulationInfected Desc

-- Showing Continents with the Highest Death Count per Population

CREATE VIEW vw_ContinentMaxDeathCount
AS
Select continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'india'
Where Continent IS NOT NULL
Group By continent
--Order by TotalDeathCount Desc

-- Showing Countries with Highest Death Count per Population

CREATE VIEW vw_CountrytMaxDeathCount
AS
Select Location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'india'
Where Continent IS NOT NULL
Group By location
--Order by TotalDeathCount Desc

-- Global Numbers

CREATE VIEW vw_globalnos
AS
Select	SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS int)) AS TotalNewDeaths, 
		SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like 'india'  
Where Continent IS NOT NULL
--Group By Date
--Order by 1, 2


-- Looking at Total Population vs Vaccinations

SELECT		dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
			SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
--			(RollingPeopleVaccinated/population) /*can't use the above column, so need to create a CTE or a Temp Table*/
FROM		PortfolioProject..CovidDeaths Dea
INNER JOIN	PortfolioProject..CovidVaccinations Vac
ON			dea.location = vac.location
AND			dea.date = vac.date
WHERE		dea.continent IS NOT NULL
ORDER BY	2,3

-- Use CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) /*Need to have all the 6 cols as in Main query*/
AS
(
SELECT		dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
			SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--			(RollingPeopleVaccinated/population) /*can't use the above column, so need to create a CTE or a Temp Table*/
FROM		PortfolioProject..CovidDeaths Dea
INNER JOIN	PortfolioProject..CovidVaccinations Vac
ON			dea.location = vac.location
AND			dea.date = vac.date
WHERE		dea.continent IS NOT NULL
--ORDER BY	2,3
)
SELECT		*, (RollingPeopleVaccinated/Population)*100
FROM		PopvsVac


-- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated /*Must have this for future alterations to the code/table*/
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME, 
Population NUMERIC, 
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)
INSERT INTO #PercentPopulationVaccinated
SELECT		dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
			SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--			(RollingPeopleVaccinated/population) /*can't use the above column, so need to create a CTE or a Temp Table*/
FROM		PortfolioProject..CovidDeaths Dea
INNER JOIN	PortfolioProject..CovidVaccinations Vac
ON			dea.location = vac.location
AND			dea.date = vac.date
--WHERE		dea.continent IS NOT NULL
--ORDER BY	2,3

SELECT		*, (RollingPeopleVaccinated/Population)*100
FROM		#PercentPopulationVaccinated


-- Create a View to store data for later visualizatons

CREATE VIEW vw_PercentPopulationVaccinated
AS
SELECT		dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
			SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM		PortfolioProject..CovidDeaths Dea
INNER JOIN	PortfolioProject..CovidVaccinations Vac
ON			dea.location = vac.location
AND			dea.date = vac.date
WHERE		dea.continent IS NOT NULL
--ORDER BY	2,3

select * from [dbo].[vw_PercentPopulationVaccinated]
