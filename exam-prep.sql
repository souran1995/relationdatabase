/*get number of students*/
select count(1) from students;

/*get students population in each year*/
select student_population_year_ref, count(1) from students
group by student_population_year_ref;

/*get students population in each program*/
select student_population_code_ref, count(1) from students
group by student_population_code_ref;

/* calculate age from dob */
SELECT contact_first_name, date_part('year',age(contact_birthdate)) as contact_age,* FROM contacts;

/*add age column to contacts*/
alter table contacts add column contact_age integer NULL;

/*calculate age from dob and insert in col contact_age*/
update contacts as c1 set contact_age = 
(SELECT date_part('year',age(contact_birthdate)) as c_age 
 FROM contacts as c2 where c1.contact_email=c2.contact_email);

/*avg student age*/
select avg(c.contact_age) as student_avg_age from students as s left join contacts as c
on c.contact_email=s.student_contact_ref

/*avg session duration for a course*/
select avg(EXTRACT(EPOCH FROM TO_TIMESTAMP(session_end_time, 'HH24:MI:SS')::TIME - TO_TIMESTAMP(session_start_time, 'HH24:MI:SS')::TIME)/3600) as duration 
from sessions as s left join courses as c
on c.course_code=s.session_course_ref
where c.course_code='SE_ADV_DB'



/*find the student with most absents*/
select count(a.attendance_student_ref) as absents,
c.contact_first_name, c.contact_last_name
from contacts as c
left join students as s on s.student_contact_ref=c.contact_email
left join attendance as a on s.student_epita_email=a.attendance_student_ref
where a.attendance_presence=1
group by c.contact_first_name, c.contact_last_name
order by absents ASC
limit 2

/*find the course with most absents*/
select sum(a.attendance_presence) as absents, c.course_name
from courses as c
left join attendance as a on c.course_code=a.attendance_course_ref
group by c.course_name
order by absents ASC
limit 1

/*find students who are not graded*/
/*first solution*/
SELECT a.student_epita_email, b.grade_score 
    FROM students a 
        LEFT JOIN grades b 
            ON a.student_epita_email=b.grade_student_epita_email_ref
                WHERE b.grade_score IS NULL

/*second solution*/
SELECT s.student_epita_email
FROM students as s
WHERE NOT EXISTS
  (SELECT *
   FROM grades as g
   WHERE s.student_epita_email = g.grade_student_epita_email_ref)
   
/*third solution*/
SELECT s.student_epita_email
FROM students as s
LEFT OUTER JOIN grades as g
  ON (s.student_epita_email = g.grade_student_epita_email_ref)
  WHERE g.grade_student_epita_email_ref IS NULL


/*find the teachers who are not in any session*/
SELECT c.contact_first_name, c.contact_last_name, t.teacher_epita_email
from contacts as c
inner join teachers as t
on c.contact_email = t.teacher_contact_ref
LEFT OUTER JOIN sessions as s
  ON t.teacher_epita_email = s.session_prof_ref
  WHERE s.session_prof_ref IS NULL

/*list of teacher who attend the total session */
select con.contact_first_name, con.contact_last_name, tea.teacher_contact_ref, count(session_prof_ref)
	from teachers tea
	inner join contacts con
	on con.contact_email = tea.teacher_contact_ref
	inner join sessions sess
	on tea.teacher_epita_email = sess.session_prof_ref

group by con.contact_first_name, con.contact_last_name, tea.teacher_contact_ref
order by count



*/ find the DSA students details with grades */

select con.contact_first_name, con.contact_last_name, stud.student_population_code_ref,
	grad.grade_course_code_ref as course_name, grad.grade_score
	from grades grad
	
	inner join students stud
	on grad.grade_student_epita_email_ref = stud.student_epita_email
	
	inner join contacts con
	on stud.student_contact_ref = con.contact_email
	
where
	student_population_code_ref = 'DSA'
	

/* attendance percentage for a student */

select (sum_atten/total_atten::float)*100 attendance_percentage, res.attendance_student_ref, res.attendance_course_ref, res.attendance_population_year_ref from
(
select count(1) as total_atten, sum(s.attendance_presence) as sum_atten,
s.attendance_student_ref, s.attendance_course_ref, s.attendance_population_year_ref
from attendance as s
where s.attendance_student_ref='jamal.vanausdal@epita.fr'
group by s.attendance_student_ref, s.attendance_course_ref, s.attendance_population_year_ref
) res
order by attendance_percentage
  

/* avg grade for DSA students*/
select avg(g.grade_score) as avg_grade, pop.population_code as population
from grades as g inner join programs as p
on g.grade_course_code_ref=p.program_course_code_ref
inner join populations as pop
on pop.population_code=p.program_assignment
where pop.population_code='DSA'
group by pop.population_code

/* All student average grade*/

Select cont.contact_first_name, cont.contact_last_name, stud.student_epita_email, avg(g.grade_score)
from students stud
	inner join contacts cont
	on cont.contact_email = stud.student_contact_ref
	
	inner join grades g
	on stud.student_epita_email = g.grade_student_epita_email_ref

group by cont.contact_first_name, cont.contact_last_name, stud.student_epita_email


/* list the course tought by teacher */
select distinct con.contact_first_name, con.contact_last_name, sess.session_course_ref
	from teachers tea
	
	inner join contacts con
	on con.contact_email = tea.teacher_contact_ref
	
	inner join sessions sess
	on tea.teacher_epita_email = sess.session_prof_ref
	


-- find the teachers who are not giving any courses
select s.student_epita_email
from students as s 
where s.student_epita_email not in 
(select g.grade_student_epita_email_ref from grades as g)



select * from teachers
select * from sessions
select * from courses
select * from contacts
select * from students
select * from grades
select * from attendance
