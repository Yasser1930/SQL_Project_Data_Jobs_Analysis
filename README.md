# 📊 Canadian Machine Learning Job Market Analysis

## 1. Introduction

As a new grad trying to break into the Machine Learning field, I wanted to answer a basic but important question:

> **What does the ML job market in Canada actually look like, based on real data?**

Rather than rely on generic blog posts or job advice, I decided to treat this as a data project:  
use SQL and Python to analyze thousands of real job postings and see:

- Which ML roles pay the most? 
- Which skills keep appearing in those roles?
- Which skills are most demanded overall?
- Which skills are associated with the highest salaries? 
- Where the best trade-off between salary and demand is?

This repository documents that process, from database schema, to SQL queries, to the insights that came out of the analysis.

---

## 2. Project Scope

In this project, I:

- Loaded job posting data into a relational database
- Wrote SQL queries to:
  - Rank ML jobs by salary
  - Link jobs to their required skills
  - Measure skill demand and salary impact
- Exported the results to CSV
- Used Python (Pandas + Matplotlib) to visualize the findings

The focus is specifically on Machine Learning–related roles in Canada with non-null yearly salaries.


---

## 3. 📂 Project Structure
```
SQL_Project_Data_Jobs_Analysis
│
├── csv_files/         # Source tables exported as CSV
│   ├── company_dim.csv
│   ├── job_postings_fact.csv
│   ├── skills_dim.csv
│   └── skills_job_dim.csv
│
├── Project_sql/       # SQL queries used for analysis
│
├── Results/           # Query outputs (CSV)
│
├── Images/            # Visualizations for README
│
├── sql_load/          # PostgreSQL loading scripts  
│
└── README.md
```
---
## 4. Technologies Used

| Tool | Role |
|------|------|
| **SQL** | Data extraction, filtering, joins, aggregations |
| **Python (Pandas, Matplotlib)** | Data manipulation & visualization |
| **PostgreSQL** | Database engine for analysis |
| **VS Code** | Main development environment |
| **Git & GitHub** | Version control & documentation |

---

## 5. Database Schema

The analysis is based on a star-like schema built from a real-world job posting dataset.

📁 Dataset Source (CSV Files):  
🔗 https://drive.google.com/drive/folders/1moeWYoUtUklJO6NJdWo9OV8zWjRn0rjN?usp=sharing

The database tables include:

- `job_postings_fact`  
  - Job postings with salary, title, location, posting date, etc.
- `company_dim`  
  - Company information (name, links, etc.)
- `skills_dim`  
  - Skill names and types (programming language, cloud, library, tool…)
- `skills_job_dim`  
  - Bridge table linking **jobs** to **skills** (many-to-many)


---

## 6. The Analysis

This section is the core of the project. Each subsection corresponds to one main SQL query, its purpose, and the insights obtained.

---

### 6.1 Top Paying ML Job Roles in Canada  

**Question**  
> *What are the highest-paid Machine Learning roles in Canada, and how much do they pay?*

**SQL Query**

```sql
SELECT 
    job_id,
    job_title,
    job_title_short,
    company_dim.name AS company_name,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date
FROM job_postings_fact
LEFT JOIN company_dim 
       ON job_postings_fact.company_id = company_dim.company_id
WHERE job_location LIKE '%Canada%'
  AND job_title      LIKE '%Machine Learning%'
  AND salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 15;
```
---
**What this does**
- Filters jobs to Machine Learning roles in Canada
- Keeps only postings with a yearly salary
- Sorts by salary (highest first)
- Returns the top 15 roles with company, location, and date

**Key findings**
- Principal / Staff / Senior ML Engineers dominate the top of the list.
- The maximum observed salary in this slice is around $225K/year.
- Almost all top roles are full-time and located in major Canadian tech hubs.

**Visualization**

<img src="Images/Salary Across the Top ML Job Roles in Canada.jpg" width="650"/>

---

### 6.2 Skills Required by the Top 15 Highest-Paying ML Jobs  

**Question**  
> *Which technical skills are specifically required for Canada’s highest-paid ML roles?*

**SQL Query**

```sql
WITH top_paying_jobs AS (
    SELECT 
        job_id,
        job_title,
        job_title_short,
        company_dim.name AS company_name,
        salary_year_avg
    FROM job_postings_fact
    LEFT JOIN company_dim 
           ON job_postings_fact.company_id = company_dim.company_id
    WHERE job_location LIKE '%Canada%'
      AND job_title      LIKE '%Machine Learning%'
      AND salary_year_avg IS NOT NULL
    ORDER BY salary_year_avg DESC
    LIMIT 15
)
SELECT
    top_paying_jobs.*,
    skills_dim.skills,
    skills_dim.type AS skill_type
FROM top_paying_jobs
INNER JOIN skills_job_dim 
        ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim 
        ON skills_job_dim.skill_id = skills_dim.skill_id;
```

**Insights**
- Python + Cloud + Deep Learning frameworks form the standard technical stack
- Production knowledge is critical: Linux, Docker, Kubernetes…

**Visualization**

