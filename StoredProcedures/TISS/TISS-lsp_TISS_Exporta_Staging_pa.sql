USE [TISS]
GO
/****** Object:  StoredProcedure [dbo].[lsp_TISS_Exporta_Staging_pa]    Script Date: 10/20/2018 8:43:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[lsp_TISS_Exporta_Staging_pa]
(@ChaveMSG int)

AS
SET NOCOUNT ON;

DECLARE @MINIMO 		INT
DECLARE @MAXIMO 		INT

-- Cria ou Apaga linhas da Temporaria (STAGING)
DROP TABLE IF EXISTS [tempdb].[dbo].[TISS_Staging];

CREATE TABLE [tempdb].[dbo].[TISS_Staging](
    [numlinha] [int] identity(1,1) NOT NULL,
	[chaveimportacao] [int] NOT NULL,
	[numconta] [int] NOT NULL,
	[tipolinha] [tinyint] NULL,
	[linha] [varchar](1000) NULL,
	[agg] [int] NULL
) ON [PRIMARY]


SELECT 
		@MINIMO = MIN(Minimo),
		@MAXIMO = MAX(Maximo)
	FROM
	(
		SELECT MIN(Chave_cnt) AS Minimo, MAX(Chave_cnt) AS Maximo
		FROM guiaSP_SADT,loteGuias 
		WHERE Chave_lgs = loteGuias.Chave AND loteGuias.Chave_msg = @ChaveMSG
		  UNION
		SELECT MIN(Chave_cnt) AS Minimo, MAX(Chave_cnt) AS Maximo
		FROM guiaResumoInternacao,loteGuias 
		WHERE Chave_lgs = loteGuias.Chave AND loteGuias.Chave_msg = @ChaveMSG
		  UNION
		SELECT MIN(Chave_cnt) AS Minimo, MAX(Chave_cnt) AS Maximo
		FROM guiaHonorarioIndividual,loteGuias
		WHERE Chave_lgs = loteGuias.Chave AND loteGuias.Chave_msg = @ChaveMSG
	) Tabela

	EXECUTE lsp_tmr_CONTA @MINIMO, @MAXIMO, @ChaveMSG;

-- Ajusta coluna AGG
WITH agrupada (conta,linha,agg)
AS
(
SELECT 
numconta
,numlinha
,dense_rank() over (partition by [chaveimportacao] order by [numconta])
FROM [tempdb].[dbo].[TISS_Staging]
WHERE tipolinha <> 0
)
UPDATE stg
SET stg.agg = agrupada.agg
FROM [tempdb].[dbo].[TISS_Staging] stg
INNER JOIN agrupada 
ON stg.numconta = agrupada.conta
AND stg.numlinha = agrupada.linha

DROP TABLE IF EXISTS [tempdb].[dbo].[TISS_Staging_ordenada];

CREATE TABLE [tempdb].[dbo].[TISS_Staging_ordenada](
    [numlinha] [int] identity(1,1) NOT NULL,
	[chaveimportacao] [int] NOT NULL,
	[numconta] [int] NOT NULL,
	[tipolinha] [tinyint] NULL,
	[linha] [varchar](1000) NULL,
	[agg] [int] NULL
) ON [PRIMARY]

INSERT [tempdb].[dbo].[TISS_Staging_ordenada]
(chaveimportacao,numconta,tipolinha,linha,agg)
SELECT 
chaveimportacao,numconta,tipolinha,linha,agg
FROM [tempdb].[dbo].[TISS_Staging]
ORDER BY agg, tipolinha

--ALTER TABLE  [tempdb].[dbo].[TISS_Staging]
--ADD CONSTRAINT [PK_TISS_Staging] PRIMARY KEY CLUSTERED 
--(
--	[numlinha] ASC,
--	[chaveimportacao] ASC,
--	[numconta] ASC
--)


SET NOCOUNT OFF;