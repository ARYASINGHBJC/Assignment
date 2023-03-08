-- TASK 1
select * from hr_employee;
alter table hr_employee add primary key(EmployeeID);
describe hr_employee;

-- TASK 2
select count(*) as rowCount, (SELECT count(*)
FROM information_schema.columns
WHERE table_name = 'hr_Employee') as colCount from hr_employee;

-- TASK 3
/* select max(EmployeeID) from hr_employee; */
select Department, count(EmployeeID), (count(*)/max(EmployeeID)*100, '%') as WorkforcePercentage 
from hr_employee group by Department;

-- TASK 4
SELECT Department, 
       CASE WHEN COUNT(CASE WHEN Gender = 'Male' THEN 1 END) > COUNT(CASE WHEN Gender = 'Female' THEN 1 END) THEN 'Male'
            ELSE 'Female' END AS Higher_Workforce_Gender
FROM hr_employee
GROUP BY Department;

-- SELECT department, gender, (count(*)/max(EmployeeID)*100) as workforce
-- FROM hr_employee
-- GROUP BY gender,department;

-- TASK 5
select count(*) as workforce, JobRole from hr_employee group by JobRole;

-- TASK 6
select count(Age), if(Age > 40, 'Senior', if (Age < 20, 'New Joinee', 'Mid-Senior')) as Age_group from hr_employee group by Age_group;

-- TASK 7
select MaritalStatus, count(MaritalStatus) as mostFrequent from hr_employee group by MaritalStatus order by mostFrequent desc limit 1;


-- TASK 8
select concat(count(*)/max(EmployeeID)*100, '%') as empPercentage, JobSatisfaction from hr_employee group by JobSatisfaction;

-- TASK 9
select count(*) as freqCount, BusinessTravel from hr_employee group by BusinessTravel order by freqCount;

-- TASK 10

-- select department from (SELECT department, 
--        ROUND(COUNT(CASE WHEN Attrition like 'YES' THEN 1 END) / COUNT(*) * 100, 2) AS attrition_rate 
-- FROM hr_employee 
-- GROUP BY department 
-- order by attrition_rate desc limit 1) as t;

SELECT Department, 
       COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*) AS AttritionRate
FROM hr_employee
GROUP BY Department
ORDER BY AttritionRate DESC
LIMIT 1;

-- TASK 11
select JobRole from (SELECT JobRole, 
       ROUND(COUNT(CASE WHEN Attrition like 'YES' THEN 1 END) / COUNT(*) * 100, 2) AS attrition_rate 
FROM hr_employee 
GROUP BY JobRole
order by attrition_rate desc limit 1) as t;

-- TASK 12
SELECT CASE WHEN YearsSinceLastPromotion >= 2 AND joblevel <= 2 THEN 'high'
            WHEN YearsSinceLastPromotion >= 5 AND joblevel <= 5 THEN 'medium'
            ELSE 'low'
       END AS chanceOfPromotion,
       COUNT(*) AS numOfEmployees,
       ROUND(COUNT(*) / (SELECT COUNT(*) FROM hr_employee) * 100, 2) AS promotionRate
FROM hr_employee
GROUP BY chanceOfPromotion
ORDER BY numOfEmployees;


-- TASK 13

SELECT MaritalStatus, 
       COUNT(*) AS TotalEmployees, 
       SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritedEmployees,
       ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS AttritionRate
FROM hr_employee
GROUP BY MaritalStatus;


-- TASK 14
SELECT Education, COUNT(*) AS AttritionCount, 
ROUND((COUNT(*)/(SELECT COUNT(*) FROM hr_employee))*100,2) AS AttritionPercentage 
FROM hr_employee
WHERE Attrition = 'Yes' 
GROUP BY Education;

-- TASK 15
SELECT BusinessTravel, COUNT(*) AS AttritionCount, 
ROUND((COUNT(*)/(SELECT COUNT(*) FROM hr_employee))*100,2) AS AttritionPercentage 
FROM hr_employee
WHERE Attrition = 'Yes' 
GROUP BY BusinessTravel;

-- TASK 16
select JobInvolvement, ROUND(COUNT(*) / (SELECT COUNT(*) FROM hr_employee) * 100, 2) AS JobInvovlement_rate, count(JobInvolvement) as workforceCount
from hr_employee where Attrition like 'YES'group by JobInvolvement;

-- TASK 17
SELECT JobSatisfaction, 
       COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) AS AttritionCount,
       COUNT(*) AS TotalCount,
       ROUND(COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*), 2) AS AttritionPercentage
FROM hr_employee
GROUP BY JobSatisfaction;


-- TASK 18

select Income,MaritalStatus, JobSatisfaction, WorkLifeBalance,YearsSinceLastPromotion from 
(select avg(Income) as avg_income from hr_employee) avg_derived_table ,hr_employee
 where (Income > avg_derived_table.avg_income or MaritalStatus = 'Single' 
 or JobSatisfaction = 'Low' or WorkLifeBalance = 'Bad' or YearsSinceLastPromotion < 5) and Attrition like 'Yes';


-- TASK 19
select * from hr_employee 
where Workex > 10 and BusinessTravel = 'Travel_Frequently' 
and WorkLifeBalance = 'Good' and JobSatisfaction = 'Very High';

-- TASK 20
select MaritalStatus, count(*) as empCount from hr_employee where 
Performance_Rating Like 'Out%' and WorkLifeBalance like 'Better' group by MaritalStatus;

