-- ================================================
-- Stored Procedure: sp_realizarVenda
-- Descrição: Procedure para fazer o processo de venda com o cliente
-- Autor: Otávio Augusto Canola do Carmo
-- Data Criação: 15/07/2026
-- ================================================

-- Criação Procedure
ALTER PROCEDURE sp_realizarVenda
	
	-- Variáveis

	-- Tabela: Venda
	@id_Cliente INT,
	@id_Funcionario INT,
	@nfe VARCHAR(100),
	@canal_Venda VARCHAR(20),

	-- Tabela: PagamentoVenda
	@forma_Pagamento VARCHAR(9),
	@valor_Pago DECIMAL (10,2),-- Quanto essa forma de pagamento supriu do valor da venda
	@valor_Recebido DECIMAL(10,2), -- Só preenchido quando 'forma_Pagamento' = 'dinheiro'
	@situacao VARCHAR(8),

	-- Tabela: ProdutoVenda
	@itens Tbl_Type_ProdutoVenda READONLY -- Aqui entra na lista inteira que criamos no banco

AS
BEGIN

	-- SET NOCOUNT ON:
    -- Evita mensagens automáticas "X linhas afetadas"
    -- Ajuda em procedures (menos “poluição” no resultado)
	SET NOCOUNT ON;

	-- Começo o caminho TRY
	BEGIN TRY 
		
		-- Inicia o ambiente de testes
		BEGIN TRAN
		
		-- Cria a variável do último id adicionado da Venda
		DECLARE @id_Venda INT;

		-- Delarando variáveis que vamos utilizar para guardar as informações recebidas nas procedures
		DECLARE  @id_Produto_Venda INT,
				 @valor_Total DECIMAL(10,2);

		-- Pega as informações da variável da tabela Type_ProdutoVenda e coloca na variável @valor_Total
		SELECT @valor_Total = SUM(qnt * valor_Unitario) FROM @itens;

		-- Faz a inserção da Venda na tabela Venda
		INSERT INTO Tbl_Venda(id_Cliente, id_Funcionario, nfe, valor, data_Venda, canal_Venda) VALUES
		(@id_Cliente, @id_Funcionario, @nfe,  @valor_Total, GETDATE(), @canal_Venda);

		-- Define o valor do último id na variável que criamos na variável
		SET @id_Venda = SCOPE_IDENTITY();

		/* Cria uma nova tabela temporária física no banco de dados 
		chamada #ItensTemp e insere nela todos os dados retornados pelo SELECT */
		SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS linha,
			id_Produto, qnt, valor_Unitario -- Gera um número para cada linha da tabela, conforme elas vem
		INTO #ItensTemp -- Copia os itens da lista recebida em @itens para dentro dessa tabela temporária 
		FROM @itens -- Em qual lugar vai fazer a busca

		-- Cria uma variável que contem o número total de linhas da tabela
		DECLARE @totalLinhas INT = (SELECT COUNT(*) FROM #ItensTemp);
		
		-- Cria uma variável que inicia o ciclo de repetição
		DECLARE @linhaAtual INT = 1;

		-- Delarando variáveis que vamos utilizar para guardar as informações recebidas nas procedures
		DECLARE 
			@id_Produto INT,
			@qnt INT,
			@valor_Unitario DECIMAL(8,2)

			-- Inicia o loop para ler todas as linhas da tabela temporária
			WHILE @linhaAtual <= @totalLinhas
			BEGIN
				SELECT 
					@id_Produto = id_produto,
					@qnt = qnt,
					@valor_Unitario = valor_Unitario
				FROM #ItensTemp
				WHERE linha = @linhaAtual

				-- Procedure que adiciona os produtos comprados pelo cliente
				EXEC sp_AddProdutoVenda
					@id_Venda = @id_Venda,
					@id_Produto = @id_Produto,
					@qnt = @qnt,
					@valor_Unitario = @valor_Unitario,
					@id_Produto_Venda = @id_Produto_Venda OUTPUT;
					
				-- Adiciona 1 índice à variável para continuar o loop
				SET @linhaAtual += 1;
			END

			-- Deleta a tabela temporária das variáveis
			DROP TABLE #ItensTemp;

			
			-- Procedure que adiciona as informações de pagamento da venda
			EXEC sp_AddPagamentoVenda
				@id_Venda = @id_Venda,
				@forma_Pagamento = @forma_Pagamento,
				@valor_Pago = @valor_Pago, 
				@valor_Recebido = @valor_Recebido, 
				@situacao = @situacao;

			PRINT 'Venda realizada com sucesso!';

			-- Commita o processo para o banco verdadeira, e não apenas na fase de teste
			COMMIT TRAN;

	END TRY

	-- Começo CATCH
	BEGIN CATCH

		IF OBJECT_ID('tempdb..#ItensTemp') IS NOT NULL
			DROP TABLE #ItensTemp;
		
		IF @@TRANCOUNT > 0 
			ROLLBACK TRAN

		DECLARE @Mensagem NVARCHAR(4000) = ERROR_MESSAGE();

		RAISERROR(@Mensagem, 16, 1)
	END CATCH
END
GO