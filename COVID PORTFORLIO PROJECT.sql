
select *
from [Portfolio Project]..CovidDeaths$
where continent is null
order by 3,4


--select *
--from [Portfolio Project]..CovidVaccinations$
--order by 3,4

--looking at total cases vs total deaths
--this shows the probability of dying of covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage
from [Portfolio Project]..CovidDeaths$
where location like '%states%'
where continent is not null
order by 1,2

--looking at the total cases vs the population
--shows what percentage of population got covid

select location,date,total_cases,Population,(total_cases/population) * 100 as percentagepopulationaffected
from [Portfolio Project]..CovidDeaths$
where continent is not null
--where location like '%states%'
order by 1,2

--looking a countries with the highest infection rates compared to population

SELECT location,
       Population,
       MAX(total_cases) AS HighestInfectionCount,
       (MAX(total_cases) / Population) * 100 AS PercentagePopulationAffected
FROM [Portfolio Project]..CovidDeaths$
where continent is not null
GROUP BY location, Population
ORDER BY PercentagePopulationAffected desc

--showing countries with the highest deathbypopulation

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths$
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--breaking things down by continent
--continent with the highest death rate per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths$
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBER

SELECT date, SUM(new_cases) as totalcases, SUM(CAST(new_deaths AS INT)) as totaldeaths, SUM(CAST(new_deaths AS INT))/ SUM(new_cases)* 100 as deathpercentage
FROM [Portfolio Project]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY date desc

--looking at total population vs vactination

Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
From [Portfolio Project].. CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea . location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
order by 2,3

--USE CTE

With PopvsVac ( Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
From [Portfolio Project].. CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea . location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



--TEMP TABLE

create table #percentagepopulationvacinated
(
continent nvarchar(255),
location nvarchar(255),
date Datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric,
)

Insert Into #percentagepopulationvacinated
 Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
From [Portfolio Project].. CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea . location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3
select *, (RollingPeopleVaccinated/Population)*100
from #percentagepopulationvacinated


--creating view to store data for later visualization
create view percentagepopulationvacinated as
 Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
From [Portfolio Project].. CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea . location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3

select *
from percentagepopulationvacinated

