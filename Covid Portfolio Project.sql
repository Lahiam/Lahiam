Select * 
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%state%'
order by 1,2

-- Total cases vs Population
-- Percentage 

Select Location, date,Population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
-- where location like '%state%'
order by 1,2

-- Countries with Highest Infection Rate Compared to Population

Select Location,Population, MAX (total_cases) as HighestInfectionCount,Max ((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
-- where location like '%state%'
Group by Location,Population
order by PercentagePopulationInfected desc

-- Contries with Highest Death Count per Population

Select Location,MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- where location like '%state%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Continents with hightest death count per population

Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- where location like '%state%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers

Select date, SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths 
--where location like '%state%'
Where continent is not null
group by date
order by 1,2

-- Total Population vs Vaccinations


   SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
   SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location)
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   order by 2,3

   -- With CTE

   With popvsvac (Continent, Location, date, population, New_vaccinations,RollingPeopleVaccinated)
   as
   (
    Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
   SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
   dea.Date) as RollingPeopleVaccinated
   --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   --order by 2,3
   )
   Select *,( RollingPeopleVaccinated/Population)*100
   From popvsvac

   -- Table View

   DROP Table if exists #PercentPopulationVaccinated
  Create table #PercentPopulationVaccinated
   (
   Continent nvarchar(255), 
   Location nvarchar (255), 
   Date datetime, 
   Population numeric, 
   New_Vaccinations numeric, 
   RollingPeopleVaccinated numeric
   )

  Insert into #PercentPopulationVaccinated
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
   dea.Date) as RollingPeopleVaccinated
   --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   --order by 2,3

   Select *, (RollingPeopleVaccinated/Population)*100
   From #PercentPopulationVaccinated

   
  -- View for Data Visualization
  
DROP VIEW PercentPopulationVaccinated
GO
CREATE VIEW PercentPopulationVaccinated AS
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
   dea.Date) as RollingPeopleVaccinated
   --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   --order by 2,3

