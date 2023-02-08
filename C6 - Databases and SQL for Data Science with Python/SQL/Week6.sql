--Week 6



--Views

--How does the syntax of a CREATE VIEW statement look?

CREATE VIEW view_name AS
SELECT column1, column2, ...
FROM table_name
WHERE condition;

--How does the syntax of a REPLACE VIEW statement look?

CREATE OR REPLACE VIEW view_name AS
SELECT column1, column2, ...
FROM table_name
WHERE condition;

--How does the syntax of a DROP VIEW statement look?

DROP VIEW view_name;



--Exercise 1: Create a View

-- 1.Let's create a view called EMPSALARY to display salary along with some basic sensitive data of employees from the HR database. To 		create the EMPSALARY view from the EMPLOYEES table, copy the code below and paste it to the textbox of the Run SQL page. Click Run all.

CREATE VIEW EMPSALARY AS 
SELECT EMP_ID, F_NAME, L_NAME, B_DATE, SEX, SALARY
FROM EMPLOYEES;

-- 2.Using SELECT, query the EMPSALARY view to retrieve all the records. Copy the code below and paste it to the textbox of the Run SQL 	page. Click Run all.

SELECT * FROM EMPSALARY;



--Exercise 2: Update a View

-- 1.It now seems that the EMPSALARY view we created in exercise 1 doesn't contain enough salary information, such as max/min salary and 	the job title of the employees. Let's update the EMPSALARY view:
--combining two tables EMPLOYEES and JOBS so that we can display our desired information from the HR database.
--including the columns JOB_TITLE, MIN_SALARY, MAX_SALARY of the JOBS table as well as excluding the SALARY column of the EMPLOYEES table.

CREATE OR REPLACE VIEW EMPSALARY  AS 
SELECT EMP_ID, F_NAME, L_NAME, B_DATE, SEX, JOB_TITLE, MIN_SALARY, MAX_SALARY
FROM EMPLOYEES, JOBS
WHERE EMPLOYEES.JOB_ID = JOBS.JOB_IDENT;

-- 2.Using SELECT, query the updated EMPSALARY view to retrieve all the records. Copy the code below and paste it to the textbox of the 	Run SQL page. Click Run all.

SELECT * FROM EMPSALARY;



--Exercise 3: Drop a View

-- 1.Let's delete the created EMPSALARY view. Copy the code below and paste it to the textbox of the Run SQL page. Click Run all.

DROP VIEW EMPSALARY;

-- 2.Using SELECT, you can verify whether the EMPSALARY view has been deleted or not. Copy the code below and paste it to the textbox of 	the Run SQL page. Click Run all.

SELECT * FROM EMPSALARY;



------------------
--Stored Procedures


--PETSALE-CREATE-v2.sql

--Exercise 1

--You will create a stored procedure routine named RETRIEVE_ALL.
--This RETRIEVE_ALL routine will contain an SQL query to retrieve all the records from the PETSALE table, so you don't need to write the 	same query over and over again. You just call the stored procedure routine to execute the query everytime.

--#SET TERMINATOR @
CREATE PROCEDURE RETRIEVE_ALL       -- Name of this stored procedure routine

LANGUAGE SQL                        -- Language used in this routine 
READS SQL DATA                      -- This routine will only read data from the table

DYNAMIC RESULT SETS 1               -- Maximum possible number of result-sets to be returned to the caller query

BEGIN 

    DECLARE C1 CURSOR               -- CURSOR C1 will handle the result-set by retrieving records row by row from the table
    WITH RETURN FOR                 -- This routine will return retrieved records as a result-set to the caller query
    
    SELECT * FROM PETSALE;          -- Query to retrieve all the records from the table
    
    OPEN C1;                        -- Keeping the CURSOR C1 open so that result-set can be returned to the caller query

END
@                                   -- Routine termination character


--To call the RETRIEVE_ALL routine, copy the code below in a new blank script and paste it to the textbox of the Run SQL page. Click Run 	all. You will have all the records retrieved from the PETSALE table.

CALL RETRIEVE_ALL;      -- Caller query

--To drop the stored procedure routine RETRIEVE_ALL

DROP PROCEDURE RETRIEVE_ALL;

CALL RETRIEVE_ALL;


--Exercise 2

--You will create a stored procedure routine named UPDATE_SALEPRICE with parameters Animal_ID and Animal_Health.
--This UPDATE_SALEPRICE routine will contain SQL queries to update the sale price of the animals in the PETSALE table depending on their 	health conditions, BAD or WORSE.
--This procedure routine will take animal ID and health conditon as parameters which will be used to update the sale price of animal in 	the PETSALE table by an amount depending on their health condition. 
--Suppose:
	--For animal with ID XX having BAD health condition, the sale price will be reduced further by 25%.
	--For animal with ID YY having WORSE health condition, the sale price will be reduced further by 50%.
	--For animal with ID ZZ having other health condition, the sale price won't change.

