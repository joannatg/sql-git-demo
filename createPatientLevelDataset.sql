/*
PROJECT: CATALYST

REQUEST DETAILS: get notes for the identified 15 pos and 5 neg pat*encs for SDOH = housing (pt list provided by Rob V)

TABLES IN: ochin.dbo.ENCOUNTER, ochin.dbo.DEMOGRAPHIC, ochin.dbo.VITAL 

TABELS OUT: 

ANALYST:JG


*/

--get encounters btw. 2013 and 2023
--        drop table if exists #encs
SELECT DISTINCT patid, admit_date, encounterid 
INTO #encs
FROM ochin.dbo.ENCOUNTER 
WHERE ADMIT_DATE BETWEEN '01-01-2013' AND '12-31-2023'
;

--get patients who had a BP reading and who were at least 3 years old 
SELECT DISTINCT d.patid, d.BIRTH_DATE, d.SEX, e.ADMIT_DATE, e.encounterid, cast(floor(datediff(day,cast(d.BIRTH_DATE  as date),cast('01-01-2013' as date))/365.25) as varchar) AS ageOn01Jan2013
--CONCAT(cast(SYSTOLIC as INT), '/', cast(DIASTOLIC AS INT)) AS BLOOD_PRESSURE
--into #pats
FROM ochin.dbo.DEMOGRAPHIC d 
INNER JOIN #encs e ON d.patid=e.patid
LEFT JOIN ochin.dbo.VITAL v ON e.patid=v.patid AND e.ENCOUNTERID=v.ENCOUNTERID
WHERE  cast(floor(datediff(day,cast(d.BIRTH_DATE  as date),cast('01-01-2013' as date))/365.25) as varchar)>=3
AND v.SYSTOLIC is not NULL
AND v.DIASTOLIC is not NULL
;
