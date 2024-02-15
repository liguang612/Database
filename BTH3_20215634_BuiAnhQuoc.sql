USE QLBongDa
GO

-- A. XỬ LÝ CHUỖI NGÀY GIỜ
-- a.1. Cho biết NGAYTD, TENCLB1, TENCLB2, KETQUA các trận đấu diễn ra vào tháng 3 trên sân nhà mà không bị thủng lưới
SELECT NGAYTD, CLB1.TENCLB, CLB2.TENCLB, KETQUA FROM
    (TRANDAU INNER JOIN SANVD ON TRANDAU.MASAN = SANVD.MASAN)
    INNER JOIN CAULACBO AS CLB1 ON TRANDAU.MACLB1 = CLB1.MACLB
    INNER JOIN CAULACBO AS CLB2 ON TRANDAU.MACLB2 = CLB2.MACLB
WHERE ((SANVD.MASAN = CLB1.MASAN AND KETQUA LIKE '%-0') OR (SANVD.MASAN = CLB2.MASAN AND KETQUA LIKE '0-%')) AND MONTH(NGAYTD) = 3

-- a.2. Cho biết mã số, họ tên, ngày sinh của các cầu thủ có họ lót là 'Công'
SELECT * FROM CAUTHU
WHERE CAUTHU.HOTEN LIKE N'%Công%'

-- a.3. Cho biết mã số, họ tên, ngày sinh của các cầu thủ có họ không phải là 'Nguyễn'
SELECT * FROM CAUTHU
WHERE CAUTHU.HOTEN NOT LIKE N'Nguyễn %'

-- a.4. Cho biết mã huấn luyện viên, họ tên, ngày sinh, địa chỉ của những huấn luyện viên Việt Nam có tuổi nằm trong khoảng 35-40
SELECT * FROM HUANLUYENVIEN
WHERE YEAR(GETDATE()) - YEAR(HUANLUYENVIEN.NGAYSINH) >= 35 AND YEAR(GETDATE()) - YEAR(HUANLUYENVIEN.NGAYSINH) <= 40

-- a.5. Cho biết tên câu lạc bộ có huấn luyện viên trưởng sinh vào ngày 20 tháng 8 năm 2019
SELECT TENCLB FROM CAULACBO
WHERE MACLB IN
    (SELECT MACLB FROM HLV_CLB
    WHERE
        MAHLV IN (SELECT MAHLV FROM HUANLUYENVIEN WHERE NGAYSINH = CONVERT(DATETIME, '8-20-2019'))
        AND VAITRO LIKE N'HLV Chính')

-- a.6. Cho biết tên câu lạc bộ, tên tỉnh mà câu lạc bộ đang đóng có số bàn thắng nhiều nhất tính đến hết vòng 3 năm 2009
SELECT TENCLB, TENTINH FROM
    CAULACBO INNER JOIN TINH ON CAULACBO.MATINH = TINH.MATINH
WHERE CAULACBO.MACLB IN
    (SELECT TOP 1 MACLB FROM BANGXH
    WHERE VONG = 3 AND NAM = 2009
    ORDER BY CAST(SUBSTRING(HIEUSO, 1, CHARINDEX('-', HIEUSO) - 1) AS INT) DESC)

-- B. TRUY VẤN CON
-- b.1. Cho biết mã câu lạc bộ, tên câu lạc bộ, tên sân vận động, địa chỉ và số lượng cầu thủ nước ngoài (có quốc tịch khác Việt Nam) tương ứng của các câu lạc bộ có nhiều hơn 2 cầu thủ nước ngoài.
SELECT CAULACBO.MACLB, TENCLB, TENSAN, DIACHI, [SOCAUTHUNUOCNGOAI] FROM 
    (SELECT MACLB, COUNT(MACT) AS SOCAUTHUNUOCNGOAI FROM CAUTHU 
        WHERE MAQG NOT IN
            (SELECT MAQG FROM QUOCGIA WHERE TENQG LIKE N'Việt Nam')
        GROUP BY MACLB) AS TABLE1
    INNER JOIN CAULACBO ON TABLE1.MACLB = CAULACBO.MACLB
    INNER JOIN SANVD ON CAULACBO.MASAN = SANVD.MASAN
WHERE SOCAUTHUNUOCNGOAI > 2

-- b.2. Cho biết tên câu lạc bộ, tên tỉnh mà câu lạc bộ đang đóng có hiệu số bàn thắng bại cao nhất năm 2009
SELECT TENCLB, TENTINH FROM
    CAULACBO INNER JOIN TINH ON CAULACBO.MATINH = TINH.MATINH
WHERE CAULACBO.MACLB IN (SELECT TOP 1 MACLB FROM BANGXH
    ORDER BY CAST(SUBSTRING(HIEUSO, 1, CHARINDEX('-', HIEUSO) - 1) AS INT) - CAST(SUBSTRING(HIEUSO, CHARINDEX('-', HIEUSO) + 1, LEN(HIEUSO)) AS INT) DESC)

