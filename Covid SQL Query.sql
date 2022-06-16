
select * 
from portfolio_project..Covid_deaths
order by 3,4

select location,date,population, total_deaths
from portfolio_project..Covid_deaths
where location like '%nigeria%'
group by location, population, total_deaths,date
order by 1,2

-- select the data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from portfolio_project..Covid_deaths
where location like '%nigeria%'
order by 1,2


select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from portfolio_project..Covid_deaths
where location like '%nigeria%'
order by 1,2

-- lets look at total cases vs population
-- shows what percentage of population got covid

select location,date,total_cases,population,(total_cases/population)*100 as infected_percentage
from portfolio_project..Covid_deaths
where location like '%nigeria%'
order by 1,2

-- Looking at coutries with highest infected rate vs population
select location,MAX(total_cases) as Highest_case,population,MAX(date), MAX (CAST (total_deaths as int)) as total_deaths ,MAX((total_cases/population))*100 as infected_percentage
from portfolio_project..Covid_deaths
--where location like '%nigeria%'
group by location,population
order by infected_percentage DESC

select location,MAX(cast (total_deaths as int)) as total_death_count 
from portfolio_project..Covid_deaths
--where location like '%nigeria%'
where continent is not NULL 
group by location
order by total_death_count DESC 

-- break things down by continent

select continent,MAX(cast (total_deaths as int)) as total_death_count 
from portfolio_project..Covid_deaths
--where location like '%nigeria%'
where continent is not  NULL 
group by continent
order by total_death_count DESC 

-- checking global case and death with respect to date
select date, sum(new_cases) as total_case,sum(cast(new_deaths as int))as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as death_percentage
from portfolio_project..Covid_deaths
--where location like '%nigeria%'
where continent is not  NULL 
group by date
order by 1,2 DESC 

-- Checking the global covid cases and death number 
select sum(new_cases) as total_case,sum(cast(new_deaths as int))as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as death_percentage
from portfolio_project..Covid_deaths
--where location like '%nigeria%'
where continent is not  NULL 
--group by date
order by 1,2 DESC 

select *
from portfolio_project..Covid_deaths dea
join portfolio_project..Covid_vaccination vac
on dea.location = vac.location
and dea.date = vac.date

-- looking at total vaccinations vs populations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from portfolio_project..Covid_deaths dea
join portfolio_project..Covid_vaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%nigeria%'
order by 2,3

-- get the sum of vaccinations with respect to date

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as vaccinated_count
from portfolio_project..Covid_deaths dea
join portfolio_project..Covid_vaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%canada%'
order by 2,3

-- Using a CTE

WITH popvsvac(continent,location,date,population,new_vaccinations,vaccinated_count)
as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as vaccinated_count
from portfolio_project..Covid_deaths dea
join portfolio_project..Covid_vaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%canada%'
--order by 2,3
)
select *,(vaccinated_count/population)*100 as percentage_vaccinated
from popvsvac
order by 2

-- using a temptable
DROP TABLE if exists #vaccinatedpopulation
CREATE TABLE #vaccinatedpopulation
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vaccinated_count numeric,
)

INSERT INTO #vaccinatedpopulation
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as vaccinated_count
from portfolio_project..Covid_deaths dea
join portfolio_project..Covid_vaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%canada%'
--order by 2,3
select *,(vaccinated_count/population)*100 as percentage_vaccinated
from #vaccinatedpopulation
order by 2

-- create view
CREATE VIEW vaccinatedpopulation as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as vaccinated_count
from portfolio_project..Covid_deaths dea
join portfolio_project..Covid_vaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%canada%'
--order by 2,3

select *
from vaccinatedpopulation
order by 2


