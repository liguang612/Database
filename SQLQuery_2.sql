CREATE DATABASE Temp
USE Temp
GO

-- 1
CREATE TABLE TacGia (
    TG# INT PRIMARY KEY,
    HoTen NVARCHAR(40),
    NgaySinh DATE,
    DiaChi NVARCHAR(100),
    Email VARCHAR(100),
)

CREATE TABLE Sach (
    MS# INT PRIMARY KEY,
    TenSach NVARCHAR(100),
    NhaXuatBan NVARCHAR(100),
    NamXuatBan INT
)

CREATE TABLE VietSach (
    TG# INT,
    MS# INT,
    NhuanBut BIGINT,
    PRIMARY KEY(TG#, MS#),
    FOREIGN KEY (TG#) REFERENCES TacGia(TG#),
    FOREIGN KEY (MS#) REFERENCES Sach(MS#)
)

-- 2
-- 2.a
SELECT * FROM TacGia
WHERE Email LIKE '%@soict.hust.edu.vn'

-- 2.b
SELECT TacGia.TG#, HoTen FROM TacGia
    INNER JOIN VietSach ON TacGia.TG# = VietSach.TG#
    INNER JOIN (SELECT MS# FROM Sach WHERE TenSach LIKE N'Tích hợp dữ liệu') AS Table1 ON VietSach.MS# = Table1.MS#

-- 2.c
SELECT MS#, COUNT(TG#) AS SoDongTacGia FROM VietSach
WHERE MS# = 112
GROUP BY MS#

-- 2.d
SELECT HoTen, NgaySinh FROM TacGia
    INNER JOIN (SELECT TG#, SUM(NhuanBut) AS TongNhuanBut FROM VietSach
        GROUP BY TG#
        HAVING SUM(NhuanBut) >= ALL(SELECT SUM(NhuanBut) FROM VietSach GROUP BY TG#)) AS Table1
    ON TacGia.TG# = Table1.TG#