<img src="Images/Skill required by the Top 15 highest-paying ML jobs in Canada.png" width="650"/>

---

### 6.3 Top 15 Most In-Demand ML Skills in Canada  

**Question**  
> *Which skills appear the most often across all Canadian ML job postings?*

**SQL Query**
```sql
SELECT 
    skills_dim.skills,
    COUNT(job_postings_fact.job_id) AS skills_count
FROM job_postings_fact
INNER JOIN skills_job_dim 
        ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim 
        ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title   LIKE '%Machine Learning%'
  AND job_location LIKE '%Canada%'
GROUP BY skills_dim.skills
ORDER BY skills_count DESC
LIMIT 15;
```
**Visualization**

<img src="Images/Top 15 Most In-Demand ML Skills in Canada.png" width="650"/>

---

### 6.4 Top 15 Highest-Paying ML Skills in Canada  

**Question**  
> *Which skills correlate with the best salary?*

**SQL Query**
```sql
SELECT 
    skills_dim.skills,
    ROUND(AVG(job_postings_fact.salary_year_avg), 2) AS average_salary
FROM job_postings_fact
INNER JOIN skills_job_dim 
        ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim 
        ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title       LIKE '%Machine Learning%'
  AND job_location    LIKE '%Canada%'
  AND salary_year_avg IS NOT NULL
GROUP BY skills_dim.skills
ORDER BY average_salary DESC
LIMIT 15;
```
**Visualization**

<img src="Images/Top 15 highest-paying ML skills in Canada.png" width="650"/>

---

### 6.5 Salary vs Demand — Best Market-Fit Skills  

**Question**  
> *Which skills offer both a high salary and strong market demand?*

**SQL Query**
```sql
WITH Skills_demand AS (
    SELECT 
        skills_dim.skill_id,
        skills_dim.skills,
        COUNT(job_postings_fact.job_id) AS skills_count
    FROM job_postings_fact
    INNER JOIN skills_job_dim 
            ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim 
            ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE job_title       LIKE '%Machine Learning%'
      AND job_location    LIKE '%Canada%'
      AND salary_year_avg IS NOT NULL
    GROUP BY skills_dim.skill_id
),
Skills_avg_salary AS (
    SELECT 
        skills_dim.skill_id,
        skills_dim.skills,
        ROUND(AVG(job_postings_fact.salary_year_avg), 2) AS average_salary
    FROM job_postings_fact
    INNER JOIN skills_job_dim 
            ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim 
            ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE job_title       LIKE '%Machine Learning%'
      AND job_location    LIKE '%Canada%'
      AND salary_year_avg IS NOT NULL
    GROUP BY skills_dim.skill_id
)
SELECT
    Skills_demand.skill_id,
    Skills_demand.skills,
    skills_count,
    average_salary
FROM Skills_demand
INNER JOIN Skills_avg_salary 
        ON Skills_demand.skill_id = Skills_avg_salary.skill_id
ORDER BY skills_count DESC
LIMIT 15;
```

**Visualization**

<img src="Images/Salary vs Demand for Top ML Skills in Canada.png" width="650"/>

---

## 7. What I Learned

This project helped me grow both technically and analytically. Some key takeaways include:

### SQL & Data Engineering Skills
- Designing and querying **fact–dimension star schemas**
- Performing advanced JOIN operations across multiple tables
- Using **CTEs (Common Table Expressions)** to improve readability and manage complex logic
- Applying filtering, grouping, aggregation, and ordering to answer real business questions
- Exporting structured query results for downstream analysis

### Analytical Thinking & Problem Framing
- Translating high-level career questions into measurable data points
- Prioritizing what to analyze based on business relevance (salary, demand, skill recurrence)
- Interpreting query results to drive actionable conclusions about the job market

### Data Visualization & Communication
- Using **Pandas** for data manipulation and cleanup after SQL extraction
- Building insightful, presentation-ready charts with **Matplotlib**
- Highlighting key trends and communicating findings clearly for decision-making

### Workflow & Tooling
- Managing datasets and scripts with **GitHub** and clean repository structure
- Using **PostgreSQL** for real analytical workloads
- Practicing reproducibility through documented queries and generated outputs

---

Overall, this project improved my confidence in working end-to-end with data:  
**from database tables → SQL transformation → Python visuals → real insights.**


---

## 8. Conclusion

The data makes one thing very clear:

> **The highest-paying ML roles in Canada require strong engineering + cloud skills, not just ML theory.**

To be competitive in the ML job market:
- Master **Python**
- Gain experience with **Deep Learning frameworks** (PyTorch, TensorFlow)
- Learn **Cloud technologies** (AWS, Azure, GCP)
- Build **software & production ML skills** (Docker, SQL, Linux)

### Closing Thoughts
This project sharpened my SQL and analytical thinking while uncovering what truly matters in the ML job market. By focusing on the most demanded and best-paid skills, candidates can make smarter decisions about where to grow and how to stand out in a competitive industry.

---

## 9. ▶️ How to Reproduce

### Run SQL Analysis
1. Load CSV files into PostgreSQL
2. Execute queries from `/Project_sql/`
3. Export results into `/Results/`


---