USE [TISS]
GO
/****** Object:  StoredProcedure [dbo].[lsp_guiaResumoInternacao]    Script Date: 10/20/2018 8:40:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[lsp_guiaResumoInternacao] 
	@Chave_lgs INT

AS
BEGIN

SET ANSI_WARNINGS OFF
SET NOCOUNT ON


DECLARE @XML XML;
DECLARE @DOC INT;
DECLARE @caminhoGUIA varchar(500) = '/ans:mensagemTISS/ans:prestadorParaOperadora/ans:loteGuias/ans:guias/ans:guiaFaturamento/ans:guiaResumoInternacao';

DECLARE @QtdGUIAS INT;
DECLARE @ContadorGRI INT = 1;
DECLARE @griVariavel VARCHAR(500);
DECLARE @Chave_gri INT;

DECLARE @QtdPRC INT;
DECLARE @contadorPRC INT = 1;
DECLARE @prcVariavel VARCHAR(500);
DECLARE @Chave_prc INT;
DECLARE @dsp VARCHAR(500);
DECLARE @opu VARCHAR(500);
DECLARE @prc VARCHAR(500);
DECLARE @prc_eqp VARCHAR(500);

SELECT @XML = ArquivoXML  FROM [TempDB].[dbo].[PreImportaXML]

EXEC sp_xml_preparedocument @DOC OUTPUT, 
	@XML,
	'<ans:guiaResumoInternacao xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" />'

-- Retorna quantidade de Guias do tipo guiaResumoInternacao
SELECT @QtdGUIAS = COUNT(*) 
FROM OPENXML(@DOC,@caminhoGUIA, 2)
WITH 
(
registroANS varchar(6) './ans:cabecalhoGuia/ans:registroANS'
)

WHILE @ContadorGRI <= @QtdGUIAS
	BEGIN
		SET @griVariavel = CONCAT(@caminhoGUIA,'[',CAST(@ContadorGRI AS VARCHAR(10)),']')

		-- Insere na tabela: guiaResumoInternacao
		INSERT guiaResumoInternacao
		SELECT 
			@Chave_lgs
			,registroANS 
			,dataEmissaoGuia 
			,numeroGuiaPrestador 
			,numeroGuiaOperadora 
			,numeroGuiaSolicitacao 
			,numeroCarteira 
			,nomeBeneficiario 
			,nomePlano 
			,validadeCarteira 
			,numeroCNS 
			,identificadorBeneficiario 
			,CNPJ 
			,cpf 
			,codigoPrestadorNaOperadora 
			,nomeContratado 
			,tipoLogradouro 
			,logradouro 
			,numero 
			,complemento 
			,codigoIBGEMunicipio 
			,municipio 
			,codigoUF 
			,cep 
			,numeroCNES 
			,dataAutorizacao 
			,senhaAutorizacao 
			,validadeSenha 
			,caraterInternacao 
			,acomodacao 
			,dataHoraInternacao 
			,dataHoraSaidaInternacao 
			,tipoInternacao
			,regimeInternacao 
			,emGestacao 
			,aborto 
			,transtornoMaternoRelGravidez 
			,complicacaoPeriodoPuerperio 
			,atendimentoRNSalaParto 
			,complicacaoNeonatal 
			,baixoPeso 
			,partoCesareo 
			,partoNormal 
			,numeroDN1 
			,numeroDN2 
			,numeroDN3 
			,numeroDN4 
			,numeroDN5 
			,numeroDN6 
			,numeroDN7 
			,numeroDN8 
			,numeroDN9 
			,numeroDN10
			,qtdNascidosVivosTermo 
			,qtdNascidosMortos 
			,qtdVivosPrematuros
			,obitoMulher 
			,qtdeobitoPrecoce 
			,qtdeobitoTardio 
			,nomeTabela 
			,codigoDiagnostico 
			,descricaoDiagnostico 
			,indicadorAcidente
			,nomeTabela1 
			,codigoDiagnostico1 
			,descricaoDiagnostico1 
			,nomeTabela2 
			,codigoDiagnostico2 
			,descricaoDiagnostico2 
			,nomeTabela3 
			,codigoDiagnostico3 
			,descricaoDiagnostico3 
			,motivoSaidaInternacao 
			,obi_nomeTabela 
			,obi_codigoDiagnostico 
			,obi_descricaoDiagnostico 
			,obi_numeroDeclaracao 
			,tipoFaturamento 
			,valorTotalOPM 
			,totalGeralOutrasDespesas 
			,servicosExecutados 
			,diarias 
			,taxas 
			,materiais 
			,medicamentos 
			,gases 
			,totalGeral 
			,observacao 
			,null Chave_CNT
			,codigoOperadora 
			,redeBeneficiario
			,null codTsConta
		FROM OPENXML(@DOC, @griVariavel, 2) 
		WITH 
		(
		registroANS varchar(6) './ans:cabecalhoGuia/ans:registroANS', -- st_registroANS
		dataEmissaoGuia varchar(30) './ans:dadosInternacao/ans:dataInicioFaturamento', -- st_data
		numeroGuiaPrestador varchar(20) './ans:cabecalhoGuia/ans:numeroGuiaPrestador', -- st_numeroGuia
		numeroGuiaOperadora varchar(20) './ans:dadosAutorizacao/ans:numeroGuiaOperadora', -- st_numeroGuia
		--
		numeroGuiaSolicitacao varchar(20) './ans:numeroGuiaSolicitacaoInternacao', -- 
		numeroCarteira varchar(20) './ans:dadosBeneficiario/ans:numeroCarteira', -- st_descricao20
		nomeBeneficiario varchar(70) './ans:dadosBeneficiario/ans:nomeBeneficiario', -- st_nome
		nomePlano varchar(40) './ans:dadosBeneficiario/ans:nomePlano', -- st_descricao40
		validadeCarteira varchar(30) './ans:dadosBeneficiario/ans:validadeCarteira', -- st_data
		numeroCNS varchar(15) './ans:dadosBeneficiario/ans:numeroCNS', -- st_descricao15
		identificadorBeneficiario varchar(1000)'./ans:dadosBeneficiario/ans:identificadorBeneficiario',
		--
		CNPJ varchar(14) './ans:dadosExecutante/ans:contratadoExecutante/ans:cnpjContratado', -- st_CNPJ [0-9]{14} 
		cpf varchar(11) './ans:dadosExecutante/ans:contratadoExecutante/ans:cpfContratado', -- st_CPF [0-9]{11} 
		codigoPrestadorNaOperadora varchar(20) './ans:dadosExecutante/ans:contratadoExecutante/ans:codigoPrestadorNaOperadora', -- st_codigoPrestadorNaOperadora
		--
		nomeContratado varchar(70) './ans:dadosExecutante/ans:contratadoExecutante/ans:nomeContratado', -- st_nome
		--
		tipoLogradouro varchar(3) './ans:identificacaoExecutante/ans:enderecoContratado/ans:tipoLogradouro', -- st_tipoLogradouro
		logradouro varchar(40) './ans:identificacaoExecutante/ans:enderecoContratado/ans:logradouro', -- st_logradouro
		numero varchar(5) './ans:identificacaoExecutante/ans:enderecoContratado/ans:numero', -- st_numeroLogradouro
		complemento varchar(15) './ans:identificacaoExecutante/ans:enderecoContratado/ans:complemento', -- st_descricao15
		codigoIBGEMunicipio varchar(7) './ans:identificacaoExecutante/ans:enderecoContratado/ans:codigoIBGEMunicipio', -- st_codigoMunicipioIBGE
		municipio varchar(40) './ans:identificacaoExecutante/ans:enderecoContratado/ans:municipio', -- st_descricao40
		codigoUF varchar(2) './ans:identificacaoExecutante/ans:enderecoContratado/ans:codigoUF', -- st_UF
		cep int './ans:identificacaoExecutante/ans:enderecoContratado/ans:cep', -- st_CEP
		--
		numeroCNES varchar(7) './ans:dadosExecutante/ans:CNES', -- st_CNES
		--
		dataAutorizacao varchar(30) './ans:dadosAutorizacao/ans:dataAutorizacao', -- st_data
		senhaAutorizacao varchar(20) './ans:dadosAutorizacao/ans:senha', -- st_senhaAutorizacao
		validadeSenha varchar(30) './ans:dadosAutorizacao/ans:dataValidadeSenha', -- st_data
		--
		caraterInternacao varchar(1) './ans:dadosInternacao/ans:caraterAtendimento', -- st_eletivaEmergencia
		acomodacao varchar(2) './ans:acomodacao', -- st_tipoAcomodacao
		--dataHoraInternacao varchar(30) './ans:dadosInternacao/ans:horaInicioFaturamento', -- st_dataHora
		--dataHoraSaidaInternacao varchar(30) './ans:dadosInternacao/ans:horaFinalFaturamento', -- st_dataHora
		-- junior 2017-10-24 alterei para coletar apenas a data ... e ignorar hora 
		dataHoraInternacao varchar(30) './ans:dadosInternacao/ans:dataInicioFaturamento', -- st_dataHora
		dataHoraSaidaInternacao varchar(30) './ans:dadosInternacao/ans:dataFinalFaturamento', -- st_dataHora
		tipoInternacao int './ans:dadosInternacao/ans:tipoInternacao', -- st_tipoInternacao
		regimeInternacao varchar(1) './ans:dadosInternacao/ans:regimeInternacao', -- st_regimeInternacao
		--
		emGestacao bit './ans:internacaoObstetrica/ans:emGestacao', -- st_simNao
		aborto bit './ans:internacaoObstetrica/ans:aborto', -- st_simNao
		transtornoMaternoRelGravidez bit './ans:internacaoObstetrica/ans:transtornoMaternoRelGravidez', -- st_simNao
		complicacaoPeriodoPuerperio bit './ans:internacaoObstetrica/ans:complicacaoPeriodoPuerperio', -- st_simNao
		atendimentoRNSalaParto bit './ans:internacaoObstetrica/ans:atendimentoRNSalaParto', -- st_simNao
		complicacaoNeonatal bit './ans:internacaoObstetrica/ans:complicacaoNeonatal', -- st_simNao
		baixoPeso bit './ans:internacaoObstetrica/ans:baixoPeso', -- st_simNao
		partoCesareo bit './ans:internacaoObstetrica/ans:partoCesareo', -- st_simNao
		partoNormal bit './ans:internacaoObstetrica/ans:partoNormal', -- st_simNao
		--
		numeroDN1 varchar(15) './ans:dadosInternacao/ans:declaracoes/ans:indicadoroDN[1]', -- st_descricao15
		numeroDN2 varchar(15) './ans:dadosInternacao/ans:declaracoes/ans:indicadoroDN[2]', -- st_descricao15
		numeroDN3 varchar(15) './ans:dadosInternacao/ans:declaracoes/ans:indicadoroDN[3]', -- st_descricao15
		numeroDN4 varchar(15) './ans:dadosInternacao/ans:declaracoes/ans:indicadoroDN[4]', -- st_descricao15
		numeroDN5 varchar(15) './ans:dadosInternacao/ans:declaracoes/ans:indicadoroDN[5]', -- st_descricao15
		numeroDN6 varchar(15) './ans:dadosInternacao/ans:declaracoes/ans:indicadoroDN[6]', -- st_descricao15
		numeroDN7 varchar(15) './ans:dadosInternacao/ans:declaracoes/ans:indicador[7]', -- st_descricao15
		numeroDN8 varchar(15) './ans:dadosInternacao/ans:declaracoes/ans:indicador[8]', -- st_descricao15
		numeroDN9 varchar(15) './ans:dadosInternacao/ans:declaracoes/ans:indicador[9]', -- st_descricao15
		numeroDN10 varchar(15) './ans:dadosInternacao/ans:declaracoes/ans:indicador[10]', -- st_descricao15
		--
		qtdNascidosVivosTermo int './ans:dadosInternacao/ans:qtdNascidosVivosTermo', -- 
		qtdNascidosMortos int './ans:internacaoObstetrica/ans:qtdNascidosMortos', -- 
		qtdVivosPrematuros int './ans:internacaoObstetrica/ans:qtdVivosPrematuros', -- 
		obitoMulher int './ans:internacaoObstetrica/ans:obitoMulher', -- st_obitoMulher
		--
		qtdeobitoPrecoce int './ans:obitoNeonatal/ans:qtdeobitoPrecoce', -- st_quantidadeObito
		qtdeobitoTardio int './ans:obitoNeonatal/ans:qtdeobitoTardio', -- st_quantidadeObito
		--
		nomeTabela varchar(10) './ans:diagnosticosSaidaInternacao/ans:diagnosticoPrincipal/ans:nomeTabela', -- st_tabelasDiagnostico
		codigoDiagnostico varchar(5) './ans:diagnosticosSaidaInternacao/ans:diagnosticoPrincipal/ans:codigoDiagnostico', -- st_codigoDiagnostico
		descricaoDiagnostico varchar(70) './ans:diagnosticosSaidaInternacao/ans:diagnosticoPrincipal/ans:descricaoDiagnostico', -- st_nome
		--
		indicadorAcidente int './ans:dadosSaidaInternacao/ans:indicadorAcidente', -- st_indicadorAcidente
		--
		nomeTabela1 varchar(10) './ans:diagnosticosSaidaInternacao/ans:diagnosticosSecundarios/ans:CID[1]/ans:nomeTabela', -- st_tabelasDiagnostico
		codigoDiagnostico1 varchar(5) './ans:diagnosticosSaidaInternacao/ans:diagnosticosSecundarios/ans:CID[1]/ans:codigoDiagnostico', -- st_codigoDiagnostico
		descricaoDiagnostico1 varchar(70) './ans:diagnosticosSaidaInternacao/ans:diagnosticosSecundarios/ans:CID[1]/ans:descricaoDiagnostico', -- st_nome 
		--
		nomeTabela2 varchar(10) './ans:diagnosticosSaidaInternacao/ans:diagnosticosSecundarios/ans:CID[2]/ans:nomeTabela', -- st_tabelasDiagnostico
		codigoDiagnostico2 varchar(5) './ans:diagnosticosSaidaInternacao/ans:diagnosticosSecundarios/ans:CID[2]/ans:codigoDiagnostico', -- st_codigoDiagnostico
		descricaoDiagnostico2 varchar(70) './ans:diagnosticosSaidaInternacao/ans:diagnosticosSecundarios/ans:CID[2]/ans:descricaoDiagnostico', -- st_nome 
		--
		nomeTabela3 varchar(10) './ans:diagnosticosSaidaInternacao/ans:diagnosticosSecundarios/ans:CID[3]/ans:nomeTabela', -- st_tabelasDiagnostico
		codigoDiagnostico3 varchar(5) './ans:diagnosticosSaidaInternacao/ans:diagnosticosSecundarios/ans:CID[3]/ans:codigoDiagnostico', -- st_codigoDiagnostico
		descricaoDiagnostico3 varchar(70) './ans:diagnosticosSaidaInternacao/ans:diagnosticosSecundarios/ans:CID[3]/ans:descricaoDiagnostico', -- st_nome 
		--
		motivoSaidaInternacao varchar(2) './ans:diagnosticosSaidaInternacao/ans:motivoSaidaInternacao', -- st_motivoSaida
		--
		obi_nomeTabela varchar(10) './ans:diagnosticosSaidaInternacao/ans:obito/ans:CID/ans:nomeTabela', -- st_tabelasDiagnostico
		obi_codigoDiagnostico varchar(5) './ans:diagnosticosSaidaInternacao/ans:obito/ans:CID/ans:codigoDiagnostico', -- st_codigoDiagnostico
		obi_descricaoDiagnostico varchar(70) './ans:diagnosticosSaidaInternacao/ans:obito/ans:CID/ans:descricaoDiagnostico', -- st_nome
		--
		obi_numeroDeclaracao varchar(12) './ans:dadosInternacao/ans:declaracoes/ans:numeroDeclaracao', -- 
		--
		tipoFaturamento varchar(1) './ans:tipoFaturamento', -- st_tipoFaturamento
		--
		valorTotalOPM decimal(9,2) './ans:valorTotal/ans:valorOPME', -- st_valorMonetario
		--
		totalGeralOutrasDespesas decimal(9,2) './ans:outrasDespesas/ans:totalGeralOutrasDespesas', -- st_valorMonetario
		--
		servicosExecutados decimal(9,2) './ans:valorTotal/ans:valorProcedimentos', -- st_valorMonetario
		diarias decimal(9,2) './ans:valorTotal/ans:valorDiarias', -- st_valorMonetario
		taxas decimal(9,2) './ans:valorTotal/ans:valorTaxasAlugueis', -- st_valorMonetario
		materiais decimal(9,2) './ans:valorTotal/ans:valorMateriais', -- st_valorMonetario
		medicamentos decimal(9,2) './ans:valorTotal/ans:valorMedicamentos', -- st_valorMonetario
		gases decimal(9,2) './ans:valorTotal/ans:valorGasesMedicinais', -- st_valorMonetario
		totalGeral decimal(9,2) './ans:valorTotal/ans:valorTotalGeral', -- st_valorMonetario
		--
		observacao varchar(240) './ans:observacao', -- st_observacao
		--
		-- 2018-02-20 Junior adicionado esses campo fora do padrao para atender a regra de operadora/rede da amil 
		codigoOperadora varchar(10) './ans:dadosBeneficiario/ans:codigoOperadora', -- st_nome
		redeBeneficiario varchar(10) './ans:dadosBeneficiario/ans:redeBeneficiario' -- st_nome

		)

		SET @Chave_gri = IDENT_CURRENT('guiaResumoInternacao')

		SET @dsp = CONCAT(@griVariavel,'/ans:outrasDespesas/ans:despesa')
		
		-- Insere DSP
		INSERT guiaResumoInternacao_dsp
		SELECT @Chave_gri
			,*
			,NULL unidadeMedida
			,NULL registroAnvisa
			,NULL codigoRefFabricante
			,NULL autorizacaoFuncionamento
			,NULL ChaveMedicamentoBrasindice
			,NULL ChaveMaterialsSimpro
			,NULL codTsItem
		FROM OPENXML(@DOC, @dsp, 2) 
		WITH 
		(
			codigo varchar(10) './ans:identificadorDespesa/ans:codigo', -- st_codigoTabela
			tipoTabela varchar(2) './ans:identificadorDespesa/ans:tipoTabela', -- st_tabela
			descricao varchar(60) './ans:identificadorDespesa/ans:descricao', -- st_descricaoTabela
			--
			tipoDespesa int './ans:tipoDespesa', -- st_outrasDespesas
			dataRealizacao varchar(30) './ans:dataRealizacao', -- st_data
			horaInicial varchar(30) './ans:horaInicial', -- st_hora
			horaFinal varchar(30) './ans:horaFinal', -- st_hora
			reducaoAcrescimo decimal(9,2) './ans:reducaoAcrescimo', -- st_percentual
			quantidade decimal(12,4) './ans:quantidade', -- st_quantidade
			valorUnitario decimal(9,2) './ans:valorUnitario', -- st_valorMonetario
			valorTotal decimal(9,2) './ans:valorTotal' -- st_valorMonetario
		)

		-- Insere OPU
		SET @opu = CONCAT(@griVariavel,'/ans:OPMUtilizada/ans:OPM/ans:identificacaoOPM')
		INSERT guiaResumoInternacao_opu
		SELECT @Chave_gri,*
		FROM OPENXML(@DOC, @opu , 2) 
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

		SET @prc = CONCAT(@griVariavel,'/ans:procedimentosRealizados/ans:procedimentos')

		-- Retorna quantidade de Guias Procedimento
		SELECT @QtdPRC = COUNT(*) 
		FROM OPENXML(@DOC, @prc, 2)
		WITH 
		(
		codigo varchar(10) './ans:procedimento/ans:codigo'
		)
		
		-- Loop para insercao de Procedimentos e Equipes
		WHILE @contadorPRC <= @QtdPRC
				BEGIN
					-- Insere PRC
					SET @prcVariavel = CONCAT(@prc,'/ans:procedimentosExecutados/ans:procedimentoExecutado[',CAST(@contadorPRC AS VARCHAR(10)),']')

					INSERT guiaResumoInternacao_prc
					SELECT @Chave_gri,*
					FROM OPENXML(@DOC, @prcVariavel, 2) 
					WITH 
					(
					codigo varchar(10) './ans:codigoProcedimento', -- st_codigoTabela
					tipoTabela varchar(2) './ans:tipoTabela', -- st_tabela
					descricao varchar(60) './ans:procedimento', -- st_descricaoTabela
					--
					data varchar(30) './ans:dataExecucao', -- st_data
					horaInicio varchar(30) './ans:horaInicial', -- st_hora
					horaFim varchar(30) './ans:horaFinal', -- st_hora
					quantidadeRealizada decimal(12,4) './ans:quantidadeExecutada', -- st_quantidade
					viaAcesso varchar(1) './ans:viaAcesso', -- st_viaDeAcesso
					tecnicaUtilizada varchar(1) './ans:tecnicaUtilizada', -- st_tecnicaUtilizada
					reducaoAcrescimo decimal(9,2) './ans:reducaoAcrescimo', -- st_percentual
					valor decimal(9,2) './ans:valorUnitario', -- st_valorMonetario
					valorTotal decimal(9,2) './ans:valorTotal' -- st_valorMonetario
					)
				
					-- Retorna chave Identity da tabela: guiaResumoInternacao_prc
					SET @Chave_prc = IDENT_CURRENT('guiaResumoInternacao_prc')

					-- Insere guias PRC_EQP
					SET @prc_eqp = CONCAT(@griVariavel,'/ans:procedimentosExecutados/ans:procedimentoExecutado[',CAST(@contadorPRC AS varchar(10)),']/ans:equipe/ans:membroEquipe')

					-- Insere PRC_EQP
					INSERT guiaResumoInternacao_prc_eqp
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
					SET @contadorPRC +=1;
				END
		SET @ContadorGRI +=1;
	END

EXEC sp_xml_removedocument @DOC

END




