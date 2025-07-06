-- Creating link to staging database and dropping existing tables
CREATE PUBLIC DATABASE LINK ToStaging CONNECT TO [USERNAME] IDENTIFIED BY StagingDatabase USING '[CONNECTION INFO]';
DROP TABLE DWUsers CASCADE CONSTRAINTS;
DROP TABLE tblCoursesDimension CASCADE CONSTRAINTS;
DROP TABLE tblGenresDimension CASCADE CONSTRAINTS;
DROP TABLE tblAuthorsDimension CASCADE CONSTRAINTS;
DROP TABLE tblBooksDimension CASCADE CONSTRAINTS;
DROP TABLE tblStudentsFact CASCADE CONSTRAINTS;
DROP TABLE tblLoansFact_Student CASCADE CONSTRAINTS;
DROP TABLE tblLoansFact_Book CASCADE CONSTRAINTS;
DROP TABLE tblFinesFact CASCADE CONSTRAINTS;

-- Creating users table for authentication system
CREATE TABLE DWUsers
( Username VARCHAR2(30) NOT NULL,
 Password VARCHAR2(30) NOT NULL,
 PRIMARY KEY (Username));

-- Inserting Head Librarian credentials into users table
INSERT INTO DWUsers(Username, Password)
VALUES ('HeadLibrarian', 'HeadLibrarian!');

-- Inserting Course Leader credentials into users table
INSERT INTO DWUsers(Username, Password)
VALUES ('CourseLeader', 'CourseLeader!');

-- Inserting Vice Chancellor credentials into users table
INSERT INTO DWUsers(Username, Password)
VALUES ('ViceChancellor', 'ViceChancellor!');

-- Finding all application users
SELECT * FROM DWUsers;

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

-- Inserting all courses from staging database course table into tblCoursesDimension
INSERT INTO tblCoursesDimension
(CourseID, CourseName)
    (SELECT CourseID, CourseName FROM tblCoursesDimension@ToStaging);

-- Inserting all genres from staging database genres table into tblGenresDimension
INSERT INTO tblGenresDimension
(GenreID, GenreName)
    (SELECT GenreID, GenreName FROM tblGenresDimension@ToStaging);

-- Inserting all authors from staging database authors table into tblAuthorsDimension
INSERT INTO tblAuthorsDimension
(AuthorID, AuthorName)
    (SELECT AuthorID, AuthorName FROM tblAuthorsDimension@ToStaging);

-- Inserting all books from staging database books table into tblBooksDimension
INSERT INTO tblBooksDimension
(BookID, BookName, GenreID, AuthorID)
    (SELECT BookID, BookName, GenreID, AuthorID FROM tblBooksDimension@ToStaging);

-- Creating student fact table to contain aggregated student data
-- The table is partitioned by JoinYear and sub-partitioned by JoinMonth.
CREATE TABLE tblStudentsFact(
                                CourseID INTEGER NOT NULL,
                                JoinMonth INTEGER NOT NULL,
                                JoinYear INTEGER NOT NULL,
                                TotalJoins INTEGER NOT NULL,
                                FOREIGN KEY(CourseID) REFERENCES tblCoursesDimension(CourseID)
)
-- PARTITION BY LIST(JoinYear)
-- SUBPARTITION BY LIST(JoinMonth)
-- (PARTITION P2023 VALUES(2023)
--     (SUBPARTITION January VALUES(1),
--     SUBPARTITION February VALUES(2),
--     SUBPARTITION March VALUES(3),
--     SUBPARTITION April VALUES(4),
--     SUBPARTITION May VALUES(5),
--     SUBPARTITION June VALUES(6),
--     SUBPARTITION July VALUES(7),
--     SUBPARTITION August VALUES(8),
--     SUBPARTITION September VALUES(9),
--     SUBPARTITION October VALUES(10),
--     SUBPARTITION November VALUES(11),
--     SUBPARTITION December VALUES(12),
--     SUBPARTITION Other VALUES(Default)),
-- PARTITION P2024 VALUES(2024)
--    (SUBPARTITION January VALUES(1),
--    SUBPARTITION February VALUES(2),
--    SUBPARTITION March VALUES(3),
--    SUBPARTITION Apr VALUES(4),
--    SUBPARTITION May VALUES(5),
--    SUBPARTITION June VALUES(6),
--    SUBPARTITION July VALUES(7),
--    SUBPARTITION August VALUES(8),
--    SUBPARTITION September VALUES(9),
--    SUBPARTITION October VALUES(10),
--    SUBPARTITION November VALUES(11),
--    SUBPARTITION December VALUES(12),
--    SUBPARTITION Other VALUES(Default)),
-- PARTITION Other VALUES(Default)
--    (SUBPARTITION January VALUES(1),
--    SUBPARTITION February VALUES(2),
--    SUBPARTITION March VALUES(3),
--    SUBPARTITION Apr VALUES(4),
--    SUBPARTITION May VALUES(5),
--    SUBPARTITION June VALUES(6),
--    SUBPARTITION July VALUES(7),
--    SUBPARTITION August VALUES(8),
--    SUBPARTITION September VALUES(9),
--    SUBPARTITION October VALUES(10),
--    SUBPARTITION November VALUES(11),
--    SUBPARTITION December VALUES(12),
--    SUBPARTITION Other VALUES(Default)),
--    )
;

