USE [TISS]
GO
/****** Object:  StoredProcedure [dbo].[lsp_guiaSP_SADT]    Script Date: 10/20/2018 8:41:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[lsp_guiaSP_SADT]
(@Chave_lgs int)

AS
BEGIN

SET ANSI_WARNINGS OFF
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @XML XML;
DECLARE @DOC INT;
DECLARE @caminhoGUIA varchar(500) = 'ans:mensagemTISS/ans:prestadorParaOperadora/ans:loteGuias/ans:guias/ans:guiaFaturamento/ans:guiaSP_SADT';

DECLARE @QtdGUIAS INT;
DECLARE @ContadorGSP INT = 1;
DECLARE @gspVariavel VARCHAR(500);
DECLARE @Chave_gsp INT;
DECLARE @dsp VARCHAR(500);
DECLARE @opu VARCHAR(500);

DECLARE @QtdPRC INT, @contadorPRC INT = 1;
DECLARE @prcVariavel VARCHAR(500);
DECLARE @Chave_prc INT;
DECLARE @prc VARCHAR(500);
DECLARE @prc_eqp varchar(500);
	

SELECT @XML = ArquivoXML FROM [TempDB].[dbo].[PreImportaXML]

EXEC sp_xml_preparedocument @DOC OUTPUT, 
	@XML,
	'<ans:guiaSP_SADT xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" />'
		
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
			,dataEmissaoGuia
			,numeroGuiaPrestador
			,numeroGuiaOperadora
			,numeroGuiaPrincipal
			,dataAutorizacao
			,senhaAutorizacao
			,validadeSenha
			,numeroCarteira
			,nomeBeneficiario
			,nomePlano
			,validadeCarteira
			,numeroCNS
			,identificadorBeneficiario
			,scn_CNPJ
			,scn_cpf
			,scn_codigoPrestadorNaOperadora
			,scn_nomeContratado
			,scn_tipoLogradouro
			,scn_logradouro
			,scn_numero
			,scn_complemento
			,scn_codigoIBGEMunicipio
			,scn_municipio
			,scn_codigoUF
			,scn_cep
			,scn_numeroCNES
			,spr_nomeProfissional
			,spr_siglaConselho
			,spr_numeroConselho
			,spr_ufConselho
			,spr_cbos
			,pe1_CNPJ
			,pe1_cpf
			,pe1_codigoPrestadorNaOperadora
			,pe1_nomeContratado
			,pe1_tipoLogradouro
			,pe1_logradouro
			,pe1_numero
			,pe1_complemento
			,pe1_codigoIBGEMunicipio
			,pe1_municipio
			,pe1_codigoUF
			,pe1_cep
			,pe1_numeroCNES
			,pe2_nomeExecutante
			,pe2_siglaConselho
			,pe2_numeroConselho
			,pe2_ufConselho
			,pe2_codigoCBOS
			,pe2_CNPJ
			,pe2_cpf
			,pe2_codigoPrestadorNaOperadora
			,indicacaoClinica
			,caraterAtendimento
			,dataHoraAtendimento
			,nomeTabela
			,codigoDiagnostico
			,descricaoDiagnostico
			,tipoDoenca
			,valor
			,unidadeTempo
			,indicadorAcidente
			,tipoSaida
			,tipoAtendimento
			,totalGeralOutrasDespesas
			,valorTotalOPM
			,servicosExecutados
			,diarias
			,taxas
			,materiais
			,medicamentos
			,gases
			,totalGeral
			,observacao
			,nomeTabela_2_01_03
			,codigoDiagnostico_2_01_03
			,descricaoDiagnostico_2_01_03
			,tipoDoenca_2_01_03
			,valor_2_01_03
			,unidadeTempo_2_01_03
			,indicadorAcidente_2_01_03
			,Chave_cnt
			,codigoOperadora
			,redeBeneficiario
			,codTsConta
		) 
		SELECT 
			@Chave_lgs
			,registroANS
			,dataEmissaoGuia 
			,numeroGuiaPrestador 
			,numeroGuiaOperadora 
			,numeroGuiaPrincipal 
			,dataAutorizacao 
			,senhaAutorizacao 
			,validadeSenha 
			,numeroCarteira 
			,nomeBeneficiario 
			,nomePlano 
			,validadeCarteira 
			,numeroCNS 
			,identificadorBeneficiario 
			,scn_CNPJ 
			,scn_cpf 
			,scn_codigoPrestadorNaOperadora 
			,scn_nomeContratado 
			,scn_tipoLogradouro 
			,scn_logradouro 
			,scn_numero 
			,scn_complemento 
			,scn_codigoIBGEMunicipio 
			,scn_municipio 
			,scn_codigoUF 
			,scn_cep 
			,spr_numeroCNES 
			,spr_nomeProfissional 
			,spr_siglaConselho 
			,spr_numeroConselho 
			,spr_ufConselho 
			,spr_cbos 
			,pe1_CNPJ 
			,pe1_cpf 
			,pe1_codigoPrestadorNaOperadora 
			,pe1_nomeContratado 
			,pe1_tipoLogradouro 
			,pe1_logradouro 
			,pe1_numero 
			,pe1_complemento 
			,pe1_codigoIBGEMunicipio 
			,pe1_municipio 
			,pe1_codigoUF 
			,pe1_cep 
			,pe1_numeroCNES 
			,pe1_nomeExecutante 
			,pe2_siglaConselho 
			,pe2_numeroConselho
			,pe2_ufConselho 
			,pe2_codigoCBOS 
			,pe2_CNPJ
			,pe2_cpf 
			,pe2_codigoPrestadorNaOperadora 
			,indicacaoClinica 
			,caraterAtendimento 
			,dataHoraAtendimento 
			,nomeTabela 
			,codigoDiagnostico 
			,descricaoDiagnostico 
			,tipoDoenca 
			,valor 
			,unidadeTempo 
			,indicadorAcidente 
			,tipoSaida 
			,tipoAtendimento 
			,totalGeralOutrasDespesas 
			,valorTotalOPM 
			,servicosExecutados 
			,diarias 
			,taxas 
			,materiais 
			,medicamentos 
			,gases 
			,totalGeral 
			,observacao 
			,nomeTabela_2_01_03  
			,codigoDiagnostico_2_01_03 
			,descricaoDiagnostico_2_01_03 
			,tipoDoenca_2_01_03 
			,valor_2_01_03 
			,unidadeTempo_2_01_03 
			,indicadorAcidente_2_01_03 
			,NULL Chave_cnt
			,codigoOperadora -- 2018-02-20 Junior adicionado esses campo fora do padrao para atender a regra de operadora/rede da amil 
			,redeBeneficiario -- 2018-02-20 Junior adicionado esses campo fora do padrao para atender a regra de operadora/rede da amil 
			,codTsConta
		FROM OPENXML(@DOC,@gspVariavel, 2)
		WITH
		(
			registroANS varchar(6) './ans:identificacaoGuiaSADTSP/ans:registroANS', -- st_registroANS
			dataEmissaoGuia varchar(20) './ans:identificacaoGuiaSADTSP/ans:dataEmissaoGuia', -- st_data
			numeroGuiaPrestador varchar(20) './ans:identificacaoGuiaSADTSP/ans:numeroGuiaPrestador', -- st_numeroGuia
			numeroGuiaOperadora varchar(20) './ans:identificacaoGuiaSADTSP/ans:numeroGuiaOperadora', -- st_numeroGuia
			--
			numeroGuiaPrincipal varchar(20) './ans:numeroGuiaPrincipal', -- 
			--
			dataAutorizacao varchar(20) './ans:dadosAutorizacao/ans:dataAutorizacao', -- st_data
			senhaAutorizacao varchar(20) './ans:dadosAutorizacao/ans:senhaAutorizacao', -- st_senhaAutorizacao
			validadeSenha varchar(20) './ans:dadosAutorizacao/ans:validadeSenha', -- st_data
			--
			numeroCarteira varchar(20) './ans:dadosBeneficiario/ans:numeroCarteira', -- st_descricao20
			nomeBeneficiario varchar(70) './ans:dadosBeneficiario/ans:nomeBeneficiario', -- st_nome
			nomePlano varchar(40) './ans:dadosBeneficiario/ans:nomePlano', -- st_descricao40
			validadeCarteira varchar(20) './ans:dadosBeneficiario/ans:validadeCarteira', -- st_data
			numeroCNS varchar(15) './ans:dadosBeneficiario/ans:numeroCNS', -- st_descricao15
			identificadorBeneficiario varchar(20) './ans:dadosBeneficiario/ans:identificadorBeneficiario',
			--
			scn_CNPJ varchar(14) './ans:dadosSolicitante/ans:contratado/ans:identificacao/ans:CNPJ', -- st_CNPJ [0-9]{14} 
			scn_cpf varchar(11) './ans:dadosSolicitante/ans:contratado/ans:identificacao/ans:cpf', -- st_CPF [0-9]{11} 
			scn_codigoPrestadorNaOperadora varchar(20) './ans:dadosSolicitante/ans:contratado/ans:identificacao/ans:codigoPrestadorNaOperadora', -- st_codigoPrestadorNaOperadora
			--
			scn_nomeContratado varchar(70) './ans:dadosSolicitante/ans:contratado/ans:nomeContratado', -- st_nome
			--
			scn_tipoLogradouro varchar(3) './ans:dadosSolicitante/ans:contratado/ans:enderecoContratado/ans:tipoLogradouro', -- st_tipoLogradouro
			scn_logradouro varchar(40) './ans:dadosSolicitante/ans:contratado/ans:enderecoContratado/ans:logradouro', -- st_logradouro
			scn_numero varchar(5) './ans:dadosSolicitante/ans:contratado/ans:enderecoContratado/ans:numero', -- st_numeroLogradouro
			scn_complemento varchar(15) './ans:dadosSolicitante/ans:contratado/ans:enderecoContratado/ans:complemento', -- st_descricao15
			scn_codigoIBGEMunicipio varchar(7) './ans:dadosSolicitante/ans:contratado/ans:enderecoContratado/ans:codigoIBGEMunicipio', -- st_codigoMunicipioIBGE
			scn_municipio varchar(40) './ans:dadosSolicitante/ans:contratado/ans:enderecoContratado/ans:municipio', -- st_descricao40
			scn_codigoUF varchar(2) './ans:dadosSolicitante/ans:contratado/ans:enderecoContratado/ans:codigoUF', -- st_UF
			scn_cep int './ans:dadosSolicitante/ans:contratado/ans:enderecoContratado/ans:cep', -- st_CEP
			--
			spr_numeroCNES varchar(7) './ans:dadosSolicitante/ans:contratado/ans:numeroCNES', -- st_CNES
			--
			spr_nomeProfissional varchar(70) './ans:dadosSolicitante/ans:profissional/ans:nomeProfissional', -- st_nome
			--
			spr_siglaConselho varchar(10) './ans:dadosSolicitante/ans:profissional/ans:conselhoProfissional/ans:siglaConselho', -- st_conselhoProfissional
			spr_numeroConselho varchar(15) './ans:dadosSolicitante/ans:profissional/ans:conselhoProfissional/ans:numeroConselho', -- st_descricao15
			spr_ufConselho varchar(2) './ans:dadosSolicitante/ans:profissional/ans:conselhoProfissional/ans:ufConselho', -- st_UF
			--
			spr_cbos varchar(5) './ans:dadosSolicitante/ans:profissional/ans:cbos', -- st_CBOS
			--
			pe1_CNPJ varchar(14) './ans:prestadorExecutante/ans:identificacao/ans:CNPJ', -- st_CNPJ [0-9]{14} 
			pe1_cpf varchar(11) './ans:prestadorExecutante/ans:identificacao/ans:cpf', -- st_CPF [0-9]{11} 
			pe1_codigoPrestadorNaOperadora varchar(20) './ans:prestadorExecutante/ans:identificacao/ans:codigoPrestadorNaOperadora', -- st_codigoPrestadorNaOperadora
			--
			pe1_nomeContratado varchar(70) './ans:prestadorExecutante/ans:nomeContratado', -- st_nome
			--
			pe1_tipoLogradouro varchar(3) './ans:prestadorExecutante/ans:enderecoContratado/ans:tipoLogradouro', -- st_tipoLogradouro
			pe1_logradouro varchar(40) './ans:prestadorExecutante/ans:enderecoContratado/ans:logradouro', -- st_logradouro
			pe1_numero varchar(5) './ans:prestadorExecutante/ans:enderecoContratado/ans:numero', -- st_numeroLogradouro
			pe1_complemento varchar(15) './ans:prestadorExecutante/ans:enderecoContratado/ans:complemento', -- st_descricao15
			pe1_codigoIBGEMunicipio varchar(7) './ans:prestadorExecutante/ans:enderecoContratado/ans:codigoIBGEMunicipio', -- st_codigoMunicipioIBGE
			pe1_municipio varchar(40) './ans:prestadorExecutante/ans:enderecoContratado/ans:municipio', -- st_descricao40
			pe1_codigoUF varchar(2) './ans:prestadorExecutante/ans:enderecoContratado/ans:codigoUF', -- st_UF
			pe1_cep int './ans:prestadorExecutante/ans:enderecoContratado/ans:cep', -- st_CEP
			--
			pe1_numeroCNES varchar(7) './ans:prestadorExecutante/ans:numeroCNES', -- st_CNES
			--
			pe1_nomeExecutante varchar(70) './ans:prestadorExecutante/ans:profissionalExecutanteCompl/ans:nomeExecutante', -- st_nome
			--
			pe2_siglaConselho varchar(10) './ans:prestadorExecutante/ans:profissionalExecutanteCompl/ans:conselhoProfissional/ans:siglaConselho', -- st_conselhoProfissional
			pe2_numeroConselho varchar(15) './ans:prestadorExecutante/ans:profissionalExecutanteCompl/ans:conselhoProfissional/ans:numeroConselho', -- st_descricao15
			pe2_ufConselho varchar(2) './ans:prestadorExecutante/ans:profissionalExecutanteCompl/ans:conselhoProfissional/ans:ufConselho', -- st_UF
			--
			pe2_codigoCBOS varchar(5) './ans:prestadorExecutante/ans:profissionalExecutanteCompl/ans:codigoCBOS', -- st_CBOS
			--
			pe2_CNPJ varchar(14) './ans:prestadorExecutante/ans:profissionalExecutanteCompl/ans:codigoProfissionalCompl/ans:CNPJ', -- st_CNPJ [0-9]{14} 
			pe2_cpf varchar(11) './ans:prestadorExecutante/ans:profissionalExecutanteCompl/ans:codigoProfissionalCompl/ans:cpf', -- st_CPF [0-9]{11} 
			pe2_codigoPrestadorNaOperadora varchar(20) './ans:prestadorExecutante/ans:profissionalExecutanteCompl/ans:codigoProfissionalCompl/ans:codigoPrestadorNaOperadora', -- st_codigoPrestadorNaOperadora
			--
			indicacaoClinica varchar(500) './ans:indicacaoClinica', -- st_indicacaoClinica
			caraterAtendimento varchar(1) './ans:caraterAtendimento', -- st_eletivaEmergencia
			dataHoraAtendimento varchar(20) './ans:dataHoraAtendimento', -- st_dataHora
			--
			nomeTabela varchar(10) './ans:diagnosticoGuia/ans:CID/ans:nomeTabela', -- st_tabelasDiagnostico
			codigoDiagnostico varchar(5) './ans:diagnosticoGuia/ans:CID/ans:codigoDiagnostico', -- st_codigoDiagnostico
			descricaoDiagnostico varchar(70) './ans:diagnosticoGuia/ans:CID/ans:descricaoDiagnostico', -- st_nome
			--
			tipoDoenca varchar(1) './ans:diagnosticoGuia/ans:tipoDoenca', -- st_tipoDoenca
			--
			valor int './ans:diagnosticoGuia/ans:tempoReferidoEvolucaoDoenca/ans:valor', -- st_numeroInteiro
			unidadeTempo varchar(1) './ans:diagnosticoGuia/ans:tempoReferidoEvolucaoDoenca/ans:unidadeTempo', -- st_unidadeTempo
			--
			indicadorAcidente int './ans:diagnosticoGuia/ans:indicadorAcidente', -- st_indicadorAcidente
			--
			tipoSaida varchar(1) './ans:tipoSaida', -- st_tipoSaidaGuiaSADT
			--
			tipoAtendimento varchar(2) './ans:tipoAtendimento', -- st_tipoAtendimento
			--
			totalGeralOutrasDespesas decimal(9,2) './ans:outrasDespesas/ans:totalGeralOutrasDespesas', -- st_valorMonetario
			--
			valorTotalOPM decimal(9,2) './ans:OPMUtilizada/ans:valorTotalOPM', -- st_valorMonetario
			--
			servicosExecutados decimal(9,2) './ans:valorTotal/ans:servicosExecutados', -- st_valorMonetario
			diarias decimal(9,2) './ans:valorTotal/ans:diarias', -- st_valorMonetario
			taxas decimal(9,2) './ans:valorTotal/ans:taxas', -- st_valorMonetario
			materiais decimal(9,2) './ans:valorTotal/ans:materiais', -- st_valorMonetario
			medicamentos decimal(9,2) './ans:valorTotal/ans:medicamentos', -- st_valorMonetario
			gases decimal(9,2) './ans:valorTotal/ans:gases', -- st_valorMonetario
			totalGeral decimal(9,2) './ans:valorTotal/ans:totalGeral', -- st_valorMonetario
			--
			observacao varchar(240) './ans:observacao', -- st_observacao
			--
			nomeTabela_2_01_03  varchar(10) './ans:diagnosticoAtendimento/ans:CID/ans:nomeTabela', -- st_tabelasDiagnostico
			codigoDiagnostico_2_01_03 varchar(5) './ans:diagnosticoAtendimento/ans:CID/ans:codigoDiagnostico', -- st_codigoDiagnostico
			descricaoDiagnostico_2_01_03 varchar(70) './ans:diagnosticoAtendimento/ans:CID/ans:descricaoDiagnostico', -- st_nome
			--
			tipoDoenca_2_01_03 varchar(1) './ans:diagnosticoAtendimento/ans:tipoDoenca', -- st_tipoDoenca
			--
			valor_2_01_03 int './ans:diagnosticoAtendimento/ans:tempoReferidoEvolucaoDoenca/ans:valor', -- st_numeroInteiro
			unidadeTempo_2_01_03 varchar(1) './ans:diagnosticoAtendimento/ans:tempoReferidoEvolucaoDoenca/ans:unidadeTempo', -- st_unidadeTempo
			--
			indicadorAcidente_2_01_03 int './ans:diagnosticoAtendimento/ans:indicadorAcidente', -- st_indicadorAcidente
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
			,NULL unidadeMedida
			,NULL registroAnvisa
			,NULL codigoRefFabricante
			,NULL autorizacaoFuncionamento
			,codTsItem
		FROM OPENXML(@DOC, @dsp, 2)
		WITH
		(
			codigo varchar(10) './ans:identificadorDespesa/ans:codigo', -- st_codigoTabela
			tipoTabela varchar(2) './ans:identificadorDespesa/ans:tipoTabela', -- st_tabela
			descricao varchar(60) './ans:identificadorDespesa/ans:descricao', -- st_descricaoTabela
			--
			tipoDespesa int './ans:tipoDespesa', -- st_outrasDespesas
			dataRealizacao varchar(20) './ans:dataRealizacao', -- st_data
			horaInicial varchar(20) './ans:horaInicial', -- st_hora
			horaFinal varchar(20) './ans:horaFinal', -- st_hora
			reducaoAcrescimo decimal(9,2) './ans:reducaoAcrescimo', -- st_percentual
			quantidade decimal(12,4) './ans:quantidade', -- st_quantidade
			valorUnitario decimal(9,2) './ans:valorUnitario', -- st_valorMonetario
			valorTotal decimal(9,2) './ans:valorTotal', -- st_valorMonetario
			codTsItem varchar(20) './ans:servicosExecutados/ans:codTsItem'
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
		codigo varchar(10) './ans:procedimento/ans:codigo'
		)
		
		SET @contadorPRC = 1;

		-- Loop para insercao de Procedimentos e Equipes
		WHILE @contadorPRC <= @QtdPRC
					BEGIN
						-- Insere guia PRC
						SET @prcVariavel = CONCAT(@prc,'/ans:procedimentosExecutados/ans:procedimentoExecutado[',CAST(@contadorPRC AS VARCHAR(10)),']')

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
