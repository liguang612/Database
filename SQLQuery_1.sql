CREATE DATABASE CSDL
GO
USE CSDL
GO

CREATE TABLE NHANVIEN (
    NV CHAR(6) NOT NULL,
    HOTEN NVARCHAR(50),
    NAMSINH INT
)
ALTER TABLE NHANVIEN ADD CONSTRAINT pk_nhanvien PRIMARY KEY(NV)

CREATE TABLE DUAN (
    DA CHAR(6) NOT NULL,
    TENDA NVARCHAR(100),
    KINHPHI INT
)
ALTER TABLE DUAN ADD CONSTRAINT pk_duan PRIMARY KEY(DA)

CREATE TABLE THAMGIA (
    NVIEN CHAR(6) NOT NULL,
    DAN CHAR(6) NOT NULL,
    MUCLUONG INT
)
ALTER TABLE THAMGIA ADD CONSTRAINT pk_thamgia PRIMARY KEY(NVIEN, DAN)
ALTER TABLE THAMGIA ADD CONSTRAINT fk_thamgia_nhanvien FOREIGN KEY(NVIEN) REFERENCES NHANVIEN(NV)
ALTER TABLE THAMGIA ADD CONSTRAINT fk_thamgia_duan FOREIGN KEY(DAN) REFERENCES DUAN(DA)