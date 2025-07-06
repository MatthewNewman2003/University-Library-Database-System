-- Dropping any potential existing tables, avoiding key constraints
DROP SEQUENCE AutoIncrementCourse;
DROP SEQUENCE AutoIncrementLoan;
DROP SEQUENCE AutoIncrementBook;
DROP SEQUENCE AutoIncrementGenre;
DROP SEQUENCE AutoIncrementAuthor;
DROP TABLE tblCourses CASCADE CONSTRAINTS;
DROP TABLE tblGenres CASCADE CONSTRAINTS;
DROP TABLE tblAuthors CASCADE CONSTRAINTS;
DROP TABLE tblStudents CASCADE CONSTRAINTS;
DROP TABLE tblBooks CASCADE CONSTRAINTS;
DROP TABLE tblLoans CASCADE CONSTRAINTS;
DROP TABLE tblFines CASCADE CONSTRAINTS;

--Creating sequence to auto-increment CourseID values
CREATE SEQUENCE AutoIncrementCourse
MINVALUE 1
START WITH 1
INCREMENT BY 1
CACHE 10;

-- Creating sequence to auto-increment LoanID values
CREATE SEQUENCE AutoIncrementLoan
MINVALUE 1
START WITH 1
INCREMENT BY 1
CACHE 10;

-- Creating sequence to auto-increment BookID values
CREATE SEQUENCE AutoIncrementBook
    MINVALUE 1
    START WITH 1
    INCREMENT BY 1
    CACHE 10;

-- Creating sequence to auto-increment GenreID values
CREATE SEQUENCE AutoIncrementGenre
    MINVALUE 1
    START WITH 1
    INCREMENT BY 1
    CACHE 10;

-- Creating sequence to auto-increment AuthorID values
CREATE SEQUENCE AutoIncrementAuthor
    MINVALUE 1
    START WITH 1
    INCREMENT BY 1
    CACHE 10;

-- Creating CoursesTable, with CourseID set as the primary key
CREATE TABLE tblCourses
( CourseID INTEGER NOT NULL,
CourseName VARCHAR2(30) NOT NULL,
PRIMARY KEY(CourseID)
);

-- Creating Genres table, with GenreID set as the primary key
CREATE TABLE tblGenres
( GenreID INTEGER NOT NULL,
  GenreName VARCHAR2(30) NOT NULL,
  PRIMARY KEY(GenreID)
);

-- Creating Authors table, with AuthorID set as the primary key
CREATE TABLE tblAuthors
( AuthorID INTEGER NOT NULL,
  AuthorName VARCHAR2(30) NOT NULL,
  PRIMARY KEY(AuthorID)
);

-- Creating StudentsTable, with EmailAddress set as the primary key
CREATE TABLE tblStudents
( EmailAddress VARCHAR2(30) NOT NULL,
  FirstName VARCHAR2(30) NOT NULL,
  LastName VARCHAR2(30) NOT NULL,
  CourseID INTEGER NOT NULL,
  JoinDate DATE NOT NULL,
  Password VARCHAR2(30) NOT NULL,
  PRIMARY KEY(EmailAddress),
  FOREIGN KEY(CourseID) REFERENCES tblCourses(CourseID)
);

-- Creating BooksTable, with BookName set as the primary key
CREATE TABLE tblBooks
( BookID INTEGER NOT NULL,
  BookName VARCHAR2(50) NOT NULL,
  GenreID INTEGER NOT NULL,
  AuthorID INTEGER NOT NULL,
  CurrentlyAvailable VARCHAR2(30) NOT NULL,
  PRIMARY KEY(BookID),
  FOREIGN KEY(GenreID) REFERENCES tblGenres(GenreID),
  FOREIGN KEY(AuthorID) REFERENCES tblAuthors(AuthorID)
);

-- Creating LoansTable, with LoanName as the primary key and EmailAddress and BookName as foreign keys
CREATE TABLE tblLoans
(   LoanID       INTEGER NOT NULL,
    EmailAddress   VARCHAR2(30) NOT NULL,
    BookID       INTEGER NOT NULL,
    LoanDate       DATE         NOT NULL,
    DueDate        DATE         NOT NULL,
    ReturnDate     DATE,
    ReturnedOnTime VARCHAR2(10),
    FinePaid       VARCHAR2(10),
    PRIMARY KEY(LoanID),
    FOREIGN KEY(EmailAddress) REFERENCES tblStudents(EmailAddress),
    FOREIGN KEY(BookID) REFERENCES tblBooks(BookID)
);

