-- Dropping any potential existing tables, avoiding key constraints
DROP TABLE StudentsTable CASCADE CONSTRAINTS;
DROP TABLE BooksTable CASCADE CONSTRAINTS;
DROP TABLE LoansTable CASCADE CONSTRAINTS;
DROP TABLE FinesTable CASCADE CONSTRAINTS;

-- Creating StudentsTable, with EmailAddress set as the primary key
CREATE TABLE StudentsTable
( EmailAddress VARCHAR2(30) NOT NULL,
FirstName VARCHAR2(30) NOT NULL,
LastName VARCHAR2(30) NOT NULL,
Password VARCHAR2(30) NOT NULL,
PRIMARY KEY(EmailAddress)
);

-- Creating BooksTable, with BookName set as the primary key
CREATE TABLE BooksTable
( BookName VARCHAR2(50) NOT NULL,
Genre VARCHAR2(30) NOT NULL,
Author VARCHAR2(50) NOT NULL,
CurrentlyAvailable VARCHAR2(30) NOT NULL,
PRIMARY KEY(BookName)
);

-- Creating LoansTable, with LoanName as the primary key and EmailAddress and BookName as foreign keys
CREATE TABLE LoansTable
(   LoanName       VARCHAR2(50) NOT NULL,
    EmailAddress   VARCHAR2(30) NOT NULL,
    BookName       VARCHAR2(50) NOT NULL,
    LoanDate       DATE         NOT NULL,
    DueDate        DATE         NOT NULL,
    ReturnDate     DATE,
    ReturnedOnTime VARCHAR2(10),
    FinePaid       VARCHAR2(10),
    PRIMARY KEY(LoanName),
    FOREIGN KEY(EmailAddress) REFERENCES StudentsTable(EmailAddress),
    FOREIGN KEY(BookName) REFERENCES BooksTable(BookName)
);

-- Creating FinesTable, with LoanName as both a primary and foreign key and EmailAddress as a foreign key
CREATE TABLE FinesTable
(LoanName VARCHAR2(50) NOT NULL,
EmailAddress VARCHAR2(30) NOT NULL,
FineDate DATE NOT NULL,
FineAmount INTEGER NOT NULL,
PRIMARY KEY(LoanName),
FOREIGN KEY(LoanName) REFERENCES LoansTable(LoanName),
FOREIGN KEY(EmailAddress) REFERENCES StudentsTable(EmailAddress)
);

-- Inserting sample books into the BooksTable
INSERT INTO BooksTable (BookName, Genre, Author, CurrentlyAvailable)
VALUES ('Advanced Operating Systems','Computing','John Smith','Yes');

INSERT INTO BooksTable (BookName, Genre, Author, CurrentlyAvailable)
VALUES ('The Theory of Everything','Physics','Stephen Hawking','Yes');

INSERT INTO BooksTable (BookName, Genre, Author, CurrentlyAvailable)
VALUES ('Macbeth','Tragedy','William Shakespeare','Yes');

INSERT INTO BooksTable (BookName, Genre, Author, CurrentlyAvailable)
VALUES ('Harry Potter and the Chamber of Secrets','Fantasy','JK Rowling','Yes');

INSERT INTO BooksTable (BookName, Genre, Author, CurrentlyAvailable)
VALUES ('MongoDB for Beginners','Computing','Charles Mongo','Yes');

-- Inserting sample students into StudentsTable
INSERT INTO StudentsTable (EmailAddress, FirstName, LastName, Password)
VALUES ('s4100701@glos.ac.uk','Matt','Newman','matt123');

INSERT INTO StudentsTable (EmailAddress, FirstName, LastName, Password)
VALUES ('user@example.com','Example','User','example123');

INSERT INTO StudentsTable (EmailAddress, FirstName, LastName, Password)
VALUES ('abc@alphabet.com','Alpha','Beta','abc123');

-- Inserting sample loans into LoansTable
INSERT INTO LoansTable (LoanName, EmailAddress, BookName, LoanDate, DueDate, ReturnDate, ReturnedOnTime, FinePaid)
VALUES ('TheoryOfEverythingAug2023','abc@alphabet.com','The Theory of Everything',TO_DATE('2023-08-12','YYYY-MM-DD'),TO_DATE('2023-08-26','YYYY-MM-DD'),TO_DATE('2023-08-29','YYYY-MM-DD'),'No','Yes');

