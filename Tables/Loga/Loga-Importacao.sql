USE [Loga]
GO

/****** Object:  Table [dbo].[Importacao]    Script Date: 10/20/2018 8:51:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Importacao](
	[Chave] [int] IDENTITY(1,1) NOT NULL,
	[Chave_msg_tiss] [int] NULL,
	[Descricao] [varchar](255) NOT NULL,
	[NomeArquivo] [varchar](150) NOT NULL,
	[Data] [datetime] NULL,
	[NomeOriginalArquivo] [varchar](20) NULL,
	[CodigoLogGestao] [int] NULL,
	[IdArquivoSAS] [int] NULL,
	[SYSDate] [datetime] NULL,
	[tamanho_arquivo] [varchar](50) NULL,
	[qtd_linhas] [int] NULL,
	[qtd_contas] [int] NULL,
	[flag_validado] [bit] NULL,
	[flag_importado] [bit] NULL,
	[flag_movido_sucesso] [bit] NULL,
	[flag_movido_erro] [bit] NULL,
	[mensagem] [varchar](200) NULL,
	[tp] [char](3) NULL,
 CONSTRAINT [PK_Importacao] PRIMARY KEY CLUSTERED 
(
	[Chave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO


