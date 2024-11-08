-- Deaths Table

Select *
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations$
--order by 3,4

-- Data being used

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
order by 1,2

-- Analysing Total Cases vs Total Deaths
-- Shows probability of death if contracted Covid in your country, e.g. United Kingdom

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject.dbo.CovidDeaths$
Where location like '%kingdom%'
and continent is not null
order by 1,2

-- Analysing Total Cases vs Population
-- Shows percentage of population that got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as infected_population_percentage
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%kingdom%'
order by 1,2

-- Viewing which countries with highest infection rate percentage in comparison to population

Select location, population, MAX(total_cases) as highest_infections, MAX((total_cases/population))*100 as infected_population_percentage
From PortfolioProject.dbo.CovidDeaths$
Group by population, location
order by infected_population_percentage desc

-- Showing countries with highest death count per population
-- Converted nvarchar to bigint 

Select location, MAX(cast(total_deaths as bigint)) as total_death_count
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
Group by location
order by total_death_count desc


-- Broken down by continent

--Select location, MAX(cast(total_deaths as bigint)) as total_death_count
--From PortfolioProject.dbo.CovidDeaths$
--Where continent is null
--Group by location
--order by total_death_count desc

--Showing continents with highest death count

Select continent, MAX(cast(total_deaths as bigint)) as total_death_count
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
Group by continent
order by total_death_count desc


-- Global Figures

-- Daily global cases to deaths statistics and percentages
Select date, SUM(new_cases) as global_cases, SUM(cast(new_deaths as bigint)) as global_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as global_death_percentage
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
Group by date
order by 1,2

-- Global statistic and percentage

Select SUM(new_cases) as global_cases, SUM(cast(new_deaths as bigint)) as global_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as global_death_percentage
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
-- Group by date
order by 1,2


---- Joining Deaths and Vaccinations Tables

--Select *
--From PortfolioProject.dbo.CovidDeaths$ dea
--Join PortfolioProject.dbo.CovidVaccinations$ vac
--	On dea.location = vac.location
--	and dea.date = vac.date

-- Total Population vs Vaccinations per day

Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as rolling_vaccinations_count
--, (rolling_vaccinations_count/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- Using a CTE

With PopuVsVacc (continent, location, date, population, new_vaccinations, rolling_vaccinations_count)
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as rolling_vaccinations_count
--, (rolling_vaccinations_count/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3
)
Select *, (rolling_vaccinations_count/population)*100
From PopuVsVacc


-- Using a Temp Table

DROP Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinations_count numeric
)

Insert into #Percent_Population_Vaccinated
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as rolling_vaccinations_count
--, (rolling_vaccinations_count/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
-- Where dea.continent is not null
-- order by 2,3

Select *, (rolling_vaccinations_count/population)*100
From #Percent_Population_Vaccinated


-- Creating View for later visualisation

Create View Percent_Population_Vaccinated as
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as rolling_vaccinations_count
--, (rolling_vaccinations_count/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3

Select *
From Percent_Population_Vaccinated