INSERT INTO LoansTable (LoanName, EmailAddress, BookName, LoanDate, DueDate, ReturnDate, ReturnedOnTime)
VALUES ('AdvancedOSSep2023','abc@alphabet.com','Advanced Operating Systems',TO_DATE('2023-09-02','YYYY-MM-DD'),TO_DATE('2023-09-16','YYYY-MM-DD'),TO_DATE('2023-09-14','YYYY-MM-DD'),'Yes');

INSERT INTO LoansTable (LoanName, EmailAddress, BookName, LoanDate, DueDate, ReturnDate, ReturnedOnTime, FinePaid)
VALUES ('MongoDBAug2023','abc@alphabet.com','MongoDB for Beginners',TO_DATE('2023-08-01','YYYY-MM-DD'),TO_DATE('2023-08-15','YYYY-MM-DD'),TO_DATE('2023-08-22','YYYY-MM-DD'),'No','Yes');

INSERT INTO LoansTable (LoanName, EmailAddress, BookName, LoanDate, DueDate, ReturnDate, ReturnedOnTime, FinePaid)
VALUES ('MongoDBOct2023','s4100701@glos.ac.uk','MongoDB for Beginners',TO_DATE('2023-10-01','YYYY-MM-DD'),TO_DATE('2023-10-15','YYYY-MM-DD'),TO_DATE('2023-10-31','YYYY-MM-DD'),'No','Yes');

INSERT INTO LoansTable (LoanName, EmailAddress, BookName, LoanDate, DueDate, ReturnDate, ReturnedOnTime)
VALUES ('HarryPotterSep2023','s4100701@glos.ac.uk','Harry Potter and the Chamber of Secrets',TO_DATE('2023-09-12','YYYY-MM-DD'),TO_DATE('2023-09-26','YYYY-MM-DD'),TO_DATE('2023-09-22','YYYY-MM-DD'),'Yes');

INSERT INTO LoansTable (LoanName, EmailAddress, BookName, LoanDate, DueDate, ReturnDate, ReturnedOnTime)
VALUES ('MacbethSep2023','user@example.com','Macbeth',TO_DATE('2023-09-05','YYYY-MM-DD'),TO_DATE('2023-09-19','YYYY-MM-DD'),TO_DATE('2023-09-17','YYYY-MM-DD'),'Yes');

INSERT INTO LoansTable (LoanName, EmailAddress, BookName, LoanDate, DueDate, ReturnDate, ReturnedOnTime, FinePaid)
VALUES ('MongoDBMay2023','user@example.com','MongoDB for Beginners',TO_DATE('2023-05-04','YYYY-MM-DD'),TO_DATE('2023-05-18','YYYY-MM-DD'),TO_DATE('2023-05-24','YYYY-MM-DD'),'No','Yes');

-- Inserting sample fines into the FinesTable
INSERT INTO FinesTable (LoanName, EmailAddress, FineDate, FineAmount)
VALUES ('TheoryOfEverythingAug2023','abc@alphabet.com',TO_DATE('2023-08-29','YYYY-MM-DD'),50);

INSERT INTO FinesTable (LoanName, EmailAddress, FineDate, FineAmount)
VALUES ('MongoDBAug2023','abc@alphabet.com',TO_DATE('2023-08-22','YYYY-MM-DD'),50);

INSERT INTO FinesTable (LoanName, EmailAddress, FineDate, FineAmount)
VALUES ('MongoDBOct2023','s4100701@glos.ac.uk',TO_DATE('2023-10-31','YYYY-MM-DD'),50);

INSERT INTO FinesTable (LoanName, EmailAddress, FineDate, FineAmount)
VALUES ('MongoDBMay2023','user@example.com',TO_DATE('2023-05-24','YYYY-MM-DD'),50);

-- Selecting all records from each table
SELECT * FROM StudentsTable;
SELECT * FROM BooksTable;
SELECT * FROM LoansTable;
SELECT * FROM FinesTable;