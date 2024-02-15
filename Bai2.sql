CREATE DATABASE BAI2
GO
USE BAI2
GO

CREATE TABLE KHACHSAN(
    MAKS CHAR(6) NOT NULL,
    TENKS NVARCHAR(100),
    DIACHI NVARCHAR(100)
)
ALTER TABLE KHACHSAN ADD CONSTRAINT pk_khachsan PRIMARY KEY(MAKS)

CREATE TABLE PHONG(
    SOP INT NOT NULL,
    MAKS CHAR(6),
    LOAIP INT,
    GIA INT
)
ALTER TABLE PHONG ADD CONSTRAINT pk_phong PRIMARY KEY(SOP)
ALTER TABLE PHONG ADD CONSTRAINT fk_phong_khachsan FOREIGN KEY(MAKS) REFERENCES KHACHSAN(MAKS)

CREATE TABLE KHACH(
    MAKHACH CHAR(6) NOT NULL,
    HOTEN NVARCHAR(50),
    DIACHI NVARCHAR(100)
)
ALTER TABLE KHACH ADD CONSTRAINT pk_khach PRIMARY KEY(MAKHACH)

CREATE TABLE DATPHONG(
    MAKS CHAR(6) NOT NULL,
    MAKHACH CHAR(6) NOT NULL,
    NGAYNHAN DATE NOT NULL,
    NGAYTRA DATE,
    SOP INT
)
ALTER TABLE DATPHONG ADD CONSTRAINT pk_datphong PRIMARY KEY(MAKS, MAKHACH, NGAYNHAN)
ALTER TABLE DATPHONG ADD CONSTRAINT fk_datphong_khachsan FOREIGN KEY(MAKS) REFERENCES KHACHSAN(MAKS)
ALTER TABLE DATPHONG ADD CONSTRAINT fk_datphong_khach FOREIGN KEY(MAKHACH) REFERENCES KHACH(MAKHACH)

-- a
SELECT LOAIP, GIA FROM PHONG
WHERE MAKS = (
    SELECT MAKS FROM KHACHSAN
    WHERE TENKS LIKE N'Melia'
)

-- b
SELECT * FROM KHACH
WHERE MAKHACH IN (
    SELECT MAKHACH FROM DATPHONG
    WHERE MAKS = (
        SELECT MAKS FROM KHACHSAN
        WHERE TENKS LIKE N'Melia'
    )
)

-- c
SELECT PHONG.SOP, HOTEN FROM PHONG
    LEFT JOIN (SELECT MAKHACH, SOP FROM DATPHONG WHERE GETDATE() > NGAYNHAN AND GETDATE() < NGAYTRA) AS TABLE1 ON PHONG.SOP = TABLE1.SOP
    INNER JOIN KHACH ON TABLE1.MAKHACH = KHACH.MAKHACH

-- d
SELECT * FROM PHONG
WHERE SOP NOT IN (
    SELECT DISTINCT SOP FROM DATPHONG
)

-- e
SELECT TABLE1.MAKS, TENKS, COUNT(SOP) AS SOP FROM (SELECT * FROM KHACHSAN WHERE DIACHI LIKE N'%London%') AS TABLE1
    INNER JOIN PHONG ON TABLE1.MAKS = PHONG.MAKS
GROUP BY TABLE1.MAKS, TENKS