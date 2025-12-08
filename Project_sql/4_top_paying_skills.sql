
select 
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

GROUP BY skills_dim.skills

order BY average_salary DESC

LIMIT 15;