-- Creating FinesTable, with LoanName as both a primary and foreign key and EmailAddress as a foreign key
CREATE TABLE tblFines
(LoanID INTEGER NOT NULL,
 EmailAddress VARCHAR2(30) NOT NULL,
 FineDate DATE NOT NULL,
 FineAmount INTEGER NOT NULL,
 PRIMARY KEY(LoanID),
 FOREIGN KEY(LoanID) REFERENCES tblLoans(LoanID),
 FOREIGN KEY(EmailAddress) REFERENCES tblStudents(EmailAddress)
);

-- Inserting sample courses into the CoursesTable
INSERT INTO tblCourses(CourseID, CourseName)
VALUES (AutoIncrementCourse.nextval,'Computer Science');

INSERT INTO tblCourses(CourseID, CourseName)
VALUES (AutoIncrementCourse.nextval,'English Literature');

INSERT INTO tblCourses(CourseID,CourseName)
VALUES (AutoIncrementCourse.nextval,'Physics');

-- Inserting sample genres into the Genres table
INSERT INTO tblGenres(GenreID, GenreName)
VALUES (AutoIncrementGenre.nextval,'Computing');

INSERT INTO tblGenres(GenreID, GenreName)
VALUES (AutoIncrementGenre.nextval,'Physics');

INSERT INTO tblGenres(GenreID, GenreName)
VALUES (AutoIncrementGenre.nextval,'Tragedy');

INSERT INTO tblGenres(GenreID, GenreName)
VALUES (AutoIncrementGenre.nextval,'Fantasy');

-- Inserting sample authors into the Authors table
INSERT INTO tblAuthors(AuthorID, AuthorName)
VALUES (AutoIncrementAuthor.nextval,'John Smith');

INSERT INTO tblAuthors(AuthorID, AuthorName)
VALUES (AutoIncrementAuthor.nextval,'Stephen Hawking');

INSERT INTO tblAuthors(AuthorID, AuthorName)
VALUES (AutoIncrementAuthor.nextval,'William Shakespeare');

INSERT INTO tblAuthors(AuthorID, AuthorName)
VALUES (AutoIncrementAuthor.nextval,'JK Rowling');

INSERT INTO tblAuthors(AuthorID, AuthorName)
VALUES (AutoIncrementAuthor.nextval,'Charles Mongo');

-- Inserting sample books into the BooksTable
INSERT INTO tblBooks (BookID, BookName, GenreID, AuthorID, CurrentlyAvailable)
VALUES (AutoIncrementBook.nextval,'Advanced Operating Systems',1,1,'Yes');

INSERT INTO tblBooks (BookID, BookName, GenreID, AuthorID, CurrentlyAvailable)
VALUES (AutoIncrementBook.nextval,'The Theory of Everything',2,2,'Yes');

INSERT INTO tblBooks (BookID, BookName, GenreID, AuthorID, CurrentlyAvailable)
VALUES (AutoIncrementBook.nextval,'Macbeth',3,3,'Yes');

INSERT INTO tblBooks (BookID,BookName, GenreID, AuthorID, CurrentlyAvailable)
VALUES (AutoIncrementBook.nextval,'Harry Potter and the Chamber of Secrets',4,4,'Yes');

INSERT INTO tblBooks (BookID, BookName, GenreID, AuthorID, CurrentlyAvailable)
VALUES (AutoIncrementBook.nextval,'MongoDB for Beginners',1,5,'Yes');

-- Inserting sample students into StudentsTable
INSERT INTO tblStudents (EmailAddress, FirstName, LastName, CourseID, JoinDate, Password)
VALUES ('s4100701@glos.ac.uk','Matt','Newman',1,TO_DATE('2023-09-03','YYYY-MM-DD'),'matt123');

INSERT INTO tblStudents (EmailAddress, FirstName, LastName, CourseID, JoinDate, Password)
VALUES ('user@example.com','Example','User',2,TO_DATE('2023-05-01','YYYY-MM-DD'),'example123');

INSERT INTO tblStudents (EmailAddress, FirstName, LastName, CourseID, JoinDate, Password)
VALUES ('abc@alphabet.com','Alpha','Beta',3,TO_DATE('2023-07-27','YYYY-MM-DD'),'abc123');

