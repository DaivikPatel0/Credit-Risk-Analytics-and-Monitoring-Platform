
-- Preview of the Dataset
select * from loan_applications

-- Total rows
select count(*) as total_rows
from loan_applications;

-- Default vs non-default counts
select loan_status, count(*) as cnt
from loan_applications
group by loan_status
order by loan_status;

-- Default rate (Percentage)
select round(100.0*AVG(loan_status), 2)
AS default_rate_pct
FROM loan_applications;

-- Avg intrest rate by grade (Ordered)
select grade, round(avg(interest_rate)::numeric, 2) as avg_interest_rate
from loan_applications
group by grade
order by avg_interest_rate desc;
-- Why did you cast before rounding?
-- ANSWER - PostgreSQL requires numeric type for precision rounding, so I explicitly casted AVG results.

-- 1. Default rate by DTI buckets
select 
case
When debit_to_income < 10 then '00-09'
When debit_to_income < 20 then '10-19'
When debit_to_income < 30 then '20-29'
When debit_to_income < 40 then '30-39'
When debit_to_income < 50 then '40-49'
else '50+'
end as dti_bucket,
count(*) as loans,
round(avg(loan_status)::numeric, 4) as default_rate
from loan_applications
group by dti_bucket
order by dti_bucket;

-- 2. Default rate by delinquency (Past 2years)
select delinquency_two_years, 
count(*) as loans,
round(avg(loan_status)::numeric, 4) as defalut_rate
from loan_applications
group by delinquency_two_years
order by delinquency_two_years;

-- 3. Default rate by inquries (6 months)
select inquires_six_months,
count(*) as loans,
round(avg(loan_status)::numeric, 4) as default_rate
from loan_applications
group by inquires_six_months
order by inquires_six_months;

-- 4. Top 10 risk segments (Grade + Term)
select grade, term,
count (*) as loans,
round(avg(loan_status)::numeric, 4) as default_rate
from loan_applications
group by grade, term
having count(*) >=200
order by default_rate desc
limit 10;

-- 5. Average loan amount by default status
select loan_status,
count(*) as loans,
round(avg(loan_amount)::numeric, 2) as avg_loan_amount
from loan_applications
group by loan_status;

--6. Funding gap by default status
select loan_status,
round(avg(loan_amount - funded_amount)::numeric, 2) as avg_funding_gap
from loan_applications
group by loan_status;

--7. Estimated gross loss by grade
select grade, 
count(*) as defaults,
round(sum(loan_amount)::numeric, 2) as exposure_amount
from loan_applications
where loan_status = 1
group by grade
order by exposure_amount desc;

--8. Net loss estimation (after recoveries)
select grade,
round(sum(loan_amount - recoveries - total_received_interest)::numeric, 2) as estimated_net_loss
from loan_applications
where loan_status = 1
group by grade
order by estimated_net_loss desc;

--9. Recovery effectiveness by grade
select grade,
count(*) as defaulted_loans,
round(avg(recoveries)::numeric, 2) as avg_recovery
from loan_applications
where loan_status = 1
group by grade
order by avg_recovery desc;

--10. High-risk but high-volume segments
select grade, term,
count(*) as loans,
round(avg(loan_status)::numeric, 2) as default_rate
from loan_applications
group by grade, term
having count(*) >= 500
order by default_rate desc;

--11. Default rate by utilization buckets (revolving_utilities)
select
	case
		when revolving_utilities < 20 then '00-19'
		when revolving_utilities < 40 then '20-39'
		when revolving_utilities < 60 then '40-59'
		when revolving_utilities < 80 then '60-79'
		when revolving_utilities < 100 then '80-99'
		else '100+'
	end as utilization_bucket,
	count(*) as loans,
	round(avg(loan_status)::numeric, 4) as defalut_rate
from loan_applications
group by utilization_bucket
order by utilization_bucket;

--12. Default rate by loan purpose (loan_title)
select loan_title,
count(*) as loans,
round(avg(loan_status)::numeric, 4) as default_rate
from loan_applications
group by loan_title
having count(*) >=200
order by default_rate desc;

--13. High-risk rule check: DTI + Delinquency combined
select 
	case when debit_to_income >= 35 then 1 else 0 end as high_dti_flag,
	case when delinquency_two_years >=1 then 1 else 0 end as prior_delinquency_flag,
	count(*) as loans,
	round(avg(loan_status)::numeric, 4) as default_rate
from loan_applications
group by high_dti_flag, prior_delinquency_flag
order by default_rate desc;

--14. Cohort analysis: default rate by batch_enrolled
select batch_enrolled,
count(*) as loans,
round(avg(loan_status)::numeric, 4) as default_rate
from loan_applications
group by batch_enrolled
having count(*) >=300
order by default_rate desc;

--15. Rank top risky segments using window function
with seg as (
	select grade, term,
	count(*) as loans,
	avg(loan_status) as default_rate
	from loan_applications
	group by grade, term
	having count(*) >=200
)
select grade, term, loans,
round(default_rate::numeric, 4) as default_rate,
dense_rank() over (order by default_rate desc) as risk_rank
from seg
order by risk_rank, loans desc
limit 15;

-- View 1: KPI Overview (single-row summary)
create or replace view v_kpi_overview as 
select 
	count(*) as total_loans,
	sum(loan_status) as total_defaults,
	round(avg(loan_status)::numeric, 4) as default_rate,
	round(avg(loan_amount)::numeric, 4) as avg_loan_amount,
	round(avg(interest_rate)::numeric, 4) as avg_interest_rate
from loan_applications;

-- View 2: Risk by Segment (grade + term)
create or replace view v_risk_by_grade_term as
select grade, term,
count(*) as loans,
round(avg(loan_status)::numeric, 4) as default_rate,
round(avg(interest_rate)::numeric, 2) as avg_interest_rate,
round(avg(loan_amount)::numeric, 2) as avg_loan_amount
from loan_applications
group by grade, term
having count(*) >=200;

-- View 3: Loss & Recovery (by grade)
create or replace view v_loss_recovery_by_grade as 
select
	grade,
	count(*) filter (where loan_status = 1) as defaulted_loans,
	round(sum(loan_amount) filter (where loan_status = 1)::numeric, 2) as exposure_amount,
	round(sum(recoveries) filter (where loan_status = 1)::numeric, 2) as total_recoveries,
	round(sum(loan_amount - recoveries - total_received_interest) filter (where loan_status = 1)::numeric, 2) as estimated_net_loss
from loan_applications
group by grade;

-- Verify views exist
Select table_name
from information_schema.views
where table_schema = 'public'
and table_name like 'v_%'
order by table_name;