USE [TISS]
GO
/****** Object:  StoredProcedure [dbo].[lsp_TISS_Corrige_Prestadores_pa]    Script Date: 10/20/2018 8:43:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[lsp_TISS_Corrige_Prestadores_pa]
(@ChaveMSG int)

AS
SET NOCOUNT ON;

DECLARE @operadora varchar(30)
SELECT @operadora = op FROM TISS.dbo.mensagemTISS WHERE Chave = @ChaveMSG

-- ************************************************************************************************************************************************************************************************************
-- ************************************************************************************************************************************************************************************************************
-- DA UMA OLHADA ANTES DE RODAR APENAS PARA CHECAR SE REALMENTE TEM ALGUM PROBLEMA COM OS CODIGOS DE PRESTAORES E DA OPERADORA.
-- ************************************************************************************************************************************************************************************************************
-- ************************************************************************************************************************************************************************************************************

IF @operadora = 'AMIL'
	BEGIN
			--------------------------------------------------------------- AMIL ---------------------------------------------------------------  
			-- mensagemTISS -> Atualiza campos: dst_registroANS e dst_codigoPrestadorNaOperadora
			
			--TESTE: SELECT dst_registroANS, dst_codigoPrestadorNaOperadora FROM mensagemTISS WHERE Chave = @ChaveMSG
			-- 326305	NULL

			UPDATE mensagemTISS 
			SET	dst_registroANS = '326305',
				dst_codigoPrestadorNaOperadora = TRY_CAST(SUBSTRING(RIGHT(Arquivo,23),1,15) AS INT)
			WHERE 
				Chave = @ChaveMSG
			 
			--TEST: SELECT TRY_CAST(SUBSTRING(RIGHT(Arquivo,23),1,15) AS INT) FROM mensagemTISS WHERE Chave = @ChaveMSG

			-- guiaResumoInternacao -> Atualiza campo: codigoPrestadorNaOperadora
			-- TESTE: 
					--SELECT * FROM 
					--guiaResumoInternacao
					--LEFT JOIN loteGuias ON
					--	guiaResumoInternacao.Chave_lgs = loteGuias.Chave 
					--LEFT JOIN mensagemTISS ON
					--	loteGuias.Chave_msg = mensagemTISS.Chave 
					--LEFT JOIN operadora ON
					--	mensagemTISS.dst_registroANS = operadora.registroANS
					--WHERE 
					--mensagemTISS.Chave = @ChaveMSG

			UPDATE guiaResumoInternacao 
			SET	 guiaResumoInternacao.codigoPrestadorNaOperadora = mensagemTISS.dst_codigoPrestadorNaOperadora
			FROM 
			  guiaResumoInternacao
				LEFT JOIN loteGuias ON
				  guiaResumoInternacao.Chave_lgs = loteGuias.Chave 
				LEFT JOIN mensagemTISS ON
				  loteGuias.Chave_msg = mensagemTISS.Chave 
				LEFT JOIN operadora ON
				  mensagemTISS.dst_registroANS = operadora.registroANS
			WHERE 
				mensagemTISS.Chave = @ChaveMSG

			-- guiaSP_SADT -> Atualiza campo: pe1_codigoPrestadorNaOperadora
			
			--TESTE:
			--SELECT pe1_codigoPrestadorNaOperadora
			--FROM 
			--	guiaSP_SADT
			--	LEFT JOIN loteGuias ON
			--		guiaSP_SADT.Chave_lgs = loteGuias.Chave 
			--	LEFT JOIN mensagemTISS ON
			--		loteGuias.Chave_msg = mensagemTISS.Chave 
			--	LEFT JOIN operadora ON
			--		mensagemTISS.dst_registroANS = operadora.registroANS
			--WHERE   	
			--	mensagemTISS.Chave = @ChaveMSG

			UPDATE guiaSP_SADT
			SET	guiaSP_SADT.pe1_codigoPrestadorNaOperadora = mensagemTISS.dst_codigoPrestadorNaOperadora
			FROM 
			  guiaSP_SADT
				LEFT JOIN loteGuias ON
				  guiaSP_SADT.Chave_lgs = loteGuias.Chave 
				LEFT JOIN mensagemTISS ON
				  loteGuias.Chave_msg = mensagemTISS.Chave 
				LEFT JOIN operadora ON
				  mensagemTISS.dst_registroANS = operadora.registroANS
			WHERE   	
				mensagemTISS.Chave = @ChaveMSG


	END
ELSE IF @operadora = 'ELETROS'
	BEGIN
			--------------------------------------------------------------- ELETROS ---------------------------------------------------------------
			-- mensagemTISS -> Atualiza campos: dst_registroANS e dst_codigoPrestadorNaOperadora
			UPDATE mensagemTISS 
			SET	mensagemTISS.dst_registroANS = '313904',
				mensagemTISS.dst_codigoPrestadorNaOperadora = SUBSTRING(SUBSTRING(mensagemTISS.ArquivoNome,CHARINDEX('-',mensagemTISS.ArquivoNome,1)+1,CHARINDEX('.xml',mensagemTISS.ArquivoNome,1)),1,CHARINDEX('\',SUBSTRING(mensagemTISS.ArquivoNome,CHARINDEX('-',mensagemTISS.ArquivoNome,1)+1,CHARINDEX('.xml',mensagemTISS.ArquivoNome,1)))-1) 
			WHERE	
				Chave = @ChaveMSG

			-- guiaResumoInternacao -> Atualiza campo: codigoPrestadorNaOperadora
			UPDATE guiaResumoInternacao 
			SET	 guiaResumoInternacao.codigoPrestadorNaOperadora = mensagemTISS.dst_codigoPrestadorNaOperadora
			FROM 
			  guiaResumoInternacao
				LEFT JOIN loteGuias ON
				  guiaResumoInternacao.Chave_lgs = loteGuias.Chave 
				LEFT JOIN mensagemTISS ON
				  loteGuias.Chave_msg = mensagemTISS.Chave 
				LEFT JOIN operadora ON
				  mensagemTISS.dst_registroANS = operadora.registroANS
			WHERE 
				mensagemTISS.Chave = @ChaveMSG

			-- guiaSP_SADT -> Atualiza campo: pe1_codigoPrestadorNaOperadora
			UPDATE guiaSP_SADT
			SET	guiaSP_SADT.pe1_codigoPrestadorNaOperadora = mensagemTISS.dst_codigoPrestadorNaOperadora
			FROM 
			  guiaSP_SADT
				LEFT JOIN loteGuias ON
				  guiaSP_SADT.Chave_lgs = loteGuias.Chave 
				LEFT JOIN mensagemTISS ON
				  loteGuias.Chave_msg = mensagemTISS.Chave 
				LEFT JOIN operadora ON
				  mensagemTISS.dst_registroANS = operadora.registroANS
			WHERE  
				mensagemTISS.Chave = @ChaveMSG
	END

ELSE IF @operadora = 'FIOSAUDE'
	BEGIN
			--------------------------------------------------------------- FIOSAUDE ---------------------------------------------------------------
			-- mensagemTISS -> Atualiza campos: dst_registroANS e dst_codigoPrestadorNaOperadora
			UPDATE mensagemTISS 
			SET	mensagemTISS.dst_registroANS = '417548',
				mensagemTISS.dst_codigoPrestadorNaOperadora = SUBSTRING(SUBSTRING(mensagemTISS.ArquivoNome,CHARINDEX('-',mensagemTISS.ArquivoNome,1)+1,CHARINDEX('.xml',mensagemTISS.ArquivoNome,1)),1,CHARINDEX('\',SUBSTRING(mensagemTISS.ArquivoNome,CHARINDEX('-',mensagemTISS.ArquivoNome,1)+1,CHARINDEX('.xml',mensagemTISS.ArquivoNome,1)))-1) 
			WHERE	
				Chave = @ChaveMSG
	END

ELSE IF @operadora = 'INTERMEDICA'
	BEGIN
			--------------------------------------------------------------- INTERMEDICA ---------------------------------------------------------------
			-- mensagemTISS -> Atualiza campos: dst_registroANS e dst_codigoPrestadorNaOperadora
			UPDATE mensagemTISS 
			SET	mensagemTISS.dst_registroANS = '008000',
				mensagemTISS.dst_codigoPrestadorNaOperadora =
				TRY_CAST(
				CASE 
					WHEN (CHARINDEX('_', REVERSE(SUBSTRING(REVERSE(mensagemTISS.ArquivoNome),1,CHARINDEX('\',REVERSE(mensagemTISS.ArquivoNome))-1)), 6) -4) < 0
					THEN 
						SUBSTRING(REVERSE(SUBSTRING(REVERSE(mensagemTISS.ArquivoNome),1,CHARINDEX('-',REVERSE(mensagemTISS.ArquivoNome))-1)),1,CHARINDEX('\',REVERSE(SUBSTRING(REVERSE(mensagemTISS.ArquivoNome),1,CHARINDEX('-',REVERSE(mensagemTISS.ArquivoNome))-1)))-1)
			
					ELSE
						SUBSTRING(
							REVERSE(SUBSTRING(REVERSE(mensagemTISS.ArquivoNome),1,CHARINDEX('\',REVERSE(mensagemTISS.ArquivoNome))-1)) -- Nome Arquivo Sem o Path
							,4
							,CHARINDEX('_', REVERSE(SUBSTRING(REVERSE(mensagemTISS.ArquivoNome),1,CHARINDEX('\',REVERSE(mensagemTISS.ArquivoNome))-1)), 6) -4 -- Procura '_' comecando na 6 casa - 4 do comeco da string
						) 
				END AS INT)
			WHERE	
				Chave = @ChaveMSG

			-- guiaResumoInternacao -> Atualiza campo: codigoPrestadorNaOperadora
			UPDATE guiaResumoInternacao 
			SET	 guiaResumoInternacao.codigoPrestadorNaOperadora = mensagemTISS.dst_codigoPrestadorNaOperadora
			FROM 
			  guiaResumoInternacao
				LEFT JOIN loteGuias ON
				  guiaResumoInternacao.Chave_lgs = loteGuias.Chave 
				LEFT JOIN mensagemTISS ON
				  loteGuias.Chave_msg = mensagemTISS.Chave 
				LEFT JOIN operadora ON
				  mensagemTISS.dst_registroANS = operadora.registroANS
			WHERE 
				mensagemTISS.Chave = @ChaveMSG

			-- guiaSP_SADT -> Atualiza campo: pe1_codigoPrestadorNaOperadora
			UPDATE guiaSP_SADT
			SET	guiaSP_SADT.pe1_codigoPrestadorNaOperadora = mensagemTISS.dst_codigoPrestadorNaOperadora
			FROM 
			  guiaSP_SADT
				LEFT JOIN loteGuias ON
				  guiaSP_SADT.Chave_lgs = loteGuias.Chave 
				LEFT JOIN mensagemTISS ON
				  loteGuias.Chave_msg = mensagemTISS.Chave 
				LEFT JOIN operadora ON
				  mensagemTISS.dst_registroANS = operadora.registroANS
			WHERE   
				mensagemTISS.Chave = @ChaveMSG
	END

ELSE IF @operadora = 'SAOFRANCISCO'
	BEGIN
		--------------------------------------------------------------- SAO FRANCISCO ---------------------------------------------------------------
		-- mensagemTISS -> Atualiza campos: dst_registroANS e dst_codigoPrestadorNaOperadora
		UPDATE mensagemTISS 
		SET	mensagemTISS.dst_registroANS = '302091',
		mensagemTISS.dst_codigoPrestadorNaOperadora = TRY_CAST(SUBSTRING(SUBSTRING(mensagemTISS.ArquivoNome,CHARINDEX('-',mensagemTISS.ArquivoNome,1)+1,CHARINDEX('.xml',mensagemTISS.ArquivoNome,1)),1,10) AS INT)
		WHERE	
			Chave = @ChaveMSG

		-- guiaResumoInternacao -> Atualiza campo: codigoPrestadorNaOperadora
		UPDATE guiaResumoInternacao 
		SET	 guiaResumoInternacao.codigoPrestadorNaOperadora = mensagemTISS.dst_codigoPrestadorNaOperadora
		FROM 
		guiaResumoInternacao
		LEFT JOIN loteGuias ON
			guiaResumoInternacao.Chave_lgs = loteGuias.Chave 
		LEFT JOIN mensagemTISS ON
			loteGuias.Chave_msg = mensagemTISS.Chave 
		LEFT JOIN operadora ON
			mensagemTISS.dst_registroANS = operadora.registroANS
		WHERE 
			mensagemTISS.Chave = @ChaveMSG

		-- guiaSP_SADT -> Atualiza campo: pe1_codigoPrestadorNaOperadora
		UPDATE guiaSP_SADT
		SET	guiaSP_SADT.pe1_codigoPrestadorNaOperadora = mensagemTISS.dst_codigoPrestadorNaOperadora
		FROM 
		guiaSP_SADT
		LEFT JOIN loteGuias ON
			guiaSP_SADT.Chave_lgs = loteGuias.Chave 
		LEFT JOIN mensagemTISS ON
			loteGuias.Chave_msg = mensagemTISS.Chave 
		LEFT JOIN operadora ON
			mensagemTISS.dst_registroANS = operadora.registroANS
		WHERE   
			mensagemTISS.Chave = @ChaveMSG
	END


SET NOCOUNT OFF;