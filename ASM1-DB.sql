CREATE DataBase QuanLyBanHang1
GO
USE QuanLyBanHang1  
GO  
-- Sao lưu cơ sở dữ liệu
BACKUP DATABASE QuanLyBanHang1
TO DISK = 'D:\Backup\QuanLyBanHang1.bak'
WITH FORMAT, NAME = 'Full Backup of QuanLyBanHang1';

-- Khôi phục cơ sở dữ liệu
RESTORE DATABASE QuanLyBanHang1
FROM DISK = 'D:\Backup\QuanLyBanHang1.bak'
WITH REPLACE;

--Tái tạo index để tối ưu hóa tìm kiếm
ALTER INDEX ALL ON Product REBUILD;


-- Bảng Inventory (quản lý nhập kho)
CREATE TABLE Inventory (  
    ProductID INT PRIMARY KEY,  
    ProductName VARCHAR(255),  
    QuantityImported INT,  
    ImportDate DATE  
);

-- Bảng Product (quản lý sản phẩm với giá bán và giá vốn)
CREATE TABLE Product (  
    ProductID INT PRIMARY KEY,  
    ProductName VARCHAR(255),  
    InventoryQuantity INT,  
    ProductImage NVARCHAR(MAX),  
    SellingPrice DECIMAL(10, 2),  
    ProductCost DECIMAL(10, 2)  -- Giá vốn sản phẩm để tính lợi nhuận
);

-- Bảng Sales (quản lý doanh thu bán hàng)
CREATE TABLE Sales(  
    SaleID INT PRIMARY KEY,  
    ProductID INT,  
    CustomerID INT,  
    EmployeeID INT,  
    QuantitySold INT,  
    SaleDate DATE,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),  
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),  
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Bảng Customers (quản lý thông tin khách hàng)
CREATE TABLE Customers (  
    CustomerID INT PRIMARY KEY,  
    CustomerName VARCHAR(255),  
    PhoneNumber VARCHAR(20),  
    Address VARCHAR(255)
);

-- Bảng Employee (quản lý thông tin nhân viên)
CREATE TABLE Employee (  
    EmployeeID INT PRIMARY KEY,  
    EmployeeName VARCHAR(255),  
    Username VARCHAR(255),  
    Password VARCHAR(255),  
    Position VARCHAR(50),
   
);

-- Truy vấn để lấy báo cáo doanh thu (tất cả giao dịch)
SELECT 
    S.SaleID AS [ID],
    P.ProductName AS [Product Name],
    S.QuantitySold AS [Sales Quantity],
    CONVERT(VARCHAR, S.SaleDate, 103) AS [Sale Date],
    (S.QuantitySold * P.SellingPrice) AS [Total Money]
FROM 
    Sales S
INNER JOIN 
    Product P ON S.ProductID = P.ProductID;

-- Truy vấn để lấy báo cáo doanh thu theo ngày bán
SELECT 
    CONVERT(DATE, S.SaleDate) AS [Sale Date],
    SUM(S.QuantitySold * P.SellingPrice) AS [Total Revenue]
FROM 
    Sales S
INNER JOIN 
    Product P ON S.ProductID = P.ProductID
GROUP BY 
    CONVERT(DATE, S.SaleDate);

-- Truy vấn để lấy báo cáo doanh thu theo tháng và năm
SELECT 
    YEAR(S.SaleDate) AS [Year],
    MONTH(S.SaleDate) AS [Month],
    SUM(S.QuantitySold * P.SellingPrice) AS [Total Revenue]
FROM 
    Sales S
INNER JOIN 
    Product P ON S.ProductID = P.ProductID
GROUP BY 
    YEAR(S.SaleDate), MONTH(S.SaleDate);

-- Truy vấn để lấy báo cáo doanh thu theo năm
SELECT 
    YEAR(S.SaleDate) AS [Year],
    SUM(S.QuantitySold * P.SellingPrice) AS [Total Revenue]
FROM 
    Sales S
INNER JOIN 
    Product P ON S.ProductID = P.ProductID
GROUP BY 
    YEAR(S.SaleDate);

-- Truy vấn để lấy báo cáo lợi nhuận theo nhân viên và sản phẩm
SELECT 
    P.ProductName AS [Product Name], 
    E.EmployeeName AS [Employee Name], 
    SUM((P.SellingPrice - P.ProductCost) * S.QuantitySold) AS [Total Profit]
FROM 
    Sales S
INNER JOIN 
    Product P ON S.ProductID = P.ProductID
INNER JOIN 
    Employee E ON S.EmployeeID = E.EmployeeID
GROUP BY 
    P.ProductName, E.EmployeeName;

SELECT 
ProductName, InventoryQuantity 
FROM 
Product 
WHERE
InventoryQuantity < 10;

SELECT 
TOP 1 CustomerID, SUM(QuantitySold * SellingPrice) AS TotalSpent
FROM 
Sales
GROUP BY 
CustomerID
ORDER BY 
TotalSpent DESC;

