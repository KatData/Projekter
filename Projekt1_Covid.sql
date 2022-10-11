select *
from PortfolioProject..CovidDød
where continent is not null
order by 3,4


--select *
--from PortfolioProject..CovidVaccination
--order by 3,4

-- select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDød
and continent is not null
order by 1,2


-- Ser på Total_cases VS Total_deaths
-- Viser  den procentvise sandsynlighed for at dø, hvis du får Covid i Danmark

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathProcentage
from PortfolioProject..CovidDød
Where location like 'Denmark'
where continent is not null
order by 1,2


-- Ser på total_cases VS population
-- viser hvor mange procent af populationen der har fået covid

select location, date, population, total_cases, (total_cases/population)*100 as CovidProcentage
from PortfolioProject..CovidDød
--Where location like 'Denmark'
where continent is not null
order by 1,2

-- Ser på lande med højest infektionstal sammenlignet med population

select location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as InfectProcentage
from PortfolioProject..CovidDød
--Where location like 'Denmark'
Group By location, population
order by InfectProcentage DESC


-- Hvor mange døde af covid i de forskellige lande?

select location, MAX(cast(total_deaths as int)) as totalDeathcount
from PortfolioProject..CovidDød
--Where location like 'Denmark'
where continent is not null
Group By location
order by totalDeathcount DESC


-- viser kontinenterne med dehøjeste dødsfald


select continent, MAX(cast(total_deaths as int)) as totalDeathcount
from PortfolioProject..CovidDød
--Where location like 'Denmark'
where continent is not null
Group By continent
order by totalDeathcount DESC

-- Globale tal (fjern date, for at få det totale tal for hele verden)
select date, MAX(total_cases) as total_cases, MAX(cast(total_deaths as int)) as total_death, MAX(cast(total_deaths as int))/MAX(total_cases)*100 as GlobalDeathspercentage
from PortfolioProject..CovidDød
--Where location like 'Denmark'
group by date
order by 1, 2


-- ser på totale population vs vaccination

Select død.continent, død.location, død.date, død.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by død.location order by død.location, død.date) as rollingPeopleVaccinated
--, (rollingReopleVaccinated/population)*100
from PortfolioProject..CovidDød død
join PortfolioProject..CovidVaccination vac
     on død.location = vac.location
	 and død.date = vac.date
Where død.continent is not null
order by 2,3

--Brug CTE

With PopvsVac (continent, location, date, population, New_vaccinations, rollingPeopleVaccinated)
as
(
Select død.continent, død.location, død.date, død.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by død.location order by død.location, død.date) as rollingPeopleVaccinated
--, (rollingReopleVaccinated/population)*100
from PortfolioProject..CovidDød død
join PortfolioProject..CovidVaccination vac
     on død.location = vac.location
	 and død.date = vac.date
Where død.continent is not null
--order by 2,3
)
Select *, (rollingPeopleVaccinated/population)*100
from PopvsVac



-- TEMP TABLE
Drop table if exists #perscentPopulationVaccinated
create table #perscentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)

Insert into #perscentPopulationVaccinated

Select død.continent, død.location, død.date, død.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by død.location order by død.location, død.date) as rollingPeopleVaccinated
--, (rollingReopleVaccinated/population)*100
from PortfolioProject..CovidDød død
join PortfolioProject..CovidVaccination vac
     on død.location = vac.location
	 and død.date = vac.date
Where død.continent is not null
--order by 2,3

Select *, (rollingPeopleVaccinated/population)*100
from #perscentPopulationVaccinated


-- creating view for store data for later visualization

Create view perscentPopulationVaccinated as
Select død.continent, død.location, død.date, død.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by død.location order by død.location, død.date) as rollingPeopleVaccinated
--, (rollingReopleVaccinated/population)*100
from PortfolioProject..CovidDød død
join PortfolioProject..CovidVaccination vac
     on død.location = vac.location
	 and død.date = vac.date
Where død.continent is not null
--order by 2,3

Select *
from perscentPopulationVaccinated