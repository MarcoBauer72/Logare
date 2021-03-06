USE [TISS]
GO
/****** Object:  StoredProcedure [dbo].[lsp_guiaSP_SADT_TISS_3]    Script Date: 10/20/2018 8:41:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[lsp_guiaSP_SADT_TISS_3]
(@Chave_lgs int)

AS
BEGIN

SET ANSI_WARNINGS OFF
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @XML XML;
DECLARE @DOC INT;
DECLARE @caminhoGUIA varchar(500) = 'ans:mensagemTISS/ans:prestadorParaOperadora/ans:loteGuias/ans:guiasTISS/ans:guiaSP-SADT';

DECLARE @QtdGUIAS INT;
DECLARE @ContadorGSP INT = 1;
DECLARE @gspVariavel VARCHAR(500);
DECLARE @Chave_gsp INT;
DECLARE @dsp VARCHAR(500);
DECLARE @opu VARCHAR(500);

DECLARE @QtdPRC INT;
DECLARE @contadorPRC INT = 1;
DECLARE @prcVariavel VARCHAR(500);
DECLARE @Chave_prc INT;
DECLARE @prc VARCHAR(500);
DECLARE @prc_eqp VARCHAR(500);

SELECT @XML = ArquivoXML  FROM [TempDB].[dbo].[PreImportaXML]

EXEC sp_xml_preparedocument @DOC OUTPUT, 
	@XML,
	'<ans:guiaSP-SADT xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" />'
		
-- Retorna quantidade de Guias do tipo guiaSP_SADT
SELECT @QtdGUIAS = COUNT(*) 
FROM OPENXML(@DOC,@caminhoGUIA, 2)
WITH 
(
registroANS varchar(6) './ans:cabecalhoGuia/ans:registroANS'
,numeroGuiaPrestador varchar(20) './ans:cabecalhoGuia/ans:numeroGuiaPrestador'
)

WHILE @ContadorGSP <= @QtdGUIAS
BEGIN
		SET @gspVariavel = CONCAT(@caminhoGUIA,'[',CAST(@ContadorGSP AS VARCHAR(10)),']')
		INSERT guiaSP_SADT (
			Chave_lgs
			,registroANS 
			,numeroGuiaPrestador 
			,numeroGuiaPrincipal 
			,numeroGuiaOperadora 
			,dataAutorizacao 
			,senhaAutorizacao 
			,validadeSenha 
			,numeroCarteira 
			,nomeBeneficiario 
			,numeroCNS 
			,identificadorBeneficiario 
			,scn_codigoPrestadorNaOperadora 
			,scn_CPF 
			,scn_CNPJ 
			,scn_nomeContratado 
			,spr_nomeProfissional 
			,spr_siglaConselho 
			,spr_numeroConselho 
			,spr_ufConselho 
			,spr_cbos 
			,dataEmissaoGuia 
			,caraterAtendimento 
			,pe1_codigoPrestadorNaOperadora 
			,pe1_cpf 
			,pe1_CNPJ 
			,pe1_nomeContratado 
			,pe1_numeroCNES 
			,indicadorAcidente --indicacaoAcidente 
			,observacao 
			,servicosExecutados --valorProcedimentos 
			,diarias  --valorDiarias 
			,taxas --valorTaxasAlugueis 
			,materiais --valorMateriais 
			,medicamentos --valorMedicamentos 
			,valorTotalOPM --valorOPME 
			,gases --valorGasesMedicinais 
			,totalGeral --valorTotalGeral 
			,Chave_cnt
			,codigoOperadora
			,redeBeneficiario
			,codTsConta
		) 
		SELECT 
			 @Chave_lgs
			,registroANS 
			,numeroGuiaPrestador 
			,numeroGuiaPrincipal 
			,numeroGuiaOperadora 
			,dataAutorizacao 
			,senhaAutorizacao 
			,validadeSenha 
			,numeroCarteira 
			,nomeBeneficiario 
			,numeroCNS 
			,identificadorBeneficiario 
			,scn_codigoPrestadorNaOperadora 
			,scn_CPF 
			,scn_CNPJ 
			,scn_nomeContratado 
			,spr_nomeProfissional 
			,spr_siglaConselho 
			,spr_numeroConselho 
			,spr_ufConselho 
			,spr_cbos 
			,dataEmissaoGuia 
			,caraterAtendimento 
			,pe1_codigoPrestadorNaOperadora 
			,pe1_cpf 
			,pe1_CNPJ 
			,pe1_nomeContratado 
			,pe1_numeroCNES 
			,indicacaoAcidente 
			,observacao 
			,valorProcedimentos 
			,valorDiarias 
			,valorTaxasAlugueis 
			,valorMateriais 
			,valorMedicamentos 
			,valorOPME 
			,valorGasesMedicinais 
			,valorTotalGeral 
			,NULL Chave_cnt
			,codigoOperadora
			,redeBeneficiario
			,codTsConta
		FROM OPENXML(@DOC,@gspVariavel, 2)
		WITH 
		(
		-- cabecalho
		registroANS varchar(6) './ans:cabecalhoGuia/ans:registroANS'
		,numeroGuiaPrestador varchar(20) './ans:cabecalhoGuia/ans:numeroGuiaPrestador'
		,numeroGuiaPrincipal varchar(20) './ans:cabecalhoGuia/ans:numeroGuiaPrincipal'
		-- dadosAutorizacao
		,numeroGuiaOperadora varchar(20) './ans:dadosAutorizacao/ans:numeroGuiaOperadora'
		,dataAutorizacao varchar(20) './ans:dadosAutorizacao/ans:dataAutorizacao'
		,senhaAutorizacao varchar(20) './ans:dadosAutorizacao/ans:senha'
		,validadeSenha varchar(20) './ans:dadosAutorizacao/ans:dataValidadeSenha'
		-- dadosBeneficiario
		,numeroCarteira varchar(20) './ans:dadosBeneficiario/ans:numeroCarteira'
		--,atendimentoRN varchar(1) './ans:dadosBeneficiario/ans:atendimentoRN'
		,nomeBeneficiario varchar(70) './ans:dadosBeneficiario/ans:nomeBeneficiario'
		,numeroCNS varchar(15) './ans:dadosBeneficiario/ans:numeroCNS' -- st_descricao15
		,identificadorBeneficiario varchar(20) './ans:dadosBeneficiario/ans:identificadorBeneficiario'
		-- dadosSolicitante
		-- dadosSolicitante/contratadoSolicitante
		,scn_codigoPrestadorNaOperadora varchar(14) './ans:dadosSolicitante/ans:contratadoSolicitante/ans:codigoPrestadorNaOperadora' -- codigoPrestadorNaOperadora [0-9]{14} 
		,scn_CPF varchar(14) './ans:dadosSolicitante/ans:contratadoSolicitante/ans:cpfContratado' -- st_CPF [0-9]{14} 
		,scn_CNPJ varchar(14) './ans:dadosSolicitante/ans:contratadoSolicitante/ans:cnpjContratado' -- st_CNPJ [0-9]{14} 
		,scn_nomeContratado varchar(70) './ans:dadosSolicitante/ans:contratadoSolicitante/ans:nomeContratado' -- st_nome
		-- dadosSolicitante/profissionalSolicitante
		,spr_nomeProfissional varchar(70) './ans:dadosSolicitante/ans:profissionalSolicitante/ans:nomeProfissional' -- st_nome
		,spr_siglaConselho varchar(10) './ans:dadosSolicitante/ans:profissionalSolicitante/ans:conselhoProfissional'  -- st_conselhoProfissional
		,spr_numeroConselho varchar(15) './ans:dadosSolicitante/ans:profissionalSolicitante/ans:numeroConselhoProfissional' -- st_descricao15
		,spr_ufConselho varchar(2) './ans:dadosSolicitante/ans:profissionalSolicitante/ans:UF' -- st_UF
		,spr_cbos varchar(5) './ans:dadosSolicitante/ans:profissionalSolicitante/ans:CBOS' -- st_CBOS
		-- dadosSolicitacao
		,dataEmissaoGuia varchar(20) './ans:dadosSolicitacao/ans:dataSolicitacao' -- dataSolicitacao
		,caraterAtendimento varchar(1) './ans:dadosSolicitacao/ans:caraterAtendimento' -- st_eletivaEmergencia
		--,indicacaoClinica varchar(500) './ans:dadosSolicitacao/ans:indicacaoClinica' -- st_indicacaoClinica
		-- dadosExecutante
		-- dadosExecutante/contratadoExecutante
		,pe1_codigoPrestadorNaOperadora varchar(20) './ans:dadosExecutante/ans:contratadoExecutante/ans:codigoPrestadorNaOperadora' -- st_codigoPrestadorNaOperadora
		,pe1_cpf varchar(11) './ans:dadosExecutante/ans:contratadoExecutante/ans:cpfContratado' -- st_CPF [0-9]{11} 
		,pe1_CNPJ varchar(14) './ans:dadosExecutante/ans:contratadoExecutante/ans:cnpjContratado' -- st_CNPJ [0-9]{14} 
		,pe1_nomeContratado varchar(70) './ans:dadosExecutante/ans:contratadoExecutante/ans:nomeContratado' -- st_nome
		,pe1_numeroCNES varchar(7) './ans:dadosExecutante/ans:CNES' -- st_CNES
		-- dadosAtendimento
		,tipoAtendimento varchar(2) './ans:dadosAtendimento/ans:tipoAtendimento' -- st_tipoAtendimento
		,indicacaoAcidente varchar(10) './ans:dadosAtendimento/ans:indicacaoAcidente' -- st_indicadorAcidente
		--,tipoConsulta varchar(10) './ans:dadosAtendimento/ans:tipoConsulta' -- 
		--,motivoEncerramento varchar(10) './ans:dadosAtendimento/ans:motivoEncerramento'
		-- observacao
		,observacao varchar(240) './ans:observacao' -- st_observacao
		-- valorTotal
		,valorProcedimentos decimal(9,2) './ans:valorTotal/ans:valorProcedimentos' -- st_valorMonetario
		,valorDiarias decimal(9,2) './ans:valorTotal/ans:valorDiarias' -- st_valorMonetario
		,valorTaxasAlugueis decimal(9,2) './ans:valorTotal/ans:valorTaxasAlugueis' -- st_valorMonetario
		,valorMateriais decimal(9,2) './ans:valorTotal/ans:valorMateriais' -- st_valorMonetario
		,valorMedicamentos decimal(9,2) './ans:valorTotal/ans:valorMedicamentos' -- st_valorMonetario
		,valorOPME decimal(9,2) './ans:valorTotal/ans:valorOPME' -- st_valorMonetario
		,valorGasesMedicinais decimal(9,2) './ans:valorTotal/ans:valorGasesMedicinais' -- st_valorMonetario
		,valorTotalGeral decimal(9,2) './ans:valorTotal/ans:valorTotalGeral', -- st_valorMonetario
		--
		-- 2018-02-20 Junior adicionado esses campo fora do padrao para atender a regra de operadora/rede da amil 
		codigoOperadora varchar(10) './ans:dadosBeneficiario/ans:codigoOperadora', -- st_nome
		redeBeneficiario varchar(10) './ans:dadosBeneficiario/ans:redeBeneficiario', -- st_nome
		codTsConta varchar(20) './ans:cabecalhoGuia/ans:codTsConta'
		)

		-- Retorna Identity da tabela guiaSP_SADT
		SET @Chave_gsp = IDENT_CURRENT('guiaSP_SADT')

		SET @dsp = CONCAT(@gspVariavel,'/ans:outrasDespesas/ans:despesa')
		
		-- Insere despesas
		INSERT guiaSP_SADT_dsp
		SELECT 
			@Chave_gsp
			,codigo
			,tipoTabela
			,descricao
			,tipoDespesa
			,dataRealizacao
			,horaInicial
			,horaFinal
			,reducaoAcrescimo
			,quantidade
			,valorUnitario
			,valorTotal
			,NULL ChaveMedicamentoBrasindice
			,NULL ChaveMaterialsSimpro
			,unidadeMedida
			,NULL registroAnvisa
			,NULL codigoRefFabricante
			,NULL autorizacaoFuncionamento
			,codTsItem
		FROM OPENXML(@DOC, @dsp, 2)
		WITH
		(
			codigo varchar(10) './ans:servicosExecutados/ans:codigoProcedimento' -- st_codigoTabela
			,tipoTabela varchar(2) './ans:servicosExecutados/ans:codigoTabela' -- st_tabela
			--codigoTabela varchar(10) './ans:servicosExecutados/ans:codigoTabela',
			,descricao varchar(60) './ans:servicosExecutados/ans:descricaoProcedimento' -- st_descricaoTabela
			--
			,tipoDespesa int './ans:codigoDespesa' -- st_outrasDespesas
			,dataRealizacao varchar(20) './ans:servicosExecutados/ans:dataExecucao' -- st_data
			,horaInicial varchar(20) './ans:servicosExecutados/ans:horaInicial' -- st_hora
			,horaFinal varchar(20) './ans:servicosExecutados/ans:horaFinal' -- st_hora
			,reducaoAcrescimo decimal(9,2) './ans:servicosExecutados/ans:reducaoAcrescimo' -- st_percentual
			,quantidade decimal(12,4) './ans:servicosExecutados/ans:quantidadeExecutada' -- st_quantidade
			,valorUnitario decimal(9,2) './ans:servicosExecutados/ans:valorUnitario' -- st_valorMonetario
			,valorTotal decimal(9,2) './ans:servicosExecutados/ans:valorTotal' -- st_valorMonetario
			,unidadeMedida varchar(3) './ans:servicosExecutados/ans:unidadeMedida' -- st_unidadeMedida
			,registroAnvisa varchar(20) './ans:servicosExecutados/ans:registroAnvisa' -- st_unidadeMedida
			,codigoRefFabricante varchar(60) './ans:servicosExecutados/ans:codigoRefFabricante' -- st_unidadeMedida
			,autorizacaoFuncionamento varchar(50) './ans:servicosExecutados/ans:autorizacaoFuncionamento' -- st_unidadeMedida
			,codTsItem varchar(20) './ans:servicosExecutados/ans:codTsItem'
		)

		SET @opu = CONCAT(@gspVariavel,'/ans:OPMUtilizada/ans:OPM/ans:identificacaoOPM')

		INSERT guiaSP_SADT_opu
		SELECT @Chave_gsp,*
		FROM OPENXML(@DOC, @opu, 2)
		WITH 
		(
		codigo varchar(10) './ans:OPM/ans:codigo', -- st_codigoTabela
		tipoTabela varchar(2) './ans:OPM/ans:tipoTabela', -- st_tabela
		descricao varchar(60) './ans:OPM/ans:descricao', -- st_descricaoTabela
		--
		quantidade decimal(12,4) './ans:quantidade', -- st_quantidade
		codigoBarra varchar(20) './ans:codigoBarra', -- st_descricao20
		valorUnitario decimal(9,2) './ans:valorUnitario', -- st_valorMonetario
		valorTotal decimal(9,2) './ans:valorTotal' -- st_valorMonetario
		)

		SET @prc = CONCAT(@gspVariavel,'/ans:procedimentosExecutados/ans:procedimentoExecutado')

		-- Retorna quantidade de Guias Procedimento
		SELECT @QtdPRC = COUNT(*) 
		FROM OPENXML(@DOC, @prc, 2)
		WITH 
		(
		codigo varchar(10) './ans:procedimento/ans:codigoProcedimento'
		)
		
		SET @contadorPRC = 1;

		-- Loop para insercao de Procedimentos e Equipes
		WHILE @contadorPRC <= @QtdPRC
					BEGIN
						-- Insere guia PRC
						SET @prcVariavel = CONCAT(@prc,'[',CAST(@contadorPRC AS VARCHAR(10)),']')

						INSERT guiaSP_SADT_prc  
						SELECT @Chave_gsp,*
						FROM OPENXML(@DOC, @prcVariavel, 2)
						WITH 
						(
						codigo varchar(10) './ans:procedimento/ans:codigoProcedimento', -- st_codigoTabela
						tipoTabela varchar(2) './ans:procedimento/ans:codigoTabela', -- st_tabela
						descricao varchar(60) './ans:procedimento/ans:descricaoProcedimento', -- st_descricaoTabela
						--
						data varchar(20) './ans:dataExecucao', -- st_data
						horaInicio varchar(20) './ans:horaInicial', -- st_hora
						horaFim varchar(20) './ans:horaFinal', -- st_hora
						quantidadeRealizada decimal(12,4) './ans:quantidadeExecutada', -- st_quantidade
						viaAcesso varchar(1) './ans:viaAcesso', -- st_viaDeAcesso
						tecnicaUtilizada varchar(1) './ans:tecnicaUtilizada', -- st_tecnicaUtilizada
						reducaoAcrescimo decimal(9,2) './ans:reducaoAcrescimo', -- st_percentual
						valor decimal(9,2) './ans:valorUnitario', -- st_valorMonetario
						valorTotal decimal(9,2) './ans:valorTotal' -- st_valorMonetario
						)

						-- Retorna chave Identity da tabela guiaSP_SADT_prc
						SET @Chave_prc = IDENT_CURRENT('guiaSP_SADT_prc')

						-- Insere guias PRC_EQP
						SET @prc_eqp = CONCAT(@gspVariavel,'/ans:procedimentosExecutados/ans:procedimentoExecutado[',CAST(@contadorPRC AS varchar(10)),']/ans:equipe/ans:membroEquipe')

						INSERT guiaSP_SADT_prc_eqp 
						SELECT @Chave_prc,*
						FROM OPENXML(@DOC, @prc_eqp, 2) 
						WITH 
						(
							CNPJ varchar(14) './ans:codigoProfissional/ans:CNPJ', -- st_CNPJ [0-9]{14} 
							cpf1 varchar(11) './ans:codigoProfissional/ans:cpf', -- st_CPF [0-9]{11} 
							codigoPrestadorNaOperadora varchar(20) './ans:membroEquipe/ans:codigoProfissional/ans:codigoPrestadorNaOperadora', -- st_codigoPrestadorNaOperadora
							--
							nomeExecutante varchar(70) './ans:identificacaoProfissional/ans:nomeExecutante', -- st_nome
							--
							siglaConselho varchar(10) './ans:identificacaoProfissional/ans:conselhoProfissional/ans:siglaConselho', -- st_conselhoProfissional
							numeroConselho varchar(15) './ans:identificacaoProfissional/ans:conselhoProfissional/ans:numeroConselho', -- st_descricao15
							ufConselho varchar(2) './ans:identificacaoProfissional/ans:conselhoProfissional/ans:ufConselho', -- st_UF
							--
							codigoCBOS varchar(5) './ans:identificacaoProfissional/ans:codigoCBOS', -- st_CBOS
							cpf2 varchar(11) './ans:cpf', -- st_CPF [0-9]{11} 
							posicaoProfissional int './ans:posicaoProfissional' -- st_posicaoProfissao
						)
						
						SET	@contadorPRC +=  1
				END


SET @ContadorGSP +=  1

END
EXEC sp_xml_removedocument @DOC
END
