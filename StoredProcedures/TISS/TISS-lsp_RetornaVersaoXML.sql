USE [TISS]
GO
/****** Object:  StoredProcedure [ctrl].[lsp_RetornaVersaoXML]    Script Date: 10/20/2018 8:20:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [ctrl].[lsp_RetornaVersaoXML]
(@versao varchar(10) OUTPUT)
AS
BEGIN
DECLARE @xml XML 
SELECT @xml = [ArquivoXML] FROM [tempdb].[dbo].[PreImportaXML]

;WITH XMLNAMESPACES('http://www.ans.gov.br/padroes/tiss/schemas' AS ans)
SELECT
    @versao = XC.value('(ans:versaoPadrao)[1]', 'varchar(10)')
FROM
    @xml.nodes('/mensagemTISS/cabecalho') AS XT(XC)

IF @versao IS NULL
WITH XMLNAMESPACES('http://www.ans.gov.br/padroes/tiss/schemas' AS ansTISS)
SELECT
    @versao = XC.value('(ansTISS:versaoPadrao)[1]', 'varchar(10)')
FROM
    @xml.nodes('/mensagemTISS/cabecalho') AS XT(XC)

IF @versao IS NULL
 WITH XMLNAMESPACES(DEFAULT 'http://www.ans.gov.br/padroes/tiss/schemas')
SELECT
    @versao = XC.value('(versaoPadrao)[1]', 'varchar(10)')
FROM
    @xml.nodes('/mensagemTISS/cabecalho') AS XT(XC)

IF @versao IS NULL
 WITH XMLNAMESPACES(DEFAULT 'http://www.ans.gov.br/padroes/tiss/schemas')
SELECT
    @versao = XC.value('(Padrao)[1]', 'varchar(10)')
FROM
    @xml.nodes('/mensagemTISS/cabecalho') AS XT(XC)

IF @versao IS NULL
 WITH XMLNAMESPACES('http://www.ans.gov.br/padroes/tiss/schemas' AS ans)
SELECT
    @versao = XC.value('(ans:Padrao)[1]', 'varchar(10)')
FROM
    @xml.nodes('/mensagemTISS/cabecalho') AS XT(XC)

IF (@versao IS NULL OR LEN(@versao)<2)
SET @versao =('Indefinida') -- Arquivo sem versao definida

SELECT @versao

RETURN
END