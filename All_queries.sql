Create Database library; -- Database created 

-- Tables Creation 

drop table if exists Books;
Create Table Books (
	isbn	Varchar(20) Primary Key,
	book_title	Varchar(55),
	category	Varchar(16),
	rental_price	Decimal(3,2),
	status	varchar(4),
	author	varchar(25),
	publisher	varchar(25)
);
drop table if exists Branch;
Create Table Branch (
	branch_id	 Varchar (4) primary key,
	manager_id	 Varchar (4),
	branch_address	 Varchar (12),
	contact_no	Numeric (12)
);

drop table if exists Employees;
Create Table Employees (
	emp_id	Varchar(4) primary Key,
	emp_name	Varchar(16),
	position	Varchar(10),
	salary	Numeric (5),	 -- use numeric to save space because integer will take more bytes then numberic (5)
	branch_id	Varchar(4) -- fk_branch_id
);


drop table if exists Issued_status;
create table issued_status(
	issued_id	VARCHAR(5) Primary Key,
	issued_member_id	Varchar(4),
	issued_book_name	Varchar(53),
	issued_date	Date,
	issued_book_isbn	Varchar(17),
	issued_emp_id	Varchar(4)
);

Drop table if exists member;
Create Table Member (
	member_id	varchar(4)	,
	member_name	varchar(14)	,
	member_address	varchar(13)	,
	reg_date	date	
);

Drop Table if Exists Return_Status;
Create Table Return_status (
	return_id	Varchar(5),
	issued_id	Varchar(5),
	return_book_name	Varchar(5),
	return_date	Date,
	return_book_isbn	Varchar(5)
);


-- data imported by GUI option 

-- checking data types and null datas 
select * from branch
select * from books
Where Book_title is null
	or 
	category is null 
	or 
	rental_price is null 
	or 
	Status is null 
	or 
	Author is null 
	or 
	Publisher is null;


select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status; -- having two column with all null values 


/* its found that Return_status table consists of two colum with all null values , 
lets bring  those data from any other table,
inside the issued stauts table almost all data are found except few , 
RS101-103 data are not even in issued table so delete these 3 entries and create as new table 
using CREATE TABLE  AS 
*/

Create table return_status_new
as(
select 
	r.return_id, 
	r.issued_id, 
	s.issued_book_name as return_book_name, 
	r.return_date, 
	s.issued_book_isbn as return_book_isbn
from return_status  as r 
Left Join issued_status as s
on r.issued_id = s.issued_id
);

-- adding primary key constaraints 
alter table return_status_new 
add Primary key (Return_id);

alter table member 
add primary key (member_id);

select * from return_status_new;

delete  from return_status_new 
where return_book_name is null ;

drop table if exists return_status;

select * from books;
select * from branch ;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;
select * from return_status_new;

-- ADDING FOREIGN KEYS 
alter table employees 
add constraint  fk_branch_id
FOREIGN KEY (branch_id) 
references branch(branch_id);


alter table issued_status 
add constraint fk_issued_emp
foreign key (issued_emp_id)
references employees (emp_id);


alter table return_status_new
add constraint fk_issued_id
foreign key (issued_id)
references issued_status(issued_id);


select * from issued_status
alter table issued_Status
add constraint Fk_isbn
foreign key (issued_book_isbn)
references books(isbn);



alter table issued_status 
add constraint fk_member_id
foreign key (issued_member_id)
references member(member_id);

/* CRUD Operations
Create: Inserted sample records into the books table.
Read: Retrieved and displayed data from various tables.
Update: Updated records in the employees table.
Delete: Removed records from the members table as needed.
*/

select * from books;

--Task 1. Create a New Book Record 
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

insert into books 
	values ('978-1-60129-456-2','To Kill a Mockingbird','Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.'
	);
--Update an Existing Member's Address 
update member 
set member_address = '125 oak St'
where member_id = 'C103';

-- changing of table name 
alter table member 
rename to members ;


/* Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
*/
delete from issued_status 
where issued_id in ('IS121');

select * from issued_status
where issued_id = 'IS121';


/*Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
*/

SELECT * FROM ISSUED_STATUS 
WHERE ISSUED_EMP_ID = 'E101';


--Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT ISSUED_EMP_ID, COUNT(ISSUED_EMP_ID) AS TOTAL FROM ISSUED_STATUS
GROUP BY 1 
HAVING COUNT(ISSUED_EMP_ID) > 2
ORDER BY 2 DESC;

