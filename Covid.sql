Select *
From CovidProject.. CovidDeaths
order by 3,4


--Select *
--From CovidProject.. CovidVaccinations
--order by 3,4



--Data Selection
Select location, date, total_cases, new_cases, total_deaths, population
From CovidProject.. CovidDeaths
order by 1,2




--Total Cases Vs. Total Deaths: shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject.. CovidDeaths
--Where location like '%states%'
where continent is not null
order by 1,2




--Total Cases VS Population: shows the percentage of population that got covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidProject.. CovidDeaths
--Where location like '%states%'
where continent is not null
order by 1,2




--Countries with highest infections rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentagePopulationInfected
From CovidProject..CovidDeaths
where continent is not null
Group by location, population
order by PercentagePopulationInfected desc




-- Countries with highest Death Count per Population
Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc




--Continent with highest Death Count per popluation
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject ..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc



--World Numbers: total cases and total deaths
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
where continent is not null
order by 1,2




--World numbers: total cases and total deaths grouped by dates across the world
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
where continent is not null
Group by date
order by 1,2



-- Total population Vs. Vaccination
--USE CTE
with PopVsVac (Continent, Location, Date,Population, New_Vaccinations,  RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.location, 
	dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac

--USING TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.location, 
	dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualization