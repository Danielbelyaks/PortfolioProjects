SELECT * 
FROM coviddeaths
ORDER BY 3,4;

-- SELECT * 
-- FROM covidvac
-- ORDER BY 3,4

-- Data That Is Going To Be Used

SELECT location, date, new_cases, total_cases, total_deaths,  population
FROM coviddeaths
ORDER BY 1,2;

-- Looking at total_cases over total_deaths
-- Looking to be much lower percentage now compared to start of deaths 02-2020

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

-- Looking at total_cases over population
-- Percentage of population contracted covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS percent_pop_infected
FROM coviddeaths
-- WHERE location LIKE '%states%'
ORDER BY 1,2;

-- Now lets look at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS max_infect_count, MAX((total_cases/population))*100 AS percent_pop_infect
FROM coviddeaths
-- WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY percent_pop_infect DESC;

-- Showing countries with highest death_count per population

SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS total_death_count
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- I will now be breaking it down by continent
-- Showing continents with highest death count

SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS total_death_count
FROM coviddeaths
WHERE continent IS NOT NULL 
GROUP BY continent 
ORDER BY total_death_count DESC;

-- Focusing on a global scale

	SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
	FROM coviddeaths
	-- WHERE location LIKE '%states%' 
	WHERE continent IS NOT NULL
	ORDER BY 1,2;

SELECT date, SUM(new_cases)
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

SELECT date, SUM(new_cases), SUM(CAST(new_deaths AS UNSIGNED))
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS UNSIGNED)) AS total_deaths, SUM(CAST(new_deaths AS UNSIGNED))/SUM(new_cases)*100 AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Looking at total population vs vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(UNSIGNED,vac.new_vaccinations))OVER(PARTITION BY dea.location ORDER BY dea.location,
dea.date)	
FROM coviddeaths dea
JOIN covidvac vac
ON dea.location=vac.location
AND dea.date=vac.date;
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Using CTE to perform partition calculation in prev query

WITH popvsvac(continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
AS
( SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(UNSIGNED, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY
dea.location, dea.date)
FROM coviddeaths dea
JOIN covidvac vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rollingpeoplevaccinated/population)*100
FROM popvsvac;


-- Temp table for calculation on partition by query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(UNSIGNED,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvac vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(UNSIGNED,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidSeaths dea
Join cvidvac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null ;















