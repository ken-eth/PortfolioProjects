SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is NOT NULL
Order by 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--Order by 3, 4

-- Select data to use

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent is NOT NULL
Order By 1, 2

--Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (Total_deaths / total_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is NOT NULL
and location like '%Nicaragua%'
Order By 1, 2

--Looking at total cases vs population
--Shows what percentage of population got COVID
Select location, date, population,  total_cases,(Total_cases / population) * 100 as populationPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%Nicaragua%'
Order By 1, 2


--Looking at countries with higher infection rate compared to population

Select location, population, MAX(total_cases) AS HighestInfectionCount,MAX((Total_cases / population)) * 100 as PopulationPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%Nicaragua%'
Group by Location, Population
Order By PopulationPercentage desc

--Showing countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%Nicaragua%'
WHERE continent is NOT NULL
Group by Location, Population
Order By TotalDeathCount desc

--Now breaking it down by continent




-- Showing continents with the highest death count per population


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%Nicaragua%'
WHERE continent is NOT NULL
Group by continent
Order By TotalDeathCount desc




-- Global numbers

Select SUM(new_cases) as TotalCases, sum(cast(new_deaths as int)) as Total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%Nicaragua%'
WHERE continent is not null
--GROUP BY date
Order By 1, 2

-- Looking at total population vs Vaccinations
--USE CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) over (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--Order by 2,3

)

Select *, (RollingPeopleVaccinated/Population) * 100
FROM PopvsVac



--TEMP TABLE
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) over (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--Order by 2,3


Select *, (RollingPeopleVaccinated/Population) * 100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) over (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--Order by 2,3

select *
FROM PercentPopulationVaccinated