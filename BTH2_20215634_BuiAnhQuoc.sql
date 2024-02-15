USE QLBongDa
GO

-- CÂU A
-- a.1. Cho biết thông tin (mã cầu thủ, họ tên, số áo, vị trí, ngày sinh, địa chỉ) của tất cả các cầu thủ
SELECT MACT, HOTEN, SO, VITRI, NGAYSINH, DIACHI FROM CAUTHU

-- a.2. Hiển thị thông tin tất cả các cầu thủ có số áo là 7 chơi ở vị trí Tiền vệ.
SELECT * FROM CAUTHU WHERE SO = 7 AND VITRI = N'Tiền vệ'

-- a.3. Cho biết tên, ngày sinh, địa chỉ, điện thoại của tất cả các huấn luyện viên.
SELECT TENHLV, NGAYSINH, DIACHI, DIENTHOAI FROM HUANLUYENVIEN

-- a.4. Hiển thi thông tin tất cả các cầu thủ có quốc tịch Việt Nam thuộc câu lạc bộ Becamex Bình Dương
SELECT * FROM CAUTHU WHERE MACLB IN (SELECT MACLB FROM CAULACBO WHERE TENCLB LIKE N'BECAMEX BÌNH DƯƠNG')

-- a.5. Cho biết mã số, họ tên, ngày sinh, địa chỉ và vị trí của các cầu thủ thuộc đội bóng ‘SHB Đà Nẵng’ có quốc tịch “Bra-xin”
SELECT * FROM CAUTHU
    INNER JOIN CAULACBO ON CAUTHU.MACLB = CAULACBO.MACLB
    WHERE TENCLB LIKE N'SHB ĐÀ NẴNG' AND MAQG IN (SELECT MAQG FROM QUOCGIA WHERE TENQG LIKE 'Bra-xin')

-- a.6. Hiển thị thông tin tất cả các cầu thủ đang thi đấu trong câu lạc bộ có sân nhà là “Long An”
SELECT * FROM CAUTHU WHERE MACLB IN (SELECT MACLB FROM CAULACBO
    INNER JOIN SANVD ON CAULACBO.MASAN = SANVD.MASAN
    WHERE TENSAN LIKE N'Long An')

-- a.7. Cho biết kết quả (MATRAN, NGAYTD, TENSAN, TENCLB1, TENCLB2, KETQUA) các trận đấu vòng 2 của mùa bóng năm 2009
SELECT MATRAN, NGAYTD, TENSAN, TENCLB1, TENCLB AS TENCLB2, KETQUA FROM
    (SELECT MATRAN, NGAYTD, TENCLB AS TENCLB1, TRANDAU.MASAN, MACLB2, KETQUA FROM TRANDAU
        INNER JOIN CAULACBO ON TRANDAU.MACLB1 = CAULACBO.MACLB
        WHERE VONG = 2 AND NAM = 2009) AS TEMP1
    INNER JOIN CAULACBO ON MACLB2 = CAULACBO.MACLB
    INNER JOIN SANVD ON TEMP1.MASAN = SANVD.MASAN

-- a.8. Cho biết mã huấn luyện viên, họ tên, ngày sinh, địa chỉ, vai trò và tên CLB đang  làm veiecj của các huấn luyện viên có quốc tịch “ViệtNam”
SELECT TABLE1.MAHLV, TENHLV, NGAYSINH, DIACHI, VAITRO, TENCLB FROM
    (SELECT MAHLV, TENHLV, NGAYSINH, DIACHI FROM HUANLUYENVIEN
        INNER JOIN QUOCGIA ON HUANLUYENVIEN.MAQG = QUOCGIA.MAQG
        WHERE TENQG LIKE N'Việt Nam') AS TABLE1,
    HLV_CLB,
    CAULACBO
WHERE TABLE1.MAHLV = HLV_CLB.MAHLV AND HLV_CLB.MACLB = CAULACBO.MACLB

-- a.9. Lấy tên 3 câu lạc bộ có điểm cao nhất sau vòng 3 năm 2009
SELECT TENCLB FROM CAULACBO WHERE MACLB IN (SELECT TOP 3 MACLB FROM BANGXH ORDER BY DIEM DESC)

-- a.10. Cho biết mã huấn luyện viên, họ tên, ngày sinh, địa chỉ, vai trò và tên CLB đang làm việc mà câu lạc bộ đó đóng ở tỉnh Binh Dương.
SELECT HUANLUYENVIEN.MAHLV, TENHLV, NGAYSINH, DIACHI, VAITRO, TENCLB FROM
    (SELECT HLV_CLB.MAHLV, TENCLB, VAITRO FROM 
        (SELECT * FROM CAULACBO WHERE MATINH IN
            (SELECT MATINH FROM TINH WHERE TENTINH LIKE N'Bình Dương')) TABLE1
        INNER JOIN HLV_CLB ON TABLE1.MACLB = HLV_CLB.MACLB
    ) AS TABLE2
    INNER JOIN HUANLUYENVIEN ON TABLE2.MAHLV = HUANLUYENVIEN.MAHLV

-- CÂU B
-- b.1. Thống kê số lượng cầu thủ của mỗi câu lạc bộ
SELECT CAULACBO.MACLB, TENCLB, [SOCAUTHU] FROM 
    (SELECT MACLB, COUNT(MACT) AS SOCAUTHU FROM CAUTHU GROUP BY MACLB) AS TABLE1
    INNER JOIN CAULACBO ON TABLE1.MACLB = CAULACBO.MACLB

-- b.2. Thống kê số lượng cầu thủ nước ngoài (có quốc tịch Việt Nam) của mỗi câu lạc bộ
SELECT CAULACBO.MACLB, TENCLB, [SOCAUTHUNUOCNGOAI] FROM 
    (SELECT MACLB, COUNT(MACT) AS SOCAUTHUNUOCNGOAI FROM CAUTHU WHERE MAQG NOT IN (SELECT MAQG FROM QUOCGIA WHERE TENQG LIKE N'Việt Nam') GROUP BY MACLB) AS TABLE1
    INNER JOIN CAULACBO ON TABLE1.MACLB = CAULACBO.MACLB

-- b.3. Cho biết mã câu lạc bộ, tên câu lạc bộ, tên sân vận động, địa chỉ và số lượng cầu thủ nước ngoài (có quốc tịch khác Việt Nam) tương ứng của các câu lạc bộ có nhiều hơn 2 cầu thủ nước ngoài.
SELECT CAULACBO.MACLB, TENCLB, TENSAN, DIACHI, [SOCAUTHUNUOCNGOAI] FROM 
    (SELECT MACLB, COUNT(MACT) AS SOCAUTHUNUOCNGOAI FROM CAUTHU WHERE MAQG NOT IN (SELECT MAQG FROM QUOCGIA WHERE TENQG LIKE N'Việt Nam') GROUP BY MACLB) AS TABLE1
    INNER JOIN CAULACBO ON TABLE1.MACLB = CAULACBO.MACLB
    INNER JOIN SANVD ON CAULACBO.MASAN = SANVD.MASAN
WHERE SOCAUTHUNUOCNGOAI > 2

-- b.4. Cho biết tên tỉnh, số lượng cầu thủ đang t hi đấu ở vị trí tiền đạo trong các câu lạc bộ thuộc địa bàn tỉnh đó quản lý.
SELECT MATINH, TENTINH, COUNT(MACT) AS SOLUONG FROM
    (SELECT TINH.MATINH, TENTINH, MACLB FROM CAULACBO INNER JOIN TINH ON CAULACBO.MATINH = TINH.MATINH) AS TABLE1
    INNER JOIN CAUTHU ON TABLE1.MACLB = CAUTHU.MACLB
WHERE VITRI LIKE N'Tiền đạo' GROUP BY MATINH, TENTINH

-- b.5. Cho biết tên câu lạc bộ, tên tỉnh mà CLB đang đóng nằm ở vị trí cao nhất của bảng xếp hạng vòng 3, năm 2009.
SELECT TENCLB, TENTINH FROM CAULACBO INNER JOIN TINH ON CAULACBO.MATINH = TINH.MATINH WHERE MACLB IN 
    (SELECT TOP 1 MACLB FROM BANGXH WHERE VONG = 3 AND NAM = 2009 ORDER BY HANG)

-- c.1. Cho biết tên huấn luyện viên đang nắm giữ một vị trí trong một câu lạc bộ mà chưa có số điện thoại
SELECT TENHLV FROM HUANLUYENVIEN, HLV_CLB WHERE HUANLUYENVIEN.MAHLV = HLV_CLB.MAHLV AND VAITRO IS NOT NULL AND DIENTHOAI IS NULL

-- c.2. Liệt kê các huấn luyện viên thuộc quốc gia Việt Nam chưa làm công tác huấn luyện tại bất kỳ một câu lạc bộ nào.
SELECT * FROM HUANLUYENVIEN WHERE
    MAQG IN (SELECT MAQG FROM QUOCGIA WHERE TENQG LIKE N'Việt Nam') AND
    MAHLV NOT IN (SELECT MAHLV FROM HLV_CLB)

-- c.3. Liệt kê các cầu thủ đang thi đấu trong các câu lạc bộ có thứ hạng ở vòng 3 năm 2009 lớn hơn 6 hoặc nhỏ hơn 3
SELECT * FROM CAUTHU WHERE MACLB IN (SELECT DISTINCT MACLB FROM BANGXH WHERE HANG > 6 OR HANG < 3)

-- c.4. Cho biết danh sách các trận đấu (NGAYTD, TENSAN, TENCLB1, TENCLB2, KETQUA) của câu lạc bộ (CLB) đang xếp hạng cao nhất tính đến hết vòng 3 năm 2009.
SELECT * FROM TRANDAU WHERE
    MACLB1 IN (SELECT MACLB FROM BANGXH WHERE HANG = 1 AND VONG = 3 AND NAM = 2009) OR
    MACLB2 IN (SELECT MACLB FROM BANGXH WHERE HANG = 1 AND VONG = 3 AND NAM = 2009)
