
/*
Covid-19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM PortfolioProjectSQL..CovidDeaths
ORDER BY 3,4
 
SELECT *
FROM PortfolioProjectSQL..CovidVaccinations
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjectSQL..CovidDeaths
ORDER BY 1,2

--% chance of dying of Covid if you get it in USA

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProjectSQL..CovidDeaths
WHERE location = 'united states'
ORDER BY 1,2

--% infected in your USA

SELECT location, population, total_cases, (total_cases/population)*100 AS infection_percentage
FROM PortfolioProjectSQL..CovidDeaths
WHERE location = 'united states'
ORDER BY 1,2

--World highest infection rate

SELECT location, population, MAX(total_Cases) AS highest_infection_count, MAX((total_cases/population))*100 AS world_infection_percentage
FROM PortfolioProjectSQL..CovidDeaths
GROUP BY location, population
ORDER BY world_infection_percentage desc

--World highest death count per population

SELECT location, MAX(CAST(total_deaths AS int)) AS highest_death_count, MAX((total_deaths/population))*100 AS world_death_percentage
FROM PortfolioProjectSQL..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY highest_death_count desc

-- Broken down by continent

SELECT location, MAX(CAST(total_deaths AS int)) AS highest_death_count
FROM PortfolioProjectSQL..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY highest_death_count desc

-- highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS highest_death_count
FROM PortfolioProjectSQL..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY highest_death_count desc

-- global numbers

SELECT DATE, SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths AS int)) AS total_new_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS total_death_percentage
FROM PortfolioProjectSQL..CovidDeaths
WHERE continent is not null
GROUP BY date

SELECT SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths AS int)) AS total_new_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS total_death_percentage
FROM PortfolioProjectSQL..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Join
--total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, SUM(CAST(dea.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS sum_of_people_vaccinated
FROM PortfolioProjectSQL..CovidDeaths dea
JOIN PortfolioProjectSQL..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Temp table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
sum_of_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, SUM(CAST(dea.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS sum_of_people_vaccinated
FROM PortfolioProjectSQL..CovidDeaths dea
JOIN PortfolioProjectSQL..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (sum_of_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated

--Create View

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, SUM(CAST(dea.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS sum_of_people_vaccinated
FROM PortfolioProjectSQL..CovidDeaths dea
JOIN PortfolioProjectSQL..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null