-- b.3. Cho biết danh sách các trận đấu (NGAYTD, TENSAN, TENCLB1, TENCLB2, KETQUA) của câu lạc bộ CLB có thứ hạng thấp nhất trong bảng xếp hạng vòng 3 năm 2009.
SELECT * FROM TRANDAU
WHERE
    TRANDAU.MACLB1 IN (SELECT TOP 1 MACLB FROM BANGXH
    WHERE VONG = 3 AND NAM = 2009
    ORDER BY HANG)
    OR
    TRANDAU.MACLB2 IN (SELECT TOP 1 MACLB FROM BANGXH
    WHERE VONG = 3 AND NAM = 2009
    ORDER BY HANG)

-- b.4. Cho biết mã câu lạc bộ, tên câu lạc bộ đã tham gia thi đấu với tất cả các câu lạc bộ còn lại (kể cả sân nhà và sân khách) trong mùa giải năm 2009.
SELECT MACLB, TENCLB FROM CAULACBO
WHERE NOT EXISTS(
    SELECT 1 FROM CAULACBO AS CLB2
    WHERE CAULACBO.MACLB <> CLB2.MACLB AND NOT EXISTS(
        SELECT 1 FROM TRANDAU
        WHERE TRANDAU.NAM = 2009 AND ((TRANDAU.MACLB1 = CAULACBO.MACLB AND TRANDAU.MACLB2 = CLB2.MACLB) OR (TRANDAU.MACLB2 = CAULACBO.MACLB) AND (TRANDAU.MACLB1 = CLB2.MACLB))
    )
)

-- b.5. Cho biết mã câu lạc bộ, tên câu lạc bộ đã tham gia thi đấu với tất cả các câu lạc bộ còn lại (chỉ tính sân nhà) trong mùa giải năm 2009.
SELECT MACLB, TENCLB FROM CAULACBO
WHERE NOT EXISTS(
    SELECT 1 FROM CAULACBO AS CLB2
    WHERE CAULACBO.MACLB <> CLB2.MACLB AND NOT EXISTS(
        SELECT 1 FROM TRANDAU
        WHERE TRANDAU.NAM = 2009 AND (TRANDAU.MACLB1 = CAULACBO.MACLB OR TRANDAU.MACLB2 = CLB2.MACLB)
    )
)

-- C. BÀI TẬP VỀ RULE
-- c.1. Khi thêm cầu thủ mới, kiểm tra vị trí trên sân của cầu thủ chỉ thuộc một trong các vị trí sau: Thủ môn, tiền đạo, tiền vệ, trung vệ, hậu vệ.
ALTER TABLE CAUTHU ADD CONSTRAINT check_vitri CHECK (VITRI IN (N'Thủ môn', N'Tiền đạo', N'Tiền vệ', N'Trung vệ', N'Hậu vệ'))

-- c.2. Khi phân công huấn luyện viên, kiểm tra vai trò của huấn luyện vi ên chỉ thuộc một trong các vai trò sau: HLV chính, HLV phụ, HLV thể lực, HLV thủ môn.
ALTER TABLE HLV_CLB ADD CONSTRAINT check_vaitro CHECK (VAITRO IN (N'HLV Chính', N'HLV phụ', N'HLV thủ môn', N'HLV thể lực'))

-- c.3. Khi thêm cầu thủ mới, kiểm tra cầu thủ đó có tuổi phải đủ 18 trở lên (chỉ tính năm sinh).
ALTER TABLE CAUTHU ADD CONSTRAINT check_namsinh CHECK (YEAR(GETDATE()) - YEAR(NGAYSINH) >= 18)

-- c.4. Kiểm tra kết quả trận đấu có dạng số_bàn_thắng-số_bàn_thua.
ALTER TABLE TRANDAU ADD CONSTRAINT check_ketqua CHECK (KETQUA LIKE '%-%')

-- D. BÀI TẬP VỀ VIEW
-- d.1. Cho biết mã số, họ tên, ngày sinh, địa chỉ và vị trí của các cầu thủ thuộc đội bón g “SHB Đà Nẵng” có quốc tịch “Bra-xin”.
GO
CREATE VIEW d_1 AS SELECT MACT, HOTEN, NGAYSINH, DIACHI, VITRI FROM CAUTHU
WHERE
    CAUTHU.MACLB IN (SELECT MACLB FROM CAULACBO WHERE TENCLB LIKE N'SHB Đà Nẵng')
    AND CAUTHU.MAQG IN (SELECT MAQG FROM QUOCGIA WHERE TENQG LIKE N'Bra-xin')

