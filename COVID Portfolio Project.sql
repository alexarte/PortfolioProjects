select *
from CovidDeaths
where continent is not null
order by 3,4

select *
from CovidVaccinations
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- Looking at Total Cases VS Total Deaths

-- Shows likelihood of dying if you contract the Covid in your contry
Select Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
from CovidDeaths
where location like 'United States'
order by 1,2

-- Looking at Total Cases VS Population
-- Shows which % of population got Covid
Select Location, date, total_cases, population, (total_cases / population)*100 as CovidPercentage
from CovidDeaths
where location like 'United States'
order by 1,2

-- Looking at countries with highest Infection Rate compared to Population
Select Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases / population))*100 as CovidPercentage
from CovidDeaths
--where location like 'United States'
group by Location, population
order by CovidPercentage desc

-- Showing Countries with the Highest Death Count per Population
Select Location, MAX(total_deaths) as TotalDeathCount
from CovidDeaths
--where location like 'United States'
where continent is not null
group by Location
order by TotalDeathCount desc

-- Lets break things down by continent

Select continent, MAX(total_deaths) as TotalDeathCount
from CovidDeaths
--where location like 'United States'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Showing continents with the highest death count per population
Select continent, MAX(total_deaths) as TotalDeathCount
from CovidDeaths
--where location like 'United States'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global numbers
Select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths , SUM (new_deaths) / SUM (new_cases) * 100 as DeathPercentage
from CovidDeaths
--where location like 'United States'
where continent is not null AND new_cases <> 0
--group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3

-- Use of CTE
with  PopvsVac (Continent, Location, Date, Population, New_Vaccs, RollingPeopleVaccinated )
as
(
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated / Population) * 100
from PopvsVac

-- Temp Table

-- if is created already
DROP Table if exists #PercentPopulationVaccinated


Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
new_vacinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
	--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated / Population) * 100
from #PercentPopulationVaccinated

--Creating View to Store data for later visualizations
Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated