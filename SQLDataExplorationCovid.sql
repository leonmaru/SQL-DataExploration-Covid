SELECT *
FROM [p.project.covid].[dbo].[CovidDeaths$]
ORDER BY 3,4

SELECT *
FROM [p.project.covid].[dbo].[CovidVaccinations$]
ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM [p.project.covid].[dbo].[CovidDeaths$]
ORDER BY 1,2

--Looking at total cases vs total deaths

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM [p.project.covid].[dbo].[CovidDeaths$]
ORDER BY 1,2

--Looking at Kenya's covid Death percentage

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM [p.project.covid].[dbo].[CovidDeaths$]
WHERE location like '%KENYA%'
ORDER BY 1,2

--Looking at total cases vs Population/Infection Rate

SELECT location,date,population,total_cases,(total_cases/population)*100 AS PercentPopulationInfected 
FROM [p.project.covid].[dbo].[CovidDeaths$]
WHERE location like '%KENYA%'
ORDER BY 1,2

--Countries with the highest infection rate compared to population

SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX ((total_cases/population))*100 AS PercentPopulationInfected 
FROM [p.project.covid].[dbo].[CovidDeaths$]
--WHERE location like '%KENYA%'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

--Showing countries with highest DeathCount per population

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM [p.project.covid].[dbo].[CovidDeaths$]
WHERE continent is not NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing Continents with Highest death count

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM [p.project.covid].[dbo].[CovidDeaths$]
WHERE continent is not NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC
 
--Looking at the global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [p.project.covid].[dbo].[CovidDeaths$]
where continent is not null 
order by 1,2

--Vaccinations

SELECT *
FROM [p.project.covid].[dbo].[CovidVaccinations$]
ORDER BY 3,4

--Join deaths and vaccinations

SELECT *
FROM [p.project.covid].[dbo].[CovidVaccinations$] dea
JOIN [p.project.covid].[dbo].[CovidDeaths$] vac
     ON dea.location = vac.location
	 and dea.date = vac.date

--Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [p.project.covid].[dbo].[CovidDeaths$] dea
Join [p.project.covid].[dbo].[CovidVaccinations$] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [p.project.covid].[dbo].[CovidDeaths$] dea
Join[p.project.covid].[dbo].[CovidVaccinations$] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [p.project.covid].[dbo].[CovidDeaths$] dea
Join [p.project.covid].[dbo].[CovidVaccinations$] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [p.project.covid].[dbo].[CovidDeaths$] dea
Join [p.project.covid].[dbo].[CovidVaccinations$] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 






