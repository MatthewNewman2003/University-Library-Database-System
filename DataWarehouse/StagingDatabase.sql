-- Creating link to operational database and dropping existing tables
CREATE PUBLIC DATABASE LINK ToOperational CONNECT TO [USERNAME] IDENTIFIED BY OperationalDatabase USING '[CONNECTION INFO]';
DROP TABLE tblCoursesDimension CASCADE CONSTRAINTS;
DROP TABLE tblGenresDimension CASCADE CONSTRAINTS;
DROP TABLE tblAuthorsDimension CASCADE CONSTRAINTS;
DROP TABLE tblBooksDimension CASCADE CONSTRAINTS;
DROP TABLE tblStudentsPrep CASCADE CONSTRAINTS;
DROP TABLE tblStudentsFact CASCADE CONSTRAINTS;
DROP TABLE tblLoansPrep CASCADE CONSTRAINTS;
DROP TABLE tblLoansPrep2_Student CASCADE CONSTRAINTS;
DROP TABLE tblLoansPrep2_Book CASCADE CONSTRAINTS;
DROP TABLE tblFinesPrep CASCADE CONSTRAINTS;
DROP TABLE tblFinesPrep2 CASCADE CONSTRAINTS;
DROP TABLE tblLoansFact_Student CASCADE CONSTRAINTS;
DROP TABLE tblLoansFact_Book CASCADE CONSTRAINTS;
DROP TABLE tblFinesFact CASCADE CONSTRAINTS;

-- Creating Courses dimension table, with CourseID set as the primary key
CREATE TABLE tblCoursesDimension
( CourseID INTEGER NOT NULL,
  CourseName VARCHAR2(30) NOT NULL,
  PRIMARY KEY(CourseID)
);

-- Creating Genres dimension table, with GenreID set as the primary key
CREATE TABLE tblGenresDimension
( GenreID INTEGER NOT NULL,
  GenreName VARCHAR2(30) NOT NULL,
  PRIMARY KEY(GenreID)
);

-- Creating Authors dimension table, with AuthorID set as the primary key
CREATE TABLE tblAuthorsDimension
( AuthorID INTEGER NOT NULL,
  AuthorName VARCHAR2(30) NOT NULL,
  PRIMARY KEY(AuthorID)
);

-- Creating Books dimension table, with BookID set as the primary key
CREATE TABLE tblBooksDimension
( BookID INTEGER NOT NULL,
BookName VARCHAR2(50) NOT NULL,
GenreID INTEGER NOT NULL,
AuthorID INTEGER NOT NULL,
PRIMARY KEY(BookID),
FOREIGN KEY(GenreID) REFERENCES tblGenresDimension(GenreID),
FOREIGN KEY(AuthorID) REFERENCES tblAuthorsDimension(AuthorID));

-- Inserting all courses from operational database course table into tblCoursesDimension
INSERT INTO tblCoursesDimension
(CourseID, CourseName)
(SELECT CourseID, CourseName FROM tblCourses@ToOperational);

-- Inserting all genres from operational database genre table into tblGenresDimension
INSERT INTO tblGenresDimension
(GenreID, GenreName)
(SELECT GenreID, GenreName FROM tblGenres@ToOperational);

-- Inserting all authors from operational database author table into tblAuthorsDimension
INSERT INTO tblAuthorsDimension
(AuthorID, AuthorName)
(SELECT AuthorID, AuthorName FROM tblAuthors@ToOperational);

-- Inserting all books from operational database book table into tblBooksDimension
INSERT INTO tblBooksDimension
(BookID, BookName, GenreID, AuthorID)
(SELECT BookID, BookName, GenreID, AuthorID FROM tblBooks@ToOperational);

-- Creating initial preparatory table for student operational data
CREATE TABLE tblStudentsPrep(
                                EmailAddress VARCHAR2(30) NOT NULL,
                                CourseID INTEGER NOT NULL,
                                JoinMonth INTEGER NOT NULL,
                                JoinYear INTEGER NOT NULL,
                                PRIMARY KEY(EmailAddress)
);

