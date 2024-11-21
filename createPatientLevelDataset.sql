/*
PROJECT: CATALYST

REQUEST DETAILS: get all patients 3+ and their geocoded addresses and encounter dates taht are btw. 2013 and 2023

TABLES IN: ochin.dbo.ENCOUNTER, ochin.dbo.DEMOGRAPHIC, ochin.dbo.VITAL 

TABELS OUT:  [research_dev].[dbo].[jg_catalyst_ptAddrEnc]

ANALYST:JG


*/



/*GET ELIGIBLE PTS*/

--get patients who had an enc btw. 2013-2023 AND had a BP reading AND who were at least 3 years old 
--        drop table if exists #pats
SELECT DISTINCT d.patid, d.BIRTH_DATE, d.SEX, e.ADMIT_DATE, e.encounterid, cast(floor(datediff(day,cast(d.BIRTH_DATE  as date),cast('01-01-2023' as date))/365.25) as varchar) AS ageOn01Jan2023
--CONCAT(cast(SYSTOLIC as INT), '/', cast(DIASTOLIC AS INT)) AS BLOOD_PRESSURE
into #pats
FROM ochin.dbo.DEMOGRAPHIC d 
LEFT JOIN ochin.dbo.ENCOUNTER e ON d.patid=e.patid
LEFT JOIN ochin.dbo.VITAL v ON e.patid=v.patid AND e.ENCOUNTERID=v.ENCOUNTERID
WHERE  e.ADMIT_DATE BETWEEN '01-01-2013' AND '12-31-2023'
AND d.BIRTH_DATE < '01-01-2020' 
AND v.SYSTOLIC is not NULL
AND v.DIASTOLIC IS NOT NULL
ORDER BY d.BIRTH_DATE DESC
;
--chk age: SELECT MIN(CAST(ageOn01Jan2023 AS INT))  FROM #pats   
--3, ok

SELECT COUNT (DISTINCT patid) FROM #pats --50,951,999 rows for 6,184,018 pts for  enc btw. 2013-01-01 and 2023-12-31


/*ADDRESSES*/

/*
SELECT COUNT (DISTINCT patid) FROM ochin.dbo.PATIENT_ADDRESS_HX  3,879,65
SELECT count (DISTINCT patid) FROM [Research_Geo].[dbo].[PAT_ADDR_HISTORY] 8,310,924
*/

--get addresses from [Research_Geo].[dbo].[PAT_ADDR_HISTORY] for patients in #pats

SELECT DISTINCT hx.patid,addr_order, addr_start_dt, addr_end_dt,  birth_date,  
 cast(floor(datediff(day,cast(birth_date  as date),cast('01-01-2013' as date))/365.25) as varchar) AS ageOn01Jan2013, ageOn01Jan2023, sex, admit_date, encounterid,
CASE WHEN admit_date >=addr_start_dt THEN 1
WHEN admit_date<addr_start_dt THEN 0
END AS startOk, 
CASE WHEN admit_date<= addr_end_dt  OR  addr_end_dt  IS NULL THEN 1
WHEN admit_date >  addr_end_dt   THEN 0
END AS endOk
INTO [research_dev].[dbo].[jg_catalyst_ptAddrEnc]
FROM [Research_Geo].[dbo].[PAT_ADDR_HISTORY] hx
LEFT JOIN #pats p ON hx.patid=p.patid
WHERE-- AND hx.patid IN ('000001B1-FFA8-4902-9D38-9BE1BA9BEE9C', '000001D5-7C41-49FF-944A-895D6950B993', '0000039E-DC3E-4010-930E-73E279616DB5','AFBAED07-8246-4E63-8433-BCFCA21B8028', 'B1A9E95C-4F59-4448-A3FF-B27B1D613751')
admit_date>=addr_start_dt AND admit_date<=addr_end_dt 
OR  --hx.patid IN ('000001B1-FFA8-4902-9D38-9BE1BA9BEE9C', '000001D5-7C41-49FF-944A-895D6950B993', '0000039E-DC3E-4010-930E-73E279616DB5', 'AFBAED07-8246-4E63-8433-BCFCA21B8028', 'B1A9E95C-4F59-4448-A3FF-B27B1D613751') AND 
admit_date>=addr_start_dt AND   addr_end_dt IS NULL
ORDER BY hx.patid, addr_start_dt, admit_date
;
--40,385,455 rows
SELECT count (DISTINCT patid) FROM [research_dev].[dbo].[jg_catalyst_ptAddrEnc]
--5,638,897

SELECT count (DISTINCT patid) FROM [Research_Geo].[dbo].[PAT_ADDR_HISTORY] --8310924

