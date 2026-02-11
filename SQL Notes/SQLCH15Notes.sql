--Stored procedures

USE AP;
GO

CREATE PROC spInvoiceReport
AS

SELECT VendorName, InvoiceNumber, InvoiceDate,
InvoiceTotal
FROM invoices i
	JOIN Vendors v
		ON i.VendorID = v.VendorID
WHERE InvoiceTotal - CreditTotal - PaymentTotal > 0
ORDER BY VendorName;

EXEC spInvoiceReport;

--Copy and delete a proc.

USE AP;

DROP PROC IF EXISTS spCopyInvoices;

GO

CREATE PROC spCopyInvoices
AS
	DROP TABLE IF EXISTS InvoiceCopy;

	SELECT *
	INTO InvoiceCopy
	FROM Invoices;

	EXEC spCopyInvoices


--Using parameters

CREATE PROC spInvTotal1
			@DateVar date,
			@InvTotal money OUTPUT
AS
SELECT @InvTotal = SUM(InvoiceTotal)
FROM Invoices
WHERE InvoiceDate >= @DateVar;

SELECT *
FROM Invoices

EXEC spInvTotal1 '2022-11-1', 0

CREATE PROC spInvTotal2

--How to see changes

DECLARE @InvCount int;
EXEC @InvCount = spInvCount '2023-01-01', 'P%';

PRINT 'Invoice count: ' + CONVERT(varchar, @InvCount);


--Stating errors
CREATE PROC spInsertInvoice
 @VendorID int, @InvoiceNumber varchar(50),
 @InvoiceDate date, @InvoiceTotal money,
 @TermsID int, @InvoiceDueDate date
AS
IF EXISTS(SELECT * FROM Vendors
 WHERE VendorID = @VendorID)
 INSERT Invoices
 VALUES (@VendorID, @InvoiceNumber,
 @InvoiceDate, @InvoiceTotal, 0, 0,
 @TermsID, @InvoiceDueDate, NULL);
ELSE
 THROW 50001, 'Not a valid VendorID!', 1;

--using a try statment
BEGIN TRY
 EXEC spInsertInvoice
 799,'ZXK-799','2023-03-01',299.95,1,'2023-04-01';
END TRY
BEGIN CATCH
 PRINT 'An error occurred.';
 PRINT 'Message: ' + CONVERT(varchar, ERROR_MESSAGE());
 IF ERROR_NUMBER() >= 50000
 PRINT 'This is a custom error message.';
END CATCH;

--User-Defined Functions
--Scalar-valued funcion: a single value
--2
--3

CREATE FUNCTION fnBalanceDue()
	RETURNS money
BEGIN
	RETURN
		(SELECT SUM(InvoiceTotal - PaymentTotal - CreditTotal)
		FROM Invoices
		WHERE InvoiceTotal - PaymentTotal - CreditTotal > 0);
END;

--dbo. is require when using the fnBalanceDue function

--table-valued function

CREATE FUNCTION fnTopVendorsDue
	(@CutOff money = 0)
	RETURNS table
RETURN
	SELECT VendorName, SUM(InvoiceTotal) AS TotalDue
	FROM Vendors v
	 JOIN invoices i ON v.VendorID = i.VendorID
	WHERE InvoiceTotal - PaymentTotal - CreditTotal > 0
	GROUP BY VendorName
	HAVING SUM(InvoiceTotal) >= @CutOff

--DROP and ALTER functions
--DROP FUNCTION [function_name]
--ALTER FUNCTION [pretty much the whole function]

--Triggers

CREATE TRIGGER Vendors_INSERT_UPDATE
	ON Vendors
	AFTER INSERT, UPDATE
AS
	UPDATE Vendors
	SET VendorState = UPPER(VendorState)
	WHERE VendorID IN (SELECT VendorID FROM Inserted);

INSERT Vendors
VALUES
('Peerless Uniforms, Inc.', '785 S Pixley Rd', NULL,
'Piqua', 'Oh', '45356', '(937) 555-8845', NULL, NULL,
 4, 550);