-- Inserting all students from operational database student table into tblStudentsPrep
-- As part of this process, transformation also occurs, with JoinDate being converted to two integers; JoinMonth and JoinYear
INSERT INTO tblStudentsPrep
(EmailAddress, CourseID, JoinMonth, JoinYear)
(SELECT EmailAddress, CourseID, EXTRACT(MONTH FROM JoinDate), EXTRACT(YEAR FROM JoinDate) FROM tblStudents@ToOperational);

-- Creating final student fact table for aggregated student data
CREATE TABLE tblStudentsFact(
    CourseID INTEGER NOT NULL,
    JoinMonth INTEGER NOT NULL,
    JoinYear INTEGER NOT NULL,
    TotalJoins INTEGER NOT NULL
);

-- Aggregating student data from preparatory table and inserting it into final facts table
INSERT INTO tblStudentsFact
(CourseID, JoinMonth, JoinYear, TotalJoins)
(SELECT CourseID, JoinMonth, JoinYear, COUNT(EmailAddress) FROM tblStudentsPrep
GROUP BY CourseID, JoinMonth, JoinYear);

-- Creating initial preparatory table for loan operational data
CREATE TABLE tblLoansPrep(
    LoanID INTEGER NOT NULL,
    EmailAddress VARCHAR2(30) NOT NULL,
    BookID INTEGER NOT NULL,
    LoanMonth INTEGER NOT NULL,
    LoanYear INTEGER NOT NULL,
    PRIMARY KEY(LoanID),
    FOREIGN KEY(EmailAddress) REFERENCES tblStudentsPrep(EmailAddress),
    FOREIGN KEY(BookID) REFERENCES tblBooksDimension(BookID)
);

-- Inserting all students from operational database loan table into tblLoansPrep
-- As part of this process, transformation also occurs, with LoanDate being converted to two integers; LoanMonth and LoanYear
INSERT INTO tblLoansPrep
(LoanID, EmailAddress, BookID, LoanMonth, LoanYear)
(SELECT LoanID, EmailAddress, BookID, EXTRACT(MONTH FROM LoanDate), EXTRACT(YEAR FROM LoanDate) FROM tblLoans@ToOperational);

-- Creating second loan preparatory table from the standpoint of students/courses
-- An inner join is formed with the student preparatory table here so that course data can be accessed
CREATE TABLE tblLoansPrep2_Student AS
SELECT tblLoansPrep.LoanID, tblLoansPrep.EmailAddress, tblStudentsPrep.CourseID, tblLoansPrep.LoanMonth, tblLoansPrep.LoanYear
FROM tblLoansPrep
INNER JOIN tblStudentsPrep
ON tblLoansPrep.EmailAddress = tblStudentsPrep.EmailAddress;

-- Creating final student loan fact table for aggregated student-based loan data
CREATE TABLE tblLoansFact_Student(
    CourseID INTEGER NOT NULL,
    LoanMonth INTEGER NOT NULL,
    LoanYear INTEGER NOT NULL,
    TotalLoans INTEGER NOT NULL,
    FOREIGN KEY(CourseID) REFERENCES tblCoursesDimension(CourseID)
);

-- Aggregating student loan data from preparatory table and inserting it into final facts table
INSERT INTO tblLoansFact_Student
(CourseID, LoanMonth, LoanYear, TotalLoans)
(SELECT CourseID, LoanMonth, LoanYear, COUNT(LoanID) FROM tblLoansPrep2_Student
GROUP BY CourseID, LoanMonth, LoanYear);

-- Creating second loan preparatory table from the standpoint of books/genres/authors
-- An inner join is formed with the book dimension table here so that book data can be accessed
CREATE TABLE tblLoansPrep2_Book AS
SELECT tblLoansPrep.LoanID, tblLoansPrep.BookID, tblBooksDimension.GenreID, tblBooksDimension.AuthorID, tblLoansPrep.LoanMonth, tblLoansPrep.LoanYear
FROM tblLoansPrep
INNER JOIN tblBooksDimension
ON tblLoansPrep.BookID = tblBooksDimension.BookID;