-- Inserting aggregated student data from staging database into student fact table
INSERT INTO tblStudentsFact
(CourseID, JoinMonth, JoinYear, TotalJoins)
(SELECT CourseID, JoinMonth, JoinYear, TotalJoins FROM tblStudentsFact@ToStaging);

-- Creating student loan fact table to contain aggregated student-based loan data
-- The table is partitioned by LoanYear and sub-partitioned by LoanMonth
CREATE TABLE tblLoansFact_Student(
    CourseID INTEGER NOT NULL,
    LoanMonth INTEGER NOT NULL,
    LoanYear INTEGER NOT NULL,
    TotalLoans INTEGER NOT NULL,
    FOREIGN KEY(CourseID) REFERENCES tblCoursesDimension(CourseID)
)
-- PARTITION BY LIST(LoanYear)
-- SUBPARTITION BY LIST(LoanMonth)
-- (PARTITION P2023 VALUES(2023)
--     (SUBPARTITION January VALUES(1),
--     SUBPARTITION February VALUES(2),
--     SUBPARTITION March VALUES(3),
--     SUBPARTITION April VALUES(4),
--     SUBPARTITION May VALUES(5),
--     SUBPARTITION June VALUES(6),
--     SUBPARTITION July VALUES(7),
--     SUBPARTITION August VALUES(8),
--     SUBPARTITION September VALUES(9),
--     SUBPARTITION October VALUES(10),
--     SUBPARTITION November VALUES(11),
--     SUBPARTITION December VALUES(12),
--     SUBPARTITION Other VALUES(Default)),
-- PARTITION P2024 VALUES(2024)
--    (SUBPARTITION January VALUES(1),
--    SUBPARTITION February VALUES(2),
--    SUBPARTITION March VALUES(3),
--    SUBPARTITION Apr VALUES(4),
--    SUBPARTITION May VALUES(5),
--    SUBPARTITION June VALUES(6),
--    SUBPARTITION July VALUES(7),
--    SUBPARTITION August VALUES(8),
--    SUBPARTITION September VALUES(9),
--    SUBPARTITION October VALUES(10),
--    SUBPARTITION November VALUES(11),
--    SUBPARTITION December VALUES(12),
--    SUBPARTITION Other VALUES(Default)),
-- PARTITION Other VALUES(Default)
--    (SUBPARTITION January VALUES(1),
--    SUBPARTITION February VALUES(2),
--    SUBPARTITION March VALUES(3),
--    SUBPARTITION Apr VALUES(4),
--    SUBPARTITION May VALUES(5),
--    SUBPARTITION June VALUES(6),
--    SUBPARTITION July VALUES(7),
--    SUBPARTITION August VALUES(8),
--    SUBPARTITION September VALUES(9),
--    SUBPARTITION October VALUES(10),
--    SUBPARTITION November VALUES(11),
--    SUBPARTITION December VALUES(12),
--    SUBPARTITION Other VALUES(Default)),
--    )
;

-- Inserting aggregated student loan data from staging database into student-based loan fact table
INSERT INTO tblLoansFact_Student
(CourseID, LoanMonth, LoanYear, TotalLoans)
(SELECT CourseID, LoanMonth, LoanYear, TotalLoans FROM tblLoansFact_Student@ToStaging);

