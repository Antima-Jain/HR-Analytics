USE hrdb;
SELECT * FROM employees;
SELECT * FROM departments;

-- Updating phone_number column
UPDATE employees SET phone_number = REPLACE(phone_number,".","-");

-- Years of joining of employee
SELECT *,floor(datediff(curdate(),hire_date)/365) AS Years_of_Joining FROM employees;

-- Employees having salaries greater than average salary
SELECT * FROM employees WHERE salary>(SELECT AVG(salary) FROM employees) ORDER BY salary DESC;

-- Employees having no manager
SELECT employee_id, first_name, last_name FROM employees WHERE manager_id IS NULL;

-- Maximum salary by department
SELECT e.*,
max(salary) OVER (PARTITION BY department_id) AS max_salary
FROM employees e;

-- Second highest salary
SELECT salary AS second_highest_salary 
FROM employees GROUP BY employee_id HAVING salary<(SELECT max(salary) FROM employees) LIMIT 1;

-- Fetching department name
SELECT e.*, d.department_name 
FROM employees AS e
LEFT JOIN departments AS d
ON e.department_id=d.department_id;

-- Fetching employee-manager details
SELECT e.employee_id, concat(e.first_name," ",e.last_name) AS employee_name, concat(m.first_name," ",m.last_name) AS manager_name,
e.salary AS emp_salary, m.salary AS manager_salary
FROM employees e
JOIN employees m 
ON m.employee_id=e.manager_id;

-- Top 2 salaries by department
SELECT * FROM (
SELECT e.*,
RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rnk
FROM employees e) AS x
WHERE x.rnk<3;

-- Department with maximum average salary
WITH cte1 AS (
SELECT department_id, AVG(salary) AS avg_salary
FROM employees GROUP BY department_id)
SELECT department_id, round(max(avg_salary),2) AS Max_Avg_Salary FROM cte1;

-- Median of salary
WITH cte2 AS (SELECT *,
ROW_NUMBER() OVER (ORDER BY salary) AS rn_asc,
ROW_NUMBER() OVER (ORDER BY salary DESC) AS rn_desc
FROM employees)
SELECT round(AVG(salary),2) AS Median_Salary FROM cte2 WHERE abs(rn_asc-rn_desc)<=1;

-- Previous and next employee salary
SELECT e.*,
LAG(salary) OVER (PARTITION BY department_id ORDER BY employee_id) AS previous_emp_salary,
LEAD(salary) OVER (PARTITION BY department_id ORDER BY employee_id) AS next_emp_salary
FROM employees e;

-- Comparison with previous employee salary
SELECT e.*,
LAG(salary) OVER (PARTITION BY department_id ORDER BY employee_id) AS previous_emp_salary,
CASE WHEN e.salary > LAG(salary) OVER (PARTITION BY department_id ORDER BY employee_id) THEN 'Higher than previous employee'
     WHEN e.salary < LAG(salary) OVER (PARTITION BY department_id ORDER BY employee_id) THEN 'Lower than previous employee'
     WHEN e.salary = LAG(salary) OVER (PARTITION BY department_id ORDER BY employee_id) THEN 'Higher than previous employee'
     END salary_range
FROM employees e;








