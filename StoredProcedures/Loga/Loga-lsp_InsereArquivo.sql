USE [Loga]
GO
/****** Object:  StoredProcedure [dbo].[lsp_InsereArquivo]    Script Date: 10/20/2018 8:48:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[lsp_InsereArquivo]
(
 @nome varchar(1000)
,@fqn varchar(1000)
,@data varchar(30)
,@tamanho varchar(50)
,@linhas smallint
,@contas smallint
,@ArqID int output
)
AS
BEGIN
Insert [ctrl].[ArquivosImportados]
(nome_arquivo,fqn,data_arquivo,tamanho_arquivo,qtd_linhas,qtd_contas)
Values (@nome,@fqn,@data,@tamanho,@linhas,@contas)

SELECT @ArqID = SCOPE_IDENTITY()

    SELECT @ArqID AS id

    RETURN
		
END