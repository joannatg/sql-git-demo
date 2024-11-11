/*
PROJECT: CATALYST

REQUEST DETAILS: get notes for the identified 15 pos and 5 neg pat*encs for SDOH = housing (pt list provided by Rob V)

TABLES IN: ochin.dbo.ENCOUNTER, ochin.dbo.DEMOGRAPHIC, ochin.dbo.VITAL 

TABELS OUT: 

ANALYST:JG


*/

SELECT DISTINCT d.patid, d.BIRTH_DATE, d.SEX, e.ADMIT_DATE, e.encounterid, cast(floor(datediff(day,cast(d.BIRTH_DATE  as date),cast('01-01-2023' as date))/365.25) as varchar) AS ageOn01Jan2023
--CONCAT(cast(SYSTOLIC as INT), '/', cast(DIASTOLIC AS INT)) AS BLOOD_PRESSURE
--into #pats
FROM ochin.dbo.DEMOGRAPHIC d 
LEFT JOIN ochin.dbo.ENCOUNTER e ON d.patid=e.patid
LEFT JOIN ochin.dbo.VITAL v ON e.patid=v.patid AND e.ENCOUNTERID=v.ENCOUNTERID
WHERE  e.ADMIT_DATE BETWEEN '01-01-2013' AND '12-31-2023'
AND d.BIRTH_DATE < '01-01-2020' 
AND v.SYSTOLIC is not NULL
AND v.DIASTOLIC is not NULL
ORDER BY d.BIRTH_DATE DESC
;
