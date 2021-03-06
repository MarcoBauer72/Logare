USE [Loga]
GO
/****** Object:  StoredProcedure [ctrl].[lsp_AtualizaArquivo]    Script Date: 10/20/2018 8:46:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ctrl].[lsp_AtualizaArquivo]
@arqid INT
,@flagvalidado bit
,@flagimportado bit
,@flagsucesso bit
,@flagerro bit
,@numconta int
,@msg VARCHAR (200)
AS
BEGIN
    UPDATE [ctrl].[ArquivosImportados]
    SET    flag_validado			= @flagvalidado
           ,flag_importado			= @flagimportado
           ,flag_movido_sucesso		= @flagsucesso
           ,flag_movido_erro		= @flagerro
		   ,ultimaconta_importada	= @numconta
           ,mensagem				= @msg
    WHERE  arquivo_id = @arqid;
END

