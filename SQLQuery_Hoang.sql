CREATE DATABASE HOANG
USE HOANG
GO

-- Bai 2
CREATE TABLE Sach (
    masach CHAR(5) PRIMARY KEY,
    tensach NVARCHAR(100),
    namxb INT,
    diachi NVARCHAR(100),
    soluong int
)

CREATE TABLE DonHang (
    maDH CHAR(5) PRIMARY KEY,
    tenKH NVARCHAR(100),
    sdt CHAR(10),
    diachi NVARCHAR(100),
    ngaymua DATE,
)

CREATE TABLE Mua (
    masach CHAR(5),
    maDH CHAR(5),
    soluong INT,

    PRIMARY KEY (masach, maDH),
    FOREIGN KEY (masach) REFERENCES Sach(masach),
    FOREIGN KEY (maDH) REFERENCES DonHang(maDH)
)

-- 2.1
SELECT * FROM Sach WHERE soluong > 10

-- 2.2
SELECT * FROM DonHang WHERE maDH = '1221'

-- 2.3
SELECT COUNT(maDH) AS soluongdonhang FROM DonHang
WHERE sdt = '0912552709'
GROUP BY sdt;

CREATE VIEW my_view AS
SELECT * FROM Sach
    INNER JOIN Mua ON Sach.masach = Mua.masach

-- 2.5
DELETE * FROM DonHang
WHERE maDH = (-- Select rows from a Table or View '[TableOrViewName]' in schema '[dbo]'
SELECT * FROM [dbo].[TableOrViewName]
WHERE /* add search conditions here */
GO)