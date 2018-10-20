USE [Loga]
GO
/****** Object:  StoredProcedure [ctrl].[lsp_PreImportaSAS]    Script Date: 10/20/2018 8:46:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ctrl].[lsp_PreImportaSAS]

AS


IF OBJECT_ID('tempdb..PreImportaSAS') IS NULL
CREATE TABLE tempdb.dbo.PreImportaSAS
(
 [numlinha] [int] NOT NULL,
 [numconta] [int] NOT NULL,
 [tipolinha]  tinyint NULL,
 [linha] [varchar](1000) NULL
)
ELSE TRUNCATE TABLE tempdb.dbo.PreImportaSAS