-- Creating final book loan fact table for aggregated book-based loan data
CREATE TABLE tblLoansFact_Book(
                                     BookID INTEGER NOT NULL,
                                     GenreID INTEGER NOT NULL,
                                     AuthorID INTEGER NOT NULL,
                                     LoanMonth INTEGER NOT NULL,
                                     LoanYear INTEGER NOT NULL,
                                     TotalLoans INTEGER NOT NULL,
                                     FOREIGN KEY(BookID) REFERENCES tblBooksDimension(BookID),
                                     FOREIGN KEY(GenreID) REFERENCES tblGenresDimension(GenreID),
                                     FOREIGN KEY(AuthorID) REFERENCES tblAuthorsDimension(AuthorID)
);

-- Aggregating book loan data from preparatory table and inserting it into final facts table
INSERT INTO tblLoansFact_Book
(BookID, GenreID, AuthorID, LoanMonth, LoanYear, TotalLoans)
    (SELECT BookID, GenreID, AuthorID, LoanMonth, LoanYear, COUNT(LoanID) FROM tblLoansPrep2_Book
     GROUP BY BookID, GenreID, AuthorID, LoanMonth, LoanYear);

-- Creating initial preparatory table for fine operational data
CREATE TABLE tblFinesPrep(
    LoanID INTEGER NOT NULL,
    EmailAddress VARCHAR2(30) NOT NULL,
    FineMonth INTEGER NOT NULL,
    FineYear INTEGER NOT NULL,
    FineAmount INTEGER NOT NULL,
    PRIMARY KEY(LoanID),
    FOREIGN KEY(LoanID) REFERENCES tblLoansPrep(LoanID),
    FOREIGN KEY(EmailAddress) REFERENCES tblStudentsPrep(EmailAddress)
);

-- Inserting all students from operational database fine table into tblFinesPrep
-- As part of this process, transformation also occurs, with FineDate being converted to two integers; FineMonth and FineYear
INSERT INTO tblFinesPrep
(LoanID, EmailAddress, FineMonth, FineYear, FineAmount)
(SELECT LoanID, EmailAddress, EXTRACT(MONTH FROM FineDate), EXTRACT(YEAR FROM FineDate), FineAmount FROM tblFines@ToOperational);

-- Creating second fine preparatory table
-- An inner join is formed with the student preparatory table here so that course data can be accessed
CREATE TABLE tblFinesPrep2 AS
SELECT tblFinesPrep.LoanID, tblFinesPrep.EmailAddress, tblFinesPrep.FineMonth, tblFinesPrep.FineYear, tblFinesPrep.FineAmount, tblStudentsPrep.CourseID
FROM tblFinesPrep
INNER JOIN tblStudentsPrep
ON tblFinesPrep.EmailAddress = tblStudentsPrep.EmailAddress;

-- Creating final fine fact table for aggregated fine data
CREATE TABLE tblFinesFact(
                                     CourseID INTEGER NOT NULL,
                                     FineMonth INTEGER NOT NULL,
                                     FineYear INTEGER NOT NULL,
                                     TotalFine INTEGER NOT NULL,
                                     FOREIGN KEY(CourseID) REFERENCES tblCoursesDimension(CourseID)
);

-- Aggregating fine data from preparatory table and inserting it into final facts table
INSERT INTO tblFinesFact
(CourseID, FineMonth, FineYear, TotalFine)
    (SELECT CourseID, FineMonth, FineYear, SUM(FineAmount) FROM tblFinesPrep2
     GROUP BY CourseID, FineMonth, FineYear);

-- Reading all data from each table
SELECT * FROM tblGenresDimension;
SELECT * FROM tblCoursesDimension;
SELECT * FROM tblAuthorsDimension;
SELECT * FROM tblBooksDimension;
SELECT * FROM tblStudentsPrep;
SELECT * FROM tblStudentsFact;
SELECT * FROM tblLoansPrep;
SELECT * FROM tblLoansPrep2_Student;
SELECT * FROM tblLoansFact_Student;
SELECT * FROM tblLoansPrep2_Book;
SELECT * FROM tblLoansFact_Book;
SELECT * FROM tblFinesPrep;
SELECT * FROM tblFinesFact;
