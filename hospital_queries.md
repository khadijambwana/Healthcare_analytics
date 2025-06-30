# Hospital Records Analysis: Complete SQL Query Log

This file documents the full sequence of SQL queries used to analyze the hospital patient records dataset. The process moves from initial data cleaning and preparation to in-depth analysis of patient stays, resource management, and statistical correlations.

---

### 1. Data Cleaning and Preparation

This initial phase was crucial for transforming raw, often text-based data into a clean, numeric format suitable for accurate mathematical analysis.

#### 1.1. Standardize 'Length of Stay' into a Numeric Column
**Purpose:** The original `stay` column contained text ranges (e.g., '21-30 days'). This query creates a new numeric column, `stay_days`, by calculating the midpoint of these ranges, making it possible to compute averages and other statistics.

```sql
UPDATE hospital_records
SET stay_days = CASE
    WHEN stay::text ILIKE '%More than%' THEN 100 -- Assign a high value for open-ended stays
    WHEN stay::text ILIKE '%less than%' THEN 5   -- Assign a low value for short stays
    WHEN stay::text ILIKE '%-%' THEN (
        (SPLIT_PART(stay::text, '-', 1)::INT + SPLIT_PART(stay::text, '-', 2)::INT) / 2
    )
    ELSE NULL
END;


1.2. Create a Computable 'Age' Column
Purpose: Similar to the stay duration, the patient_age column was a text range. This query adds a new numeric column, age_mid, to store the midpoint of the age range, enabling analysis and grouping by age.
-- First, add the new column
ALTER TABLE hospital_records
ADD COLUMN age_mid INT;

-- Then, populate it with the calculated midpoint of the age range
UPDATE hospital_records
SET age_mid = (
  (SPLIT_PART(patient_age, '-', 1)::INT + SPLIT_PART(patient_age, '-', 2)::INT) / 2
)
WHERE patient_age LIKE '%-%';


2. Length of Stay (LOS) Analysis
This section analyzes the primary drivers and patterns of how long patients stay in the hospital.

2.1. Average Length of Stay by Department
Purpose: To identify which hospital departments typically handle patients with longer stays, which is key for resource planning.
SELECT
    department,
    ROUND(AVG(stay_days), 2) AS avg_stay_days
FROM hospital_records
GROUP BY department
ORDER BY avg_stay_days DESC;


2.2. Patient with the Longest Stay in Each Department
Purpose: To identify specific outlier cases for review. This uses a window function (ROW_NUMBER) to find the individual patient with the longest stay within each department.
SELECT
    department,
    stay_days,
    first_name,
    last_name
FROM (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY stay_days DESC) AS row_no
    FROM hospital_records
) AS ranked_stays
WHERE row_no = 1;


2.3. Impact of Illness Severity and Admission Type on Stay
Purpose: To understand how the urgency of admission and the severity of a case combine to affect patient stay duration, helping to forecast bed occupancy.
SELECT
    severity_of_illness,
    type_of_admission,
    COUNT(*) AS total_patients,
    ROUND(AVG(stay_days), 2) AS avg_stay_days
FROM hospital_records
GROUP BY severity_of_illness, type_of_admission
ORDER BY avg_stay_days DESC;


3. Patient Demographics and Diagnosis Analysis
This analysis focuses on understanding the patient population and their primary health conditions.

3.1. Top 10 Most Frequent Diagnoses
Purpose: To identify the most common health issues treated at the hospital, which informs specialization and supply chain needs.
SELECT
    diagnosis,
    COUNT(*) AS diagnosis_count
FROM hospital_records
GROUP BY diagnosis
ORDER BY diagnosis_count DESC
LIMIT 10;


3.2. Top Diagnosis by Gender
Purpose: To determine if there are differences in the most common diagnoses between male and female patients.
SELECT gender, diagnosis, diagnosis_count
FROM (
    SELECT
        gender,
        diagnosis,
        COUNT(*) AS diagnosis_count,
        ROW_NUMBER() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) AS row_num
    FROM hospital_records
    GROUP BY gender, diagnosis
) AS ranked_diagnoses
WHERE row_num = 1;


3.3. Most Common Diagnoses by Age Group and Gender
Purpose: To create a detailed demographic profile of health issues by breaking down diagnoses by custom-created age groups and gender.
SELECT
    CASE
      WHEN age_mid < 18 THEN 'Child (<18)'
      WHEN age_mid BETWEEN 18 AND 35 THEN 'Young Adult (18–35)'
      WHEN age_mid BETWEEN 36 AND 59 THEN 'Adult (36–59)'
      ELSE 'Senior (60+)'
    END AS age_group,
    gender,
    diagnosis,
    COUNT(*) AS diagnosis_count
FROM hospital_records
WHERE age_mid IS NOT NULL
GROUP BY age_group, gender, diagnosis
ORDER BY age_group, gender, diagnosis_count DESC;


4. Hospital Resource Management
These queries analyze the efficiency of key hospital resources like beds and rooms.

4.1. Bed Grade Utilization for Severe Cases
Purpose: To check if the highest-quality beds are being allocated to the patients with the most severe illnesses, ensuring optimal resource allocation.
SELECT
    bed_grade,
    severity_of_illness,
    COUNT(*) AS patient_count
FROM hospital_records
GROUP BY bed_grade, severity_of_illness
ORDER BY bed_grade, severity_of_illness;


4.2. Most Commonly Used Bed Grade per Hospital
Purpose: To identify the default or most-used bed grade at each hospital facility. This uses the MODE() aggregate function, a powerful tool for finding the most frequent value.
SELECT
    hospital_code,
    MODE() WITHIN GROUP (ORDER BY bed_grade) AS most_used_bed_grade
FROM hospital_records
GROUP BY hospital_code;


4.3. Average Available Room Capacity by Hospital
Purpose: To identify which hospitals have more or less surplus room capacity on average.
SELECT
    hospital_code,
    ROUND(AVG(available_extra_rooms_in_hospital), 2) AS avg_available_rooms
FROM hospital_records
GROUP BY hospital_code
ORDER BY avg_available_rooms DESC;


5. Geographic and Admission Analysis
This section explores patterns related to patient location and admission type.

5.1. Cities with the Highest Admission Counts
Purpose: To identify the primary catchment areas for the hospital system by finding which city codes have the most admissions.
SELECT
    city_code_patient,
    COUNT(*) AS admission_count
FROM hospital_records
GROUP BY city_code_patient
ORDER BY admission_count DESC
LIMIT 10;


5.2. Analysis of Emergency and Extreme Cases by City
Purpose: To determine if certain cities have a disproportionately high rate of emergency admissions or extreme severity cases, which is critical for regional emergency preparedness. This query uses the FILTER clause for concise conditional aggregation.
SELECT
  city_code_patient,
  COUNT(*) AS total_admissions,
  COUNT(*) FILTER (WHERE type_of_admission = 'Emergency') * 100.0 / COUNT(*) AS emergency_rate_percent,
  COUNT(*) FILTER (WHERE severity_of_illness = 'Extreme') * 100.0 / COUNT(*) AS extreme_rate_percent
FROM hospital_records
GROUP BY city_code_patient
ORDER BY emergency_rate_percent DESC, extreme_rate_percent DESC;


6. Statistical Correlation Analysis: Visitors and Patient Stay
This advanced analysis uses statistical functions to explore the relationship between patient visitors (as a proxy for social support) and health outcomes.

6.1. Correlation Between Number of Visitors and Length of Stay
Purpose: To investigate if there is a statistical relationship between the number of visitors a patient receives and their length of stay. The analysis is performed overall and then segmented by severity, gender, and age for deeper insight.

-- Overall Correlation
SELECT
    CORR(visitors::NUMERIC, stay_days::NUMERIC) AS overall_correlation_visitors_stay
FROM hospital_records;

-- Correlation by Severity of Illness
SELECT
    severity_of_illness,
    CORR(visitors::NUMERIC, stay_days::NUMERIC) AS correlation_visitors_stay
FROM hospital_records
GROUP BY severity_of_illness;

-- Correlation by Age Group
SELECT
    CASE
      WHEN age_mid < 18 THEN 'Child (<18)'
      WHEN age_mid BETWEEN 18 AND 59 THEN 'Adult (18-59)'
      ELSE 'Senior (60+)'
    END AS age_group,
    CORR(visitors::NUMERIC, stay_days::NUMERIC) AS correlation_visitors_stay
FROM hospital_records
WHERE age_mid IS NOT NULL
GROUP BY age_group;


6.2. Average Number of Visitors by Age Group
Purpose: To determine if social interaction patterns (measured by visitors) differ across a patient's lifespan.
SELECT
    CASE
      WHEN age_mid < 18 THEN 'Child (<18)'
      WHEN age_mid BETWEEN 18 AND 35 THEN 'Young Adult (18–35)'
      WHEN age_mid BETWEEN 36 AND 59 THEN 'Adult (36–59)'
      ELSE 'Senior (60+)'
    END AS age_group,
    ROUND(AVG(visitors), 2) AS avg_visitors
FROM hospital_records
WHERE age_mid IS NOT NULL
GROUP BY age_group
ORDER BY avg_visitors DESC;