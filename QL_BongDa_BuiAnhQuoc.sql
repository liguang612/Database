CREATE DATABASE QL_BongDa_BuiAnhQuoc

-- A. TẠO LẬP CƠ SỞ DỮ LIỆU QUẢN LÝ BÓGN ĐÁ
USE QL_BongDa_BuiAnhQuoc
GO

-- 1. Tạo các cấu trúc bảng, đưa ra các quan hệ
CREATE TABLE DOIBONG (
    MaDoi VARCHAR(2) NOT NULL,
    TenDoi VARCHAR(100),
    NamTL INT
)
ALTER TABLE DOIBONG ADD CONSTRAINT pk_doibong PRIMARY KEY(MaDoi)

CREATE TABLE CAUTHU (
    MaCauThu VARCHAR(2) NOT NULL,
    TenCauThu VARCHAR(50),
    Phai BIT,
    NgaySinh DATETIME,
    NoiSinh VARCHAR(50),
    MaDoi VARCHAR(2)
)
ALTER TABLE CAUTHU ADD CONSTRAINT pk_cauthu PRIMARY KEY(MaCauThu)
ALTER TABLE CAUTHU ADD CONSTRAINT fk_cauthu_doibong FOREIGN KEY(MaDoi) REFERENCES DOIBONG(MaDoi)

CREATE TABLE THIDAU (
    MaDoi VARCHAR(2) NOT NULL,
    NgayThiDau DATETIME NOT NULL,
    HieuSo VARCHAR(6),
    KetQua BIT
)
ALTER TABLE THIDAU ADD CONSTRAINT pk_thidau PRIMARY KEY(MaDoi, NgayThiDau)
ALTER TABLE THIDAU ADD CONSTRAINT fk_thidau_doibong FOREIGN KEY(MaDoi) REFERENCES DOIBONG(MaDoi)

CREATE TABLE PENALTY (
    MaPhat VARCHAR(2) NOT NULL,
    MaCT VARCHAR(2),
    TienPhat NUMERIC(1, 1),
    LoaiThe VARCHAR(1),
    NgayPhat DATETIME
)
ALTER TABLE PENALTY ADD CONSTRAINT pk_penalty PRIMARY KEY(MaPhat)
ALTER TABLE PENALTY ADD CONSTRAINT fk_penalty_cauthu FOREIGN KEY(MaCT) REFERENCES CAUTHU(MaCauThu)

-- 2. Nhập liệu (Không có bộ dữ liệu mẫu, lười nhập vcc)

-- B. THỰC HIỆN CÁC TRUY VẤN
-- 1. Đưa ra thông tin các cầu thủ từ 35 tuổi trở lên
SELECT * FROM CAUTHU
WHERE YEAR(GETDATE()) - YEAR(NgaySinh) >= 35

-- 2. Thống kê số cầu thủ theo loại thẻ phạt
SELECT LoaiThe, COUNT(MaCT) AS SoCauThu, SUM(TienPhat) AS TongTienPhat FROM PENALTY
WHERE YEAR(NgayPhat) = 2019
GROUP BY LoaiThe

-- 3. Hiển thị danh sách cầu thủ có số lần bị phạt thẻ đỏ nhiều nhất năm 2019
SELECT TenCauThu, Phai, NgaySinh, NoiSinh FROM CAUTHU
WHERE MaCauThu IN (
    SELECT MaCT FROM PENALTY
    WHERE LoaiThe = 'D' AND YEAR(NgayPhat) = 2019
    GROUP BY MaCT
    HAVING COUNT(MaCT) >= ALL(
        SELECT COUNT(MaCT) AS SOLANPHAT FROM PENALTY
        WHERE LoaiThe = 'D' AND YEAR(NgayPhat) = 2019
        GROUP BY MaCT
    )
)

-- 4. Hiển thị danh sách các đội có hiệu số bé nhất năm 2020
SELECT THIDAU.MaDoi, DOIBONG.TenDoi, SUM(CAST(SUBSTRING(HieuSo, 1, CHARINDEX(HieuSo, '-')  -1) AS INT)) - SUM(CAST(SUBSTRING(HieuSo, CHARINDEX(HieuSo, '-') + 1, LEN(HieuSo)) AS INT)) AS HIEUSO FROM
    THIDAU
    INNER JOIN DOIBONG ON THIDAU.MaDoi = DOIBONG.MaDoi
WHERE YEAR(NgayThiDau) = 2020
GROUP BY THIDAU.MaDoi, DOIBONG.TenDoi
HAVING SUM(CAST(SUBSTRING(HieuSo, 1, CHARINDEX(HieuSo, '-')  -1) AS INT)) - SUM(CAST(SUBSTRING(HieuSo, CHARINDEX(HieuSo, '-') + 1, LEN(HieuSo)) AS INT)) <= ALL (
    SELECT SUM(CAST(SUBSTRING(HieuSo, 1, CHARINDEX(HieuSo, '-')  -1) AS INT)) - SUM(CAST(SUBSTRING(HieuSo, CHARINDEX(HieuSo, '-') + 1, LEN(HieuSo)) AS INT)) AS HIEUSO FROM THIDAU
    WHERE YEAR(NgayThiDau) = 2020
    GROUP BY MaDoi
)

-- 5. Đưa ra các đội bóng trẻ thành lập sau 1990 có số lần thắng ít nhất
SELECT MaDoi, TenDoi FROM DOIBONG
WHERE NamTL > 1990 AND MaDoi IN (
    SELECT MaDoi FROM THIDAU
    WHERE KetQua = 1
    GROUP BY MaDoi
    HAVING COUNT(KetQua) <= ALL (
        SELECT COUNT(KetQua) FROM THIDAU
        WHERE KetQua = 1
        GROUP BY MaDoi
    )
)

-- 6. Tạo các Rule
-- 6.1. Kiểm tra các loại thẻ phạt chỉ có thể là 'D' hoặc 'V'
ALTER TABLE PENALTY ADD CONSTRAINT check_loaithe CHECK(LoaiThe IN ('D', 'V'))

-- 6.2. Kiểm tra ngày thi đấu không quá ngày hiện tại
ALTER TABLE THIDAU ADD CONSTRAINT check_ngaythidau CHECK(NgayThiDau <= GETDATE())