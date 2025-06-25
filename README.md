# Healthcare Operations Analytics: A Deep Dive into Hospital Admission Data
### Project by: [kHADIJA MBWANA]

## Project Objective
The primary goal of this project is to analyze an hospital admissions dataset to uncover insights that can help optimize hospital operations, reduce costs, and improve patient outcomes. By using SQL for data querying,excel for data cleaning and Power BI for visualization, this analysis addresses critical business questions related to length of stay, resource utilization, and patient demographics.

---

## Key Business Questions Explored

This analysis was structured to answer the following core questions:

### 1. Analysis of Hospital Length of Stay (LoS)
*To reduce costs and minimize patient risk of hospital-acquired infections, we need to understand what drives the length of stay.*
*   **1.1:** What is the average length of stay (LoS) for patients, and how does it differ across various hospital departments and admission types?
*   **1.2:** How does the severity of a patient's illness directly impact their length of stay?
*   **1.3:** Which specific departments experience the longest average patient stays, signaling potential areas for process improvement?

### 2. Bed and Resource Utilization Analysis
*Hospital beds, especially specialized ones, are expensive and critical assets. This analysis seeks to ensure they are being used effectively.*
*   **2.1:** Are high-grade, specialized beds being appropriately allocated to patients with the most severe conditions?
*   **2.2:** Is there evidence of some hospitals consistently operating at or over capacity, while others have available beds?
*   **2.3:** What is the utilization rate for different bed types, and can we identify opportunities for better load-balancing across the hospital network?

### 3. Patient Demographics and Diagnosis Patterns
*Understanding our patient population is key for strategic planning, including staff specialization and community health initiatives.*
*   **3.1:** What are the top 10 most frequent diagnoses among admitted patients?
*   **3.2:** How does the prevalence of the most common diagnoses vary by patient age group and gender?
*   **3.3:** What insights can be drawn from these demographic patterns to guide resource allocation and staff training?

### 4. Geographical Analysis of Admissions and Severity
*This analysis investigates geographical patterns to identify potential public health hotspots and guide targeted outreach.*
*   **4.1:** Which city codes are the source of the highest number of patient admissions?
*   **4.2:** Do any specific city codes show a disproportionately high number of emergency admissions or cases with 'Extreme' severity?
*   **4.3:** Could these geographical clusters indicate underlying environmental factors, localized outbreaks, or gaps in primary care access that warrant public health intervention?

---

## Interactive Dashboard

An interactive dashboard was created in Power BI to explore these findings visually. It allows users to filter data by hospital, department, demographics, and more to uncover deeper insights.

## 📸 Dashboard Preview

![My Healthcare Dashboard](./assets/hospital_dashboard.png)

*You can view the full interactive dashboard here:*
**[Link to your published Power BI dashboard]**

---

## Key Findings & Insights

*   **Insight 1:** The primary driver for Length of Stay is the **Severity of Illness**. Patients with 'Extreme' severity stay, on average(35.43)longer than those with 'Minor' and 'moderate' severity.
*   **Insight 2:**  bed grade 2 was found most commonly used across all severity of illness.
*   **Insight 3:** The most common diagnosis is **depression and axiety disorder**, which disproportionately affects **males over 60]**.
*   **Insight 4:** **City Code 8** has a higher number of admission(124,011)hence indicating a critical area for public health outreach.

---

## Actionable Recommendations
1.  **Implement Proactive Discharge Planning:** For patients admitted with 'Extreme' or 'Severe' illness to streamline their transition and reduce Loss.
2.  **Establish a Patient Transfer Protocol:** Create a formal system to move patients from over-capacity hospitals (like Hospital code 26) to those with available beds.
3.  **Launch a Targeted Health Campaign:** Focus community health efforts on **city code 8** in areas with a high prevalence of **coronary artery disease**.

---

## Tools Used
*   **Data extraction and Querying:** sql(postgreSQL)
*   **Data cleaning:** excel
*   **Data Visualization and dashboard creation:** Power BI

##Data Analysis & SQL Logic
## 📊 Analysis: Impact of Illness Severity and Admission Type on Stay Duration

### 🧠 Purpose
This analysis explores how the **severity of illness** and **type of hospital admission** affect the **average hospital stay**. This insight can help hospital management plan resources better and improve patient flow.

---

### 💻 SQL Query

```sql
-- How severity of illness and type of admission impact stay
SELECT
  severity_of_illness,
  type_of_admission,
  COUNT(*) AS total_patient,
  ROUND(AVG(stay_days), 2) AS avg_stay
FROM hospital_records
GROUP BY severity_of_illness, type_of_admission
ORDER BY avg_stay DESC;
```

---

### 📌 Sample Output (Mock Data)

| Severity of Illness | Type of Admission | Total Patients | Avg Stay (days) |
|---------------------|-------------------|----------------|---------------|
| Extreme             | Trauma            | 28837          | 35.43         |
| Extreme             | Emergency         | 19844          | 35.22         |
| Moderate            | Trauma            | 86624          | 34.58         |

---

### ✅ Key Insights
- Patients with **Extreme** severity and **Trauma** admissions stay the longest on average.
- This helps highlight areas for optimizing patient care and bed utilization.

---

### 📁 Dataset
- `hospital_records` contains fields like:
  - `severity_of_illness`
  - `type_of_admission`
  - `stay_days`

The SQL scripts used for data cleaning, transformation, and analysis for this project can be found in this repository.
