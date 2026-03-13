# Library Management System using SQL 
# Project --P2

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/somnathmaity556-lab/Library-Management-System/blob/32b5b48cd440cae59401db594e5ac6cc72dbc6c6/Library-Management-System.png)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/somnathmaity556-lab/Library-Management-System/blob/b6c6ed83bb00a6a072c15cabd56d0c32cca67045/Library_erd1.png)

- **Database Creation**: Created a database named `library`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library;

drop table if exists Books;
Create Table Books
(
	isbn	Varchar(20) Primary Key,
	book_title	Varchar(55),
	category	Varchar(16),
	rental_price Decimal(3,2),
	status	varchar(4),
	author	varchar(25),
	publisher	varchar(25)
);
drop table if exists Branch;
Create Table Branch
(
	branch_id	 Varchar (4) primary key,
	manager_id	 Varchar (4),
	branch_address Varchar (12),
	contact_no	Numeric (12)
);

drop table if exists Employees;
Create Table Employees
(
	emp_id	Varchar(4) primary Key,
	emp_name	Varchar(16),
	position	Varchar(10),
	salary	Numeric (5),	 -- use numeric to save space because integer will take more bytes then numberic (5)
	branch_id	Varchar(4) -- fk_branch_id
);


drop table if exists Issued_status;
create table issued_status
(
	issued_id	VARCHAR(5) Primary Key,
	issued_member_id Varchar(4),
	issued_book_name Varchar(53),
	issued_date	Date,
	issued_book_isbn Varchar(17),
	issued_emp_id Varchar(4)
);

Drop table if exists member;
Create Table Member
(
	member_id	varchar(4)	,
	member_name	varchar(14)	,
	member_address varchar(13)	,
	reg_date	date	
);

Drop Table if Exists Return_Status;
Create Table Return_status
(
	return_id	Varchar(5),
	issued_id	Varchar(5),
	return_book_name Varchar(5),
	return_date	Date,
	return_book_isbn Varchar(5)
);

```

--** data imported by GUI option (imported directly with csv files )**

```sql

-- **Reading** checking data types and null datas 
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
```
/* its found that Return_status table consists of two colum with all null values , 
lets bring  those data from any other table,
inside the issued stauts table almost all data are found except few , 
RS101-103 data are not even in issued table so delete these 3 entries and create as new table 
using CREATE TABLE  AS 
*/

**Task : Creating a new return table wmtih all missing data**
```
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
```
            -- **adding primary key constaraints** 
```
alter table return_status_new 
add Primary key (Return_id);

alter table member 
add primary key (member_id);

select * from return_status_new;

delete  from return_status_new 
where return_book_name is null ;
```

            -- ADDING FOREIGN KEYS 
```
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
```
### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

--Task 1. Create a New Book Record 
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
```
insert into books 
	values ('978-1-60129-456-2','To Kill a Mockingbird','Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.'
	);
```
**Task : Update an Existing Member's Address**
```
```sql
update member 
set member_address = '125 oak St'
where member_id = 'C103';

-- changing of table name 
alter table member 
rename to members ;
```

**Task : Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```

** Task : Delete a Record from the Issued Status Table **
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
```
delete from issued_status 
where issued_id in ('IS121');
```
**Task : Retrieve All Books Issued by a Specific Employee *
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
*/
```
SELECT * FROM ISSUED_STATUS 
WHERE ISSUED_EMP_ID = 'E101';
```

**Task : List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
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
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT 
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM 
issued_status as ist
JOIN
books as b
ON b.isbn = ist.issued_book_isbn
GROUP BY 1
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM employees as e1
JOIN 
branch as b
ON e1.branch_id = b.branch_id    
JOIN
employees as e2
ON e2.emp_id = b.manager_id
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 5.00;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
select 
            member_id,
            Member_name,
            issued_book_name,
            issued_date, 
            return_date,
            case 
		when (return_date - issued_date)<= 30 then 0 
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
```

```
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
```

**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

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
            issued_book_isbn, issued_book_name
            into
            V_issued_id,V_isbn,V_Book_name
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
```


**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql

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
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

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

SELECT * FROM active_members;

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
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
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    
```
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
```	

**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

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
                                    Values (P_issued_id,P_issued_member_id,V_book_title,current_date,P_issued_book_isbn ,P_issued_emp_id);


            Update books
            set status = 'No'
            Where isbn = P_issued_book_isbn;

            raise notice 'New issue succesfully made against Member Name % and Book name is %',V_member_name,V_book_title;

end;
$$;



--checked 
call add_issued_book('IS183','C107','978-0-7432-4722-4','E104')

```



**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines

```
Create table overdues 
as   
(
select
            i.issued_member_id as member_id,
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


```






## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.





