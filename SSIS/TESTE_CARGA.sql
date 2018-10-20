
------------------ IMPORTA XML PARA O TISS ------------------
USE TISS
GO

DELETE TISS.[dbo].[mensagemTISS]
DELETE TISS.[dbo].[loteGuias]
DELETE TISS.[dbo].[guiaConsulta]
DELETE TISS.[dbo].[guiaHonorarioIndividual]
DELETE TISS.[dbo].[guiaHonorarioIndividual_prc]
DELETE TISS.[dbo].[guiaResumoInternacao]
DELETE TISS.[dbo].[guiaResumoInternacao_dsp]
DELETE TISS.[dbo].[guiaResumoInternacao_opu]
DELETE TISS.[dbo].[guiaResumoInternacao_prc]
DELETE TISS.[dbo].[guiaResumoInternacao_prc_eqp]
DELETE TISS.[dbo].[guiaSP_SADT]
DELETE TISS.[dbo].[guiaSP_SADT_dsp]
DELETE TISS.[dbo].[guiaSP_SADT_opu]
DELETE TISS.[dbo].[guiaSP_SADT_prc]
DELETE TISS.[dbo].[guiaSP_SADT_prc_eqp]
DELETE TISS.[dbo].[guiaSolicInternacao]
DELETE TISS.[dbo].[guiaSolicInternacao_ops]
DELETE TISS.[dbo].[guiaSolicInternacao_prc]

-- mensagem
SELECT * FROM TISS.[dbo].[mensagemTISS]
-- loteGuias
SELECT * FROM TISS.[dbo].[loteGuias]

-- guiaConsulta
SELECT * FROM TISS.[dbo].[guiaConsulta]

-- guiaHonorarioIndividual
SELECT * FROM TISS.[dbo].[guiaHonorarioIndividual]
SELECT * FROM TISS.[dbo].[guiaHonorarioIndividual_prc]

--guiaResumoInternacao
SELECT * FROM TISS.[dbo].[guiaResumoInternacao]
SELECT * FROM TISS.[dbo].[guiaResumoInternacao_dsp]
SELECT * FROM TISS.[dbo].[guiaResumoInternacao_opu]
SELECT * FROM TISS.[dbo].[guiaResumoInternacao_prc]
SELECT * FROM TISS.[dbo].[guiaResumoInternacao_prc_eqp]

-- guiaSP_SADT
SELECT * FROM TISS.[dbo].[guiaSP_SADT]
SELECT * FROM TISS.[dbo].[guiaSP_SADT_dsp]
SELECT * FROM TISS.[dbo].[guiaSP_SADT_opu]
SELECT * FROM TISS.[dbo].[guiaSP_SADT_prc]
SELECT * FROM TISS.[dbo].[guiaSP_SADT_prc_eqp]

-- guiaSolicInternacao
SELECT * FROM TISS.[dbo].[guiaSolicInternacao]
SELECT * FROM TISS.[dbo].[guiaSolicInternacao_ops]
SELECT * FROM TISS.[dbo].[guiaSolicInternacao_prc]



------------------ EXPORTA TISS PARA O LOGA ------------------

USE LOGA
GO
DELETE [dbo].[Operadora]
DELETE [dbo].[Prestador]
DELETE [dbo].[Paciente]
DELETE [dbo].[Medico]
DELETE [dbo].[Conta]
DELETE [dbo].[TabelaProcedimento]
DELETE [dbo].[ContaProcedimento]
DELETE [dbo].[ContaMaterial]
DELETE [dbo].[ContaMedicamento]
DELETE [dbo].[TabelaMedicamento]
DELETE [dbo].[ContaMedicamento]
DELETE [dbo].[TabelaMaterial]
DELETE [dbo].[ContaMaterial]
USE LOGA
GO

SELECT * FROM [dbo].[Operadora]
SELECT * FROM [dbo].[Prestador]
SELECT * FROM [dbo].[Paciente]
SELECT * FROM [dbo].[Medico]
SELECT * FROM [dbo].[Conta]

SELECT * FROM [dbo].[TabelaProcedimento]
SELECT * FROM [dbo].[ContaProcedimento] 

SELECT * FROM [dbo].[TabelaMaterial]
SELECT * FROM [dbo].[ContaMaterial]

SELECT * FROM [dbo].[TabelaMedicamento]
SELECT * FROM [dbo].[ContaMedicamento]