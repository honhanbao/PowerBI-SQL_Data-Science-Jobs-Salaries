
-- Task 1: Top 10 popular job title -- 

-- Create 2 tables:
	-- One table of job title frequency
	-- One table of job frequency of top 10 popular job title

-- show top 50 rows--
	Select 
		top 50 * 
	from salaries;

-- show column of unique job title --
	Select 
		distinct job_title 
	from salaries;

-- show job titles with counts in descending order--
	Select 
		job_title as 'Job Title',
		count(*) as Count
	from salaries
	group by job_title
	order by count desc

-- save into tempt as #job_count -- 
	Select 
		job_title 'Job Title',
		count(*) Count
	into #job_count
	from salaries
	group by job_title
	order by count desc

-- show #job_count --
	Select * 
	from #job_count
	order by count desc;

	-- create table job_title_frequency --
	Create table job_title_frequency (
		job_title	char(50),
		counts		int
	);

	Insert into job_title_frequency 
	select * 
	from #job_count
	order by count desc;
	
	Select * from job_title_frequency;

-- show top 10 most popular job titles with counts in descending order--
	Select 
		top 10 * 
	from #job_count
	order by count desc;

-- create table of 10 popular_titles --
	Create table popular_job_titles (
		job_title	char(50),
		counts		int
	);

	Insert into popular_job_titles 
	select 
		top 10 * 
	from #job_count
	order by count desc;

	Select * from popular_job_titles;


-- Task 2: Top 10 highest paid job titles in average -- 

	-- drop if exit --
	IF OBJECT_ID('tempdb..#average_salary') IS NOT NULL
	BEGIN
	   EXEC('DROP TABLE #experience_average_salary;');
	END

	-- show average salary of job title in desc order -- 
	-- save into tempt --
	Select 
		job_title 'Job Title',
		ceiling(avg(salary_in_usd)) 'Average Salary'
	into #average_salary
	from salaries
	group by job_title

	-- show --
	select * 
	from #average_salary
	order by 'Average Salary' desc;

	-- top 10 --
	Select 
		top 10 * 
	from #average_salary
	order by 'Average Salary' desc;

	-- create table average_salary --
	Create table average_salary (
		job_title char(50),
		average_salary decimal(10, 2)
	);

	Insert into average_salary
	select 
		top 10 * 
	from #average_salary
	order by 'Average Salary' desc;

	select * from average_salary;


-- Task 3: Average salary of levels of jobs with more than 50 posts --

	-- show all job title order by Job Title, Experience, Salary --
	Select 
		job_title 'Job Title',
		experience_level Experience,
		salary_in_usd Salary
	from salaries
		order by 'Job Title', 
		case experience_level
			when 'EN' then 1
			when 'MI' then 2
			when 'SE' then 3
			when 'EX' then 4
			else 5
		end,
		Salary;
	
	-- show all job title order by Job Title, Experience, Average Salary by experience level --

	-- delete if exist --
	If object_id('tempdb..#experience_average_salary') is not null
		begin
		   exec('DROP TABLE #experience_average_salary;');
		end

	-- save into #experience_average_salary --
	Select 
		job_title 'Job Title',
		experience_level Experience,
		ceiling(avg(salary_in_usd)) 'Average Salary'
	into #experience_average_salary
	from salaries
	group by job_title, experience_level;

	-- order by job title and experience level --
	Select *
	from #experience_average_salary
	order by 
		'Job Title', 
		case Experience
			when 'EN' then 1
			when 'MI' then 2
			when 'SE' then 3
			when 'EX' then 4
			else 5
		end;


	-- delete if exist --
	If object_id('tempdb..#selected_job_titles') is not null
		begin
		   exec('DROP TABLE #selected_job_titles;');
		end;

	-- show job title with more than 50 posts -- 
	Select
		job_title 'Job Title',
		COUNT(job_title) 'Job Title Frequency'
	into #selected_job_titles
	from salaries
	group by job_title
	having count(job_title) >= 50;

	Select *
	from #selected_job_titles
	order by 'Job Title Frequency' desc;


	-- show all job title of frequency >= 50 order by Job Title, Experience, Average Salary by experience level --
	-- save into #selected_experience_average_salary -- 
	If object_id('tempdb..#average_salary_experience') is not null
		begin
		   exec('DROP TABLE #average_salary_experience;');
		end;

	Select 
		e.[Job Title],
		e.Experience,
		e.[Average Salary]
	into #average_salary_experience
	from 
		#experience_average_salary e
		inner join #selected_job_titles t
			on e.[Job Title] = t.[Job Title];

	-- show -- 
	Select * 
	from #average_salary_experience
	order by 
		'Job Title', 
		case Experience
			when 'EN' then 1
			when 'MI' then 2
			when 'SE' then 3
			when 'EX' then 4
			else 5
		end;

	-- create table -- 
	If object_id('average_salary_experience') is not null
		drop table average_salary_experience;

	Create table average_salary_experience (
		job_title char(50),
		experience_level char(5),
		average_salary decimal(10, 2)
	);

	Insert into average_salary_experience
	select * 
	from #average_salary_experience
	order by 
		[Job Title] asc, 
		case Experience
			when 'EN' then 1
			when 'MI' then 2
			when 'SE' then 3
			when 'EX' then 4
			else 5
		end;

	Select * from average_salary_experience;