-- d.2. Cho biết kết quả (MATRAN, NGAYTD, TENSAN, TENCLB1, TENCLB2, KETQUA) các trận đấu vòng 3 của mùa bóng năm 2009.
GO
CREATE VIEW d_2 AS SELECT MATRAN, NGAYTD, TENSAN, CLB1.TENCLB AS TENCLB1, CLB2.TENCLB AS TENCLB2, KETQUA FROM
    TRANDAU INNER JOIN SANVD ON TRANDAU.MASAN = SANVD.MASAN
    INNER JOIN CAULACBO AS CLB1 ON TRANDAU.MACLB1 = CLB1.MACLB
    INNER JOIN CAULACBO AS CLB2 ON TRANDAU.MACLB2 = CLB2.MACLB
WHERE VONG = 3 AND NAM = 2009

-- d.3. Cho biết mã huấn luyện viên, họ tên, ngày sinh, địa chỉ, vai trò và tên CLB đang làm việc của các huấn luyện viên có quốc tịch “Việt Nam”.
GO
CREATE VIEW d_3 AS SELECT HUANLUYENVIEN.MAHLV, TENHLV, NGAYSINH, DIACHI, VAITRO FROM 
    HUANLUYENVIEN INNER JOIN HLV_CLB ON HUANLUYENVIEN.MAHLV = HLV_CLB.MAHLV
    INNER JOIN CAULACBO ON HLV_CLB.MACLB = CAULACBO.MACLB
WHERE HUANLUYENVIEN.MAQG IN (SELECT MAQG FROM QUOCGIA WHERE TENQG LIKE N'Việt Nam')

-- d.4. Cho biết mã câu lạc bộ, tên câu lạc bộ, tên sân vận động, địa chỉ và số lượng cầu thủ nước ngoài (có quốc tịch khác “Việt Nam”) tương ứng của các câu lạc bộ nhiều hơn 2 cầu thủ nước ngoài.
GO
CREATE VIEW d_4 AS SELECT CAULACBO.MACLB, TENCLB, TENSAN, DIACHI, [SOCAUTHUNUOCNGOAI] FROM 
    (SELECT MACLB, COUNT(MACT) AS SOCAUTHUNUOCNGOAI FROM CAUTHU 
        WHERE MAQG NOT IN
            (SELECT MAQG FROM QUOCGIA WHERE TENQG LIKE N'Việt Nam')
        GROUP BY MACLB) AS TABLE1
    INNER JOIN CAULACBO ON TABLE1.MACLB = CAULACBO.MACLB
    INNER JOIN SANVD ON CAULACBO.MASAN = SANVD.MASAN
WHERE SOCAUTHUNUOCNGOAI > 2

-- d.5. Cho biết tên tỉnh, số lượng câu thủ đang thi đấu ở vị trí tiền đạo trong các câu lạc bộ thuộc địa bàn tỉnh đó quản lý.
GO
CREATE VIEW d_5 AS SELECT TENTINH, SOLUONG FROM
    TINH INNER JOIN 
        (SELECT CAULACBO.MACLB, CAULACBO.MATINH, COUNT(MACT) AS SOLUONG FROM 
            CAULACBO INNER JOIN CAUTHU ON CAULACBO.MACLB = CAUTHU.MACLB
        WHERE VITRI LIKE N'Tiền đạo'
        GROUP BY CAULACBO.MACLB, CAULACBO.MATINH) AS TABLE2
     ON TINH.MATINH = TABLE2.MATINH

-- d.6. Cho biết tên câu lạc bộ, tên tỉnh mà CLB đang đóng nằm ở vị trí cao nhất của bảng xếp hạng của vòng 3 năm 2009.
GO
CREATE VIEW d_6 AS SELECT TENCLB, TENTINH FROM
    CAULACBO INNER JOIN TINH ON CAULACBO.MATINH = TINH.MATINH
WHERE MACLB IN
    (SELECT TOP 1 MACLB FROM BANGXH
    WHERE VONG = 3 AND NAM = 2009
    ORDER BY HANG)

-- d.7. Cho biết tên huấn luyện viên đang nắm giữ một vị trí trong 1 câu lạc bộ mà chưa có số điện thoại.
GO
CREATE VIEW d_7 AS SELECT TENHLV FROM HUANLUYENVIEN
WHERE DIENTHOAI IS NULL
    AND MAHLV IN (SELECT MAHLV FROM HLV_CLB)

-- d.8. Liệt kê các huấn luyện viên thuộc quốc gia Việt Nam chưa làm công tác huấn luyện tại bất kỳ một câu lạc bộ
GO
CREATE VIEW d_8 AS SELECT * FROM HUANLUYENVIEN
WHERE MAQG IN (SELECT MAQG FROM QUOCGIA WHERE TENQG LIKE N'Việt Nam')
    AND MAHLV NOT IN (SELECT MAHLV FROM HLV_CLB)
GO