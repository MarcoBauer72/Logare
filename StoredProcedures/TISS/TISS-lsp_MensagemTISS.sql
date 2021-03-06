USE [TISS]
GO
/****** Object:  StoredProcedure [dbo].[lsp_MensagemTISS]    Script Date: 10/20/2018 8:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 ALTER PROC [dbo].[lsp_MensagemTISS]
(@ArquivoNome VARCHAR(255),@VersaoXML varchar(10), @tamanho varchar(50), @ChaveMSG INT OUTPUT, @NOME VARCHAR(150) OUTPUT, @CAMINHO VARCHAR(255) OUTPUT)
AS
BEGIN

-- TESTE AMIL:
-- DECLARE @ArquivoNome VARCHAR(255) = 'D:\OneDrive\BauerTech\Clientes\Logare\Arquivos\Amil\2018\XML\20180803\2018070316582600000001000896900000196.xml'

-- TESTE INTERMEDICA:
-- DECLARE @ArquivoNome VARCHAR(255) = 'D:\Arquivos\Intermedica\xml_valido\ftp\2018\08\02\2039445-3219\1282336_Protocolo_1282336.xml' 

-- TESTE SAOFRANCISCO
-- DECLARE @ArquivoNome VARCHAR(255) = 'D:\Arquivos\SaoFrancisco\XML\2018\11\13\302091-0000001594-2601708-072018\2601708 - GUARIBA.xml'

DECLARE @op VARCHAR(30);
SET @NOME  = REVERSE(SUBSTRING(SUBSTRING(REVERSE(@ArquivoNome),0,CHARINDEX('\',REVERSE(@ArquivoNome))),5,LEN(@ArquivoNome)));
SET @CAMINHO  = REVERSE(SUBSTRING(REVERSE(@ArquivoNome),CHARINDEX('\',REVERSE(@ArquivoNome))+1,LEN(@ArquivoNome)))

IF CHARINDEX('Amil',@ArquivoNome) > 0 
BEGIN
	SET @op = 'AMIL';
END
ELSE IF CHARINDEX('Eletros',@ArquivoNome) > 0 
BEGIN
	SET @op = 'ELETROS';
END
ELSE IF CHARINDEX('Intermedica',@ArquivoNome) > 0
BEGIN
	SET @op = 'INTERMEDICA';
END
ELSE IF CHARINDEX('SaoFrancisco',@ArquivoNome) > 0 
BEGIN
	SET @op = 'SAOFRANCISCO';
END
ELSE IF CHARINDEX('FioSaude',@ArquivoNome) > 0
BEGIN
	SET @op = 'FIOSAUDE';
END;

WITH XMLNAMESPACES ('http://www.ans.gov.br/padroes/tiss/schemas' AS ans)

INSERT [dbo].[mensagemTISS] 
(tipoTransacao,sequencialTransacao,dataRegistroTransacao,horaRegistroTransacao,org_codigoPrestadorNaOperadora
,dst_codigoPrestadorNaOperadora,dst_registroANS,versaoPadrao,hash,numGrd,codTsNr,ArquivoNome,ArquivoData,op,Arquivo,tamanho_arquivo
 )
SELECT  
 ArquivoXML.value('(/ans:mensagemTISS/ans:cabecalho/ans:identificacaoTransacao/ans:tipoTransacao)[1]','varchar(50)') AS tipoTransacao
,ArquivoXML.value('(/ans:mensagemTISS/ans:cabecalho/ans:identificacaoTransacao/ans:sequencialTransacao)[1]','bigint') AS sequencialTransacao
,ArquivoXML.value('(/ans:mensagemTISS/ans:cabecalho/ans:identificacaoTransacao/ans:dataRegistroTransacao)[1]','varchar(100)') AS dataRegistroTransacao
,ArquivoXML.value('(/ans:mensagemTISS/ans:cabecalho/ans:identificacaoTransacao/ans:horaRegistroTransacao)[1]','varchar(100)') AS horaRegistroTransacao
,ArquivoXML.value('(/ans:mensagemTISS/ans:cabecalho/ans:origem/ans:identificacaoPrestador/ans:codigoPrestadorNaOperadora)[1]','varchar(100)') AS org_codigoPrestadorNaOperadora
,ArquivoXML.value('(/ans:mensagemTISS/ans:cabecalho/ans:destino/ans:codigoPrestadorNaOperadora)[1]','varchar(100)') AS dst_codigoPrestadorNaOperadora
,ArquivoXML.value('(/ans:mensagemTISS/ans:cabecalho/ans:destino/ans:registroANS)[1]','varchar(100)') AS dst_registroANS
,@VersaoXML
,ArquivoXML.value('(/ans:mensagemTISS/ans:epilogo/ans:hash)[1]','varchar(100)') AS hash
,ArquivoXML.value('(/ans:mensagemTISS/ans:prestadorParaOperadora/ans:loteGuias/ans:numGrd)[1]','varchar(100)') AS numGrd
,ArquivoXML.value('(/ans:mensagemTISS/ans:prestadorParaOperadora/ans:loteGuias/ans:codTsNr)[1]','varchar(20)') AS codTsNr
,@ArquivoNome
,GETDATE()
,@op
,@NOME -- Sem Extensao do Arquivo
,@tamanho
FROM [TempDB].[dbo].[PreImportaXML]
WHERE LEN(ArquivoXML.value('(/ans:mensagemTISS/ans:cabecalho/ans:identificacaoTransacao/ans:tipoTransacao)[1]','varchar(50)') )>0

SET  @ChaveMSG = @@IDENTITY
SELECT  @ChaveMSG AS id,@NOME AS nome,@CAMINHO AS caminho;
RETURN;

END
