SELECT *
FROM [protfoilo project].dbo.CovidDeaths
where continent is not null
order by 3,4

--select *
--from [protfoilo project].dbo.CovidVaccinations
--order by 3,4

--SELECT DISTINCT *
--FROM [protfoilo project].dbo.CovidDeaths

--total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from [protfoilo project].dbo.CovidDeaths
where continent is not null
where location like '%states%'
order by 1,2

--total cases vs population
--what percentage of population got covid

select location, date, total_cases, population, (total_deaths/population)*100 as percentpopulationinfected
from [protfoilo project].dbo.CovidDeaths
where continent is not null
where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to popluation

select location, Max(total_cases) as highestinfectioncount, population, max((total_cases/population))*100 as percentpopulationinfected
from [protfoilo project].dbo.CovidDeaths
where continent is not null
--where location like '%states%'
group by location, population
order by  percentpopulationinfected desc

--showing countries with highest death count per population

select location,Max(cast(Total_deaths as int)) as TotalDeathcount
from [protfoilo project].dbo.CovidDeaths
where continent is not null
--where location like '%states%'
group by location 
order by  TotalDeathcount desc

--let's break things down by continent

select continent, Max(cast(Total_deaths as int)) as TotalDeathcount
from [protfoilo project].dbo.CovidDeaths
where continent is not null
--where location like '%states%'
group by continent 
order by  TotalDeathcount desc

---showing continents with the highest death count per population

select continent, Max(cast(Total_deaths as int)) as TotalDeathcount
from [protfoilo project].dbo.CovidDeaths
where continent is not null
group by continent 
order by  TotalDeathcount desc

--global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from [protfoilo project].dbo.CovidDeaths
where continent is not null
---where location like '%states%'
--group by date
order by 1,2

--looking at total popluation vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [protfoilo project].dbo.CovidDeaths dea
Join [protfoilo project].dbo.CovidVaccinations vac
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
From [protfoilo project].dbo.CovidDeaths dea
Join [protfoilo project].dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

---- temp table
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
From [protfoilo project].dbo.CovidDeaths dea
Join [protfoilo project].dbo.CovidVaccinations vac
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
From [protfoilo project].dbo.CovidDeaths dea
Join [protfoilo project].dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null