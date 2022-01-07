select *
from PortfolioProject1..Covid_Deaths 
where continent is null
order by 3,4

--select *
--from PortfolioProject1..Covid_Vaccinations
--order by 3,4


select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject1..Covid_Deaths
where continent is not null
order by 1,2


-- Looking at the total case vs total deaths & calculating death percentage
-- Shows the likelihood og dying if you attract COVID in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject1..Covid_Deaths
--where location like '%india%'
where continent is not null
order by 1,2

-- Looking at the total cases vs Population
-- what percentage of population has got COVID

select location, date, population, total_cases, (total_cases/population)*100 as percentagePopulationAffected
from PortfolioProject1..Covid_Deaths
--where location like '%India%'
where continent is not null
order by 1,2

--Looking at Countries with highest infection rate compared to populations


select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as percentagePopulationAffected
from PortfolioProject1..Covid_Deaths
--where location like '%India%'
group by location, population
order by percentagePopulationAffected desc

-- Showing Countries with highest death count per population

select location, max(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject1..Covid_Deaths
--where location like '%India%'
where continent is not null
group by location
order by HighestDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the Continents with the highest death count

select continent, max(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject1..Covid_Deaths
--where location like '%India%'
where continent is not null
group by continent
order by HighestDeathCount desc



-- GLOBAL NUMBERS

select date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject1..Covid_Deaths
--where location like '%india%'
where continent is not null
group by date
order by 1,2

-- Looking at total population vs vaccinations
--merging two tables using join

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population
from PortfolioProject1..Covid_Deaths dea
join PortfolioProject1..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac. date
where dea.continent is not null
and dea.location like '%canada%'
order by 2,3

-- USE CTE
with popvsvac (Continent, location, date, population, new_vacciations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population
from PortfolioProject1..Covid_Deaths dea
join PortfolioProject1..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac. date
where dea.continent is not null
--and dea.location like '%canada%'
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from popvsvac


-- TEMP TABLE
drop table if exists #percentPopulationvaccianted
create table #percentPopulationvaccianted
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacciantions numeric,
rollingpeoplevaccinated numeric
)
insert into #percentPopulationvaccianted
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject1..Covid_Deaths dea
join PortfolioProject1..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac. date
where dea.continent is not null
--and dea.location like '%canada%'
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #percentPopulationvaccianted


-- creating view to store data for later visualizations

Create View #percentPopulationvaccianted as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject1..Covid_Deaths dea
join PortfolioProject1..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac. date
where dea.continent is not null
--and dea.location like '%canada%'
--order by 2,3