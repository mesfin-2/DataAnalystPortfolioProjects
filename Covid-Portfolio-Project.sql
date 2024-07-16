
select *
 from  coviddeaths 
 where continent is not null 
 order by 3,4

--Select data that we are using
 
select location , date , total_cases ,new_cases ,total_deaths , population 
 where continent is not null 
 from  coviddeaths 
 order by 1,2

 
 -- Looking at Total Cases Vs Total Deaths
 
 select location , date , total_cases  ,total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
 from  coviddeaths 
  where continent is not null  
 order by 1,2
 
 
 -- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths,population, (total_deaths/population)*100 as DeathPercentage
From coviddeaths c 
and continent is not null 
order by 1,2
 
 --Which Country has the highest infection rate compared to the country population
 
 Select "location" , population, max(total_cases) as HighestInfectionCount, max((total_cases /population)*100) as PercentPopulationInfected
From coviddeaths 
group by "location" , population 
 where continent is not null 
order by PercentPopulationInfected desc 

-- Showing Countries with Highest Death Count per Population
 Select "location" , max(cast(total_deaths as int)) as TotalDeathCount
From coviddeaths 
 where 'continent' is not null 
group by "location"  
order by TotalDeathCount desc 

-- Lets Break things down by continent

 Select continent , max(cast(total_deaths as int)) as TotalDeathCount
From coviddeaths 
 where 'continent' is not  null 
group by continent  
order by TotalDeathCount desc 


--Global numbers

-- Showing the continents with the highest death count per population

select date,
    sum(cast(new_cases as int)) as total_new_cases,
    sum(new_deaths)as total_new_deaths,
    case
	    -- CASE statement to check if the sum of new_cases is zero.
	    --If the sum of new_cases is zero, the DeathPercentage is set to zero.
        when sum(cast(new_cases as int)) = 0 then 0
        --Otherwise, it calculates the DeathPercentage as before.
        else (sum(new_deaths) / sum(cast(new_cases as int))) * 100
    end as DeathPercentage
from
    coviddeaths
where
    continent is not null
group by
    date
order by
    date;

   --Total new cases and total deather overall the world
   select
    sum(cast(new_cases as int)) as total_new_cases,
    sum(new_deaths) as total_new_deaths,
    case
	    -- CASE statement to check if the sum of new_cases is zero.
	    --If the sum of new_cases is zero, the DeathPercentage is set to zero.
        when sum(cast(new_cases as int)) = 0 then 0
        --Otherwise, it calculates the DeathPercentage as before.
        else (sum(new_deaths) / sum(cast(new_cases as int))) * 100
    end as DeathPercentage
from
    coviddeaths
where
    continent is not null



--Explore Vacinnation dataset
    
    
--Joining coviddeaths with covidvaccin
    
    select * 
    from coviddeaths cd
    join covidvaccinations cv
    on cd.location  = cv.location
    and cd.date  = cv.date
    
    --Looking at Total Population vs Vaccinations
    
     select  cd.continent , cd."location" , cd."date" , cd.population , cv.new_vaccinations 
    from coviddeaths cd
    join covidvaccinations cv
    	on cd.location  = cv.location
    	and cd.date  = cv.date
    where cd.continent is not null
    order by 2,3
    
    
--Total Vaccination Per location/Countries
 -- total_vaccinations_per_location is a running total
SELECT
    cd.continent,
    cd."location",
    cd."date",
    cd.population,
    cv.new_vaccinations,
        SUM(CAST(NULLIF(cv.new_vaccinations, '') as DECIMAL)) OVER (PARTITION BY cd."location" order by cd.location,
        cd.date ) as total_vaccinations_per_location,
       -- (total_vaccinations_per_location/population)*100
    from coviddeaths cd
JOIN
    covidvaccinations cv
    ON cd.location = cv.location
    AND cd.date = cv.date
WHERE
    cd.continent IS NOT NULL
ORDER BY
    2,3
    
    
  --SQL does not allow referring to an alias in the same SELECT clause so ,
  --Use subquery or CTE-common table Expression
  
  --Use CTE
  
  with PopvsVac(continent, location, date,population,new_vaccinations,total_vaccinations_per_location)
  as 
  (
  SELECT
    cd.continent,
    cd."location",
    cd."date",
    cd.population,
    cv.new_vaccinations,
        SUM(CAST(NULLIF(cv.new_vaccinations, '') as DECIMAL)) OVER (PARTITION BY cd."location" order by cd.location,
        cd.date ) as total_vaccinations_per_location
	from coviddeaths cd
	JOIN
    covidvaccinations cv
    ON cd.location = cv.location
    AND cd.date = cv.date
	WHERE
    cd.continent IS NOT NULL
--ORDER BY  2,3
 )
select * , (total_vaccinations_per_location/population)*100 as totalVaccinPerPop
from PopvsVac

--Temp Table

-- Step 1: Drop the Table if it Exists
DROP TABLE IF EXISTS temp_percentPopVaccinated;

-- Step 2: Create the Table
CREATE TABLE temp_percentPopVaccinated (
    continent varchar(255),
    location varchar(255),
    date timestamp,
    population numeric,
    new_vaccinations numeric,
    total_vaccinations_per_location numeric
);

   
 -- Step 3: Insert Data into the Table
INSERT INTO temp_percentPopVaccinated
SELECT
    dea.continent,
    dea.location,
    CAST(NULLIF(dea."date", '') AS timestamp) AS date,
    dea.population,
    CAST(NULLIF(vac.new_vaccinations, '') AS numeric) AS new_vaccinations,
    SUM(CAST(NULLIF(vac.new_vaccinations, '') AS numeric)) OVER (
        PARTITION BY dea.location
        ORDER BY dea.location, CAST(NULLIF(dea."date", '') AS timestamp)
    ) AS total_vaccinations_per_location
FROM
    coviddeaths dea
JOIN
    covidvaccinations vac
    ON dea.location = vac.location
    AND CAST(NULLIF(dea."date", '') AS timestamp) = CAST(NULLIF(vac."date", '') AS timestamp)
WHERE
    dea.continent IS NOT NULL;
   
   -- Step 4: Select Data from the Table
SELECT 
    *, 
    (total_vaccinations_per_location / population) * 100 AS vaccination_percentage
FROM 
    temp_percentPopVaccinated
ORDER BY
    location, date;
   
   
   --Create View for data store and using it for later data visualization
   
   create View percentPopVaccinated as
   SELECT
    dea.continent,
    dea.location,
    CAST(NULLIF(dea."date", '') AS timestamp) AS date,
    dea.population,
    CAST(NULLIF(vac.new_vaccinations, '') AS numeric) AS new_vaccinations,
    SUM(CAST(NULLIF(vac.new_vaccinations, '') AS numeric)) OVER (
        PARTITION BY dea.location
        ORDER BY dea.location, CAST(NULLIF(dea."date", '') AS timestamp)
    ) AS total_vaccinations_per_location
FROM
    coviddeaths dea
JOIN
    covidvaccinations vac
    ON dea.location = vac.location
    AND CAST(NULLIF(dea."date", '') AS timestamp) = CAST(NULLIF(vac."date", '') AS timestamp)
WHERE
    dea.continent IS NOT NULL;
   	--order by 2,3
   
   --Since Its A view we can use it later for visuslization
   select *
   from percentpopvaccinated 
