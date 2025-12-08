/*
Purpose:
    Retrieve the top 15 Data Analyst job postings in Canada by average yearly salary.

Inputs:
    - job_postings_fact:
            job_id, job_title, job_title_short, company_id, job_location,
            job_schedule_type, salary_year_avg, job_posted_date
    - company_dim:
            company_id, name (joined to provide company_name)
Parameters / Filters:
    - job_location LIKE '%Canada%'
    - job_title_short LIKE '%Data Analyst%'
    - salary_year_avg IS NOT NULL

Main operations:
    - LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    - Filter by location and title substring and non-null salary
    - ORDER BY salary_year_avg DESC
    - LIMIT 15

Output:
    - job_id: identifier of the job posting
    - job_title: full job title
    - job_title_short: normalized/short title used for filtering
    - company_name: company_dim.name (NULL if no match)
    - job_location: location string (contains 'Canada')
    - job_schedule_type: e.g., full-time/part-time/contract
    - salary_year_avg: average yearly salary (used for ranking)
    - job_posted_date: date the job was posted
*/

select 
    job_id,
    job_title,
    job_title_short,
    company_dim.name as company_name,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date

from 
    job_postings_fact

left join company_dim on job_postings_fact.company_id = company_dim.company_id

where 
    job_location like '%Canada%' 
and 
    job_title like '%Machine Learning%'
and 
    salary_year_avg is not null 

 ORDER BY salary_year_avg DESC

LIMIT 15;   