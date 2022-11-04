
SELECT * FROM PortfolioProject..CovidDeaths
order by 3,4


SELECT * FROM PortfolioProject..CovidVaccinations
order by 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2



SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,1) as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%states%' AND continent IS NOT NULL
order by 1,2

SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,1) as CasePercentage
FROM PortfolioProject..CovidDeaths
where location like '%states%' AND continent IS NOT NULL
order by 1,2



SELECT location, population, MAX(total_cases) as HighestInfectionCount, round(MAX((total_cases/population)*100),2) as HighestInfectionRate
FROM PortfolioProject..CovidDeaths
where continent IS NOT NULL
group by location, population
order by 4 desc


SELECT continent, location, date, max(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
where continent is not null
GROUP BY continent, location, date
ORDER BY TotalDeathCount desc;

WITH PopsvsVac (continent, location, date, population, new_vaccinations, RollingVac)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingVac
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)


SELECT *, (Rollingvac/population)*100 FROM PopsvsVac


CREATE TABLE #PercentVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
DATE datetime,
Population numeric,
New_vaccinations numeric,
Rollingvac numeric
)


INSERT INTO #PercentVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingVac
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *, (Rollingvac/population)*100
FROM #PercentVaccinated

CREATE VIEW PercentVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingVac
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM PercentVaccinated

DROP TABLE IF EXISTS CovidDeathCounting
CREATE TABLE CovidDeathCounting
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
total_cases numeric,
total_deaths numeric)

INSERT INTO CovidDeathCounting
SELECT continent, location, date, population, total_cases,total_deaths
FROM CovidDeaths
where continent is not null
-- GROUP BY continent, location, date

SELECT *, total_cases/population as percent_cases, total_deaths/total_cases,5 as percent_deaths
FROM CovidDeathCounting


CREATE VIEW CasesDeathsPercent AS
SELECT continent, location, date, population, total_cases,total_deaths, total_cases/population as percent_cases, total_deaths/total_cases as percent_deaths
FROM  CovidDeaths
where continent is not null

SELECT * FROM CasesDeathsPercent