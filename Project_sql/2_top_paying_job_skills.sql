

WITH top_paying_jobs AS (

select 
    job_id,
    job_title,
    job_title_short,
    company_dim.name as company_name,
    salary_year_avg

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

LIMIT 15
)

select
    top_paying_jobs.* ,
    skills_dim.skills,
    skills_dim.type as skill_type

from top_paying_jobs

Inner JOIN skills_job_dim on top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim on skills_job_dim.skill_id = skills_dim.skill_id