-- Inserting sample loans into LoansTable
INSERT INTO tblLoans (LoanID, EmailAddress, BookID, LoanDate, DueDate, ReturnDate, ReturnedOnTime, FinePaid)
VALUES (AutoIncrementLoan.nextval,'abc@alphabet.com',2,TO_DATE('2023-08-12','YYYY-MM-DD'),TO_DATE('2023-08-26','YYYY-MM-DD'),TO_DATE('2023-08-29','YYYY-MM-DD'),'No','Yes');

INSERT INTO tblLoans (LoanID, EmailAddress, BookID, LoanDate, DueDate, ReturnDate, ReturnedOnTime)
VALUES (AutoIncrementLoan.nextval,'abc@alphabet.com',1,TO_DATE('2023-09-02','YYYY-MM-DD'),TO_DATE('2023-09-16','YYYY-MM-DD'),TO_DATE('2023-09-14','YYYY-MM-DD'),'Yes');

INSERT INTO tblLoans (LoanID, EmailAddress, BookID, LoanDate, DueDate, ReturnDate, ReturnedOnTime, FinePaid)
VALUES (AutoIncrementLoan.nextval,'abc@alphabet.com',5,TO_DATE('2023-08-01','YYYY-MM-DD'),TO_DATE('2023-08-15','YYYY-MM-DD'),TO_DATE('2023-08-22','YYYY-MM-DD'),'No','Yes');

INSERT INTO tblLoans (LoanID, EmailAddress, BookID, LoanDate, DueDate, ReturnDate, ReturnedOnTime, FinePaid)
VALUES (AutoIncrementLoan.nextval,'s4100701@glos.ac.uk',5,TO_DATE('2023-10-01','YYYY-MM-DD'),TO_DATE('2023-10-15','YYYY-MM-DD'),TO_DATE('2023-10-31','YYYY-MM-DD'),'No','Yes');

INSERT INTO tblLoans (LoanID, EmailAddress, BookID, LoanDate, DueDate, ReturnDate, ReturnedOnTime)
VALUES (AutoIncrementLoan.nextval,'s4100701@glos.ac.uk',4,TO_DATE('2023-09-12','YYYY-MM-DD'),TO_DATE('2023-09-26','YYYY-MM-DD'),TO_DATE('2023-09-22','YYYY-MM-DD'),'Yes');

INSERT INTO tblLoans (LoanID, EmailAddress, BookID, LoanDate, DueDate, ReturnDate, ReturnedOnTime)
VALUES (AutoIncrementLoan.nextval,'user@example.com',3,TO_DATE('2023-09-05','YYYY-MM-DD'),TO_DATE('2023-09-19','YYYY-MM-DD'),TO_DATE('2023-09-17','YYYY-MM-DD'),'Yes');

INSERT INTO tblLoans (LoanID, EmailAddress, BookID, LoanDate, DueDate, ReturnDate, ReturnedOnTime, FinePaid)
VALUES (AutoIncrementLoan.nextval,'user@example.com',5,TO_DATE('2023-05-04','YYYY-MM-DD'),TO_DATE('2023-05-18','YYYY-MM-DD'),TO_DATE('2023-05-24','YYYY-MM-DD'),'No','Yes');

-- Inserting sample fines into the FinesTable
INSERT INTO tblFines (LoanID, EmailAddress, FineDate, FineAmount)
VALUES (1,'abc@alphabet.com',TO_DATE('2023-08-29','YYYY-MM-DD'),50);

INSERT INTO tblFines (LoanID, EmailAddress, FineDate, FineAmount)
VALUES (3,'abc@alphabet.com',TO_DATE('2023-08-22','YYYY-MM-DD'),50);

INSERT INTO tblFines (LoanID, EmailAddress, FineDate, FineAmount)
VALUES (4,'s4100701@glos.ac.uk',TO_DATE('2023-10-31','YYYY-MM-DD'),50);

INSERT INTO tblFines (LoanID, EmailAddress, FineDate, FineAmount)
VALUES (7,'user@example.com',TO_DATE('2023-05-24','YYYY-MM-DD'),50);

-- Selecting all records from each table
SELECT * FROM tblCourses;
SELECT * FROM tblGenres;
SELECT * FROM tblAuthors;
SELECT * FROM tblStudents;
SELECT * FROM tblBooks;
SELECT * FROM tblLoans;
SELECT * FROM tblFines;