--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results -
-- each book and total book_issued_cnt**
CREATE TABLE BOOK_ISSUED_SUMMARY 
AS (
SELECT ISBN,BOOK_TITLE, COUNT (ISSUED_BOOK_ISBN) AS TOTAL_ISSUED FROM BOOKS 
JOIN ISSUED_STATUS 
ON ISBN = ISSUED_BOOK_ISBN
GROUP BY 1);

SELECT * FROM BOOK_ISSUED_SUMMARY ;

-- FOREIGN KEY ADDED
ALTER TABLE BOOK_ISSUED_SUMMARY 
ADD CONSTRAINT fk_ISSUED_SUMMARY 
FOREIGN KEY (ISBN)
REFERENCES BOOKS (ISBN);

--Task 7. Retrieve All Books in a Specific Category (Mystery):
SELECT * FROM BOOKS 
WHERE CATEGORY  = 'Mystery';

--Task 8: Find Total Rental Incomes  Categorywise, incl. book name and times of issued :

select issued_book_isbn,issued_book_name,Count(*) as issued_times, sum(rental_price) as Total_rental_income   from issued_status
left Join books
on issued_book_isbn = isbn
Group by 1,2
order by 3 desc;


--List Members Who Registered in the Last 180 Days:

select * from members 
where reg_date >= (current_date - 180);

--List Employees with Their Branch Manager's Name and their branch details:
select e.emp_id,
	e.emp_name as emp_name, 
	m.emp_name as manager_name,
	b.branch_address
from employees e
Join branch b
		on e.branch_id = b.branch_id 
left Join employees m 
		on b.manager_id = m.emp_id;

--Create a Table of Books with Rental Price Above a Certain Threshold (like $5):
Create Table Best_Books
as
Select * from books
where rental_price > 5
order by rental_price desc ;

--Task 12: Retrieve the List of Books Not Yet Returned
select * from issued_status b
left join return_status_new r 
on b.issued_id = r.issued_id
where r.return_id is null ;

--Task 13: Identify Members with Overdue Books
--Display the member's_id, member's name, book title, issue date, and days overdue.

select 
	member_id,
	Member_name,
	issued_book_name,
	issued_date, 
	return_date,
	case 
		when (return_date - issued_date)<= 30 then 0 /*-- here i can also use when return date is not null then 0
													but i keep this to check the members who returned the book after 30days 
													basically who is not following the 30days rule (for this remove where query from below)
													*/
		when (return_date - issued_date)>30 then (return_date - issued_date-30) 
		when return_date is null then (current_date -issued_date)
		end 
		as Overdues 
from members m
join issued_status as I
on member_id = issued_member_id
left join return_status_new as rs
on i.issued_id=rs.issued_id
where return_date is null -- to filter the not-returned books 
order by 1;
 


-- adding new input 

INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '24 days',  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '13 days',  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL '7 days',  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL '32 days',  '978-0-375-50167-0', 'E101');

-- Adding new column in return_status

ALTER TABLE return_status_new
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status_new
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
SELECT * FROM return_status_new;



/*Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).		
--also Return_book_name and return_book_isbn comes automatically without user's direct input 
*/

/*-- few chnages made before proceeds 
update books
set status ='no'
where isbn IN (select issued_book_isbn from issued_status
where issued_id between 'IS122' and 'IS154')
*/

-- creating Procedure 

create or replace procedure Add_return(		
	P_return_id varchar(5),
	P_issued_id varchar(5),
	P_Book_quality varchar(15)
)
language plpgsql
as
$$
	Declare
		V_issued_id varchar(5);
		V_isbn Varchar(17);
		V_Book_name Varchar (53);

begin 
	
	select issued_id,
		issued_book_isbn,
		issued_book_name
	into V_issued_id,V_isbn,V_Book_name
	from issued_status
	where Issued_Id = P_issued_Id;

	if V_issued_id is null then
	raise exception 'Invalid Issued_id : %',P_issued_id;
	end if;	
	
	
	insert into return_status_new (return_id,issued_id,return_book_name,return_date,return_book_isbn,book_quality)
				values (P_return_id,P_issued_id,V_Book_name,current_date,V_isbn,P_Book_quality);

	
	Update Books
	set status ='yes'
	where isbn = V_isbn;

end;
$$;

-- try out the producre 
call Add_return('RS122','IS122','Good');

call Add_return('RS123','IS123','Good');

--working great:)



/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, 
showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/