--#SET TERMINATOR @
CREATE PROCEDURE UPDATE_SALEPRICE ( 
    IN Animal_ID INTEGER, IN Animal_Health VARCHAR(5) )     -- ( { IN/OUT type } { parameter-name } { data-type }, ... )

LANGUAGE SQL                                                -- Language used in this routine
MODIFIES SQL DATA                                           -- This routine will only write/modify data in the table

BEGIN 

    IF Animal_Health = 'BAD' THEN                           -- Start of conditional statement
        UPDATE PETSALE
        SET SALEPRICE = SALEPRICE - (SALEPRICE * 0.25)
        WHERE ID = Animal_ID;
    
    ELSEIF Animal_Health = 'WORSE' THEN
        UPDATE PETSALE
        SET SALEPRICE = SALEPRICE - (SALEPRICE * 0.5)
        WHERE ID = Animal_ID;
        
    ELSE
        UPDATE PETSALE
        SET SALEPRICE = SALEPRICE
        WHERE ID = Animal_ID;

    END IF;                                                 -- End of conditional statement
    
END
@                                                           -- Routine termination character


--Call the UPDATE_SALEPRICE routine. We want to update the sale price of animal with ID 1 having BAD health condition in the PETSALE table.

CALL RETRIEVE_ALL;

CALL UPDATE_SALEPRICE(1, 'BAD');        -- Caller query

CALL RETRIEVE_ALL;


--To drop the stored procedure routine UPDATE_SALEPRICE

DROP PROCEDURE UPDATE_SALEPRICE;



------------------
--Committing and Rolling back a Transaction using a Stored Procedure


--Task A: Example exercise

--You will create a stored procedure routine named TRANSACTION_ROSE which will include TCL commands like COMMIT and ROLLBACK.
--Now develop the routine based on the given scenario to execute a transaction.
--Scenario: Let’s buy Rose a pair of Boots from ShoeShop. So we have to update the Rose balance as well as the ShoeShop balance in the 		BankAccounts table. Then we also have to update Boots stock in the ShoeShop table. After Boots, let’s also attempt to buy Rose a pair 	  of Trainers.

--#SET TERMINATOR @
CREATE PROCEDURE TRANSACTION_ROSE                           -- Name of this stored procedure routine

LANGUAGE SQL                                                -- Language used in this routine 
MODIFIES SQL DATA                                           -- This routine will only write/modify data in the table

BEGIN

        DECLARE SQLCODE INTEGER DEFAULT 0;                  -- Host variable SQLCODE declared and assigned 0
        DECLARE retcode INTEGER DEFAULT 0;                  -- Local variable retcode with declared and assigned 0
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION           -- Handler tell the routine what to do when an error or warning occurs
        SET retcode = SQLCODE;                              -- Value of SQLCODE assigned to local variable retcode
        
        UPDATE BankAccounts
        SET Balance = Balance-200
        WHERE AccountName = 'Rose';
        
        UPDATE BankAccounts
        SET Balance = Balance+200
        WHERE AccountName = 'Shoe Shop';
        
        UPDATE ShoeShop
        SET Stock = Stock-1
        WHERE Product = 'Boots';
        
        UPDATE BankAccounts
        SET Balance = Balance-300
        WHERE AccountName = 'Rose';

        IF retcode < 0 THEN                                  --  SQLCODE returns negative value for error, zero for success, positive value for warning
            ROLLBACK WORK;
        
        ELSE
            COMMIT WORK;
        
        END IF;
        
END
@                                                            -- Routine termination character



--now check if the transaction can successfully be committed or not

CALL TRANSACTION_ROSE;  -- Caller query

SELECT * FROM BankAccounts;

SELECT * FROM ShoeShop;

--Task B: Practice exercise

--Create a stored procedure TRANSACTION_JAMES to execute a transaction based on the following scenario: First buy James 4 pairs of 			Trainers from ShoeShop. Update his balance as well as the balance of ShoeShop. Also, update the stock of Trainers at ShoeShop. Then 	attempt to buy James a pair of Brogues from ShoeShop. If any of the UPDATE statements fail, the whole transaction fails. You will roll 	   back the transaction. Commit the transaction only if the whole transaction is successful.

--#SET TERMINATOR @
CREATE PROCEDURE TRANSACTION_JAMES                          -- Name of this stored procedure routine

LANGUAGE SQL                                                -- Language used in this routine 
MODIFIES SQL DATA                                           -- This routine will only write/modify data in the table

