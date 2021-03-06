USE [TISS]
GO
/****** Object:  StoredProcedure [dbo].[lsp_LoteGuias]    Script Date: 10/20/2018 8:41:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[lsp_LoteGuias]
(@ChaveMSG INT, @ChaveLGS INT OUTPUT)
AS
BEGIN

WITH XMLNAMESPACES ('http://www.ans.gov.br/padroes/tiss/schemas' AS ans)

INSERT [dbo].[loteGuias] ([Chave_msg],[numeroLote])
SELECT	 @ChaveMSG
		,ArquivoXML.value('(/ans:mensagemTISS/ans:prestadorParaOperadora/ans:loteGuias/ans:numeroLote)[1]','varchar(20)') AS numeroLote
FROM [TempDB].[dbo].[PreImportaXML]
WHERE LEN(ArquivoXML.value('(/ans:mensagemTISS/ans:prestadorParaOperadora/ans:loteGuias/ans:numeroLote)[1]','varchar(20)')) > 0

SET  @ChaveLGS = @@IDENTITY
SELECT  @ChaveLGS AS id;
RETURN;

END
