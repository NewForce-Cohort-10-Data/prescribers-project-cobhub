-- 1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
-- Bruce Pendley

select count (p1.npi),
p1.npi,
sum(total_claim_count) as total_claims
from prescriber as p1
inner join prescription
using(npi)
group by p1.npi
order by total_claims desc;

-- 1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.

select nppes_provider_first_name,
nppes_provider_last_org_name,
specialty_description,
sum(total_claim_count) as total_claims
from prescriber
inner join prescription
using(npi)
group by nppes_provider_first_name,
nppes_provider_last_org_name,
specialty_description
order by total_claims desc;

-- 2a. Which specialty had the most total number of claims (totaled over all drugs)?
--Family Practice had the most claims (9,752,347)

select specialty_description,
sum(total_claim_count) as total_claims
from prescriber
inner join prescription
using(npi)
group by specialty_description
order by total_claims desc;

-- 2b. Which specialty had the most total number of claims for opioids?
-- Nurse Practitioner had the most claims (900,845)

select specialty_description,
opioid_drug_flag,
sum(total_claim_count) as total_claims
from prescriber as p1
inner join prescription as p2
using(npi)
inner join drug as d
on p2.drug_name = d.drug_name
where opioid_drug_flag = 'Y'
group by specialty_description,
opioid_drug_flag
order by total_claims desc;

select*
from drug;
select*
from prescription;
select*
from prescriber;

select sum(p1.total_drug_cost) as total_drug_cost
from prescription as p1
join prescriber as p2
using (npi)
join drug as d
using (drug_name)
where p2.specialty_description = 'Nurse Practitioner'
and d.opioid_drug_flag = 'Y';

-- 2c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
-- "Chiropractic"
-- "Specialist/Technologist, Other"
-- "Occupational Therapist in Private Practice"
-- "Licensed Practical Nurse"
-- "Midwife"
-- "Medical Genetics"
-- "Physical Therapy Assistant"
-- "Ambulatory Surgical Center"
-- "Undefined Physician type"

select specialty_description
from prescriber
except
select specialty_description
from prescriber as p1
join prescription as p2
using(npi)
join drug as d
on p2.drug_name = d.drug_name;

-- 2d. Difficult Bonus: Do not attempt until you have solved all other problems!
-- For each specialty, report the percentage of total claims by that specialty which are for opioids.
-- Which specialties have a high percentage of opioids?


WITH opioids AS (
	select specialty_description,
sum(total_claim_count) as total_opioid_claims,
p2.drug_name as drug_name
from prescriber as p1
inner join prescription as p2
using(npi)
inner join drug as d
on p2.drug_name = d.drug_name
where opioid_drug_flag = 'Y'
group by specialty_description,
p2.drug_name
order by total_opioid_claims desc
	)
SELECT specialty_description,
	ROUND((COUNT(opioids.drug_name)/SUM(total_claim_count)*100), 2) AS opioid_percent
FROM prescriber
JOIN prescription
USING (npi)
JOIN opioids
USING (specialty_description)
GROUP BY specialty_description
ORDER BY opioid_percent DESC;


-- WITH opioids AS (
-- 	SELECT drug_name
-- 	FROM drug
-- 	WHERE opioid_drug_flag = 'Y'
-- 	)
-- SELECT specialty_description,
-- 	ROUND((COUNT(opioids.drug_name)/SUM(total_claim_count)*100), 2) AS opioid_percent
-- FROM prescriber
-- JOIN prescription
-- USING (npi)
-- JOIN opioids
-- USING (drug_name)
-- GROUP BY specialty_description
-- ORDER BY opioid_percent DESC;


-- with opioid_claims as (
-- select specialty_description,
-- sum(total_claim_count) as total_opioid_claims
-- from prescriber as p1
-- inner join prescription as p2
-- using(npi)
-- inner join drug as d
-- on p2.drug_name = d.drug_name
-- where opioid_drug_flag = 'Y'
-- group by specialty_description,
-- opioid_drug_flag
-- order by total_opioid_claims desc
-- )
-- select specialty_description,
-- sum(p2.total_claim_count) as total_claims,
-- o.total_opioid_claims,
-- (o.total_opioid_claims/sum(total_claim_count)) as percentage
-- from prescriber as p1
-- inner join prescription as p2
-- using(npi)
-- inner join opioid_claims as o
-- using(specialty_description)
-- inner join drug as d
-- on p2.drug_name = d.drug_name
-- where opioid_drug_flag = 'Y'
-- group by specialty_description,p2.total_claim_count,o.total_opioid_claims





-- select*
-- from prescriber;
-- select*
-- from prescription;
-- select*
-- from drug;






-- 3a. Which drug (generic_name) had the highest total drug cost?
-- INSULIN GLARGINE,HUM.REC.ANLOG at $149,257,897.75

select generic_name,
sum(total_drug_cost) + sum(total_drug_cost_ge65) as sum_of_drug_cost
from drug
join prescription
using (drug_name)
group by generic_name
having sum(total_drug_cost) + sum(total_drug_cost_ge65) is not null
order by sum_of_drug_cost desc;

-- 3b. Which drug (generic_name) has the hightest total cost per day?
-- CHENODIOL at $86,741.13 

select generic_name,
sum(total_drug_cost) + sum(total_drug_cost_ge65) as sum_of_drug_cost,
sum(total_30_day_fill_count) + sum(total_30_day_fill_count_ge65) as fill_count,
(sum(total_drug_cost) + sum(total_drug_cost_ge65))/(sum(total_30_day_fill_count) + sum(total_30_day_fill_count_ge65)) as cost_per_day
from drug
join prescription
using (drug_name)
group by generic_name
having sum(total_drug_cost) + sum(total_drug_cost_ge65) is not null
and sum(total_30_day_fill_count) + sum(total_30_day_fill_count_ge65) is not null
order by cost_per_day desc;

