USE [TISS]
GO
/****** Object:  StoredProcedure [dbo].[lsp_Exportar_TISS_Staging_para_Loga_pa]    Script Date: 10/20/2018 8:34:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[lsp_Exportar_TISS_Staging_para_Loga_pa] 

AS

SET NOCOUNT Off;

DECLARE @qtdcontas int = 0;
DECLARE @ChaveOperadora int = 0;
DECLARE @ChavePrestador int = 0;
DECLARE @chaveimportacao int = 0;
DECLARE @i int = 1;
DECLARE @qtdlinhas int;
DECLARE @ArqID int;
DECLARE @msg VARCHAR(200) = '';

SELECT TOP 1 @chaveimportacao =  [chaveimportacao] 
FROM [TEMPDB].[dbo].[TISS_Staging_ordenada]

SELECT @qtdcontas = MAX(agg), @qtdlinhas = COUNT(*)  
FROM tempdb.dbo.TISS_Staging_ordenada 
			

			------------------------ IMPORTACAO ------------------------
			INSERT [LOGA].[dbo].[Importacao] 
			(
			Chave_msg_tiss
			,Descricao
			,NomeArquivo
			,Data
			,SYSDate
			,tamanho_arquivo
			,qtd_linhas
			,qtd_contas
			,mensagem
			,tp
			)
			SELECT
			 Chave
			,ArquivoNome
			,Arquivo
			,ArquivoData
			,SYSDATETIME()
			,tamanho_arquivo
			,@qtdlinhas
			,@qtdcontas
			,'Log: Importando Arquivo do TISS para Loga!'
			,'xml'
			FROM [TISS].[DBO].mensagemTISS AS MSG
			WHERE MSG.Chave = @chaveimportacao

	
			SELECT @ArqID = @@IDENTITY;

			IF @qtdcontas > 0 
			BEGIN TRY
			  BEGIN TRAN EXPORTATISS
			  ------------------------- OPERADORA -------------------------
						--VERIFICANDO SE EXISTE A OPERADORA
						SET @msg = 'Log: Verificando se Existe Operadora';

						SELECT TOP 1 @ChaveOperadora = COALESCE(OP.Chave,0)
						FROM LOGA.[dbo].[Operadora] AS OP
						INNER JOIN tempdb.[dbo].[TISS_Staging_ordenada] AS P
						ON  OP.Codigo = SUBSTRING(P.linha,3,10)
						AND P.chaveimportacao = @chaveimportacao
						AND P.tipolinha = 11 -- Operadora

						-- SE NÃO EXISTIR OPERADORA ENTAO INSERE
						IF @ChaveOperadora = 0
						BEGIN
			  			    SET @msg = 'Log: Inserindo Nova Operadora!';
							INSERT LOGA.[dbo].[Operadora] 
							(Codigo,Nome,SYSDate)
							SELECT TOP 1
								 SUBSTRING(P.linha,3,10) 
								,TRIM(SUBSTRING(linha,13,22)) 
								,GETDATE()
							FROM tempdb.[dbo].[TISS_Staging_ordenada] AS P
							WHERE P.chaveimportacao = @chaveimportacao
							AND P.tipolinha = 11 -- Operadora

							SELECT @ChaveOperadora = @@IDENTITY
						END

			   ------------------------- PRESTADOR ------------------------- 

					-- VERIFICA SE EXISTE PRESTADOR COM O MESMO CODIGO DE PRESTADOR E CHAVE DE OPERADORA
					SET @msg = 'Log: Verificando se Existe Prestador';
					SELECT TOP 1 @ChavePrestador = COALESCE(PR.Chave,0)
					FROM LOGA.[dbo].[Prestador] AS  PR
					INNER JOIN tempdb.[dbo].[TISS_Staging_ordenada] AS P
					ON  PR.Codigo = SUBSTRING(P.linha,3,10)
					WHERE PR.Codigo <> '0000000000' 
 					AND PR.Codigo not like 'PJ%'
					AND PR.Codigo not like 'F%'
					AND ChaveOperadora = @ChaveOperadora
					AND P.chaveimportacao = @chaveimportacao
					AND P.tipolinha = 12  -- Prestador
		
					--DEBUG CNPJ:
					--SELECT TRIM(SUBSTRING(linha,65,14)) FROM tempdb.[dbo].[TISS_Staging_ordenada] WHERE tipolinha = 0 

				   --SE NÃO EXISTIR PRESTADOR PROCURA POR CNPJ
				   IF @ChavePrestador = 0
					BEGIN
					  SET @msg = 'Buscando Prestador por CNPJ!'

					  --VERIFICANDO SE EXISTE PRESTADOR COM O MESMO CNPJ E CHAVE DE OPERADORA
					  SELECT DISTINCT @ChavePrestador = Chave 
					  FROM  LOGA.[dbo].[Prestador] AS PR
					  INNER JOIN tempdb.[dbo].[TISS_Staging_ordenada] AS P
					  ON PR.CNPJ = TRIM(SUBSTRING(P.linha,187,14))	
					  WHERE PR.CNPJ <> '00000000000000' 
					  AND TRIM(PR.CNPJ) <> ''  
					  AND PR.ChaveOperadora = @ChaveOperadora
					  AND P.chaveimportacao = @chaveimportacao
					  AND P.tipolinha = 12  -- Prestador
					END
  				   --DEBUG CPF:
				   --SELECT TRIM(SUBSTRING(linha,65,11)) FROM tempdb.[dbo].[TISS_Staging_ordenada] WHERE tipolinha = 0 

				   --SE NÃO EXISTIR PRESTADOR PROCURA POR CPF
				   IF @ChavePrestador = 0
					BEGIN
					  SET @msg = 'Buscando Prestador por CPF!'

					  --VERIFICANDO SE EXISTE PRESTADOR COM O MESMO CPF E CHAVE DE OPERADORA
					  SELECT DISTINCT @ChavePrestador = Chave 
					  FROM LOGA.[dbo].[Prestador] AS PR
					  INNER JOIN tempdb.[dbo].[TISS_Staging_ordenada] AS P
					  ON  PR.CPF = TRIM(SUBSTRING(P.linha,187,11))
					  WHERE PR.CPF <> '00000000000' 
					  AND TRIM(PR.CPF) <> ''  
					  AND PR.ChaveOperadora = @ChaveOperadora
					  AND P.chaveimportacao = @chaveimportacao
					  AND P.tipolinha = 12  -- Prestador
					END

				   --SE NÃO EXISTIR PRESTADOR PROCURA PELO NOME
				   IF @ChavePrestador IS NULL
					BEGIN

					  --VERIFICANDO SE EXISTE PRESTADOR COM O MESMO NOME E CHAVE DE OPERADORA
					  SELECT TOP 1 @ChavePrestador = Chave 
					  FROM LOGA.[dbo].[Prestador] AS PR
					  INNER JOIN tempdb.[dbo].[TISS_Staging_ordenada] AS P
					  ON  Nome = TRIM(SUBSTRING(P.linha,13,40))
					  WHERE TRIM(Nome) <> ''  
					  AND ChaveOperadora = @ChaveOperadora
					  AND P.chaveimportacao = @chaveimportacao
					  AND P.tipolinha = 12  -- Prestador
					END

				-- SE NÃO EXISTIR PRESTADOR ENTAO INSERE NOVO PRESTADOR DESASSOCIADO
					IF @ChavePrestador = 0
					  BEGIN
						SET @msg = 'Log: Inserindo Novo Prestador!';
						INSERT LOGA.[dbo].[Prestador] (ChaveOperadora,Codigo,Nome,CPF,CNPJ,CEP,SYSDate)
						SELECT TOP 1
						 @ChaveOperadora 
						,SUBSTRING(P.linha,3,10) AS CODIGO
						,TRIM(SUBSTRING(P.linha,13,40)) AS Nome
						,TRIM(SUBSTRING(P.linha,187,11)) AS CPF
						,TRIM(SUBSTRING(P.linha,187,14)) AS CNPJ
						,TRIM(SUBSTRING(P.linha,279,8)) AS CEP
    					,GETDATE()
						FROM tempdb.[dbo].[TISS_Staging_ordenada] AS P
						WHERE P.chaveimportacao = @chaveimportacao
						AND P.tipolinha = 12  -- Prestador

						SELECT @ChavePrestador = @@IDENTITY
					END

			   DECLARE @ChavePaciente int;
			   DECLARE @ChaveMedico int;
			   DECLARE @ChaveSolicitante int;
			   DECLARE @ChaveConta int;
			   DECLARE @DataRemessa DATETIME;
			   DECLARE @Remessa int;
			   DECLARE @EmpresaConectividade VARCHAR(10);
			   DECLARE @IdArquivo VARCHAR(9);
			   DECLARE @Lote int;
			   DECLARE @Plano int;
			   DECLARE @Senha varchar(10);
			   DECLARE @DataEntrada DATETIME;
			   DECLARE @DataSaida DATETIME;
			   DECLARE @TipoAcomodacao AS CHAR(2);
			   DECLARE @TipoAtendimento AS CHAR(2);
			   DECLARE @Cid AS CHAR(5);
			   DECLARE @NumParcela int;
			   DECLARE @QtdeItens int;
			   DECLARE @Valor numeric(12,2); 
			   DECLARE @Numero AS CHAR(10);
			   DECLARE @ValorProcedimento AS numeric(12,2);
			   DECLARE @ValorMedicamento AS numeric(12,2);
			   DECLARE @ValorMaterial AS numeric(12,2);
			   DECLARE @ValorTaxa AS numeric(12,2);
			   DECLARE @ValorDiaria AS numeric(12,2);

			   -- Header Arquivo
			   SELECT TOP 1 @DataRemessa = TRY_CONVERT(DATETIME,CONCAT(SUBSTRING(P.linha,17,4),SUBSTRING(P.linha,15,2),SUBSTRING(P.linha,13,2)),112)
					   ,@Remessa = TRIM(SUBSTRING(P.linha,152,4))
					   ,@EmpresaConectividade = TRIM(SUBSTRING(P.linha,146,4))
					  , @IdArquivo = TRIM(SUBSTRING(P.linha,150,9))
			   FROM tempdb.[dbo].[TISS_Staging_ordenada] AS P
			   WHERE P.chaveimportacao = @chaveimportacao
			   AND P.tipolinha = 1

			   DECLARE @numconta int = 1;

			   -- RECURSIVIDADE PARA ITENS DA MESMA CONTA
			   WHILE (@numconta <= @qtdcontas)
				 BEGIN

				  ----------------------- PACIENTE ------------------------- 
					SET @ChavePaciente = 0
					-- VERIFICANDO SE EXISTE PACIENTE COM O MESMO CODIGO DE PACIENTE E CHAVE DE OPERADORA
	 					SET @msg = 'Log: Verificando se Existe Paciente';
						SELECT TOP 1 @ChavePaciente = COALESCE(PC.Chave,0)
	 					FROM LOGA.[dbo].[Paciente] AS  PC
	 					INNER JOIN tempdb.[dbo].[TISS_Staging_ordenada] AS P
	 					ON  PC.Codigo = SUBSTRING(P.linha,3,30)
						WHERE PC.ChaveOperadora = @ChaveOperadora
						AND P.chaveimportacao = @chaveimportacao
						AND P.agg = @numconta 
						AND P.tipolinha = 13 -- Paciente
		
					IF @ChavePaciente = 0
					BEGIN
					    SET @msg = 'Log: Inserindo Novo Paciente!';
						INSERT LOGA.[dbo].[Paciente] (ChaveOperadora,Codigo,DataNascimento,Sexo,SYSDate)
						SELECT
						 @ChaveOperadora 
						,TRIM(SUBSTRING(P.linha,3,30)) AS Codigo
						,TRY_CONVERT(DATETIME,CONCAT(SUBSTRING(P.linha,87,4),SUBSTRING(P.linha,85,2),SUBSTRING(P.linha,83,2)),112) AS DataNascimento
						,TRIM(SUBSTRING(P.linha,91,1)) AS Sexo
						,GETDATE() AS SYSDate
						FROM tempdb.[dbo].[TISS_Staging_ordenada] AS P
						WHERE P.chaveimportacao = @chaveimportacao
						AND P.agg = @numconta
						AND P.tipolinha = 13 -- Paciente


						SELECT @ChavePaciente = @@IDENTITY
					END

			  ----------------------- MEDICO -------------------------  

					SET @ChaveMedico = 0;
					SET @ChaveSolicitante = 0;

					 --VERIFICANDO SE EXISTE MEDICO COM O MESMO CRM DE MEDICO E CHAVE DE PRESTADOR
					    SET @msg = 'Log: Verificando se Existe Medico';
						SELECT TOP 1 @ChaveMedico   = COALESCE(M.Chave ,0)
						FROM  LOGA.[dbo].[Medico] AS M
						INNER JOIN tempdb.[dbo].[TISS_Staging_ordenada] AS P
						ON M.CRM = TRIM(SUBSTRING(P.linha,117,6))
						AND M.CRMUF = TRIM(SUBSTRING(P.linha,123,2))
						WHERE M.CRM	<> ''		
          				AND	M.ChavePrestador = @ChavePrestador
						AND P.chaveimportacao = @chaveimportacao
						AND P.agg = @numconta
						AND P.tipolinha = 12 -- Cabecalho Conta	

    				   ---??? Sem NOME do MEDICO no arquivo SAS	
					   --IF @ChaveMedico = 0
					   --BEGIN
						  ----VERIFICANDO SE EXISTE MEDICO COM O MESMO CRM DE MEDICO E CHAVE DE PRESTADOR
						  --SELECT @ChaveMedico = COALESCE(M.Chave ,0)
						  --FROM  [dbo].[Medico] AS M
						  --INNER JOIN tempdb.[dbo].[TISS_Staging_ordenada] AS P
						  --ON M.Nome = 1 --@Medico
						  --WHERE	M.Nome <> 
						  --AND M.ChavePrestador = @ChavePrestador
						  --AND P.numconta = @numconta
						  --AND P.tipolinha = 1 -- Cabecalho Conta	
					   --END

					IF @ChaveMedico = 0
					BEGIN
						SET @msg = 'Log: Inserindo Novo Medico!';
						INSERT LOGA.[dbo].[Medico] (ChavePrestador,CRM,CRMUF,SYSDate)
						SELECT DISTINCT
						 @ChavePrestador
						,TRIM(SUBSTRING(P.linha,117,6))
						,TRIM(SUBSTRING(P.linha,123,2))
						,GETDATE() AS SYSDate
						FROM tempdb.[dbo].[TISS_Staging_ordenada] AS P
						WHERE P.agg = @numconta
						AND P.chaveimportacao = @chaveimportacao
						AND P.tipolinha = 12 -- Cabecalho Conta

						SELECT @ChaveMedico = @@IDENTITY
					END

			  ----------------------- CONTA ------------------------- 
				SET @ChaveConta = 0;
				SET @Lote = NULL;
				SET @Plano = NULL;
				SET @Senha = NULL;
				SET @DataEntrada = NULL;
				SET @DataSaida = NULL;
				SET @TipoAcomodacao = NULL;
				SET @TipoAtendimento = NULL;
				SET @Cid = NULL;
				SET @NumParcela = NULL;
				SET @QtdeItens = NULL;
				SET @Valor = NULL;
				SET @Numero = NULL;
				SET @ValorProcedimento = NULL;
				SET @ValorMedicamento = NULL;
				SET @ValorMaterial = NULL;
				SET @ValorTaxa = NULL;;
				SET @ValorDiaria = NULL;

				   -- Cabecalho Conta
				   SELECT TOP 1  @Lote = TRIM(SUBSTRING(P.linha,116,8))
						   ,@Plano = TRIM(SUBSTRING(P.linha,124,3))
						   ,@Senha = TRIM(SUBSTRING(P.linha,127,10))
						   ,@TipoAcomodacao = TRIM(SUBSTRING(P.linha,115,1))
						   ,@DataEntrada = TRY_CONVERT(DATETIME,TRIM(CONCAT(SUBSTRING(P.linha,25,4),SUBSTRING(P.linha,23,2),SUBSTRING(P.linha,21,2))),102)
   						   ,@DataSaida = TRY_CONVERT(DATETIME,TRIM(CONCAT(SUBSTRING(P.linha,33,4),SUBSTRING(P.linha,31,2),SUBSTRING(P.linha,29,2))),102)
						   ,@TipoAtendimento = TRIM(SUBSTRING(P.linha,114,1))
						   ,@Cid = TRIM(SUBSTRING(P.linha,37,6))  
				   FROM tempdb.[dbo].[TISS_Staging_ordenada] AS P
				   WHERE agg = @numconta
				   AND P.chaveimportacao = @chaveimportacao
				   AND P.tipolinha = 1

				   -- Total Procedimento
				   SELECT @ValorProcedimento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(P.linha,72,15)))
				   FROM tempdb.[dbo].[TISS_Staging_ordenada] AS P
				   WHERE agg = @numconta
				   AND P.chaveimportacao = @chaveimportacao
				   AND P.tipolinha = 21

				   -- Total Material
				   SELECT @ValorMaterial = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(P.linha,81,15)))
				   FROM tempdb.[dbo].[TISS_Staging_ordenada] AS P
				   WHERE agg = @numconta
				   AND P.chaveimportacao = @chaveimportacao
				   AND P.tipolinha = 23

				   -- Total Medicamento
				   SELECT @ValorMedicamento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(P.linha,81,15)))
				   FROM tempdb.[dbo].[TISS_Staging_ordenada] AS P
				   WHERE agg = @numconta
				   AND P.chaveimportacao = @chaveimportacao
				   AND P.tipolinha = 22

				   -- Total Conta
				   SELECT   @NumParcela = TRY_CONVERT(int,TRIM(SUBSTRING(P.linha,137,2)))
						   ,@QtdeItens = TRY_CONVERT(int,TRIM(SUBSTRING(P.linha,139,3)))
						   ,@Valor = TRY_CONVERT(decimal(12,2),TRIM(SUBSTRING(P.linha,47,11)))
						   ,@Numero = TRIM(SUBSTRING(P.linha,5,8))
				   FROM tempdb.[dbo].[TISS_Staging_ordenada] AS P
				   WHERE agg = @numconta
				   AND P.chaveimportacao = @chaveimportacao
				   AND P.tipolinha = 1

				   SET @msg = 'Log: Inserindo Nova Conta!';
				   INSERT LOGA.[dbo].[Conta]
					 (ChaveImportacao -- Importacao.chave
					  ,Sequencial
					  ,ChaveOperadora
					  ,ChavePrestador
					  ,ChavePaciente
					  ,ChaveMedico
					  ,ChaveMedicoSolicitante
					  ,Numero
					  ,DataRemessa
					  ,DataEntrada
					  ,DataSaida
					  ,CIDPrincipal
					  ,Valor
					  ,ValorProcedimento
					  ,ValorMedicamento
					  ,ValorMaterial
					  ,ValorTaxa
					  ,ValorDiaria
					  ,TipoAtendimento
					  ,TipoAcomodacao
					  ,Remessa
					  ,EmpresaConectividade
					  ,IdArquivo
					  ,Lote
					  ,Plano
					  ,Senha
					  ,NumParcela
					  ,QtdeItens
					  ,SYSDate)
				  SELECT
					   @ArqID
					  ,@numconta
					  ,@ChaveOperadora
					  ,@ChavePrestador
					  ,@ChavePaciente
					  ,@ChaveMedico
					  ,@ChaveSolicitante
					  ,@Numero
					  ,@DataRemessa
					  ,@DataEntrada
					  ,@DataSaida
					  ,@Cid
					  ,@Valor
					  ,@ValorProcedimento
					  ,@ValorMedicamento
					  ,@ValorMaterial
					  ,@ValorTaxa
					  ,@ValorDiaria
					  ,@TipoAtendimento
					  ,@TipoAcomodacao
					  ,@Remessa
					  ,@EmpresaConectividade
					  ,@IdArquivo
					  ,@Lote
					  ,@Plano
					  ,@Senha
					  ,@NumParcela
					  ,@QtdeItens
					  ,GETDATE()

				  --ATRIBUINDO CHAVE DA NOVA CONTA A VARIAVEL DE RETORNO
				  SELECT @ChaveConta = @@IDENTITY;


			   ----------------------- PROCEDIMENTO ------------------------- 
					DECLARE @TotalProcedimentoConta int = 0;
					DECLARE @NumeroLinhaProcedimentoConta int = 0;
					DECLARE @iLoopProcedimento int = 1;

					SELECT @TotalProcedimentoConta = COUNT(*)
					,@NumeroLinhaProcedimentoConta = MIN(numlinha)
					FROM tempdb.[dbo].[TISS_Staging_ordenada] AS P  
					WHERE P.chaveimportacao = @chaveimportacao
					AND agg = @numconta
					AND P.tipolinha = 21

					DECLARE @ChaveProcedimento INT, @CodProcedimento CHAR(10), @DescrProcedimento VARCHAR(50), @CodDWProcedimento INT;
					DECLARE @QtdeProcedimento numeric(12,2),  @VrTotalProcedimento numeric(12,2),   @PosicaoProcedimento bit,   @EmergProcedimento bit; -- @VrUnit numeric(12,2) ???
					DECLARE @DheProcedimento bit,   @NumItemProcedimento int,  @AnexoProcedimento int,   @NumItemSASProcedimento int;

					WHILE (@iLoopProcedimento <= @TotalProcedimentoConta)
					BEGIN
						SET @ChaveProcedimento = NULL;
						SET @CodProcedimento = NULL;
						SET @DescrProcedimento = NULL;
						SET @CodDWProcedimento = NULL;
						SET @QtdeProcedimento= NULL;
						SET @VrTotalProcedimento = NULL;
						SET @PosicaoProcedimento = NULL;
						SET @EmergProcedimento = NULL;
						SET @DheProcedimento = NULL;
						SET @NumItemProcedimento = NULL;
						SET @AnexoProcedimento = NULL;
						SET @NumItemSASProcedimento = NULL;

						SELECT @codProcedimento = TRIM(SUBSTRING(linha,5,8))
						,@DescrProcedimento = TRIM(SUBSTRING(linha,13,50))
						,@QtdeProcedimento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,67,5)))
						---??? ,@VrUnit = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,99,5)))
						,@VrTotalProcedimento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,72,15)))
						,@PosicaoProcedimento = TRY_CONVERT(bit,TRIM(SUBSTRING(linha,96,1)))
						,@EmergProcedimento = CASE WHEN TRIM(SUBSTRING(linha,97,1)) IN ('S','1') THEN 1 ELSE 0 END
						,@DheProcedimento = CASE WHEN TRIM(SUBSTRING(linha,98,1)) IN ('S','1') THEN 1 ELSE 0 END
						,@NumItemProcedimento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,99,3)))
						,@AnexoProcedimento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,103,2)))
						,@NumItemSASProcedimento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,108,3)))
						FROM tempdb.[dbo].[TISS_Staging_ordenada]
						WHERE agg = @numconta
						AND chaveimportacao = @chaveimportacao
						AND tipolinha = 21 -- Itens da Conta (PROCEDIMENTO)
						AND numlinha = @NumeroLinhaProcedimentoConta			
				 
	  				SELECT  @ChaveProcedimento = Chave
						FROM  LOGA.dbo.TabelaProcedimento 
						WHERE ChaveOperadora = @ChaveOperadora
						   AND ChavePrestador = @ChavePrestador
						   AND (Codigo = IIF(@CodProcedimento ='0000000000',NULL,@CodProcedimento)  OR Descricao = @DescrProcedimento)

						IF @ChaveProcedimento IS NULL
							BEGIN
								--INSERIR NA TABELA
								SET @msg = 'Log: Inserindo na Tabela Procedimento!';
								INSERT INTO LOGA.dbo.TabelaProcedimento 
								(
								 ChaveOperadora 
								,ChavePrestador 
								,Codigo
								,Descricao 
								,CodigoProcedimentoDW	
								,SYSDate
								)
								VALUES 
								(
								 @ChaveOperadora
								,@ChavePrestador 
								,COALESCE(@CodProcedimento,'0000000000')
								,@DescrProcedimento
								,NULL 
								,GETDATE()
								)
					
								--OBTER CHAVE NOVA
								SELECT @ChaveProcedimento = @@IDENTITY
							END

								-- INSERIR NA CONTA   
								SET @msg = 'Log: Inserindo Conta Procedimento!';
								INSERT INTO LOGA.dbo.ContaProcedimento
								(
									 ChaveConta
									,ChaveTabelaProcedimento
									,ContaQuantidade
									-- ,ContaValorUnitario ???
									,ContaValorTotal
									,Principal
									,Emergencia
									,DHE
									,NumItem
									,Anexo
									,NumItemSAS
									,DataEntrada
									,DataSaida
									,SYSDate
									) 
								VALUES
								(
									 @ChaveConta
									,@ChaveProcedimento
									,@QtdeProcedimento
									 --,@VrUnit ???
									,@VrTotalProcedimento
									,@PosicaoProcedimento
									,@EmergProcedimento
									,@DheProcedimento
									,@NumItemProcedimento
									,@AnexoProcedimento
									,@NumItemSASProcedimento
									,NULL    -- ??? @DataEntrada
									,NULL	 -- ??? @DataSaida
									,GETDATE()
									)					
						SET @NumeroLinhaProcedimentoConta += 1
						SET @iLoopProcedimento += 1
					END -- FIM DO LOOP PROCEDIMENTO

	
				  ----------------------- MEDICAMENTO ------------------------- 
				   DECLARE @TotalMedicamentoConta smallint = 0;
				   DECLARE @NumeroLinhaMedicamentoConta int = 0;
				   DECLARE @iLoopMedicamento int = 1;

					SELECT @TotalMedicamentoConta = COUNT(*)
					,@NumeroLinhaMedicamentoConta = MIN(numlinha)
					FROM tempdb.[dbo].[TISS_Staging_ordenada] AS P  
					WHERE P.chaveimportacao = @chaveimportacao
					AND agg = @numconta
					AND P.tipolinha = 22 -- MEDICAMENTO

						DECLARE @ChaveMedicamento INT = NULL, @CodMedicamento CHAR(10) = NULL, @DescrMedicamento VARCHAR(50) = NULL, @CodDWMedicamento INT = NULL;
						DECLARE @QtdeMedicamento numeric(12,2),  @VrTotalMedicamento numeric(12,2), @EmergMedicamento bit, @PosicaoMedicamento int;
						DECLARE @UnidadeMedicamento varchar(3), @DheMedicamento bit,   @NumItemMedicamento int,  @AnexoMedicamento int,   @NumItemSASMedicamento int;

					WHILE (@iLoopMedicamento <= @TotalMedicamentoConta)
					BEGIN
						SET @ChaveMedicamento = NULL;
						SET @CodMedicamento = NULL;
						SET @DescrMedicamento = NULL;
						SET @CodDWMedicamento = NULL;
						SET @QtdeMedicamento= NULL;
						SET @VrTotalMedicamento = NULL;
						SET @EmergMedicamento = NULL;
						SET @PosicaoMedicamento = NULL;
						SET @UnidadeMedicamento = NULL;
						SET @DheMedicamento = NULL;
						SET @NumItemMedicamento = NULL;
						SET @AnexoMedicamento = NULL;
						SET @NumItemSASMedicamento = NULL;

						SELECT @CodMedicamento  = dbo.PADLEFT(TRIM(SUBSTRING(linha,3,10)),10)
						,@DescrMedicamento = TRIM(SUBSTRING(linha,13,50))
						,@QtdeMedicamento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,67,7)))
						,@UnidadeMedicamento = TRIM(SUBSTRING(linha,105,3))
						,@VrTotalMedicamento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,81,15)))
						--,@PosicaoMedicamento = TRY_CONVERT(bit,TRIM(SUBSTRING(linha,98,1)))
						--,@EmergMedicamento = TRY_CONVERT(bit,TRIM(SUBSTRING(linha,90,1)))
						--,@DheMedicamento = TRY_CONVERT(bit,TRIM(SUBSTRING(linha,91,1)))
						,@NumItemMedicamento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,99,3)))
						,@AnexoMedicamento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,103,2)))
						,@NumItemSASMedicamento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,108,3)))
						FROM tempdb.[dbo].[TISS_Staging_ordenada]
						WHERE chaveimportacao = @chaveimportacao
						AND agg = @numconta
						AND tipolinha = 22 -- MEDICAMENTO
						AND numlinha = @NumeroLinhaMedicamentoConta	

						SELECT @ChaveMedicamento = Chave
						FROM   LOGA.dbo.TabelaMedicamento
						WHERE
						ChaveOperadora = @ChaveOperadora
						AND ChavePrestador = @ChavePrestador
						AND Codigo = @CodMedicamento	
						AND Descricao = @DescrMedicamento

						IF @ChaveMedicamento IS NULL
						BEGIN
							IF @CodMedicamento IS NULL SET @CodMedicamento = '0000000000'

							 --INSERIR NA TABELA MEDICAMENTO
							 SET @msg = 'Log: Inserindo na Tabela Medicamento!';
							 INSERT INTO LOGA.dbo.TabelaMedicamento
							   (ChaveOperadora 
								,ChavePrestador
								,Codigo
								,Descricao
								,CodigoMedicamentoDW
								,SYSDate)
							 VALUES 
							   (@ChaveOperadora
								,@ChavePrestador
								,COALESCE(@CodMedicamento,'0000000000')
								,@DescrMedicamento
								,NULL	 
								,GETDATE())
							 --OBTER CHAVE (NOVA)
							 SELECT @ChaveMedicamento = @@IDENTITY
						END
						ELSE
						BEGIN
								--atualizando o codigo ja existente
								SET @msg = 'Log: Atualizando Codigo na Tabela Medicamento!';
								Update LOGA.dbo.TabelaMedicamento Set Codigo = @CodMedicamento
								Where Chave = @ChaveMedicamento AND Codigo <> @CodMedicamento
						END

						-- SET @dataRealizacao = RIGHT(@dataRealizacao,4) + SUBSTRING(@dataRealizacao,3,2) + LEFT(@dataRealizacao,2) ???

							--INSERIR NA CONTA MEDICAMENTO  
							SET @msg = 'Log: Inserindo Conta Medicamento!';
							INSERT INTO LOGA.dbo.ContaMedicamento
							(ChaveConta
							,ChaveTabelaMedicamento
							,ContaQuantidade
							--,ContaValorUnitario ???
							,ContaValorTotal
							,NumItem
							,Posicao
							,Anexo
							,Unidade
							,NumItemSAS
							,SYSDate
							--,ChaveItemTISS ??
							-- ,tipoTabela ??
							-- ,dataRealizacao ??
							,horaInicial 
							,horaFinal 
							,unidadeMedida 
							--,registroAnvisa  ??
							--,codigoRefFabricante  ?? 
							--,autorizacaoFuncionamento  ?? 
							--,tipoGuia  ??
							--,tipoDespesa  ??
							) 
							VALUES
							(
							 @ChaveConta
							,@ChaveMedicamento
							,@QtdeMedicamento
	    					,@VrTotalMedicamento
							,@NumItemMedicamento
							,@PosicaoMedicamento
							,@AnexoMedicamento
							,@UnidadeMedicamento
							,@NumItemSASMedicamento
							,GETDATE()
							--,@ChaveItemTISSMedicamento ??
							--,@tipoTabela ??
							--,@dataRealizacao ??
							,NULL
							,NULL
							,@unidadeMedicamento
							--,@registroAnvisa ?? 
							--,@codigoRefFabricante ?? 
							--,@autorizacaoFuncionamento ?? 
							--,@tipoGuia ??
							--,@tipoDespesa ??
						)

						SET @NumeroLinhaMedicamentoConta += 1	
						SET @iLoopMedicamento += 1
					END -- FIM DO LOOP MEDICAMENTO


				  --------------------- MATERIAL ------------------------- 
				   DECLARE @TotalMaterialConta smallint = 0;
				   DECLARE @NumeroLinhaMaterialConta int = 0;
				   DECLARE @iLoopMaterial int = 1;

					SELECT @TotalMaterialConta = COUNT(*)
					,@NumeroLinhaMaterialConta = MIN(numlinha)
					FROM tempdb.[dbo].[TISS_Staging_ordenada] AS P  
					WHERE P.chaveimportacao = @chaveimportacao
					AND agg = @numconta
					AND P.tipolinha = 23 -- MATERIAL

					DECLARE @ChaveMaterial INT, @CodMaterial CHAR(10), @DescrMaterial VARCHAR(50), @CodDWMaterial INT;
					DECLARE @QtdeMaterial numeric(12,2),  @VrTotalMaterial numeric(12,2), @EmergMaterial bit, @PosicaoMaterial int;
					DECLARE @UnidadeMaterial varchar(3), @DheMaterial bit,   @NumItemMaterial int,  @AnexoMaterial int,   @NumItemSASMaterial int;

					WHILE (@iLoopMaterial <= @TotalMaterialConta)
					BEGIN
						SET @ChaveMaterial = NULL;
						SET @CodMaterial = NULL;
						SET @DescrMaterial = NULL;
						SET @CodDWMaterial = NULL;
						SET @QtdeMaterial= NULL;
						SET @VrTotalMaterial = NULL;
						SET @EmergMaterial = NULL;
						SET @PosicaoMaterial = NULL;
						SET @UnidadeMaterial = NULL;
						SET @DheMaterial = NULL;
						SET @NumItemMaterial = NULL;
						SET @AnexoMaterial = NULL;
						SET @NumItemSASMaterial = NULL;

						SELECT @CodMaterial  = dbo.PADLEFT(TRIM(SUBSTRING(linha,3,10)),10)
						,@DescrMaterial = TRIM(SUBSTRING(linha,13,50))
						,@QtdeMaterial = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,67,7)))
						,@UnidadeMaterial = TRIM(SUBSTRING(linha,105,3))
						,@VrTotalMaterial = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,81,15)))
						,@PosicaoMaterial = TRY_CONVERT(bit,TRIM(SUBSTRING(linha,98,1)))
						,@EmergMaterial = TRY_CONVERT(bit,TRIM(SUBSTRING(linha,90,1)))
						,@DheMaterial = TRY_CONVERT(bit,TRIM(SUBSTRING(linha,91,1)))
						,@NumItemMaterial = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,99,3)))
						,@AnexoMaterial = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,103,2)))
						,@NumItemSASMaterial = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,108,3)))
						FROM tempdb.[dbo].[TISS_Staging_ordenada]
						WHERE chaveimportacao = @chaveimportacao
						AND agg = @numconta
						AND tipolinha = 23 -- MATERIAL
						AND numlinha = @NumeroLinhaMaterialConta	

						SELECT @ChaveMaterial = Chave
						FROM  LOGA.dbo.TabelaMedicamento
						WHERE
						ChaveOperadora = @ChaveOperadora
						AND ChavePrestador = @ChavePrestador
						AND (Codigo = IIF(@CodMaterial='0000000000','',@CodMaterial))  
						AND Descricao = @DescrMaterial

						 IF @ChaveMaterial IS NULL
						  BEGIN
								--INSERIR NA TABELA MATERIAL
								SET @msg = 'Log: Inserindo na Tabela Material!';	
								INSERT INTO LOGA.dbo.TabelaMaterial
								(	ChaveOperadora 
								,ChavePrestador
								,Codigo 
								,Descricao
								,CodigoMaterialDW 
								,SYSDate)
								VALUES 
								(	@ChaveOperadora
								,@ChavePrestador
								,COALESCE(@CodMaterial,'0000000000')
								,@DescrMaterial
								,NULL	
								,GETDATE())
								--OBTER CHAVE (NOVA)
								SELECT @ChaveMaterial = @@IDENTITY 
						  END
						  ELSE
							BEGIN
								--atualizando o codigo ja existente
								SET @msg = 'Log: Atualizando Codigo na Tabela Material!';
								Update LOGA.dbo.TabelaMaterial Set Codigo = @CodMaterial Where Chave = @ChaveMaterial AND Codigo <> @CodMaterial	
							END

							--  SET @dataRealizacao = RIGHT(@dataRealizacao,4) + SUBSTRING(@dataRealizacao,3,2) + LEFT(@dataRealizacao,2) ???

							--INSERIR NA CONTA MATERIAL
							SET @msg = 'Log: Inserindo Conta Material!';
							INSERT INTO LOGA.dbo.ContaMaterial
							(ChaveConta
							,ChaveTabelaMaterial
							,ContaQuantidade
							--,ContaValorUnitario ??
							,ContaValorTotal
							,NumItem
							,Posicao
							,Anexo
							,Unidade
							,NumItemSAS
							,SYSDate
							--,ChaveItemTISS ??
							--,tipoTabela ?? 
							--,dataRealizacao ??
							,horaInicial 
							,horaFinal 
							,unidadeMedida 
							--,registroAnvisa ?? 
							--,codigoRefFabricante ?? 
							--,autorizacaoFuncionamento ?? 
							--,tipoGuia ??
							--,tipoDespesa ??
							) 
							VALUES
							(@ChaveConta
							,@ChaveMaterial
							,@QtdeMaterial
							--,@VrUnit
							,@VrTotalMaterial
							,@NumItemMaterial
							,@PosicaoMaterial
							,@AnexoMaterial
							,@UnidadeMaterial
							,@NumItemSASMaterial
							,GETDATE()
							--,@ChaveItemTISS
							--,@tipoTabela 
							--,@dataRealizacao 
							,NULL --@horaInicial 
							,NULL --@horaFinal 
							,@UnidadeMaterial 
							--,@registroAnvisa 
							--,@codigoRefFabricante 
							--,@autorizacaoFuncionamento 
							--,@tipoGuia
							--,@tipoDespesa
							)

						SET @NumeroLinhaMaterialConta += 1
						SET @iLoopMaterial += 1	
					END -- FIM DO LOOP MATERIAL

				  --------------------- TAXA ------------------------- 
				   DECLARE @TotalTaxaConta smallint = 0;
				   DECLARE @NumeroLinhaTaxaConta int = 0;
				   DECLARE @iLoopTaxa int = 1;

					SELECT @TotalTaxaConta = COUNT(*)
					,@NumeroLinhaTaxaConta = MIN(numlinha)
					FROM tempdb.[dbo].[TISS_Staging_ordenada] AS P  
					WHERE P.chaveimportacao = @chaveimportacao
					AND P.agg = @numconta
					AND P.tipolinha = 24 -- TAXA

					DECLARE @ChaveTaxa INT, @CodTaxa VARCHAR(10), @DescrTaxa VARCHAR(50), @CodDWTaxa  VARCHAR(10);
					DECLARE @QtdeTaxa numeric(12,2),  @VrUnitarioTaxa numeric(12,2), @VrTotalTaxa numeric(12,2); 

					WHILE (@iLoopTaxa <= @TotalTaxaConta)
					BEGIN
						SET @ChaveTaxa = NULL;
						SET @CodTaxa = NULL;
						SET @CodDWTaxa = NULL;
						SET @DescrTaxa = NULL;
						SET @QtdeTaxa = NULL;
						SET @VrUnitarioTaxa = NULL;
						SET @VrTotalTaxa = NULL;

						SELECT @CodTaxa  = dbo.PADLEFT(TRIM(SUBSTRING(linha,3,10)),10)
						,@DescrTaxa = TRIM(SUBSTRING(linha,13,50))
						,@QtdeTaxa = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,63,11)))/100
						,@VrUnitarioTaxa = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,74,11)))/100
						,@VrTotalTaxa = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,85,11)))/100
						FROM tempdb.[dbo].[TISS_Staging_ordenada]
						WHERE chaveimportacao = @chaveimportacao
						AND agg = @numconta
						AND numlinha = @NumeroLinhaTaxaConta
						AND tipolinha = 24 -- TAXA

						SELECT TOP 1 @ChaveTaxa = Chave
						FROM  LOGA.dbo.TabelaTaxa
						WHERE
						ChaveOperadora = @ChaveOperadora 
						AND	ChavePrestador = @ChavePrestador 
						AND Codigo = @CodTaxa
			
						IF @ChaveTaxa IS NULL
						BEGIN
								SET @msg = 'Log: Inserindo na Tabela Taxa!';
								INSERT LOGA.dbo.TabelaTaxa
							   (
								 ChaveOperadora 
								,ChavePrestador
								,Codigo
								,Descricao
								,CodigoTaxaDW 
								,SYSDate
								)
								VALUES 
							   (
								 @ChaveOperadora 
								,@ChavePrestador
								,COALESCE(@CodTaxa,'0000000000')
								,@DescrTaxa
								,NULL
								,GETDATE()
								)
								 --OBTER CHAVE (NOVA)
								SELECT @ChaveTaxa = @@IDENTITY 
						END
								--INSERIR NA CONTA TAXA     
								SET @msg = 'Log: Inserindo Conta Taxa!';	
								INSERT INTO LOGA.dbo.ContaTaxa
								(
								 ChaveConta
								,ChaveTabelaTaxa
								,ContaQuantidade
								,ContaValorUnitario
								,ContaValorTotal
								,SYSDate
								) 
								VALUES
								(
								 @ChaveConta
								,@ChaveTaxa
								,@QtdeTaxa
								,@VrUnitarioTaxa
								,@VrTotalTaxa
								,GETDATE()
								)
						SET @NumeroLinhaTaxaConta += 1
						SET @iLoopTaxa +=1;
					END -- FIM DO LOOP TAXA


				  --------------------- DIARIA ------------------------- 
				   DECLARE @TotalDiariaConta smallint = 0;
				   DECLARE @NumeroLinhaDiariaConta int = 0;
				   DECLARE @iLoopDiaria int = 1;

					SELECT @TotalDiariaConta = COUNT(*)
					,@NumeroLinhaDiariaConta = MIN(numlinha)
					FROM tempdb.[dbo].[TISS_Staging_ordenada] AS P  
					WHERE chaveimportacao = @chaveimportacao
					AND P.agg = @numconta
					AND P.tipolinha = 25 -- DIARIA

					DECLARE @ChaveDiaria INT, @CodDiaria CHAR(10), @DescrDiaria VARCHAR(50), @CodDWDiaria  VARCHAR(10);
					DECLARE @QtdeDiaria numeric(12,2),  @VrUnitarioDiaria numeric(12,2), @VrTotalDiaria numeric(12,2); 

					WHILE (@iLoopDiaria <= @TotalDiariaConta)
					BEGIN
						SET @ChaveDiaria = NULL;
						SET @CodDiaria = NULL;
						SET @CodDWDiaria = NULL;
						SET @DescrDiaria = NULL;
						SET @QtdeDiaria = NULL;
						SET @VrUnitarioDiaria = NULL;
						SET @VrTotalDiaria = NULL;

						SELECT @CodDiaria  = dbo.PADLEFT(TRIM(SUBSTRING(linha,3,10)),10)
						,@DescrDiaria = TRIM(SUBSTRING(linha,13,50))
						,@QtdeDiaria = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,63,11)))/100
						,@VrUnitarioDiaria = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,74,11)))/100
						,@VrTotalDiaria = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,85,11)))/100
						FROM tempdb.[dbo].[TISS_Staging_ordenada]
						WHERE chaveimportacao = @chaveimportacao
						AND agg = @numconta
						AND tipolinha = 25 -- DIARIA
						AND numlinha = @NumeroLinhaDiariaConta

						SELECT TOP 1 @ChaveDiaria = Chave
						FROM  LOGA.dbo.TabelaDiaria
						WHERE
						ChaveOperadora = @ChaveOperadora AND
						ChavePrestador = @ChavePrestador  AND
						Codigo = @CodDiaria

						IF @ChaveDiaria IS NULL
						BEGIN
							    SET @msg = 'Log: Inserindo na Tabela Diaria!';
								INSERT LOGA.dbo.TabelaDiaria
							   (
								 ChaveOperadora 
								,ChavePrestador
								,Codigo
								,Descricao
								,CodigoDiariaDW 
								,SYSDate
								)
								VALUES 
							   (
								 @ChaveOperadora 
								,@ChavePrestador
								,COALESCE(@CodDiaria,'0000000000')
								,@DescrDiaria
								,NULL
								,GETDATE()
								)
								 --OBTER CHAVE (NOVA)
								SELECT @ChaveDiaria = @@IDENTITY 
						  END
								--INSERIR NA CONTA TAXA   
								SET @msg = 'Log: Inserindo Conta Diaria!';
								INSERT LOGA.dbo.ContaDiaria
								(
								 ChaveConta
								,ChaveTabelaDiaria
								,ContaQuantidade
								,ContaValorUnitario
								,ContaValorTotal
								,SYSDate
								) 
								VALUES
								(
								 @ChaveConta
								,@ChaveDiaria
								,@QtdeDiaria
								,@VrUnitarioDiaria
								,@VrTotalDiaria
								,GETDATE()
								)
						SET @NumeroLinhaDiariaConta += 1
						SET @iLoopDiaria +=1;
					END -- FIM DO LOOP DIARIA

				   SET @numconta += 1; -- INCREMENTA VARIAVEL CONDICAO DE SAIDA DO LOOP!
				END -- FECHA TODOS OS LOOPS / WHILE MAIS EXTERNO

				----------------------- INFO ARQUIVO SAS ------------------------- 
				DECLARE @NomeOriginalArquivo varchar(20), @CodigoLogGestao int , @IdArquivoSAS int

				SELECT
				 @NomeOriginalArquivo = TRIM(SUBSTRING(linha,3,8))
				,@CodigoLogGestao = TRY_CONVERT(INT,TRIM(SUBSTRING(linha,11,10)))
				,@IdArquivoSAS = TRY_CONVERT(INT,TRIM(SUBSTRING(linha,24,10)))
				FROM tempdb.[dbo].[TISS_Staging_ordenada]
				WHERE chaveimportacao = @chaveimportacao
				AND tipolinha = 9 -- TRAILLER

				UPDATE LOGA.dbo.[Importacao]
				SET
					[NomeOriginalArquivo] = @NomeOriginalArquivo
				   ,[CodigoLogGestao] = @CodigoLogGestao
				   ,[IdArquivoSAS] = @IdArquivoSAS
				   ,[flag_importado] = 1
				   ,[mensagem] = 'Log: Arquivo TISS para LOGA Importado com Sucesso!'
				WHERE
				[Chave] = @ArqID

				UPDATE TISS.dbo.mensagemTISS
				SET
					flag_movido_loga = 1
				WHERE
				[Chave] = @chaveimportacao

				 IF @@TRANCOUNT > 0 COMMIT TRANSACTION EXPORTATISS;
			END TRY
			BEGIN CATCH
			
			   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION EXPORTATISS;

				UPDATE LOGA.dbo.[Importacao]
				SET
					[NomeOriginalArquivo] = @NomeOriginalArquivo
				   ,[CodigoLogGestao] = @CodigoLogGestao
				   ,[IdArquivoSAS] = @IdArquivoSAS
				   ,[flag_importado] = 0
				   ,[mensagem] = @msg
				WHERE
				[Chave] = @ArqID

				UPDATE TISS.dbo.mensagemTISS
				SET
					flag_movido_loga = 0
				WHERE
				[Chave] = @chaveimportacao
			END CATCH
		
IF OBJECT_ID('tempdb.dbo.TISS_Staging') IS NOT NULL
TRUNCATE TABLE [tempdb].[dbo].[TISS_Staging]

IF OBJECT_ID('tempdb.dbo.TISS_Staging_ordenada') IS NOT NULL
TRUNCATE TABLE [tempdb].[dbo].[TISS_Staging_ordenada]


SET NOCOUNT OFF;