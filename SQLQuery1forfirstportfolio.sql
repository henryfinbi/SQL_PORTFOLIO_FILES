select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

select *
from PortfolioProject..CovidVaccinations$
where continent is not null
order by 3,4

--Selecting data I'm going to use	

select location, date, total_cases,new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--shows the likelihood of dying if you contact covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%Nigeria%'
order by 1,2


-- i used these to change the columns i needed to int;
ALTER TABLE PortfolioProject..CovidDeaths$
ALTER COLUMN total_cases float;

ALTER TABLE PortfolioProject..CovidDeaths$
ALTER COLUMN total_deaths float;


--Looking at the Total Cases vs Population
-- shows what percentage of te population got covid
select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
from PortfolioProject..CovidDeaths$
where location like '%Nigeria%'
order by 1,2


--Looking at Countries with the Highest Infection Rate Compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as CasePercentage
from PortfolioProject..CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
group by location, population
order by CasePercentage desc


--Looking at Countries with the Highest Death Rate Compared to Population

select location, population, max(total_deaths) as HighestDeathCount, max((total_deaths/population))*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
group by location, population
order by DeathPercentage desc


--Looking at Countries with the Highest Death Counts

select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc


--BREAKING THINGS DOWN BY CONTINENT!!!

--Looking at Continents with the Highest Death Counts

select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is null
group by location
order by TotalDeathCount desc



--GLOBAL NUMBERS!!!

--Death Percentage of the World per Day

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) TotalDeaths, 
case when sum(new_cases) <> 0 then
sum(cast(new_deaths as int))/ sum(new_cases)*100 
else 00
END AS DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is  not null
group by date
order by 1


--Numbers for the Whole World 'no date'

select  sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) TotalDeaths, 
case when sum(new_cases) <> 0 then
sum(cast(new_deaths as int))/ sum(new_cases)*100 
else 00
END AS DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is  not null
order by 1


--JOINUNG THE TWO TABLES TOGETHER
--Looking at Total Population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Using CTE so we can see the Percentage of People Vaccinated

WITH POPVSVAC
AS (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentagePeopleVaccinated
FROM POPVSVAC

--Using temptable to see the Percentage of People Vaccinated

drop table if exists #PercentpopulationVaccinated
create table #PercentpopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentpopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 PercentagePeopleVaccinated
FROM #PercentpopulationVaccinated




--creating view to store data for later visualizations

create view PercentpopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentpopulationVaccinated







