USE [Loga]
GO
/****** Object:  StoredProcedure [ctrl].[lsp_PreImportaSAS_CNVT]    Script Date: 10/20/2018 8:47:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ctrl].[lsp_PreImportaSAS_CNVT]

AS

IF OBJECT_ID('tempdb..PreImportaSAS_CNVT') IS NULL
CREATE TABLE tempdb.dbo.PreImportaSAS_CNVT
(
 [numlinha] [int] NOT NULL,
 [numconta] [int] NOT NULL,
 [tipolinha]  tinyint NULL,
 [linha] [varchar](1000) NULL
)
ELSE TRUNCATE TABLE tempdb.dbo.PreImportaSAS_CNVT
