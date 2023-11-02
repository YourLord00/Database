USE `crime_db2023khan`;
-- 4. For each calendar day in the database, generate the number of crime incidents that occurred on that day. The result should contain the calendar day and the count of the crimes. Rename the count of the crimes to num_crimes. Return the results ordered by the incident date in ascending order. (5 points)
-- Question 4: 
SELECT 
	DATE(incident_date) AS calender_day, 
    COUNT(incident_number) AS num_crimes 
FROM 
	incidents 
GROUP BY 
	DATE(incident_date)
ORDER BY 
	calender_day ASC; 

-- 5. Which street had the most number of crime incidents? Return the street name and the number of incidents. (5 points)
SELECT 
    street,
    COUNT(incident_number) AS num_incidents
FROM 
    incidents 
GROUP BY 
    street
ORDER BY 
    num_incidents DESC
LIMIT 1;

-- What is the maximum number of crimes that could have occurred in the North End during the specific time period? Return the number  (5 points)
-- Q6.
Select count(incident_number) as number_of_crimes from incidents as inci
join neighborhoods as ns on ns.district_code = inci.district

where ns.neighborhood_name = 'North End';

-- Q7.How many crimes occurred in Hyde Park? Return the number. (5 points)
Select count(incident_number) as number_of_crimes from incidents as inci
join neighborhoods as ns on ns.district_code = inci.district

where ns.neighborhood_name = 'Hyde Park';
-- Q8.Report on all rapes that occurred during the time period. Return the crime code, the incident date and the district. Order the results by date, then by district.  (5 points)
Select crime_code, incident_date, district from offense_codes as oc
join incidents as inci on inci.offense_code = oc.crime_code
where oc.name = '%rapes';

-- Q9
Select oc.crime_code, oc.name, coalesce( count(*),0 )as num_occurences from offense_codes as oc
left join incidents as inci on inci.offense_code = oc.crime_code
group by oc.crime_code,oc.name
order by num_occurences desc;

-- Q10
Select district_code, district_name, count(incident_number) as num_crimes from districts as d
join incidents as i on d.district_code = i.district
group by district_code, district_name
order by num_crimes desc;

-- Q11
Select crime_code, coalesce(count(distinct district ),0)  as num_districts from offense_codes as o
left join incidents as i on i.offense_code = o.crime_code
group by crime_code
ORDER BY num_districts DESC;

-- Q12
Select i.incident_number, d.district_name,o.name, incident_date from incidents as i
join districts as d on d.district_code = i.district
join offense_codes as o on o.crime_code = i.offense_code
where incident_date between '2022-12-25' AND '2022-12-28'
order by (incident_date) asc;

-- Q13 
With crimeCount as(
	select d.district_name, o.name, count(incident_number) as number_of_incidents from incidents as i
    join offense_codes as o on o.crime_code = i.offense_code
    join districts as d on d.district_code = i.district
    group by i.district, o.name
	),
maxCrimeCount as(
	Select district_name, Max(number_of_incidents) as number_of_incidents from crimeCount
    group by district_name
)
Select mcc.district_name,c.name, mcc.number_of_incidents from maxCrimeCount as mcc
join  crimeCount as c on c.number_of_incidents=mcc.number_of_incidents and c.district_name =mcc.district_name
ORDER BY 
	c.number_of_incidents DESC;

-- Q14
Select o.name AS crime_description, group_concat(DISTINCT d.district_name) as district, count(i.incident_number) as num_crimes from incidents as i
join offense_codes as o on o.crime_code = i.offense_code
join districts as d on d.district_code = i.district
group by o.name
order by num_crimes desc;

-- Q15
select i_hour, count(incident_number) from incidents
where i_hour between 18 and 24
group by i_hour
order by i_hour asc;

-- Q16
select i_day_of_week, count(incident_number) from incidents
group by i_day_of_week
order by i_day_of_week asc;

-- Q17
Select AVG(daily_crimes) AS average_crimes_per_day
From(
	Select DATE(incident_date) calender_day, count(incident_number) daily_crimes from incidents
    group by DATE(incident_date)
) as daily_count_crime;

-- Q18
SELECT o.crime_code, o.name from offense_codes o
where o.crime_code not in( select offense_code from incidents);









