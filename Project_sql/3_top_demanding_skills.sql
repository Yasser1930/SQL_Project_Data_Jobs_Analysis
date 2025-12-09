select 
    skills_dim.skills,
    count(job_postings_fact.job_id) as Skills_count
from job_postings_fact
inner JOIN skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
inner JOIN skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
where 
    job_title like '%Machine Learning%'
and 
    job_location like '%Canada%'
GROUP BY skills_dim.skills
order BY Skills_count DESC
LIMIT 15;