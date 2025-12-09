With Skills_demand as (
select 
    skills_dim.skill_id,
    skills_dim.skills,
    count(job_postings_fact.job_id) as Skills_count
from job_postings_fact

inner JOIN skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
inner JOIN skills_dim on skills_job_dim.skill_id = skills_dim.skill_id

where 
    job_title like '%Machine Learning%'
and 
    job_location like '%Canada%'
AND 
    salary_year_avg IS NOT NULL

GROUP BY skills_dim.skill_id
),

Skills_avg_Salary as (
select 
    skills_dim.skill_id,
    skills_dim.skills,
    round (avg (job_postings_fact.salary_year_avg), 2) as average_salary
from job_postings_fact

inner JOIN skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
inner JOIN skills_dim on skills_job_dim.skill_id = skills_dim.skill_id

where 
    job_title like '%Machine Learning%'
and 
    job_location like '%Canada%'
AND 
    salary_year_avg IS NOT NULL

GROUP BY skills_dim.skill_id
)

select
    Skills_demand.skill_id,
    Skills_demand.skills,
    Skills_count,
    average_salary
from 
    Skills_demand
inner join Skills_avg_Salary on Skills_demand.skill_id = Skills_avg_Salary.skill_id

order BY Skills_count DESC
LIMIT 15;