-- Creating book loan fact table to contain aggregated book-based loan data
-- The table is partitioned by LoanYear and sub-partitioned by LoanMonth
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
)
-- PARTITION BY LIST(LoanYear)
-- SUBPARTITION BY LIST(LoanMonth)
-- (PARTITION P2023 VALUES(2023)
--     (SUBPARTITION January VALUES(1),
--     SUBPARTITION February VALUES(2),
--     SUBPARTITION March VALUES(3),
--     SUBPARTITION April VALUES(4),
--     SUBPARTITION May VALUES(5),
--     SUBPARTITION June VALUES(6),
--     SUBPARTITION July VALUES(7),
--     SUBPARTITION August VALUES(8),
--     SUBPARTITION September VALUES(9),
--     SUBPARTITION October VALUES(10),
--     SUBPARTITION November VALUES(11),
--     SUBPARTITION December VALUES(12),
--     SUBPARTITION Other VALUES(Default)),
-- PARTITION P2024 VALUES(2024)
--    (SUBPARTITION January VALUES(1),
--    SUBPARTITION February VALUES(2),
--    SUBPARTITION March VALUES(3),
--    SUBPARTITION Apr VALUES(4),
--    SUBPARTITION May VALUES(5),
--    SUBPARTITION June VALUES(6),
--    SUBPARTITION July VALUES(7),
--    SUBPARTITION August VALUES(8),
--    SUBPARTITION September VALUES(9),
--    SUBPARTITION October VALUES(10),
--    SUBPARTITION November VALUES(11),
--    SUBPARTITION December VALUES(12),
--    SUBPARTITION Other VALUES(Default)),
-- PARTITION Other VALUES(Default)
--    (SUBPARTITION January VALUES(1),
--    SUBPARTITION February VALUES(2),
--    SUBPARTITION March VALUES(3),
--    SUBPARTITION Apr VALUES(4),
--    SUBPARTITION May VALUES(5),
--    SUBPARTITION June VALUES(6),
--    SUBPARTITION July VALUES(7),
--    SUBPARTITION August VALUES(8),
--    SUBPARTITION September VALUES(9),
--    SUBPARTITION October VALUES(10),
--    SUBPARTITION November VALUES(11),
--    SUBPARTITION December VALUES(12),
--    SUBPARTITION Other VALUES(Default)),
--    )
;

-- Inserting aggregated book loan data from staging database into book-based loan fact table
INSERT INTO tblLoansFact_Book
(BookID, GenreID, AuthorID, LoanMonth, LoanYear, TotalLoans)
(SELECT BookID, GenreID, AuthorID, LoanMonth, LoanYear, TotalLoans FROM tblLoansFact_Book@ToStaging);

-- Creating fine fact table to contain aggregated fine data.
-- The table is partitioned by FineYear and sub-partitioned by FineMonth.
CREATE TABLE tblFinesFact(
                                     CourseID INTEGER NOT NULL,
                                     FineMonth INTEGER NOT NULL,
                                     FineYear INTEGER NOT NULL,
                                     TotalFine INTEGER NOT NULL,
                                     FOREIGN KEY(CourseID) REFERENCES tblCoursesDimension(CourseID)
)
-- PARTITION BY LIST(FineYear)
-- SUBPARTITION BY LIST(FineMonth)
-- (PARTITION P2023 VALUES(2023)
--     (SUBPARTITION January VALUES(1),
--     SUBPARTITION February VALUES(2),
--     SUBPARTITION March VALUES(3),
--     SUBPARTITION April VALUES(4),
--     SUBPARTITION May VALUES(5),
--     SUBPARTITION June VALUES(6),
--     SUBPARTITION July VALUES(7),
--     SUBPARTITION August VALUES(8),
--     SUBPARTITION September VALUES(9),
--     SUBPARTITION October VALUES(10),
--     SUBPARTITION November VALUES(11),
--     SUBPARTITION December VALUES(12),
--     SUBPARTITION Other VALUES(Default)),
-- PARTITION P2024 VALUES(2024)
--    (SUBPARTITION January VALUES(1),
--    SUBPARTITION February VALUES(2),
--    SUBPARTITION March VALUES(3),
--    SUBPARTITION Apr VALUES(4),
--    SUBPARTITION May VALUES(5),
--    SUBPARTITION June VALUES(6),
--    SUBPARTITION July VALUES(7),
--    SUBPARTITION August VALUES(8),
--    SUBPARTITION September VALUES(9),
--    SUBPARTITION October VALUES(10),
--    SUBPARTITION November VALUES(11),
--    SUBPARTITION December VALUES(12),
--    SUBPARTITION Other VALUES(Default)),
-- PARTITION Other VALUES(Default)
--    (SUBPARTITION January VALUES(1),
--    SUBPARTITION February VALUES(2),
--    SUBPARTITION March VALUES(3),
--    SUBPARTITION Apr VALUES(4),
--    SUBPARTITION May VALUES(5),
--    SUBPARTITION June VALUES(6),
--    SUBPARTITION July VALUES(7),
--    SUBPARTITION August VALUES(8),
--    SUBPARTITION September VALUES(9),
--    SUBPARTITION October VALUES(10),
--    SUBPARTITION November VALUES(11),
--    SUBPARTITION December VALUES(12),
--    SUBPARTITION Other VALUES(Default)),
--    )
    ;

