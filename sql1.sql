/* Create Table */
/* Primary key: id */
/* foreign key: dept_name <- department */
create instructor(
	id char(5),
	name varchar(20) not null,
	dept_name varchar(20),
	salary numeric(8, 2),
	primary key(id), 
	foreign key (dept_name) references department);

/* Add Attribute */
alter table instructor add sex char(1)  default 1;

/* Delete Attribute */
alter table instructor drop salary;


/* names of all instructors whose salary is greater than 80000 */
select name
from instructor
where salary > 80000;

/* 교수가 가르치는 모든 course id */
select name, course.title
from instructor, teaches, course
where instructor.id = teaches.id and teaches.course_id = course.course_id;


/* 컴공과의 모든 분반 */
select course.course_id, semester, year, title, sec_id
from course, section
where course.course_id = section.course_id and course.dept_name = 'Comp. Sci.';

/* 교수가 가르치는 모든 과목의 이름 */
select name, title
from instructor natural join teaches, course
where course.course_id = teaches.course_id;

/* 얘는 dept_name도 포함돼서 모든 과목 출력x, 다른 학과를 가르칠 수 도 있음. */
select name 
from instructor natural join teaches natural join course;

/* 아무 컴공 교수보다 돈 많은 교수 */
select distinct(a.name)
from instructor as a, instructor as b
where a.salary > b.salary and b.dept_name ='Comp. Sci.';

/* 이름에 dar가 들어가는 교수 &는 string, _는 character
||도 제공 문자열을합침 */
select name
from instructor
where name like '_instei_';

/* 문자열로 정렬 desc asc */
select name
from instructor
order by name asc;

/* 정수 범위 */
select name
from instructor
where salary between 90000 and 100000;

/* 2009년 가을, 2010년 봄에 열린 강의들 */
(select course_id
from section 
where semester='Fall' and year='2009')
intersect
(select course_id
from section
where semester='Spring' and year='2010');

/* nested query*/
select course_id
from section
where semester='Fall' and year='2009' and course_id in (select course_id 
										  from section
										  where semester='Spring' and year='2010');
/* 2009년 가을, 그런데 봄 2010년에 안열린 강의들 */
(select course_id
from section 
where semester='Fall' and year='2009')
except
(select course_id
from section
where semester='Spring' and year='2010');

/*nested query*/
select course_id
from section
where semester='Fall' and year='2009' and course_id not in (select course_id 
										  from section
										  where semester='Spring' and year='2010');

/* 2009년 가을 또는 2010년 봄에 열린 강의들 */
(select course_id
from section 
where semester='Fall' and year='2009')
union
(select course_id
from section
where semester='Spring' and year='2010');

/* null 값 */
select name
from instructor 
where salary = null
/* null <> null, 5 < null */

/* *************** 주의 null은 where에서 false 취급 */

/* 2010 봄에 가르친 교수 모두 */
select count(distinct name)
from instrurctor
where semester='Spring' and year='2010';

/* 모든 학과 교수의 평균 연봉 */
select dept_name, avg(salary)
from instructor
group by dept_name;


/* 42000불 이상 where은 from 바로 다음 순번 */
select dept_name, avg(salary)
from instructor
group by dept_name
having avg(salary) > 42000;

/* count는 null 센다, 다른건 무시, table이 비어있으면? count는 0, 나머진 null */



/* 총 학생 수, 10101 교수한테 배운 학생 수*/
select count(distinct id)
from takes
where (course_id, sec_id, semester, year) in(select course_id, sec_id, semester, year from teaches where id='10101');

/* 생명학과 교수 한명보다 연봉높은 교수 모두 */
select distinct a.id
from instructor as a, instructor as b
where a.salary > b.salary and b.dept_name='Biology';

select distinct id
from instructor
where salary > some (select salary from instructor where dept_name='Biology');


/* 2009년 가을, 2010년 봄에 열린 강의들 */
select course_id
from section as a
where semester='Fall' and year='2009' and
exists (select course_id from section 
	   where a.course_id= course_id and semester='Spring' and year='2010');

/* 생명학과 모든 강의를 들은 학생 except는 course로 하는게 좋다. 목적어가 드가는게 좋음 */
select id, name
from student as a
where not exists((select course_id
				 from course
				where dept_name='Biology')
				except
				(select takes.course_id
				from takes
				where takes.id = a.id));
				

/* 42000 불 이상 받는 학과 */
select dept_name, avg_salary
from (select dept_name, avg(salary)
	 from instructor
	 group by dept_name
	 having avg(salary) > 42000) as avg_dept(dept_name, avg_salary);
	 
select dept_name, avg_salary
from (select dept_name, avg(salary)
	 from instructor
	 group by dept_name) as avg_dept(dept_name, avg_salary)
where avg_salary > 42000;

/* 교수의 연봉과 학과의 평균 연봉 alias를 꼭 붙여줘야 함 */
select name, salary, avg_salary, dept_name
from instructor l1, lateral (select avg(salary) as avg_salary
						   from instructor as l2
						   where l2.dept_name = l1.dept_name) as l3;

/* 제일 연보 많은 학과 */
with max_budget(budget) as
(select max(budget)
from department)
select dept_name, max_budget
from department, max_budget
where department.budget = max_budget.budget;

/* 총합 연봉이 모든 학과의 총합의 평균보다 큰 학과를찾아라 */
with total_sal(tot_sal, dept_name) as
(select sum(salary), dept_name
from instructor
group by dept_name),

avg_sal_of_tot_sal(avg_sal) as
(select avg(tot_sal)
from total_sal)

select dept_name, tot_sal
from total_sal, avg_sal_of_tot_sal
where tot_sal >= avg_sal;


/* scalar subquer는 단일 행만 가지는 테이블을 select에 쓸 수 있음 */

/*************************DELETE*********************/
delete from instructor;
where dept_name='Finance';

/*Watson에 있는 instructor 삭제*/
delete from instructor
where dept_name in (select dept_name
				   from department
				   where building='Watson');
				   
/* 평균 instructor보다 돈 못받는 애들 다삭제 avg값 변경 x 미리 계산해놓음 */
delete from instructor
where salary > (select avg(salary)
			   from instructor);
			   
insert into course(course_id, title, dept_name, credits)/*순서가정*/
values ('CS-437', 'Database Systems', 'Comp. Sci.' null); /*null값 가느 */ 

/* 모든 교수 student에 넣음 */
insert into student
select id, name, dept_name, 0
from instructor;
			   
/* 100000이 넘으면 3퍼센트 올려줌 */
update instructor
set salary = salary * 1.03;
where salary > 100000;
update instructor
set salary = salary * 1.05;
where salary <= 100000;

/*case 써라 */
update instructor
 set salary = case when salary <= 100000 then salary * 1.05 else salary * 1.03 
 end;
	

/* 이수한 학점가지고 학생들의 tot_cred 변경 */
update student as A
set tot_cred = (select sum(credits)
			   from takes natural join course	
			   where student.id = takes.id and grade <> 'F' and takes.grade is	 not null);
			   
update student as A
set tot_cred = (select case when sum(credits) is null then 0 else sum(credits) end
			   from takes natural join course
			   where student.id =takes.id and takes.grade <> 'F' and takes.grade is not null)
