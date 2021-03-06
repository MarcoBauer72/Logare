USE [TISS]
GO
/****** Object:  StoredProcedure [dbo].[lsp_guiaSolicInternacao_TISS_3]    Script Date: 10/20/2018 8:41:04 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[lsp_guiaSolicInternacao_TISS_3] 
	@Chave_msg int

AS
BEGIN

SET ANSI_WARNINGS OFF
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @XML XML;
DECLARE @DOC INT;
DECLARE @caminhoGUIA varchar(500) = '/ans:mensagemTISS/ans:prestadorParaOperadora/ans:loteGuias/ans:guiasTISS/ans:guiaSolicInternacao';

DECLARE @QtdGUIAS INT;
DECLARE @ContadorGSI INT = 1;
DECLARE @gsiVariavel VARCHAR(500);
DECLARE @Chave_gsi INT;

DECLARE @prc VARCHAR(500);
DECLARE @ops VARCHAR(500);

SELECT @XML = ArquivoXML  FROM [TempDB].[dbo].[PreImportaXML]

EXEC sp_xml_preparedocument @DOC OUTPUT, 
	@XML,
	'<ans:guiaSP_SADT xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" />'

-- Retorna quantidade de Guias do tipo: guiaSolicInternaca
SELECT @QtdGUIAS = COUNT(*) 
FROM OPENXML(@DOC,@caminhoGUIA, 2)
WITH 
(
registroANS varchar(6) './ans:identificacaoGuiaSolicitacaoInternacao/ans:registroANS'
)

WHILE @ContadorGSI <= @QtdGUIAS
	BEGIN
		SET @gsiVariavel = CONCAT(@caminhoGUIA,'[',CAST(@ContadorGSI AS VARCHAR(10)),']')

		INSERT guiaSolicInternacao
		SELECT @Chave_msg,* 
		FROM OPENXML(@DOC, @gsiVariavel, 2) 
		WITH 
		(
		registroANS varchar(6) './ans:identificacaoGuiaSolicitacaoInternacao/ans:registroANS', -- st_registroANS
		dataEmissaoGuia varchar(30) './ans:identificacaoGuiaSolicitacaoInternacao/ans:dataEmissaoGuia', -- st_data
		numeroGuiaOperadora varchar(20) './ans:identificacaoGuiaSolicitacaoInternacao/ans:numeroGuiaOperadora', -- st_numeroGuia
		numeroGuiaPrestador varchar(20) './ans:identificacaoGuiaSolicitacaoInternacao/ans:numeroGuiaPrestador', -- st_numeroGuia
		--
		numeroCarteira varchar(20) './ans:dadosBeneficiario/ans:numeroCarteira', -- st_descricao20
		nomeBeneficiario varchar(70) './ans:dadosBeneficiario/ans:nomeBeneficiario', -- st_nome
		nomePlano varchar(40) './ans:dadosBeneficiario/ans:nomePlano', -- st_descricao40
		validadeCarteira varchar(30) './ans:dadosBeneficiario/ans:validadeCarteira', -- st_data
		numeroCNS varchar(15) './ans:dadosBeneficiario/ans:numeroCNS', -- st_descricao15
		identificadorBeneficiario varchar(1000) './ans:dadosBeneficiario/ans:identificadorBeneficiario',
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
		scn_numeroCNES varchar(7) './ans:dadosSolicitante/ans:contratado/ans:numeroCNES', -- st_CNES
		--
		spr_nomeProfissional varchar(70) './ans:dadosSolicitante/ans:profissional/ans:nomeProfissional', -- st_nome
		--
		spr_siglaConselho varchar(10) './ans:dadosSolicitante/ans:profissional/ans:conselhoProfissional/ans:siglaConselho', -- st_conselhoProfissional
		spr_numeroConselho varchar(15) './ans:dadosSolicitante/ans:profissional/ans:conselhoProfissional/ans:numeroConselho', -- st_descricao15
		spr_ufConselho varchar(2) './ans:dadosSolicitante/ans:profissional/ans:conselhoProfissional/ans:ufConselho', -- st_UF
		--
		spr_cbos varchar(5) './ans:dadosSolicitante/ans:profissional/ans:cbos', -- st_CBOS
		--
		psl_CNPJ varchar(14) './ans:prestadorSolicitado/ans:CNPJ', -- st_CNPJ [0-9]{14} 
		psl_cpf varchar(11) './ans:prestadorSolicitado/ans:cpf', -- st_CPF [0-9]{11} 
		psl_codigoPrestadorNaOperadora varchar(20) './ans:prestadorSolicitado/ans:codigoPrestadorNaOperadora', -- st_codigoPrestadorNaOperadora
		--
		psl_nomePrestador varchar(70) './ans:prestadorSolicitado/ans:nomePrestador', -- st_nome
		--
		caraterInternacao varchar(1) './ans:caraterInternacao', -- st_eletivaEmergencia
		tipoInternacao int './ans:tipoInternacao', -- st_tipoInternacao
		indicacaoClinica varchar(500) './ans:indicacaoClinica', -- st_indicacaoClinica
		regimeInternacao varchar(1) './ans:regimeInternacao', -- st_regimeInternacao
		--
		nomeTabela varchar(10) './ans:hipotesesDiagnosticas/ans:CIDPrincipal/ans:CID/ans:nomeTabela', -- st_tabelasDiagnostico
		codigoDiagnostico varchar(5) './ans:hipotesesDiagnosticas/ans:CIDPrincipal/ans:CID/ans:codigoDiagnostico', -- st_codigoDiagnostico
		descricaoDiagnostico varchar(70) './ans:hipotesesDiagnosticas/ans:CIDPrincipal/ans:CID/ans:descricaoDiagnostico', -- st_nome
		--
		tipoDoenca varchar(1) './ans:hipotesesDiagnosticas/ans:CIDPrincipal/ans:tipoDoenca', -- st_tipoDoenca
		--
		valor int './ans:hipotesesDiagnosticas/ans:CIDPrincipal/ans:tempoReferidoEvolucaoDoenca/ans:valor', -- st_numeroInteiro
		unidadeTempo varchar(1) './ans:hipotesesDiagnosticas/ans:CIDPrincipal/ans:tempoReferidoEvolucaoDoenca/ans:unidadeTempo', -- st_unidadeTempo
		--
		indicadorAcidente int './ans:hipotesesDiagnosticas/ans:CIDPrincipal/ans:indicadorAcidente', -- st_indicadorAcidente
		--
		nomeTabela1 varchar(10) './ans:hipotesesDiagnosticas/ans:diagnosticosSecundarios/ans:CID[1]/ans:nomeTabela', -- st_tabelasDiagnostico
		codigoDiagnostico1 varchar(5) './ans:hipotesesDiagnosticas/ans:diagnosticosSecundarios/ans:CID[1]/ans:codigoDiagnostico', -- st_codigoDiagnostico
		descricaoDiagnostico1 varchar(70) './ans:hipotesesDiagnosticas/ans:diagnosticosSecundarios/ans:CID[1]/ans:descricaoDiagnostico', -- st_nome
		--
		nomeTabela2 varchar(10) './ans:hipotesesDiagnosticas/ans:diagnosticosSecundarios/ans:CID[2]/ans:nomeTabela', -- st_tabelasDiagnostico
		codigoDiagnostico2 varchar(5) './ans:hipotesesDiagnosticas/ans:diagnosticosSecundarios/ans:CID[2]/ans:codigoDiagnostico', -- st_codigoDiagnostico
		descricaoDiagnostico2 varchar(70) './ans:hipotesesDiagnosticas/ans:diagnosticosSecundarios/ans:CID[2]/ans:descricaoDiagnostico', -- st_nome
		--
		nomeTabela3 varchar(10) './ans:hipotesesDiagnosticas/ans:diagnosticosSecundarios/ans:CID[3]/ans:nomeTabela', -- st_tabelasDiagnostico
		codigoDiagnostico3 varchar(5) './ans:hipotesesDiagnosticas/ans:diagnosticosSecundarios/ans:CID[3]/ans:codigoDiagnostico', -- st_codigoDiagnostico
		descricaoDiagnostico3 varchar(70) './ans:hipotesesDiagnosticas/ans:diagnosticosSecundarios/ans:CID[3]/ans:descricaoDiagnostico', -- st_nome
		--
		diasSolicitados int './ans:diasSolicitados', -- st_data
		dataProvavelAdmisHosp varchar(30) './ans:dataProvavelAdmisHosp', -- st_data
		observacao varchar(240) './ans:observacao' -- st_observacao
		)

		-- Retorna Identity da tabela guiaSolicInternacao
		SET @Chave_gsi = IDENT_CURRENT('guiaSolicInternacao')

		SET @prc = CONCAT(@gsiVariavel,'/ans:procedimentosExamesSolicitados')

		INSERT INTO guiaSolicInternacao_prc
		SELECT @Chave_gsi,*
		FROM OPENXML(@DOC,@prc, 2) 
		WITH 
		(
			quantidadeSolicitada decimal(12,4) './ans:procedimentoSolicitado/ans:quantidadeSolicitada', -- st_quantidade
			--
			codigo varchar(10) './ans:procedimentoSolicitado/ans:procedimento/ans:codigo', -- st_codigoTabela
			tipoTabela varchar(2) './ans:procedimentoSolicitado/ans:procedimento/ans:tipoTabela', -- st_tabela
			descricao varchar(60) './ans:procedimentoSolicitado/ans:procedimento/ans:descricao' -- st_descricaoTabela
		)

		SET @ops = CONCAT(@gsiVariavel,'/ans:OPMsSolicitadas')

		INSERT INTO guiaSolicInternacao_ops
		SELECT @Chave_gsi,*
		FROM OPENXML(@DOC, @ops, 2) 
		WITH 
		(
			quantidadeSolicitada decimal(12,4) './ans:OPMSolicitada/ans:quantidadeSolicitada', -- st_quantidade
			fabricante varchar(40) './ans:OPMSolicitada/ans:fabricante', -- st_descricao40
			valor decimal(9,2) './ans:OPMSolicitada/ans:valor', -- st_valorMonetario
			--
			codigo varchar(10) './ans:OPMSolicitada/ans:OPM/ans:codigo', -- st_codigoTabela
			tipoTabela varchar(2) './ans:OPMSolicitada/ans:OPM/ans:tipoTabela', -- st_tabela
			descricao varchar(60) './ans:OPMSolicitada/ans:OPM/ans:descricao' -- st_descricaoTabela
		)

		SET @ContadorGSI +=1

	END

EXEC sp_xml_removedocument @DOC

END
