USE [TISS]
GO
/****** Object:  StoredProcedure [dbo].[lsp_guiaConsulta]    Script Date: 10/20/2018 8:36:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[lsp_guiaConsulta] 
(@Chave_lgs int)
AS
BEGIN

SET ANSI_WARNINGS OFF
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @XML XML;
DECLARE @DOC INT;
DECLARE @caminhoGUIA varchar(150) = '/ans:mensagemTISS/ans:prestadorParaOperadora/ans:loteGuias/ans:guias/ans:guiaFaturamento/ans:guiaConsulta';

SELECT @XML = ArquivoXML  FROM [TempDB].[dbo].[PreImportaXML]

EXEC sp_xml_preparedocument @DOC OUTPUT, 
	@XML,
	'<ans:guiaConsulta xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" />'

INSERT guiaConsulta
SELECT @Chave_lgs,* 
FROM OPENXML(@DOC, @caminhoGUIA, 2) 
 WITH 
(
registroANS varchar(6) './ans:identificacaoGuia/ans:registroANS', -- st_registroANS
dataEmissaoGuia varchar(30) './ans:identificacaoGuia/ans:dataEmissaoGuia', -- st_data
numeroGuiaPrestador varchar(20) './ans:identificacaoGuia/ans:numeroGuiaPrestador', -- st_numeroGuia
numeroGuiaOperadora varchar(20) './ans:identificacaoGuia/ans:numeroGuiaOperadora', -- st_numeroGuia
--
numeroCarteira varchar(20) './ans:beneficiario/ans:numeroCarteira', -- st_descricao20
nomeBeneficiario varchar(70) './ans:beneficiario/ans:nomeBeneficiario', -- st_nome
nomePlano varchar(40) './ans:beneficiario/ans:nomePlano', -- st_descricao40
validadeCarteira varchar(30) './ans:beneficiario/ans:validadeCarteira', -- st_data
numeroCNS varchar(15) './ans:beneficiario/ans:numeroCNS', -- st_descricao15
identificadorBeneficiario varchar(1000)'./ans:beneficiario/ans:identificadorBeneficiario',
--
CNPJ varchar(14) './ans:dadosContratado/ans:identificacao/ans:CNPJ', -- st_CNPJ [0-9]{14} 
cpf varchar(11) './ans:dadosContratado/ans:identificacao/ans:cpf', -- st_CPF [0-9]{11} 
codigoPrestadorNaOperadora varchar(20) './ans:dadosContratado/ans:identificacao/ans:codigoPrestadorNaOperadora', -- st_codigoPrestadorNaOperadora
--
nomeContratado varchar(70) './ans:dadosContratado/ans:nomeContratado', -- st_nome
--
tipoLogradouro varchar(3) './ans:dadosContratado/ans:enderecoContratado/ans:tipoLogradouro', -- st_tipoLogradouro
logradouro varchar(40) './ans:dadosContratado/ans:enderecoContratado/ans:logradouro', -- st_logradouro
numero varchar(5) './ans:dadosContratado/ans:enderecoContratado/ans:numero', -- st_numeroLogradouro
complemento varchar(15) './ans:dadosContratado/ans:enderecoContratado/ans:complemento', -- st_descricao15
codigoIBGEMunicipio varchar(7) './ans:dadosContratado/ans:enderecoContratado/ans:codigoIBGEMunicipio', -- st_codigoMunicipioIBGE
municipio varchar(40) './ans:dadosContratado/ans:enderecoContratado/ans:municipio', -- st_descricao40
codigoUF varchar(2) './ans:dadosContratado/ans:enderecoContratado/ans:codigoUF', -- st_UF
cep integer './ans:dadosContratado/ans:enderecoContratado/ans:cep', -- st_CEP
--
numeroCNES varchar(7) './ans:dadosContratado/ans:numeroCNES', -- st_CNES
--
nomeProfissional varchar(70) './ans:profissionalExecutante/ans:nomeProfissional', -- st_nome
--
siglaConselho varchar(10) './ans:profissionalExecutante/ans:conselhoProfissional/ans:siglaConselho', -- st_conselhoProfissional
numeroConselho varchar(15) './ans:profissionalExecutante/ans:conselhoProfissional/ans:numeroConselho', -- st_descricao15
ufConselho varchar(2) './ans:profissionalExecutante/ans:conselhoProfissional/ans:ufConselho', -- st_UF
--
cbos varchar(5) './ans:profissionalExecutante/ans:cbos', -- st_CBOS
--
nomeTabela varchar(10) './ans:hipoteseDiagnostica/ans:CID/ans:nomeTabela', -- st_tabelasDiagnostico
codigoDiagnostico varchar(5) './ans:hipoteseDiagnostica/ans:CID/ans:codigoDiagnostico', -- st_codigoDiagnostico
descricaoDiagnostico varchar(70) './ans:hipoteseDiagnostica/ans:CID/ans:descricaoDiagnostico', -- st_nome
--
tipoDoenca varchar(1) './ans:hipoteseDiagnostica/ans:tipoDoenca', -- st_tipoDoenca
--
valor integer './ans:hipoteseDiagnostica/ans:tempoReferidoEvolucaoDoenca/ans:valor', -- st_numeroInteiro
unidadeTempo varchar(1) './ans:hipoteseDiagnostica/ans:tempoReferidoEvolucaoDoenca/ans:unidadeTempo', -- st_unidadeTempo
--
indicadorAcidente integer './ans:hipoteseDiagnostica/ans:indicadorAcidente', -- st_indicadorAcidente
--
nomeTabela1 varchar(10) './ans:hipoteseDiagnostica/ans:diagnosticoSecundario/ans:CID[1]/ans:nomeTabela', -- st_tabelasDiagnostico
codigoDiagnostico1 varchar(5) './ans:hipoteseDiagnostica/ans:diagnosticoSecundario/ans:CID[1]/ans:codigoDiagnostico', -- st_codigoDiagnostico
descricaoDiagnostico1 varchar(70) './ans:hipoteseDiagnostica/ans:diagnosticoSecundario/ans:CID[1]/ans:descricaoDiagnostico', -- st_nome
--
nomeTabela2 varchar(10) './ans:hipoteseDiagnostica/ans:diagnosticoSecundario/ans:CID[2]/ans:nomeTabela', -- st_tabelasDiagnostico
codigoDiagnostico2 varchar(5) './ans:hipoteseDiagnostica/ans:diagnosticoSecundario/ans:CID[2]/ans:codigoDiagnostico', -- st_codigoDiagnostico
descricaoDiagnostico2 varchar(70) './ans:hipoteseDiagnostica/ans:diagnosticoSecundario/ans:CID[2]/ans:descricaoDiagnostico', -- st_nome
--
nomeTabela3 varchar(10) './ans:hipoteseDiagnostica/ans:diagnosticoSecundario/ans:CID[3]/ans:nomeTabela', -- st_tabelasDiagnostico
codigoDiagnostico3 varchar(5) './ans:hipoteseDiagnostica/ans:diagnosticoSecundario/ans:CID[3]/ans:codigoDiagnostico', -- st_codigoDiagnostico
descricaoDiagnostico3 varchar(70) './ans:hipoteseDiagnostica/ans:diagnosticoSecundario/ans:CID[3]/ans:descricaoDiagnostico', -- st_nome
--
dataAtendimento varchar(30) './ans:dadosAtendimento/ans:dataAtendimento', -- st_data
--
codigoTabela varchar(2) './ans:dadosAtendimento/ans:procedimento/ans:codigoTabela', -- st_tabela
codigoProcedimento varchar(10) './ans:dadosAtendimento/ans:procedimento/ans:codigoProcedimento', -- st_codigoTabela
--
tipoConsulta varchar(1) './ans:dadosAtendimento/ans:tipoConsulta', -- st_tipoConsulta
tipoSaida integer './ans:dadosAtendimento/ans:tipoSaida', -- st_tipoSaidaGuiaConsulta
--
observacao varchar(240) './ans:observacao' -- st_observacao
)

EXEC sp_xml_removedocument @DOC

END
