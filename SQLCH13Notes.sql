--Creating a view
CREATE VIEW VendorsMin AS
SELECT VendorName, VendorState, VendorPhone
FROM Vendors;

SELECT *
FROM VendorsMin
WHERE VendorState = 'CA';

--How to restrict data
CREATE VIEW InvestorsGeneral
AS
SELECT InvestorID, LastName, FirstName, Address, 
	City, State, ZipCode, Phone
FROM Investors;

--Getting an ID from an Invoice/filtering
CREATE VIEW VendorShortList
AS
SELECT VendorName, VendorContactLName,
 VendorContactFName, VendorPhone
FROM Vendors
WHERE VendorID IN (SELECT VendorID FROM Invoices);

--This also works
CREATE VIEW VendorInvoices
AS
SELECT VendorName, InvoiceNumber, InvoiceDate,
 InvoiceTotal
FROM Vendors AS v JOIN Invoices AS i
 ON v.VendorID = i.VendorID;

--Filter using top 5 and order
CREATE VIEW TopVendors
AS
SELECT TOP 5 PERCENT VendorID, InvoiceTotal
FROM Invoices
ORDER BY InvoiceTotal DESC;

--Creates a view to show who still owes money
CREATE VIEW OutstandingInvoices
 (InvoiceNumber, InvoiceDate, InvoiceTotal,
BalanceDue)
AS
SELECT InvoiceNumber, InvoiceDate, InvoiceTotal,
 InvoiceTotal - PaymentTotal - CreditTotal
FROM Invoices
WHERE InvoiceTotal - PaymentTotal - CreditTotal > 0;

--Uses an aggrogate function(Sum function)
CREATE VIEW InvoiceSummary
AS
SELECT VendorName, COUNT(*) AS InvoiceQty,
SUM(InvoiceTotal) AS InvoiceSum
FROM Vendors AS v JOIN Invoices AS i
 ON v.VendorID = i.VendorID
GROUP BY VendorName;

--Table for those who owe money, but with schemabinding.
--Schemabinding prevents your table from breaking if you change something
CREATE VIEW VendorsDue WITH SCHEMABINDING
AS
SELECT InvoiceDate AS Date, VendorName AS Name,
VendorContactFName + ' ' + VendorContactLName AS Contact,
 InvoiceNumber AS Invoice,
 InvoiceTotal - PaymentTotal - CreditTotal AS BalanceDue
FROM dbo.Vendors AS v JOIN dbo.Invoices AS i
 ON v.VendorID = i.VendorID
WHERE InvoiceTotal - PaymentTotal - CreditTotal > 0;

--You can Alter data in a view, even though it holds no data. There are rules
--Can't include top or distinct clause.
--Can't use an aggregate function like SUM or AVERAGE
--The Select cant include a GROUP BY or HAVING
--The view can't include the UNION operator
--Requiremnets for an updatable column:
--The clooumn cant be the result of a calculation

--An updatable view
CREATE VIEW InvoiceCredit
AS
SELECT InvoiceNumber, InvoiceDate, InvoiceTotal,
 PaymentTotal, CreditTotal
FROM Invoices
WHERE InvoiceTotal - PaymentTotal - CreditTotal > 0;

--UPDATE statement that updates the view
UPDATE InvoiceCredit
SET CreditTotal = CreditTotal + 200
WHERE InvoiceTotal - PaymentTotal - CreditTotal >= 200;

--A read only views
--Has a SUM
CREATE VIEW StateTotals
AS
SELECT VendorState, SUM(InvoiceTotal) AS InvoiceTotal
FROM Invoices i JOIN Vendors v
 ON i.VendorID = v.VendorID
GROUP BY VendorState;
--Result of a calculation
CREATE VIEW OutstandingInvoices
AS
SELECT InvoiceNumber, InvoiceDate, InvoiceTotal,
 InvoiceTotal - PaymentTotal - CreditTotal AS BalanceDue
FROM Invoices
WHERE InvoiceTotal - PaymentTotal - CreditTotal > 0;

--Doesn't work because the value in VendorID comes back NULL
INSERT INTO IBM_Invoices (InvoiceNumber, InvoiceDate,
 InvoiceTotal)
VALUES ('RA23988', '2023-03-04', 417.34);

--A delete that works because no new data is added
DELETE FROM IBM_Invoices
WHERE InvoiceNumber = 'Q545443';

--Don't mess with tables views from the Master sys.DB any other time
SELECT t.name AS TableName, s.name AS SchemaName
FROM sys.tables t
 JOIN sys.schemas s
 ON t.schema_id = s.schema_id;
