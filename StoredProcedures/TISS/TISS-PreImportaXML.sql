USE [TISS]
GO
/****** Object:  StoredProcedure [ctrl].[lsp_PreImportaXML]    Script Date: 10/20/2018 8:19:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ctrl].[lsp_PreImportaXML]
AS

IF OBJECT_ID('tempdb.dbo.PreImportaXML') IS NULL
BEGIN
CREATE TABLE [tempdb].[dbo].[PreImportaXML]
(
     [ID] int identity primary key,
	[ArquivoXML] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE PRIMARY XML INDEX ix_PreImportaXML
    ON [tempdb].[dbo].[PreImportaXML] (ArquivoXML)

END
ELSE TRUNCATE TABLE tempdb.dbo.PreImportaXML




