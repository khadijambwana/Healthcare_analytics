update hospital_records
set stay_days = case
when stay::text ilike '%More than%' then 100
when stay::text ilike '%less than%' then 5
when stay::text ilike '%-%'  then ((split_part(stay::text, '-',1)::int + 
split_part(stay::text,'-',2):: int)/2)
else null
end;
select * from hospital_records;
select  stay_days from hospital_records
order by stay_days desc;

SELECT DISTINCT stay_days FROM hospital_records LIMIT 20;
select round(avg(stay_days),2) from hospital_records;
---questions to be answered
--avg stay per department
select
department,
round(avg(stay_days),2) as avg_stay_days
from hospital_records
group by department
order by avg_stay_days desc;
--maximum saty
select
max(stay) as max_days
from hospital_records;
--the longest per department
select 
department,
stay_days,
first_name,
last_name
from 
(select *,
row_number() over (partition by department order by stay_days desc) as row_no
from hospital_records) as ranked
where row_no = 1;
--how severity of illness and type of admission impact stay
select * from hospital_records;
select
severity_of_illness,
type_of_admission,
count (*) as total_patient,
round(avg(stay_days ),2) as avg_stay
from hospital_records
group by severity_of_illness,type_of_admission
order by avg_stay desc;
-- if most highest grade beds are used for the most severe cases
select
bed_grade,
severity_of_illness,
count(*) as total_patient,
count(case_id) as cases
from hospital_records
group by bed_grade,severity_of_illness
order by bed_grade;

--the highest diagnosis by gender
select * from hospital_records;
select 
gender,count(diagnosis) as diagnosis_count
from hospital_records
group by gender
order by diagnosis_count desc;
--the diagnosis by gender
select gender,diagnosis,diagnosis_count from
(select gender,diagnosis ,count(*) as diagnosis_count,
row_number() over (partition by gender order by count(*) desc) as row_num
from hospital_records
group by gender,diagnosis)
where row_num = 1;
--avg available extra rooms by hospital code
select * from hospital_records;
select 
hospital_code,
round(avg(available_extra_rooms_in_hospital),2) as avg_room
from hospital_records
group by hospital_code
order by avg_room desc;
--most used bed grade per hospital
select 
hospital_code,
mode() within group (order by bed_grade) as most_used_bed_grade
from hospital_records
group by hospital_code,severity_of_illness;
--top 10 most diagnosis
select
diagnosis,
count (*) as diagnosis_count
from hospital_records
group by diagnosis
order by diagnosis_count desc
limit 10;
--most common diagnosis by age group and gender
--created another column for age_mid int
ALTER TABLE hospital_records
ADD COLUMN age_mid INT;
UPDATE hospital_records
SET age_mid = (
  (SPLIT_PART(patient_age, '-', 1)::INT + SPLIT_PART(patient_age, '-', 2)::INT)/ 2
)
WHERE patient_age LIKE '%-%';  -- only for values like '10-30'
SELECT patient_age, age_mid
FROM hospital_records
LIMIT 20;

  SELECT 
    CASE 
      WHEN age_mid < 5 THEN 'Under 5'
      WHEN age_mid BETWEEN 5 AND 17 THEN 'Child (5–17)'
      WHEN age_mid BETWEEN 18 AND 35 THEN 'Youth (18–35)'
      WHEN age_mid BETWEEN 36 AND 59 THEN 'Adult (36–59)'
      ELSE 'Senior (60+)' 
    END AS age_group,
    gender,
    diagnosis,
    COUNT(*) AS diagnosis_count
  FROM hospital_records
  WHERE age_mid IS NOT NULL
  GROUP BY age_group, gender, diagnosis
  order by age_group,gender,diagnosis_count desc;
--which city code has highest no of admissions
select * from hospital_records;
select
city_code_patient,
count(*) as admission_count
from hospital_records
group by city_code_patient
order by admission_count desc;
--does particular city have higher proportion of admission emergency admi or extreme severity cases
SELECT 
  city_code_patient,
  COUNT(*) AS total_admissions,
  COUNT(*) FILTER (WHERE type_of_admission = 'Emergency') AS emergency_admissions,
  COUNT(*) FILTER (WHERE severity_of_illness = 'Extreme') AS extreme_cases,
  ROUND(
    COUNT(*) FILTER (WHERE type_of_admission = 'Emergency')*100/count(*),2
  ) AS emergency_rate_percent,
  ROUND(
    COUNT(*) FILTER (WHERE severity_of_illness = 'Extreme') * 100.0 / COUNT(*), 2
  ) AS extreme_rate_percent
FROM hospital_records
GROUP BY city_code_patient
ORDER BY emergency_rate_percent DESC, extreme_rate_percent DESC;
--compare the avg admission stay for emergency,trauma
SELECT 
  type_of_admission,
  ROUND(AVG(stay_days), 2) AS avg_stay_days
FROM hospital_records
WHERE type_of_admission IN ('Emergency', 'Trauma')
GROUP BY type_of_admission
ORDER BY avg_stay_days DESC;
--correlate no. of visitors with patient and admission stay
SELECT 
 CORR(visitors::NUMERIC, stay_days::NUMERIC) AS correlation_visitors_stay
FROM hospital_records;
--correlation by gender
SELECT 
  gender,
  CORR(visitors::NUMERIC, stay_days::NUMERIC) AS correlation_visitors_stay
FROM hospital_records
GROUP BY gender;
--correlation by sevrity of illness
SELECT 
  severity_of_illness,
  CORR(visitors::NUMERIC,stay_days::NUMERIC) AS correlation_visitors_stay
FROM hospital_records
GROUP BY severity_of_illness;
--correlation by age group
SELECT 
  CASE 
    WHEN age_mid < 18 THEN 'Child (<18)'
    WHEN age_mid BETWEEN 18 AND 35 THEN 'Young Adult (18–35)'
    WHEN age_mid BETWEEN 36 AND 59 THEN 'Adult (36–59)'
    ELSE 'Senior (60+)' 
  END AS age_group,
  CORR(visitors::NUMERIC, stay_days::NUMERIC) AS correlation_visitors_stay
FROM hospital_records
GROUP BY age_group;

--does avg number of visitors differ by age group
SELECT 
  CASE 
    WHEN age_mid < 18 THEN 'Child (<18)'
    WHEN age_mid BETWEEN 18 AND 35 THEN 'Young Adult (18–35)'
    WHEN age_mid BETWEEN 36 AND 59 THEN 'Adult (36–59)'
    ELSE 'Senior (60+)' 
  END AS age_group,
  ROUND(AVG(visitors), 2) AS avg_visitors
FROM hospital_records
GROUP BY age_group
ORDER BY avg_visitors DESC;




