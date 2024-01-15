-- select * from coviddeaths;
-- select * from covidvaccinations;
select location, date, total_cases, new_cases, total_deaths, population 
from coviddeaths
order by 1, 2;


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you catch covid in your country
select location, date, total_cases, total_deaths, ((total_deaths / total_cases) * 100) as death_percentage
from coviddeaths
order by 1, 2;


-- Looking at Total Cases vs Population
-- Shows the percentage of population that caught covid
select location, date, population, total_cases, total_deaths, ((total_cases / population) * 100) as covid_infection_rate
from coviddeaths
order by 1, 2;


-- Looking at countries with the highest infection rate
select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases / population)) * 100 as covid_infection_rate
from coviddeaths
group by location, population
order by covid_infection_rate desc;


-- Showing countires with the most deaths per population
select location, MAX(cast(total_deaths as SIGNED)) as total_death_count
from coviddeaths
where continent is not null
group by location
order by total_death_count desc;


-- Showing countires with the most deaths per population
-- Broken down by continent
select continent, MAX(cast(total_deaths as SIGNED)) as total_death_count
from coviddeaths
where continent is not null
group by continent
order by total_death_count desc;


-- Global Numbers
select date, SUM(new_cases) as total_cases,
SUM(new_deaths) as total_deaths, 
SUM(new_deaths) / SUM(cast(new_cases as SIGNED)) * 100 as global_death_percentage
from coviddeaths
where continent is not null
group by date
order by 1, 2;


-- Looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as SIGNED)) 
	OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3;


-- USE CTE
With PopVsVac (continent, location, date, population,new_vaccinations, Rolling_People_Vaccinated)
as 
(
	select dea.continent, dea.location, dea.date, dea.population,
	vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as SIGNED)) 
		OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
	from coviddeaths dea
	join covidvaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	-- order by 2, 3
)
Select *, (Rolling_People_Vaccinated / population) * 100
 from PopVsVac;
 
 -- USE TEMP TABLE
 Drop table if exists PercentPopulationVaccinated;
 Create Table PercentPopulationVaccinated
 (
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vacinations numeric,
	Rolling_People_Vaccinated numeric 
);
insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as SIGNED)) 
	OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
 where dea.continent is not null
 order by 2, 3;
Select *, (Rolling_People_Vaccinated / population) * 100
 from PercentPopulationVaccinated;
 
 
 
 -- VIEWS SECTION
 
 
 -- Create View to store data visualizations
Drop table if exists PercentPopulationVaccinated;
Drop View if exists PercentPopulationVaccinated;
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as SIGNED)) 
	OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
 where dea.continent is not null;
-- order by 2, 3


-- Create view showing countires with the most deaths per population
-- Broken down by continent
Create View  Death_Per_Population_By_Continent as
select continent, MAX(cast(total_deaths as SIGNED)) as total_death_count
from coviddeaths
where continent is not null
group by continent
order by total_death_count desc;


-- Create view showing at Total Cases vs Population
-- Shows the percentage of population that caught covid
Create View Total_Cases_vs_Population as
select location, date, population, total_cases, total_deaths, ((total_cases / population) * 100) as covid_infection_rate
from coviddeaths
order by 1, 2;