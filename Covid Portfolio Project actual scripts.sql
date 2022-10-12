
SELECT *
FROM CovidDeaths
ORDER BY 3, 4

SELECT *
FROM CovidVaccination
ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE LOCATION like '%Nigeria%'
ORDER BY 1, 2


-- Looking at Total Cases vs Population
-- Shows what Percentage of Population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentagePoulationInfected
FROM CovidDeaths
WHERE LOCATION like '%Nigeria%'
ORDER BY 1, 2

-- Looking at Continents with Highest Infection Rate compared to Population

SELECT continent, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePoulationInfected
FROM CovidDeaths
--WHERE LOCATION like '%Nigeria%'
GROUP BY continent, population
ORDER BY PercentagePoulationInfected DESC

-- Showing Continents with Highest Death Count per Population
-- Breaking it down by Continent

SELECT continent, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM CovidDeaths
--WHERE LOCATION like '%Nigeria%'
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Death_Percentage
FROM CovidDeaths
--WHERE LOCATION like '%Nigeria%'
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM CovidDeaths dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM CovidDeaths dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM PopvsVac


-- Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO  #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM CovidDeaths dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating view to store data later for visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM CovidDeaths dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated