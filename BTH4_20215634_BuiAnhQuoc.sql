USE QLBongDa
GO

-- a. STORE PROCEDURE

-- a.2. In ra dòng ‘Xin chào’ + @ten với @ten là tham số đầu vào là tên của bạn. Cho thực thi và in giá trị của các tham số này để kiểm tra.
GO
CREATE PROCEDURE a_2 AS
BEGIN
    DECLARE @ten NVARCHAR(50);
    SET @ten = N'Bùi Anh Quốc';
    PRINT 'Xin chào ' + @ten;
END;

-- a.4. Nhập vào 2 số @s1,@s2. Xuất tổng @s1+@s2 ra tham số @tong. Nhập vào 2 số @s1,@s2. In ra câu ‘Số lớn nhất của @s1 và @s2 là max’ với @s1,@s2,max là các giá trị tương ứng.
GO
CREATE PROCEDURE a_4 AS
BEGIN
    DECLARE @s1 INT;
    DECLARE @s2 INT;
    DECLARE @tong INT;
    DECLARE @max INT;

    SET @s1 = 10;
    SET @s2 = 20;
    SET @tong = @s1 + @s2;
    SET @max = IIF(@s1 > @s2, @s1, @s2);

    PRINT N'Số lớn nhất của ' + CAST(@s1 AS NVARCHAR) + N' và ' + CAST(@s2 AS NVARCHAR) + N' là ' + CAST(@max AS NVARCHAR)
END;

-- a.5. Nhập vào 2 số @s1, @s2. Xuất min và max của chúng ra tham số @min và @max. Cho thực thi và in giá trị của các tham số này để kiểm tra.
GO
CREATE PROCEDURE a_5 AS
BEGIN
    DECLARE @s1 INT;
    DECLARE @s2 INT;
    DECLARE @min INT;
    DECLARE @max INT;

    SET @s1 = 10;
    SET @s2 = 20;
    SET @min = IIF(@s1 > @s2, @s2, @s1);
    SET @max = IIF(@s1 > @s2, @s1, @s2);

    PRINT N'Số lớn nhất là ' + CAST(@max AS NVARCHAR);
    PRINT N'Số bé nhất là ' + CAST(@min AS NVARCHAR);
END;

-- a.8. Nhập vào số nguyên @n. In ra tổng và số lượng các số chẵn từ 1 đến @n. Cho thực thi và in giá trị của các tham số này để kiểm tra.
GO
CREATE PROCEDURE a_8 AS
BEGIN
    DECLARE @i INT;
    DECLARE @n INT;
    DECLARE @tong INT;

    SET @n = 10;
    SET @i = @n;
    SET @tong = 0;

    WHILE @i > 0
    BEGIN
        SET @tong = @tong + IIF(@i % 2 = 0, @i, 0);
        SET @i = @i - 1;
    END;

    PRINT CONCAT(N'Tổng các số chẵn từ 1 đến ', @n, N' là ', @tong);
END;

-- b. TRIGGER
-- b.1. Khi thêm cầu thủ mới, kiểm tra vị trí trên sân của cần thủ chỉ thuộc một trong các vị trí sau: Thủ môn, Tiền đạo, Tiền vệ, Trung vệ, Hậu vệ.
GO
CREATE TRIGGER b_1 ON CAUTHU
AFTER INSERT AS
BEGIN
    IF EXISTS(
        SELECT 1 FROM inserted
        WHERE inserted.VITRI NOT IN (N'Thủ môn', N'Tiền đạo', N'Tiền vệ', N'Trung vệ', N'Hậu vệ')
    )
    BEGIN
        RAISERROR(N'Vị trí của cầu thủ phải là 1 trong các loại Thủ môn, Tiền đạo, Tiền vệ, Trung vệ, Hậu vệ', 16, 1);
        ROLLBACK;
    END;
END;

-- b.2. Khi thêm cầu thủ mới, kiểm tra số áo của cầu thủ thuộc cùng một câu lạc bộ phải khác nhau.
GO
CREATE TRIGGER b_2 ON CAUTHU
AFTER INSERT AS
BEGIN
    IF EXISTS(
        SELECT 1 FROM inserted
            INNER JOIN CAUTHU ON inserted.MACLB = CAUTHU.MACLB AND inserted.SO = CAUTHU.SO
    )
    BEGIN
        RAISERROR(N'Số áo của các cầu thủ trong cùng 1 câu lạc bộ phải khác nhau', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;

-- b.3. Khi thêm thông tin cầu thủ thì in ra câu thông báo bằng Tiếng Việt ‘Đã thêm cầu thủ mới’
GO
CREATE TRIGGER b_3 ON CAUTHU
AFTER INSERT AS
BEGIN
    PRINT N'Đã thêm cầu thủ mới';
END;

-- b.4. Khi thêm cầu thủ mới, kiểm tra số lượng cầu thủ nước ngoài ở mỗi câu lạc bộ chỉ được phép đăng ký tối đa 8 cầu thủ.
GO
CREATE TRIGGER b_4 ON CAUTHU
AFTER INSERT AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM (SELECT * FROM CAUTHU UNION SELECT * FROM inserted) AS Table1
        WHERE Table1.MAQG NOT IN (SELECT MAQG FROM QUOCGIA WHERE TENQG = N'Việt Nam')
        GROUP BY MACLB
        HAVING COUNT(MACT) > 8
    )
    BEGIN
        RAISERROR(N'Số lượng cầu thủ người nước ngoài không được vượt quá 8 cầu thủ', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;
GO