-- Inserting aggregated fine data from staging database into fine fact table
INSERT INTO tblFinesFact
(CourseID, FineMonth, FineYear, TotalFine)
(SELECT CourseID, FineMonth, FineYear, TotalFine FROM tblFinesFact@ToStaging);

-- Creating bitmap index based on CourseID for tblStudentsFact
-- CREATE BITMAP INDEX CourseIndexStudents ON tblStudentsFact(CourseID);
-- DROP INDEX CourseIndexStudents;

-- Creating bitmap index based on CourseID for tblLoansFact_Student
-- CREATE BITMAP INDEX CourseIndexLoans ON tblLoansFact_Student(CourseID);
-- DROP INDEX CourseIndexLoans;

-- Creating bitmap index based on GenreID for tblLoansFact_Book
-- CREATE BITMAP INDEX GenreIndex ON tblLoansFact_Book(GenreID);
-- DROP INDEX GenreIndex;

-- Creating bitmap index based on CourseID for tblFinesFact
-- CREATE BITMAP INDEX CourseIndexFines on tblFinesFact(CourseID);
-- DROP INDEX CourseIndexFines;

-- Reading all data from each table
SELECT * FROM tblGenresDimension;
SELECT * FROM tblAuthorsDimension;
SELECT * FROM tblBooksDimension;
SELECT * FROM tblCoursesDimension;
SELECT * FROM tblStudentsFact;
SELECT * FROM tblLoansFact_Student;
SELECT * FROM tblLoansFact_Book;
SELECT * FROM tblFinesFact;

-- Creating admin user account with full permissions
-- CREATE USER DWAdmin IDENTIFIED BY AdminPassword;
-- GRANT CREATE SESSION TO DWAdmin;
-- GRANT UNLIMITED TABLESPACE TO DWAdmin;
-- GRANT CONNECT, RESOURCE, DBA TO DWAdmin;
-- GRANT SELECT, INSERT, UPDATE, DELETE TO DWAdmin;

-- Creating head librarian user account with read-only permissions
-- CREATE USER HeadLibrarian IDENTIFIED BY LibrarianPassword;
-- GRANT CREATE SESSION TO HeadLibrarian;
-- GRANT CONNECT TO HeadLibrarian;
-- GRANT SELECT ON tblLoansFact_Book TO HeadLibrarian;

-- Creating course leader user account with read-only permissions
-- CREATE USER CourseLeader IDENTIFIED BY CourseLeaderPassword;
-- GRANT CREATE SESSION TO CourseLeader;
-- GRANT CONNECT TO CourseLeader;
-- GRANT SELECT ON tblStudentsFact TO CourseLeader;
-- GRANT SELECT ON tblLoansFact_Student TO CourseLeader;
-- GRANT SELECT ON tblFinesFact TO CourseLeader;

-- Creating vice chancellor user account with read-only permissions
-- CREATE USER ViceChancellor IDENTIFIED BY ViceChancellorPassword;
-- GRANT CREATE SESSION TO ViceChancellor;
-- GRANT CONNECT TO ViceChancellor;
-- GRANT SELECT ON tblStudentsFact TO ViceChancellor;
-- GRANT SELECT ON tblLoansFact_Student TO ViceChancellor;
-- GRANT SELECT ON tblFinesFact TO ViceChancellor;