BEGIN

        DECLARE SQLCODE INTEGER DEFAULT 0;                  -- Host variable SQLCODE declared and assigned 0
        DECLARE retcode INTEGER DEFAULT 0;                  -- Local variable retcode with declared and assigned 0
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION           -- Handler tell the routine what to do when an error or warning occurs
        SET retcode = SQLCODE;                              -- Value of SQLCODE assigned to local variable retcode
        
        UPDATE BankAccounts
        SET Balance = Balance-1200
        WHERE AccountName = 'James';
        
        UPDATE BankAccounts
        SET Balance = Balance+1200
        WHERE AccountName = 'Shoe Shop';
        
        UPDATE ShoeShop
        SET Stock = Stock-4
        WHERE Product = 'Trainers';
        
        UPDATE BankAccounts
        SET Balance = Balance-150
        WHERE AccountName = 'James';

        IF retcode < 0 THEN                                  --  SQLCODE returns negative value for error, zero for success, positive value for warning
            ROLLBACK WORK;
        
        ELSE
            COMMIT WORK;
        
        END IF;
        
END
@                                                            -- Routine termination character



------------------
--Joins

--CROSS JOIN (also known as Cartesian Join) statement syntax

SELECT column_name(s)
FROM table1
CROSS JOIN table2;

--INNER JOIN statement syntax

SELECT column_name(s)
FROM table1
INNER JOIN table2
ON table1.column_name = table2.column_name;
WHERE condition;

--LEFT OUTER JOIN statement syntax

SELECT column_name(s)
FROM table1
LEFT OUTER JOIN table2
ON table1.column_name = table2.column_name
WHERE condition;

--RIGHT OUTER JOIN statement syntax

SELECT column_name(s)
FROM table1
RIGHT OUTER JOIN table2
ON table1.column_name = table2.column_name
WHERE condition;

--FULL OUTER JOIN statement syntax

SELECT column_name(s)
FROM table1
FULL OUTER JOIN table2
ON table1.column_name = table2.column_name
WHERE condition;

--SELF JOIN statement syntax

SELECT column_name(s)
FROM table1 T1, table1 T2
WHERE condition;


--Exercise

--Select the names and job start dates of all employees who work for the department number 5.

select E.F_NAME,E.L_NAME, JH.START_DATE 
from EMPLOYEES as E 
INNER JOIN JOB_HISTORY as JH on E.EMP_ID=JH.EMPL_ID 
where E.DEP_ID ='5';

--Select the names, job start dates, and job titles of all employees who work for the department number 5.

select E.F_NAME,E.L_NAME, JH.START_DATE, J.JOB_TITLE 
from EMPLOYEES as E 
INNER JOIN JOB_HISTORY as JH on E.EMP_ID=JH.EMPL_ID 
INNER JOIN JOBS as J on E.JOB_ID=J.JOB_IDENT
where E.DEP_ID ='5';

--Perform a Left Outer Join on the EMPLOYEES and DEPARTMENT tables and select employee id, last name, department id and department name 	for all employees.

select E.EMP_ID,E.L_NAME,E.DEP_ID,D.DEP_NAME
from EMPLOYEES AS E 
LEFT OUTER JOIN DEPARTMENTS AS D ON E.DEP_ID=D.DEPT_ID_DEP;

--Re-write the previous query but limit the result set to include only the rows for employees born before 1980.

select E.EMP_ID,E.L_NAME,E.DEP_ID,D.DEP_NAME
from EMPLOYEES AS E 
LEFT OUTER JOIN DEPARTMENTS AS D ON E.DEP_ID=D.DEPT_ID_DEP 
where YEAR(E.B_DATE) < 1980;

--Re-write the previous query but have the result set include all the employees but department names for only the employees who were born before 1980.

select E.EMP_ID,E.L_NAME,E.DEP_ID,D.DEP_NAME
from EMPLOYEES AS E 
LEFT OUTER JOIN DEPARTMENTS AS D ON E.DEP_ID=D.DEPT_ID_DEP 
AND YEAR(E.B_DATE) < 1980;

--Perform a Full Join on the EMPLOYEES and DEPARTMENT tables and select the First name, Last name and Department name of all employees.

select E.F_NAME,E.L_NAME,D.DEP_NAME
from EMPLOYEES AS E 
FULL OUTER JOIN DEPARTMENTS AS D ON E.DEP_ID=D.DEPT_ID_DEP;

--Re-write the previous query but have the result set include all employee names but department id and department names only for male employees.

select E.F_NAME,E.L_NAME,D.DEPT_ID_DEP, D.DEP_NAME
from EMPLOYEES AS E 
FULL OUTER JOIN DEPARTMENTS AS D ON E.DEP_ID=D.DEPT_ID_DEP AND E.SEX = 'M';


























