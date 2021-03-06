USE [TISS]
GO
/****** Object:  StoredProcedure [dbo].[lsp_TISS_Atualiza_NumeroGuiaPrincipal_pa]    Script Date: 10/20/2018 8:42:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[lsp_TISS_Atualiza_NumeroGuiaPrincipal_pa]
(@ChaveMSG int)
AS
SET NOCOUNT ON;
-- ESSE UPDATE existe pq o campo nao pode ser BRANCO = '' pq se nao, ele nao exporta a guia no arquivo 
UPDATE g SET
	g.numeroGuiaPrincipal = NULL
FROM 
	guiaSP_SADT g
	INNER JOIN loteGuias l
	ON g.Chave_lgs = l.Chave
	INNER JOIN mensagemTISS m  
	ON l.Chave_msg = m.Chave 
WHERE (g.numeroGuiaPrincipal = '' or LEN(g.numeroGuiaPrincipal) = 0)
	AND m.Chave = @ChaveMSG
SET NOCOUNT OFF;	