-- 3c. Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.

select generic_name,
sum(total_drug_cost) + sum(total_drug_cost_ge65) as sum_of_drug_cost,
sum(total_30_day_fill_count) + sum(total_30_day_fill_count_ge65) as fill_count,
round((sum(total_drug_cost) + sum(total_drug_cost_ge65))/(sum(total_30_day_fill_count) + sum(total_30_day_fill_count_ge65)),2) as cost_per_day
from drug
join prescription
using (drug_name)
group by generic_name
having sum(total_drug_cost) + sum(total_drug_cost_ge65) is not null
and sum(total_30_day_fill_count) + sum(total_30_day_fill_count_ge65) is not null
order by cost_per_day desc;

-- 4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y',
--says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says
--'neither' for all other drugs.
--Hint: You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/

select drug_name,
case when opioid_drug_flag = 'Y' then 'opioid'
when antibiotic_drug_flag = 'Y' then 'antibiotic'
else 'neither'
end as drug_type
from drug;

-- 4b. Building off of the query you wrote for part a, determine whether
--more was spent (total_drug_cost) on opioids or on antibiotics.
--Hint: Format the total costs as MONEY for easier comparision.
--More was spent on opioids at $105,080,626.37

select 
case when opioid_drug_flag = 'Y' then 'opioid'
when antibiotic_drug_flag = 'Y' then 'antibiotic'
else 'neither'
end as drug_type,
sum(total_drug_cost) as total_cost
from drug
join prescription
using(drug_name)
group by drug_type
order by total_cost desc;

-- 5a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.
-- 58

select sum(count_rows) as total_count
from(
select cbsa,
cbsaname,
count(*) as count_rows
from cbsa
where cbsaname ILIKE '%tn%'
group by cbsa, cbsaname)
as tn_cbsa;

-- 5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
-- Nashville-Davidson--Murfreesboro--Franklin, TN has the largest at 1,830,410 and Morristown, TN has the smallest at 116,352

select cbsaname, sum(population) as combined_pop
from cbsa
join population
using(fipscounty)
group by cbsaname
order by combined_pop desc;

-- 5c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
-- Sevier county at 95,523 people

select county, state,population, cbsa
from fips_county
left join population
using(fipscounty)
left join cbsa
using(fipscounty)
where cbsa IS NULL
and population IS NOT NULL
group by fipscounty, county, state,population, cbsa
order by population desc;

--6a. Find all rows in the prescription table where total_claims is at least 3000.
--Report the drug_name and the total_claim_count.

select drug_name, sum(total_claim_count) as total_claim_count
from drug
join prescription
using(drug_name)
where total_claim_count >=3000
group by drug_name;

--6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

select drug_name, sum(total_claim_count) as total_claim_count,
case when opioid_drug_flag = 'Y' then 'opioid'
else 'not opioid'
end as drug_type
from drug
join prescription
using(drug_name)
where total_claim_count >=3000
group by drug_name, opioid_drug_flag;

--6c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

select nppes_provider_first_name, nppes_provider_last_org_name,drug_name, sum(total_claim_count) as total_claim_count,
case when opioid_drug_flag = 'Y' then 'opioid'
else 'not opioid'
end as drug_type
from prescription
join drug
using(drug_name)
join prescriber
using (npi)
where total_claim_count >=3000
group by drug_name,
opioid_drug_flag,
nppes_provider_first_name,
nppes_provider_last_org_name,
drug_name;

-- The goal of this exercise is to generate a full list of all pain management specialists
--in Nashville and the number of claims they had for each opioid.
--Hint: The results from all 3 parts will have 637 rows.

-- 7a. First, create a list of all npi/drug_name combinations for pain management
--specialists (specialty_description = 'Pain Management) in the city of Nashville
--(nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y').
--Warning: Double-check your query before running it. You will only need to use the prescriber and
--drug tables since you don't need the claims numbers yet.

select p.npi, d.drug_name
from prescriber as p
cross join drug as d
where p.specialty_description = 'Pain Management'
and p.nppes_provider_city = 'NASHVILLE'
and d.opioid_drug_flag = 'Y';

-- 7b. Next, report the number of claims per drug per prescriber.
--Be sure to include all combinations, whether or not the prescriber had
--any claims. You should report the npi, the drug name,
--and the number of claims (total_claim_count).

with pain_management_specialists as (
select p.npi, d.drug_name
from prescriber as p
cross join drug as d
where p.specialty_description = 'Pain Management'
and p.nppes_provider_city = 'NASHVILLE'
and d.opioid_drug_flag = 'Y'
)
select pain_management_specialists.npi, pain_management_specialists.drug_name, total_claim_count
from pain_management_specialists
left join prescription
using(npi, drug_name);

-- 7c. Finally, if you have not done so already, fill in any missing values
--for total_claim_count with 0. Hint - Google the COALESCE function.

with pain_management_specialists as (
select p.npi, d.drug_name
from prescriber as p
cross join drug as d
where p.specialty_description = 'Pain Management'
and p.nppes_provider_city = 'NASHVILLE'
and d.opioid_drug_flag = 'Y'
)
select pain_management_specialists.npi,
pain_management_specialists.drug_name,
coalesce(p.total_claim_count, 0) as total_claim_count
from pain_management_specialists
left join prescription as p
using(npi, drug_name);