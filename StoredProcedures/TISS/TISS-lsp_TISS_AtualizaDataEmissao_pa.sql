USE [TISS]
GO
/****** Object:  StoredProcedure [dbo].[lsp_TISS_AtualizaDataEmissao_pa]    Script Date: 10/20/2018 8:42:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Checa se alguma guia esta sem a dataEmissao e tenta usar uma data valida 
CREATE PROCEDURE [dbo].[lsp_TISS_AtualizaDataEmissao_pa]
(@ChaveMSG int)
AS

SET NOCOUNT ON;
UPDATE g SET 	
	g.dataEmissaoGuia = coalesce(
		(select min(dataRealizacao) from tiss.dbo.guiaSP_SADT_dsp where chave_gsp = g.chave)
		,(select min(data) from tiss.dbo.guiaSP_SADT_prc where chave_gsp = g.chave)
		,g.dataAutorizacao
	)
FROM
	TISS.dbo.mensagemTISS m
	INNER JOIN TISS.dbo.loteGuias l on 
		m.Chave = l.Chave_msg
	INNER JOIN TISS.dbo.guiaSP_SADT g on
		l.Chave = g.Chave_lgs
WHERE g.dataEmissaoGuia IS NULL OR LEN(dataEmissaoGuia) < 8
	  AND m.Chave = @ChaveMSG
SET NOCOUNT OFF;