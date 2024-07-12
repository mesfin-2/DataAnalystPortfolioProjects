--Select data that we are using
 
select location , date , total_cases ,new_cases ,total_deaths , population 
 from  coviddeaths 
 order by 1,2

 -- Looking at Total Cases Vs Total Deaths
 
 select location , date , total_cases  ,total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
 from  coviddeaths 
 where "location"='Africa' 
 order by 1,2

  --Looking at Total Cases vs Population
 -- Shows what percentage of population got Covid
 
 select location , date , total_cases  ,population , (total_cases/population)*100 as TotalCasePercentage
 from  coviddeaths 
 where "location"='Italy' 
 order by 1,2
 
