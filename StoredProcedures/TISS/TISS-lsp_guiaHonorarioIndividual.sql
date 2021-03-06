USE [TISS]
GO
/****** Object:  StoredProcedure [dbo].[lsp_guiaHonorarioIndividual]    Script Date: 10/20/2018 8:38:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[lsp_guiaHonorarioIndividual]
  @Chave_lgs INT

AS
BEGIN

SET ANSI_WARNINGS OFF
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @caminhoGUIA VARCHAR(500) = '/ans:mensagemTISS/ans:prestadorParaOperadora/ans:loteGuias/ans:guias/ans:guiaFaturamento/ans:guiaHonorarioIndividual'
DECLARE @XML XML;
DECLARE @Qtde_ghi INT;
DECLARE @ghiVariavel VARCHAR(500);
DECLARE @ghi_prc_Variavel VARCHAR(500);
DECLARE @ContadorGHI INT = 1;
DECLARE @Chave_ghi INT;
DECLARE @DOC INT;

SELECT @XML = ArquivoXML FROM [TempDB].[dbo].[PreImportaXML]

EXEC sp_xml_preparedocument @DOC OUTPUT, 
	@XML,
	'<ans:guiaHonorarioIndividual xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" />'

SELECT @Qtde_ghi = COUNT(*)
FROM OPENXML(@DOC, @caminhoGUIA, 2) 
WITH 
(
registroANS varchar(6) './ans:identificacaoGuiaHonorarioIndividual/ans:registroANS' -- st_registroANS
)

WHILE @ContadorGHI <= @Qtde_ghi
		BEGIN
			SET @ghiVariavel = CONCAT(@caminhoGUIA,'[',CAST(@ContadorGHI AS VARCHAR(10)),']')

			-- Insere na tabela: guiaHonorarioIndividual
			INSERT guiaHonorarioIndividual
			SELECT @Chave_lgs,*,NULL
			FROM OPENXML(@DOC, @ghiVariavel, 2) 
			WITH 
			(
			registroANS varchar(6) './ans:identificacaoGuiaHonorarioIndividual/ans:registroANS', -- st_registroANS
			dataEmissaoGuia varchar(30) './ans:identificacaoGuiaHonorarioIndividual/ans:dataEmissaoGuia', -- st_data
			numeroGuiaPrestador varchar(20) './ans:identificacaoGuiaHonorarioIndividual/ans:numeroGuiaPrestador', -- st_numeroGuia
			numeroGuiaOperadora varchar(20) './ans:identificacaoGuiaHonorarioIndividual/ans:numeroGuiaOperadora', -- st_numeroGuia
			--
			numeroGuiaPrincipal varchar(20) './ans:numeroGuiaPrincipal',
			--
			cnt_numeroCarteira varchar(20) './ans:dadosBeneficiario/ans:numeroCarteira', -- st_descricao20
			cnt_nomeBeneficiario varchar(70) './ans:dadosBeneficiario/ans:nomeBeneficiario', -- st_nome
			cnt_nomePlano varchar(40) './ans:dadosBeneficiario/ans:nomePlano', -- st_descricao40
			cnt_validadeCarteira varchar(30) './ans:dadosBeneficiario/ans:validadeCarteira', -- st_data
			cnt_numeroCNS varchar(15) './ans:dadosBeneficiario/ans:numeroCNS', -- st_descricao15
			cnt_identificadorBeneficiario varchar(20) './ans:dadosBeneficiario/ans:identificadorBeneficiario',
			--
			cnt_CNPJ varchar(14) './ans:contratado/ans:identificacao/ans:CNPJ', -- st_CNPJ [0-9]{14} 
			cnt_cpf varchar(11) './ans:contratado/ans:identificacao/ans:cpf', -- st_CPF [0-9]{11} 
			cnt_codigoPrestadorNaOperadora varchar(20) './ans:contratado/ans:identificacao/ans:codigoPrestadorNaOperadora', -- st_codigoPrestadorNaOperadora
			--
			cnt_nomeContratado varchar(70) './ans:contratado/ans:nomeContratado', -- st_nome
			--
			cnt_tipoLogradouro varchar(3) './ans:contratado/ans:enderecoContratado/ans:tipoLogradouro', -- st_tipoLogradouro
			cnt_logradouro varchar(40) './ans:contratado/ans:enderecoContratado/ans:logradouro', -- st_logradouro
			cnt_numero varchar(5) './ans:contratado/ans:enderecoContratado/ans:numero', -- st_numeroLogradouro
			cnt_complemento varchar(15) './ans:contratado/ans:enderecoContratado/ans:complemento', -- st_descricao15
			cnt_codigoIBGEMunicipio varchar(7) './ans:contratado/ans:enderecoContratado/ans:codigoIBGEMunicipio', -- st_codigoMunicipioIBGE
			cnt_municipio varchar(40) './ans:contratado/ans:enderecoContratado/ans:municipio', -- st_descricao40
			cnt_codigoUF varchar(2) './ans:contratado/ans:enderecoContratado/ans:codigoUF', -- st_UF
			cnt_cep int './ans:contratado/ans:enderecoContratado/ans:cep', -- st_CEP
			--
			cnt_numeroCNES varchar(7) './ans:contratado/ans:numeroCNES', -- st_CNES
			--
			cne_CNPJ varchar(14) './ans:contratadoExecutante/ans:identificacao/ans:CNPJ', -- st_CNPJ [0-9]{14} 
			cne_cpf varchar(11) './ans:contratadoExecutante/ans:identificacao/ans:cpf', -- st_CPF [0-9]{11} 
			cne_codigoPrestadorNaOperadora varchar(20) './ans:contratadoExecutante/ans:identificacao/ans:codigoPrestadorNaOperadora', -- st_codigoPrestadorNaOperadora
			--
			cne_nomeContratado varchar(70) './ans:contratadoExecutante/ans:nomeContratado', -- st_nome
			--
			cne_tipoLogradouro varchar(3) './ans:contratadoExecutante/ans:enderecoContratado/ans:tipoLogradouro', -- st_tipoLogradouro
			cne_logradouro varchar(40) './ans:contratadoExecutante/ans:enderecoContratado/ans:logradouro', -- st_logradouro
			cne_numero varchar(5) './ans:contratadoExecutante/ans:enderecoContratado/ans:numero', -- st_numeroLogradouro
			cne_complemento varchar(15) './ans:contratadoExecutante/ans:enderecoContratado/ans:complemento', -- st_descricao15
			cne_codigoIBGEMunicipio varchar(7) './ans:contratadoExecutante/ans:enderecoContratado/ans:codigoIBGEMunicipio', -- st_codigoMunicipioIBGE
			cne_municipio varchar(40) './ans:contratadoExecutante/ans:enderecoContratado/ans:municipio', -- st_descricao40
			cne_codigoUF varchar(2) './ans:contratadoExecutante/ans:enderecoContratado/ans:codigoUF', -- st_UF
			cne_cep int './ans:contratadoExecutante/ans:enderecoContratado/ans:cep', -- st_CEP
			--
			cne_numeroCNES varchar(7) './ans:contratadoExecutante/ans:numeroCNES', -- st_CNES
			--
			nomeExecutante varchar(70) './ans:contratadoExecutante/ans:identificacaoProfissional/ans:nomeExecutante', -- st_nome
			--
			siglaConselho varchar(10) './ans:contratadoExecutante/ans:identificacaoProfissional/ans:conselhoProfissional/ans:siglaConselho', -- st_conselhoProfissional
			numeroConselho varchar(15) './ans:contratadoExecutante/ans:identificacaoProfissional/ans:conselhoProfissional/ans:numeroConselho', -- st_descricao15
			ufConselho varchar(2) './ans:contratadoExecutante/ans:identificacaoProfissional/ans:conselhoProfissional/ans:ufConselho', -- st_UF
			--
			codigoCBOS varchar(5) './ans:contratadoExecutante/ans:identificacaoProfissional/ans:codigoCBOS', -- st_CBOS
			--
			posicaoProfissional int './ans:contratadoExecutante/ans:posicaoProfissional', -- st_posicaoProfissao
			--
			tipoAcomodacao varchar(2) './ans:contratadoExecutante/ans:tipoAcomodacao', -- st_tipoAcomodacao
			--
			totalGeralHonorario decimal(9,2) './ans:procedimentosExamesRealizados/ans:totalGeralHonorario', -- st_valorMonetario
			--
			observacao varchar(240) './ans:observacao' -- st_observacao
			)

			-- Retorna Identity da tabela: guiaHonorarioIndividual
			SET @Chave_ghi = IDENT_CURRENT('guiaHonorarioIndividual')

			SET @ghi_prc_Variavel = CONCAT (@ghiVariavel,'/ans:procedimentosExamesRealizados/ans:procedimentoRealizado')

			-- Insere na tabela: guiaHonorarioIndividual_prc
			INSERT guiaHonorarioIndividual_prc
			SELECT @Chave_ghi,*
			FROM OPENXML(@DOC, @ghi_prc_Variavel, 2) 
			WITH 
			(
			data varchar(30) './ans:data', -- st_data
			horaInicio varchar(30) './ans:horaInicio', -- st_hora
			horaFim varchar(30) './ans:horaFim', -- st_hora
			--
			codigo varchar(10) './ans:procedimento/ans:codigo', -- st_codigoTabela
			tipoTabela varchar(2) './ans:procedimento/ans:tipoTabela', -- st_tabela
			descricao varchar(60) './ans:procedimento/ans:descricao', -- st_descricaoTabela
			--
			quantidadeRealizada decimal(12,4) './ans:quantidadeRealizada', -- st_quantidade
			viaAcesso varchar(1) './ans:viaAcesso', -- st_viaDeAcesso
			tecnicaUtilizada varchar(1) './ans:tecnicaUtilizada', -- st_tecnicaUtilizada
			reducaoAcrescimo decimal(9,2) './ans:reducaoAcrescimo', -- st_percentual
			valor decimal(9,2) './ans:valor', -- st_valorMonetario
			valorTotal decimal(9,2) './ans:valorTotal' -- st_valorMonetario
			)

			SET @ContadorGHI +=1
		END

EXEC sp_xml_removedocument @DOC
END
