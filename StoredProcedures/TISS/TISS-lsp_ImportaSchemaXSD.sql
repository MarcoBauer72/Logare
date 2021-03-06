USE [TISS]
GO
/****** Object:  StoredProcedure [ctrl].[lsp_ImportaSchemasXSD]    Script Date: 10/20/2018 8:18:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ctrl].[lsp_ImportaSchemasXSD]
AS
BEGIN


-- Importa cada XSD para cada versao do XML TISS

---------- V2_01_02 ----------
IF NOT EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'TISS_2_01_02')
BEGIN
DECLARE @XSD20102 XML
SET @XSD20102 = (
    SELECT CAST(BulkColumn AS XML)
    FROM OPENROWSET(BULK N'E:\OneDrive\BauerTech\Clientes\Logare\Arquivos\Amil\VERSOES\2_01_02.xsd', SINGLE_BLOB)
    AS Arquivo) 

-- Cria um novo schema de validação
CREATE XML SCHEMA COLLECTION TISS_2_01_02 AS @XSD20102
END

---------- V2_01_03 ----------
--IF NOT EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'TISS_2_01_03')
--BEGIN
--DECLARE @XSD20103 XML
--SET @XSD20103 = (
--    SELECT CAST(BulkColumn AS XML)
--    FROM OPENROWSET(BULK N'E:\OneDrive\BauerTech\Clientes\Logare\Arquivos\Amil\VERSOES\2_01_03.xsd', SINGLE_BLOB)
--    AS Arquivo) 

---- Cria um novo schema de validação
--CREATE XML SCHEMA COLLECTION TISS_2_01_03 AS @XSD20103 
--END


---------- V2_02_01 ----------
--IF NOT EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'TISS_2_02_01')
--BEGIN
--DECLARE @XSD20201 XML
--SET @XSD20201 = (
--    SELECT CAST(BulkColumn AS XML)
--    FROM OPENROWSET(BULK N'E:\OneDrive\BauerTech\Clientes\Logare\Arquivos\Amil\VERSOES\2_02_01.xsd', SINGLE_BLOB)
--    AS Arquivo) 

-- Cria um novo schema de validação
--CREATE XML SCHEMA COLLECTION TISS_2_02_01 AS @XSD20201 
--END
---------- V2_02_02 ----------
--IF NOT EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'TISS_2_02_02')
--BEGIN
--DECLARE @XSD20202 XML
--SET @XSD20202 = (
--    SELECT CAST(BulkColumn AS XML)
--    FROM OPENROWSET(BULK N'E:\OneDrive\BauerTech\Clientes\Logare\Arquivos\Amil\VERSOES\2_02_02.xsd', SINGLE_BLOB)
--    AS Arquivo) 

-- Cria um novo schema de validação
--CREATE XML SCHEMA COLLECTION TISS_2_02_02 AS @XSD20202 

--END

---------- V2_02_03 ----------
--IF NOT EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'TISS_2_03_00')
--BEGIN
--DECLARE @XSD20203 XML
--SET @XSD20203 = (
--    SELECT CAST(BulkColumn AS XML)
--    FROM OPENROWSET(BULK N'E:\OneDrive\BauerTech\Clientes\Logare\Arquivos\Amil\VERSOES\2_02_03.xsd', SINGLE_BLOB)
--    AS Arquivo) 

---- Cria um novo schema de validação
--CREATE XML SCHEMA COLLECTION TISS_2_02_03 AS @XSD20203 
--END

---------- V3_00_00 ----------
--IF NOT EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'TISS_3_00_00')
--BEGIN
--DECLARE @XSD30000 XML
--SET @XSD30000 = (
--    SELECT CAST(BulkColumn AS XML)
--    FROM OPENROWSET(BULK N'E:\OneDrive\BauerTech\Clientes\Logare\Arquivos\Amil\VERSOES\3_00_00.xsd', SINGLE_BLOB)
--    AS Arquivo) 

---- Cria um novo schema de validação
--CREATE XML SCHEMA COLLECTION TISS_3_00_00 AS @XSD30000
--END

---------- V3_01_00 ----------
--IF NOT EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'TISS_3_01_00')
--BEGIN
--DECLARE @XSD30100 XML
--SET @XSD30100 = (
--    SELECT CAST(BulkColumn AS XML)
--    FROM OPENROWSET(BULK N'E:\OneDrive\BauerTech\Clientes\Logare\Arquivos\Amil\VERSOES\3_01_00.xsd', SINGLE_BLOB)
--    AS Arquivo) 

---- Cria um novo schema de validação
--CREATE XML SCHEMA COLLECTION TISS_3_01_00 AS @XSD30100
--END

---------- V3_02_00 ----------
IF NOT EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'TISS_3_02_00')
BEGIN
DECLARE @XSD30200 XML
SET @XSD30200 = (
    SELECT CAST(BulkColumn AS XML)
    FROM OPENROWSET(BULK N'E:\OneDrive\BauerTech\Clientes\Logare\Arquivos\Amil\VERSOES\3_02_00.xsd', SINGLE_BLOB)
    AS Arquivo) 

-- Cria um novo schema de validação
CREATE XML SCHEMA COLLECTION TISS_3_02_00 AS @XSD30200
END


---------- V3_02_01 ----------
--IF NOT EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'TISS_3_02_01')
--BEGIN
--DECLARE @XSD30201 XML
--SET @XSD30201 = (
--    SELECT CAST(BulkColumn AS XML)
--    FROM OPENROWSET(BULK N'E:\OneDrive\BauerTech\Clientes\Logare\TISS\schemas\tissV3_02_01.xsd', SINGLE_BLOB)
--    AS Arquivo) 

---- Cria um novo schema de validação
--CREATE XML SCHEMA COLLECTION TISS_3_02_01 AS @XSD30201
--END

---------- V3_02_02 ----------
--IF NOT EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'TISS_3_02_02')
--BEGIN
--DECLARE @XSD30202 XML
--SET @XSD30202 = (
--    SELECT CAST(BulkColumn AS XML)
--    FROM OPENROWSET(BULK N'E:\OneDrive\BauerTech\Clientes\Logare\TISS\schemas\tissV3_02_02.xsd', SINGLE_BLOB)
--    AS Arquivo) 

---- Cria um novo schema de validação
--CREATE XML SCHEMA COLLECTION TISS_3_02_02 AS @XSD30202
--END

---------- V3_03_00 ----------
--IF NOT EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'TISS_3_03_00')
--BEGIN
--DECLARE @XSD30300 XML
--SET @XSD30300 = (
--    SELECT CAST(BulkColumn AS XML)
--    FROM OPENROWSET(BULK N'E:\OneDrive\BauerTech\Clientes\Logare\TISS\schemas\tissV3_03_00.xsd', SINGLE_BLOB)
--    AS Arquivo) 

---- Cria um novo schema de validação
--CREATE XML SCHEMA COLLECTION TISS_3_03_00 AS @XSD30300
--END

---------- V3_03_01 ----------
IF NOT EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'TISS_3_03_01')
BEGIN
DECLARE @XSD30301 XML
SET @XSD30301 = (
    SELECT CAST(BulkColumn AS XML)
    FROM OPENROWSET(BULK N'E:\OneDrive\BauerTech\Clientes\Logare\Arquivos\Amil\VERSOES\3_03_01.XSD', SINGLE_BLOB)
    AS Arquivo) 

-- Cria um novo schema de validação
CREATE XML SCHEMA COLLECTION TISS_3_03_01 AS @XSD30301
END

---------- V3_03_02 ----------
--IF NOT EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'TISS_3_03_02')
--BEGIN
--DECLARE @XSD30302 XML
--SET @XSD30302 = (
--    SELECT CAST(BulkColumn AS XML)
--    FROM OPENROWSET(BULK N'E:\OneDrive\BauerTech\Clientes\Logare\TISS\schemas\tissV3_03_02.xsd', SINGLE_BLOB)
--    AS Arquivo) 

---- Cria um novo schema de validação
--CREATE XML SCHEMA COLLECTION TISS_3_03_02 AS @XSD30302
--END

---------- V3_03_03 ----------
--IF NOT EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'TISS_3_03_03')
--BEGIN
--DECLARE @XSD30303 XML
--SET @XSD30303 = (
--    SELECT CAST(BulkColumn AS XML)
--    FROM OPENROWSET(BULK N'E:\OneDrive\BauerTech\Clientes\Logare\TISS\schemas\tissV3_03_03.xsd', SINGLE_BLOB)
--    AS Arquivo) 
---- Cria um novo schema de validação
--CREATE XML SCHEMA COLLECTION TISS_3_03_03 AS @XSD30303
--END

END