select 
	b.branch_id,
	b.branch_address,
	count (i.issued_id) as No_of_issued,
	Count(r.return_id) as no_of_return,
	sum(bk.rental_price) as Total_revenue
from branch b 
left Join employees e
on b.branch_id =e.branch_id
left join issued_status i
on e.emp_id = i.issued_emp_id
left join books bk 
on i.issued_book_isbn = bk.isbn
left join return_status_new r
on i.issued_id=r.issued_id
group by 1,2
order by 1,2,3;




/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
containing members who have issued at least one book in the last 6 months.
*/
drop table if exists active_members
create table Active_members 
as 
(
select 
	member_id,
	Member_name,
	Max(Issued_date) as last_issued_date
	from members 
left join issued_status 
on member_id=issued_member_id
Where issued_date >= current_date-interval'6 months'
group by 1,2
);



/*Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/

select 
	employee_name,
	Branch,
	Books_processed
from 
(
select 
	e.emp_name as employee_name,
	b.branch_id as Branch,
	count(i.issued_id) as Books_processed,
	dense_rank () over (order by (count(i.issued_id)) desc ) as Rank --instead of max limit i think rank is better choice 
from issued_status i
left join employees e
on i.issued_emp_id =e.emp_id
join branch b
on e.branch_id= b.branch_id
group by 1,2
)
where Rank in (1,2,3);


/*
Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who returned books with the status "damaged" more than once.
Display the member name, book title, and the number of times they've issued damaged books.    
*/


select 
	m.member_name, 
	Count(*)  as returned_quality
from return_status_new rs
join issued_status i
on rs.issued_id=i.issued_id
join members m 
on i.issued_member_id=m.member_id
where rs.book_quality ='Damaged' 
group by 1
having count(*)>1
	
/*
Task 19: Stored Procedure
Objective: Create a stored procedure to manage the status of books in a library system.
    Description: Write a stored procedure that updates the status of a book based (inside Books Table) on its issuance or return. Specifically:
    If a book is issued, the status should change to 'no'.
*/

Create or Replace procedure add_issued_book(
	P_issued_id varchar(5),
	P_issued_member_id  varchar(4),
	P_issued_book_isbn  varchar(17),
	P_issued_emp_id varchar(4)
	)

language plpgsql
as 
$$

declare 
			V_member_name varchar(14);
			V_status varchar(4);
			V_book_title Varchar(55);


begin 
		select member_name
		into V_member_name
		from members 
		where member_id = P_issued_member_id;

		
		Select status,book_title
		into V_status,V_book_title
		from books
		Where isbn = P_issued_book_isbn;
	

		if V_status not in ('Yes','yes') then 
		Raise exception 'Book is currently unavilable: % %', V_book_title,P_issued_book_isbn;
		end if;


		insert into issued_status (issued_id,issued_member_id,Issued_book_name,issued_date,Issued_book_isbn,Issued_emp_id)
				Values (P_issued_id,P_issued_member_id,	V_book_title,current_date,P_issued_book_isbn ,P_issued_emp_id);


		Update books
		set status = 'No'
		Where isbn = P_issued_book_isbn;

		raise notice 'New issue succesfully made against Member Name % and Book name is %',V_member_name,V_book_title;

end;
$$;



--checked 
call add_issued_book('IS183','C107','978-0-7432-4722-4','E104')


/*Task 20: Create Table As Select (CTAS) Objective: 
Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
Description: Write a CTAS query to create a new table that lists each member and 
the books they have issued but not returned within 30 days. The table should include: 
	The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
	The number of books issued by each member. 
The resulting table should show: Member ID Number of overdue books Total fines
*/

Create table overdues 
as   
(
select 	i.issued_member_id as member_id,
		m.member_name,
		i.issued_book_name as book_name,
		i.issued_date,
		rs.return_date,
		case
			when return_date is null and (issued_date + interval'30days')> current_date then 0
			when return_date is null and (issued_date+interval '30days') <current_date 
					then (current_date-issued_date-30)*.5
			when (return_date-issued_date )<=30 then 0
			when (return_date-issued_date)>30 then (return_date-issued_date-30)*.5
			end as Penalty 
from issued_status i
join members m 
on i.issued_member_id = m.member_id
left join return_status_new rs
on i.issued_id=rs.issued_id
order by penalty desc 
);





select * from employees;
select*from branch;
select * from issued_status; 
select * from employees;
select * from books;
select * from members;
select*from return_status_new;
select * from overdues;