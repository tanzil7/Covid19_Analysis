SELECT *
FROM Covid..['CovidDeath']
Order BY 3,4


--SELECT *
--FROM Covid..['CovidVaccination']
--Order BY 3,4


SELECT location, date, population, total_cases, new_cases, total_deaths
FROM Covid..['CovidDeath']
Order BY 1,2


-- Lets look at total death vs total cases

SELECT location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercent
FROM Covid..['CovidDeath']
--Lets Look at United States
WHERE location like '%states'
Order BY 1,2

-- Lets observe total cases vs population

SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectionPercent
FROM Covid..['CovidDeath']
--Lets Look at United States
WHERE location like '%states'
Order BY 1,2

-- Lets look at countries with high infection rate compared to population

SELECT location, population, MAX(total_cases) as HighInfectionCase , MAX((total_cases/population))*100 AS InfectionPercent
FROM Covid..['CovidDeath']
group by location, population
Order BY InfectionPercent desc

-- Lets look at countries with high death count based on population

SELECT location, population, MAX(cast (total_deaths as Int)) as TotalDeath 
FROM Covid..['CovidDeath']
where continent is not null
group by location, population
Order BY TotalDeath desc


-- Lets show continent with the highest death count per population

SELECT location, MAX(cast (total_deaths as Int)) as TotalDeath 
FROM Covid..['CovidDeath']
where continent is null
group by location
Order BY TotalDeath desc


-- Global data on covid

SELECT date, sum(new_cases) as Total_Case, sum(cast (new_deaths as INT)) as Total_Death, sum(cast(new_deaths as INT)) /sum(new_cases)* 100 as Death_Percent
FROM Covid..['CovidDeath']
WHERE continent is not null
group by date
order by date 


-- lets join the 2 tables
-- then see total population vs  vaccination
-- will use CTE

With popVSvac (continent, location, date, population, New_Vaccination, total_vaccinated)
as
(
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
	sum(cast(vaccine.new_vaccinations as bigint)) OVER (Partition by death.location order BY death.location, death.date) as total_vaccinated
FROM Covid..['CovidDeath'] death JOIN 
Covid..['CovidVaccination'] vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE death.continent is not null
--Order By 2,3
)

SELECT *, (total_vaccinated/population)*100
From popVSvac


-- creating temp table 

Create Table PercentPopulationVaccination (
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccination numeric,
	total_vaccinated numeric
)

Insert into PercentPopulationVaccination

SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
	sum(cast(vaccine.new_vaccinations as bigint)) OVER (Partition by death.location order BY death.location, death.date) as total_vaccinated
FROM Covid..['CovidDeath'] death JOIN 
Covid..['CovidVaccination'] vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE death.continent is not null
--Order By 2,3


SELECT *, (total_vaccinated/population)*100
From PercentPopulationVaccination


--Drop Table if exists PercentPopulationVaccination

-- lets create view for later visulization

Create View PercentPopulationVaccinate
as

(SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
	sum(cast(vaccine.new_vaccinations as bigint)) OVER (Partition by death.location order BY death.location, death.date) as total_vaccinated
FROM Covid..['CovidDeath'] death JOIN 
Covid..['CovidVaccination'] vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE death.continent is not null
--Order By 2,3
)