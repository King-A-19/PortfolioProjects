--Covid 19 Data Exploration 
Select *
from PortfolioProjects..CovidDeaths$
order by 3,4

Select *
from PortfolioProjects..CovidVaccinations$
order by 3,4

-- Shows likelihood of dying if you contract covid in your country
	
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths$
where location like '%south africa%'
order by 1,2

select location, date, population, total_cases,(total_cases/population)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths$
where location like '%south africa%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population
	
select location, population, MAX(total_cases)as HighestInfectiolnCount,MAX((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProjects..CovidDeaths$
--where location like '%south africa%'
Group by location, population
order by PercentagePopulationInfected desc
	
-- Countries with Highest Death Count per Population
	
Select Location, Max(cast(Total_deaths as int)) as TotalDeathsCount
From PortfolioProjects..CovidDeaths$
Where continent is not null
Group by Location
Order by TotalDeathsCount desc

-- Showing contintents with the highest death count per population
	
Select continent, Max(cast(Total_deaths as int)) as TotalDeathsCount
From PortfolioProjects..CovidDeaths$
Where continent is not null
Group by continent
Order by TotalDeathsCount desc

Select Location, Max(cast(Total_deaths as int)) as TotalDeathsCount
From PortfolioProjects..CovidDeaths$
Where continent is null
Group by Location
Order by TotalDeathsCount desc

Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths$
Where continent is not null
--Group by Location
Order by 1,2

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
	
Select dea.continent, dea.Location, dea.population, vac.new_vaccinations
From PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


Select dea.continent, dea.Location, dea.population, dea.date, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location)
From PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

Select dea.continent, dea.Location, dea.population, dea.date, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date )
From PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Using CTE
	
With PopvsVac (Continent, Location, Population, Date, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.Location, dea.population, dea.date, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query
	
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Population numeric,
Date datetime,
New_Vaccinatons numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.Location, dea.population, dea.date, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
Select *,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Population numeric,
Date datetime,
New_Vaccinatons numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.Location, dea.population, dea.date, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3
Select *,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
	
Create View PercentPopulationVaccinated as
Select dea.continent, dea.Location, dea.population, dea.date, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select * 
From PercentPopulationVaccinated

