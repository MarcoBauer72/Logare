USE [Loga]
GO
/****** Object:  StoredProcedure [dbo].[lsp_Importar_SAS]    Script Date: 10/20/2018 8:47:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[lsp_Importar_SAS]
(@qtdcontas AS INT,@ArqID AS INT)
AS
BEGIN

SET NOCOUNT ON;

DECLARE @ChaveOperadora int = 0;
DECLARE @ChavePrestador int = 0;

DECLARE @msg VARCHAR(200) = '';

IF @qtdcontas > 0 
BEGIN TRY
  BEGIN TRAN
  ------------------------- OPERADORA -------------------------
			--VERIFICANDO SE EXISTE A OPERADORA
			SET @msg = 'Buscando Operadora!'

			SELECT @ChaveOperadora = COALESCE(OP.Chave,0)
			FROM [dbo].[Operadora] AS OP
			INNER JOIN tempdb.[dbo].[PreImportaSAS] AS P
			ON  OP.Codigo = '9000000001'
			AND P.tipolinha = 0 -- Header Arquivo

			-- SE NÃO EXISTIR OPERADORA ENTAO INSERE
			IF @ChaveOperadora = 0
			BEGIN
				SET @msg = 'Inserindo Operadora!'

				INSERT [dbo].[Operadora] 
				(Codigo,Nome,SYSDate)
				SELECT
					 '9000000001' -- SulAmerica
					,TRIM(SUBSTRING(linha,34,22))
					,GETDATE()
				FROM tempdb.[dbo].[PreImportaSAS] AS P
				WHERE P.tipolinha = 0 -- Header Arquivo

				SELECT @ChaveOperadora = @@IDENTITY
			END

   ------------------------- PRESTADOR ------------------------- 

		-- VERIFICA SE EXISTE PRESTADOR COM O MESMO CODIGO DE PRESTADOR E CHAVE DE OPERADORA
		SET @msg = 'Buscando Prestador por Codigo!'
		
		SELECT @ChavePrestador = COALESCE(PR.Chave,0)
		FROM [dbo].[Prestador] AS  PR
		INNER JOIN tempdb.[dbo].[PreImportaSAS] AS P
		ON  PR.Codigo = CONCAT(REPLICATE('0',10-LEN(SUBSTRING(P.linha,6,5))),SUBSTRING(P.linha,6,5))
		WHERE PR.Codigo <> '0000000000' 
 	    AND PR.Codigo not like 'PJ%'
        AND PR.Codigo not like 'F%'
        AND ChaveOperadora = @ChaveOperadora
		AND P.tipolinha = 0  -- Header Arquivo
		
		--DEBUG CNPJ:
		--SELECT TRIM(SUBSTRING(linha,65,14)) FROM tempdb.[dbo].[PreImportaSAS] WHERE tipolinha = 0 

	   --SE NÃO EXISTIR PRESTADOR PROCURA POR CNPJ
	   IF @ChavePrestador = 0
	    BEGIN
		  SET @msg = 'Buscando Prestador por CNPJ!'

		  --VERIFICANDO SE EXISTE PRESTADOR COM O MESMO CNPJ E CHAVE DE OPERADORA
		  SELECT @ChavePrestador = Chave 
		  FROM   [dbo].[Prestador] AS PR
		  INNER JOIN tempdb.[dbo].[PreImportaSAS] AS P
		  ON PR.CNPJ = TRIM(SUBSTRING(P.linha,65,14))	
		  WHERE PR.CNPJ <> '00000000000000' 
		  AND TRIM(PR.CNPJ) <> ''  
		  AND PR.ChaveOperadora = @ChaveOperadora
		  AND P.tipolinha = 0 -- Header Arquivo
		END
  	   --DEBUG CPF:
	   --SELECT TRIM(SUBSTRING(linha,65,11)) FROM tempdb.[dbo].[PreImportaSAS] WHERE tipolinha = 0 

	   --SE NÃO EXISTIR PRESTADOR PROCURA POR CPF
	   IF @ChavePrestador = 0
		BEGIN
		  SET @msg = 'Buscando Prestador por CPF!'

		  --VERIFICANDO SE EXISTE PRESTADOR COM O MESMO CPF E CHAVE DE OPERADORA
		  SELECT @ChavePrestador = Chave 
		  FROM  [dbo].[Prestador] AS PR
		  INNER JOIN tempdb.[dbo].[PreImportaSAS] AS P
		  ON  PR.CPF = TRIM(SUBSTRING(P.linha,65,11))
		  WHERE PR.CPF <> '00000000000' 
		  AND TRIM(PR.CPF) <> ''  
		  AND PR.ChaveOperadora = @ChaveOperadora
		  AND P.tipolinha = 0 -- Header Arquivo
		END

	   --SE NÃO EXISTIR PRESTADOR PROCURA PELO NOME
	   IF @ChavePrestador IS NULL
		BEGIN
		  SET @msg = 'Buscando Prestador por Nome!'

		  --VERIFICANDO SE EXISTE PRESTADOR COM O MESMO NOME E CHAVE DE OPERADORA
		  SELECT @ChavePrestador = Chave 
		  FROM  [dbo].[Prestador] AS PR
		  INNER JOIN tempdb.[dbo].[PreImportaSAS] AS P
		  ON  Nome = TRIM(SUBSTRING(P.linha,79,40))
		  WHERE TRIM(Nome) <> ''  
		  AND ChaveOperadora = @ChaveOperadora
		  AND P.tipolinha = 0 -- Header Arquivo
		END

	-- SE NÃO EXISTIR PRESTADOR ENTAO INSERE NOVO PRESTADOR DESASSOCIADO
		IF @ChavePrestador = 0
		  BEGIN
		    SET @msg = 'Inserindo Prestador!'
			
			INSERT [dbo].[Prestador] (ChaveOperadora,Codigo,Nome,CPF,CNPJ,CEP,SYSDate)
			SELECT
			 @ChaveOperadora 
			,CONCAT(REPLICATE('0',10-LEN(SUBSTRING(P.linha,6,5))),SUBSTRING(P.linha,6,5)) AS CODIGO
			,TRIM(SUBSTRING(P.linha,79,40)) AS Nome
			,TRIM(SUBSTRING(P.linha,65,11)) AS CPF
			,TRIM(SUBSTRING(P.linha,65,14)) AS CNPJ
			,TRIM(SUBSTRING(P.linha,56,8)) AS CEP
    		,GETDATE()
			FROM tempdb.[dbo].[PreImportaSAS] AS P
			WHERE P.tipolinha = 0  -- Header Arquivo

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
   SELECT   @DataRemessa = TRY_CONVERT(DATETIME,DATEFROMPARTS('20' + SUBSTRING(P.linha,123,2),SUBSTRING(P.linha,121,2),SUBSTRING(P.linha,119,2)),112)
		   ,@Remessa = TRIM(SUBSTRING(P.linha,125,4))
		   ,@EmpresaConectividade = TRIM(SUBSTRING(P.linha,1,4))
		  , @IdArquivo = TRIM(SUBSTRING(P.linha,131,9))
   FROM tempdb.[dbo].[PreImportaSAS] AS P
   WHERE P.tipolinha = 0

   DECLARE @numconta tinyint = 1;

   -- RECURSIVIDADE PARA ITENS DA MESMA CONTA
   WHILE (@numconta <= @qtdcontas)
	 BEGIN

	  ----------------------- PACIENTE ------------------------- 
		SET @ChavePaciente = 0
	    -- VERIFICANDO SE EXISTE PACIENTE COM O MESMO CODIGO DE PACIENTE E CHAVE DE OPERADORA
	 		SELECT @ChavePaciente = COALESCE(PC.Chave,0)
	 		FROM [dbo].[Paciente] AS  PC
	 		INNER JOIN tempdb.[dbo].[PreImportaSAS] AS P
	 		ON  PC.Codigo = TRIM(CONCAT(REPLICATE('0',30-LEN(SUBSTRING(P.linha,32,17))),SUBSTRING(P.linha,32,17)))
			WHERE PC.ChaveOperadora = @ChaveOperadora
			AND P.numconta = @numconta 
			AND P.tipolinha = 1 -- Cabecalho Conta
					
		IF @ChavePaciente = 0
		BEGIN
			INSERT [dbo].[Paciente] (ChaveOperadora,Codigo,DataNascimento,Sexo,SYSDate)
			SELECT
			 @ChaveOperadora 
			,TRIM(CONCAT(REPLICATE('0',30-LEN(SUBSTRING(P.linha,32,17))),SUBSTRING(P.linha,32,17))) AS Codigo
			,TRY_CONVERT(DATETIME,CONCAT(SUBSTRING(P.linha,121,4),SUBSTRING(P.linha,119,2),SUBSTRING(P.linha,117,2)),112) AS DataNascimento
			,TRIM(SUBSTRING(P.linha,116,1)) AS Sexo
			,GETDATE() AS SYSDate
			FROM tempdb.[dbo].[PreImportaSAS] AS P
			WHERE P.tipolinha = 1 -- Cabecalho Conta
			AND P.numconta = @numconta

			SELECT @ChavePaciente = @@IDENTITY
		END
  
  ----------------------- MEDICO -------------------------  

		SET @ChaveMedico = 0;
		SET @ChaveSolicitante = 0;

		 --VERIFICANDO SE EXISTE MEDICO COM O MESMO CRM DE MEDICO E CHAVE DE PRESTADOR
			SELECT @ChaveMedico   = COALESCE(M.Chave ,0)
			FROM  [dbo].[Medico] AS M
			INNER JOIN tempdb.[dbo].[PreImportaSAS] AS P
			ON M.CRM = TRIM(SUBSTRING(P.linha,108,6))
			AND M.CRMUF = TRIM(SUBSTRING(P.linha,114,2))
			WHERE M.CRM	<> ''		
          	AND	M.ChavePrestador = @ChavePrestador
			AND P.numconta = @numconta
			AND P.tipolinha = 1 -- Cabecalho Conta	
			
    	   ---??? Sem NOME do MEDICO no arquivo SAS	
		   --IF @ChaveMedico = 0
		   --BEGIN
			  ----VERIFICANDO SE EXISTE MEDICO COM O MESMO CRM DE MEDICO E CHAVE DE PRESTADOR
			  --SELECT @ChaveMedico = COALESCE(M.Chave ,0)
			  --FROM  [dbo].[Medico] AS M
			  --INNER JOIN tempdb.[dbo].[PreImportaSAS] AS P
			  --ON M.Nome = 1 --@Medico
			  --WHERE	M.Nome <> 
			  --AND M.ChavePrestador = @ChavePrestador
			  --AND P.numconta = @numconta
			  --AND P.tipolinha = 1 -- Cabecalho Conta	
		   --END

		IF @ChaveMedico = 0
		BEGIN
			INSERT [dbo].[Medico] (ChavePrestador,CRM,CRMUF,SYSDate)
			SELECT
			 @ChavePrestador
			,TRIM(SUBSTRING(P.linha,108,6))
			,TRIM(SUBSTRING(P.linha,114,2))
			,GETDATE() AS SYSDate
			FROM tempdb.[dbo].[PreImportaSAS] AS P
			WHERE P.numconta = @numconta
			AND P.tipolinha = 1 -- Cabecalho Conta

			SELECT @ChaveMedico = @@IDENTITY
		END

		---??? Sem CRM de SOLICITANTE no arquivo SAS	

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
	   SELECT   @Lote = TRIM(SUBSTRING(P.linha,11,8))
			   ,@Plano = TRIM(SUBSTRING(P.linha,29,3))
			   ,@Senha = TRIM(SUBSTRING(P.linha,50,10))
			   ,@TipoAcomodacao = TRIM(SUBSTRING(P.linha,60,1))
			   ,@DataEntrada = TRIM(SUBSTRING(P.linha,61,6))
   			   ,@DataSaida = TRIM(SUBSTRING(P.linha,71,6))
			   ,@TipoAtendimento = TRIM(SUBSTRING(P.linha,93,1))
			   ,@Cid = TRIM(SUBSTRING(P.linha,94,6))  
	   FROM tempdb.[dbo].[PreImportaSAS] AS P
	   WHERE numconta = @numconta
	   AND P.tipolinha = 1

	   -- Total Procedimento
	   SELECT @ValorProcedimento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(P.linha,104,15)))
	   FROM tempdb.[dbo].[PreImportaSAS] AS P
	   WHERE numconta = @numconta
	   AND P.tipolinha = 2

	   -- Total Material
	   SELECT @ValorMaterial = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(P.linha,109,15)))
	   FROM tempdb.[dbo].[PreImportaSAS] AS P
	   WHERE numconta = @numconta
	   AND P.tipolinha = 5

	   -- Total Medicamento
	   SELECT @ValorMedicamento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(P.linha,109,15)))
	   FROM tempdb.[dbo].[PreImportaSAS] AS P
	   WHERE numconta = @numconta
	   AND P.tipolinha = 6

	   -- Total Conta
	   SELECT   @NumParcela = TRY_CONVERT(int,TRIM(SUBSTRING(P.linha,27,2)))
			   ,@QtdeItens = TRY_CONVERT(int,TRIM(SUBSTRING(P.linha,29,3)))
			   ,@Valor = TRY_CONVERT(decimal(12,2),TRIM(SUBSTRING(P.linha,32,15)))
			   ,@Numero = TRIM(SUBSTRING(P.linha,19,8))
	   FROM tempdb.[dbo].[PreImportaSAS] AS P
	   WHERE numconta = @numconta
	   AND P.tipolinha = 3

	   INSERT [dbo].[Conta]
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
		FROM tempdb.[dbo].[PreImportaSAS] AS P  
		WHERE numconta = @numconta
		AND P.tipolinha = 2

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

			SELECT @codProcedimento = TRIM(SUBSTRING(linha,32,8))
			,@DescrProcedimento = TRIM(SUBSTRING(linha,40,50))
			,@QtdeProcedimento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,99,5)))
			---??? ,@VrUnit = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,99,5)))
			,@VrTotalProcedimento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,104,15)))
			,@PosicaoProcedimento = TRY_CONVERT(bit,TRIM(SUBSTRING(linha,98,1)))
			,@EmergProcedimento = CASE WHEN TRIM(SUBSTRING(linha,90,1)) IN ('S','1') THEN 1 ELSE 0 END
			,@DheProcedimento = CASE WHEN TRIM(SUBSTRING(linha,91,1)) IN ('S','1') THEN 1 ELSE 0 END
			,@NumItemProcedimento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,29,3)))
			,@AnexoProcedimento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,122,2)))
			,@NumItemSASProcedimento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,124,3)))
			FROM tempdb.[dbo].[PreImportaSAS]
			WHERE numconta = @numconta
			AND tipolinha = 2 -- Itens da Conta (PROCEDIMENTO)
			AND numlinha = @NumeroLinhaProcedimentoConta			
			 
	  	SELECT  @ChaveProcedimento = Chave
			FROM   dbo.TabelaProcedimento 
			WHERE ChaveOperadora = @ChaveOperadora
			   AND ChavePrestador = @ChavePrestador
			   AND (Codigo = IIF(@CodProcedimento ='0000000000',NULL,@CodProcedimento)  OR Descricao = @DescrProcedimento)

			IF @ChaveProcedimento IS NULL
				BEGIN
					--INSERIR NA TABELA
					INSERT INTO dbo.TabelaProcedimento 
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
					INSERT INTO ContaProcedimento
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
		FROM tempdb.[dbo].[PreImportaSAS] AS P  
		WHERE numconta = @numconta
		AND P.tipolinha = 6 -- MEDICAMENTO

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
			,@DescrMedicamento = TRIM(SUBSTRING(linha,40,50))
			,@QtdeMedicamento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,99,7)))
			,@UnidadeMedicamento = TRIM(SUBSTRING(linha,106,3))
			,@VrTotalMedicamento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,109,15)))
			,@PosicaoMedicamento = TRY_CONVERT(bit,TRIM(SUBSTRING(linha,98,1)))
			,@EmergMedicamento = CASE WHEN TRIM(SUBSTRING(linha,90,1)) IN ('S','1') THEN 1 ELSE 0 END
			,@DheMedicamento = CASE WHEN TRIM(SUBSTRING(linha,91,1)) IN ('S','1') THEN 1 ELSE 0 END
			,@NumItemMedicamento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,29,3)))
			,@AnexoMedicamento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,127,2)))
			,@NumItemSASMedicamento = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,129,3)))
			FROM tempdb.[dbo].[PreImportaSAS]
			WHERE numconta = @numconta
			AND tipolinha = 6 -- MEDICAMENTO
			AND numlinha = @NumeroLinhaMedicamentoConta	

			SELECT @ChaveMedicamento = Chave
			FROM   dbo.TabelaMedicamento
			WHERE
			ChaveOperadora = @ChaveOperadora
			AND ChavePrestador = @ChavePrestador
			AND Codigo = @CodMedicamento	
	        AND Descricao = @DescrMedicamento

			IF @ChaveMedicamento IS NULL
			BEGIN
				IF @CodMedicamento IS NULL SET @CodMedicamento = '0000000000'

				 --INSERIR NA TABELA MEDICAMENTO
				 INSERT INTO TabelaMedicamento
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
					Update TabelaMedicamento Set Codigo = @CodMedicamento
					Where Chave = @ChaveMedicamento AND Codigo <> @CodMedicamento
			END

			-- SET @dataRealizacao = RIGHT(@dataRealizacao,4) + SUBSTRING(@dataRealizacao,3,2) + LEFT(@dataRealizacao,2) ???

			    --INSERIR NA CONTA MEDICAMENTO    
				INSERT INTO ContaMedicamento
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
		FROM tempdb.[dbo].[PreImportaSAS] AS P  
		WHERE numconta = @numconta
		AND P.tipolinha = 5 -- MATERIAL

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
			,@DescrMaterial = TRIM(SUBSTRING(linha,40,50))
			,@QtdeMaterial = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,99,7)))
			,@UnidadeMaterial = TRIM(SUBSTRING(linha,106,3))
			,@VrTotalMaterial = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,109,15)))
			,@PosicaoMaterial = TRY_CONVERT(bit,TRIM(SUBSTRING(linha,98,1)))
			,@EmergMaterial = CASE WHEN TRIM(SUBSTRING(linha,90,1)) IN ('S','1') THEN 1 ELSE 0 END
			,@DheMaterial = CASE WHEN TRIM(SUBSTRING(linha,91,1)) IN ('S','1') THEN 1 ELSE 0 END
			,@NumItemMaterial = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,29,3)))
			,@AnexoMaterial = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,127,2)))
			,@NumItemSASMaterial = TRY_CONVERT(numeric(12,2),TRIM(SUBSTRING(linha,129,3)))
			FROM tempdb.[dbo].[PreImportaSAS]
			WHERE numconta = @numconta
			AND tipolinha = 5 -- MATERIAL
			AND numlinha = @NumeroLinhaMaterialConta	

			SELECT @ChaveMaterial = Chave
			FROM   dbo.TabelaMedicamento
			WHERE
			ChaveOperadora = @ChaveOperadora
			AND ChavePrestador = @ChavePrestador
			AND (Codigo = IIF(@CodMaterial='0000000000','',@CodMaterial))  
	        AND Descricao = @DescrMaterial

		     IF @ChaveMaterial IS NULL
			  BEGIN
					--INSERIR NA TABELA MATERIAL
					INSERT INTO TabelaMaterial
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
					Update TabelaMaterial Set Codigo = @CodMaterial Where Chave = @ChaveMaterial AND Codigo <> @CodMaterial	
				END

				--  SET @dataRealizacao = RIGHT(@dataRealizacao,4) + SUBSTRING(@dataRealizacao,3,2) + LEFT(@dataRealizacao,2) ???

				--INSERIR NA CONTA      
				INSERT INTO ContaMaterial
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

	   SET @numconta += 1; -- INCREMENTA VARIAVEL CONDICAO DE SAIDA DO LOOP!
	END -- FECHA TODOS OS LOOPS / WHILE MAIS EXTERNO

	----------------------- INFO ARQUIVO SAS ------------------------- 
	DECLARE @NomeOriginalArquivo varchar(20), @CodigoLogGestao int , @IdArquivoSAS int

	SELECT
	 @NomeOriginalArquivo = TRIM(SUBSTRING(linha,49,8))
	,@CodigoLogGestao = TRY_CONVERT(INT,TRIM(SUBSTRING(linha,125,10)))
	,@IdArquivoSAS = TRY_CONVERT(INT,TRIM(SUBSTRING(linha,135,10)))
	FROM tempdb.[dbo].[PreImportaSAS]
	WHERE tipolinha = 9 -- TRAILLER

	UPDATE [dbo].[Importacao]
	SET
		[NomeOriginalArquivo] = @NomeOriginalArquivo
	   ,[CodigoLogGestao] = @CodigoLogGestao
	   ,[IdArquivoSAS] = @IdArquivoSAS
	   ,[flag_importado] = 1
	   ,[mensagem] = 'Arquivo Importado com Sucesso!'
	WHERE
    [Chave] = @ArqID

	--SET @msg = CONCAT('Conta ',@numconta,' Importada com sucesso!')

	--EXEC [ctrl].[lsp_AtualizaArquivo] @arquivo,1,0,0,0,0,@msg

	IF @@TRANCOUNT > 0 COMMIT;
END TRY
BEGIN CATCH
	--SET @msg = 'Erro ao Carregar Arquivo - Insercoes Revertidas!'	
    -- EXEC [ctrl].[lsp_AtualizaArquivo] @arquivo,1,1,0,0,0,@msg
		
	IF @@TRANCOUNT > 0 ROLLBACK;

	UPDATE [dbo].[Importacao]
	SET
		[NomeOriginalArquivo] = @NomeOriginalArquivo
	   ,[CodigoLogGestao] = @CodigoLogGestao
	   ,[IdArquivoSAS] = @IdArquivoSAS
	   ,[flag_importado] = 1
	   ,[mensagem] = 'Erro ao Carregar Arquivo - Insercoes Revertidas!'
	WHERE
    [Chave] = @ArqID

END CATCH

SET NOCOUNT OFF;
END