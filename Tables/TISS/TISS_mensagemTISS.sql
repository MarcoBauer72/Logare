USE [TISS]
GO

/****** Object:  Table [dbo].[mensagemTISS]    Script Date: 10/20/2018 8:53:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[mensagemTISS](
	[Chave] [int] IDENTITY(1,1) NOT NULL,
	[tipoTransacao] [varchar](50) NULL,
	[sequencialTransacao] [bigint] NULL,
	[dataRegistroTransacao] [varchar](30) NULL,
	[horaRegistroTransacao] [varchar](30) NULL,
	[codigoGlosa] [varchar](4) NULL,
	[descricaoGlosa] [varchar](100) NULL,
	[observacao] [varchar](240) NULL,
	[org_CNPJ] [varchar](14) NULL,
	[org_cpf] [varchar](11) NULL,
	[org_codigoPrestadorNaOperadora] [varchar](20) NULL,
	[org_registroANS] [varchar](6) NULL,
	[dst_CNPJ] [varchar](14) NULL,
	[dst_cpf] [varchar](11) NULL,
	[dst_codigoPrestadorNaOperadora] [varchar](20) NULL,
	[dst_registroANS] [varchar](6) NULL,
	[versaoPadrao] [varchar](10) NULL,
	[ArquivoNome] [varchar](255) NULL,
	[ArquivoData] [datetime] NULL,
	[nomeAplicativo] [varchar](100) NULL,
	[versaoAplicativo] [varchar](100) NULL,
	[fabricanteAplicativo] [varchar](100) NULL,
	[loginPrestador] [varchar](255) NULL,
	[senhaPrestador] [varchar](255) NULL,
	[hash] [varchar](255) NULL,
	[numGrd] [varchar](50) NULL,
	[codTsNr] [varchar](20) NULL,
	[op] [varchar](30) NULL,
	[Arquivo] [varchar](100) NULL,
	[tamanho_arquivo] [varchar](50) NULL,
	[flag_importado] [bit] NULL,
	[flag_movido_sucesso] [bit] NULL,
	[flag_movido_erro] [bit] NULL,
	[flag_movido_loga] [bit] NULL,
 CONSTRAINT [pk_msg] PRIMARY KEY CLUSTERED 
(
	[Chave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[mensagemTISS] ADD  CONSTRAINT [DF_mensagemTISS_tamanho_arquivo]  DEFAULT ((0)) FOR [tamanho_arquivo]
GO

ALTER TABLE [dbo].[mensagemTISS] ADD  CONSTRAINT [DF_mensagemTISS_flag_importado]  DEFAULT ((0)) FOR [flag_importado]
GO

ALTER TABLE [dbo].[mensagemTISS] ADD  CONSTRAINT [DF_mensagemTISS_flag_movido_sucesso]  DEFAULT ((0)) FOR [flag_movido_sucesso]
GO

ALTER TABLE [dbo].[mensagemTISS] ADD  CONSTRAINT [DF_mensagemTISS_flag_movido_erro]  DEFAULT ((0)) FOR [flag_movido_erro]
GO

ALTER TABLE [dbo].[mensagemTISS] ADD  CONSTRAINT [DF_mensagemTISS_flag_movido_loga]  DEFAULT ((0)) FOR [flag_movido_loga]
GO


