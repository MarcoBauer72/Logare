USE [TISS]
GO
/****** Object:  StoredProcedure [ctrl].[lsp_ValidaXML]    Script Date: 10/20/2018 8:29:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ctrl].[lsp_ValidaXML]
(@versao char(7), @valido bit OUTPUT)
AS
IF @versao = '2.01.02'
BEGIN
BEGIN TRY
		DECLARE @XML20102 XML (TISS_2_01_02)
		SELECT @XML20102 = [ArquivoXML] FROM [tempdb].[dbo].[PreImportaXML]

		SELECT @valido = 1
		RETURN;
END TRY
BEGIN CATCH
		SELECT @valido = 0
		RETURN;
END CATCH
END
ELSE
IF @versao = '3.02.00'
BEGIN
BEGIN TRY
		DECLARE @XML30200 XML (TISS_3_02_00)
		SELECT @XML30200 = [ArquivoXML] FROM [tempdb].[dbo].[PreImportaXML]

		SELECT @valido = 1
		RETURN;
END TRY
BEGIN CATCH
		SELECT @valido = 0
		RETURN;
END CATCH
END
ELSE
IF @versao = '3.03.01'
BEGIN
	BEGIN TRY
		DECLARE @XML30301 XML (TISS_3_03_01)
		SELECT @XML30301 = [ArquivoXML] FROM [tempdb].[dbo].[PreImportaXML]
		SELECT @valido = 1
		RETURN;
END TRY
BEGIN CATCH
		SELECT @valido = 0
		RETURN;
	END CATCH

END
