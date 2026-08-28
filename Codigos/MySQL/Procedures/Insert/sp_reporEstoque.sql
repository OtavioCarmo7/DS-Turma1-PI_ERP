-- ================================================
-- Stored Procedure: sp_ReporEstoque
-- Descrição: Procedure para fazer o processo de compras de produto com o fornecedor
-- Autor: Otávio Augusto Canola do Carmo
-- Data Criação: 10/07/2026
-- ================================================

-- Criação Procedure
CREATE OR ALTER PROCEDURE sp_ReporEstoque
	
	-- Compra
	@id_Fornecedor INT,
	@total_Compra DECIMAL (10,2),
	@itens Tbl_Type_ProdutoCompra READONLY

AS
BEGIN

	-- SET NOCOUNT ON:
    -- Evita mensagens automáticas "X linhas afetadas"
    -- Ajuda em procedures (menos “poluição” no resultado)
	SET NOCOUNT ON;

	-- Começo TRY
	BEGIN TRY 
		
		-- Inicia o ambiente de testes
		BEGIN TRAN
		
		-- Declara a variável do último id adicionado da Compra
		DECLARE @id_Compra INT;

		-- Faz a inserção da Compra
		INSERT INTO Tbl_Compra(id_Fornecedor, data_Compra, total_Compra) VALUES
		(@id_Fornecedor, GETDATE(), @total_Compra);

		-- Define o valor do último id na variável que criamos
		SET @id_Compra = SCOPE_IDENTITY();

		/* Cria uma nova tabela temporária física no banco de dados 
		chamada #ItensTemp e insere nela todos os dados retornados pelo SELECT */
		SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS linha,
			id_Produto, qnt, valor_Unitario, cod, validade, posicao
		INTO #ItensTemp
		FROM @itens

		-- Cria uma variável que contem o número total de linhas da tabela
		DECLARE @totalLinhas INT = (SELECT COUNT(*) FROM #ItensTemp);
		
		-- Cria uma variável que inicia o ciclo de repetição
		DECLARE @linhaAtual INT = 1;

		-- Delarando variáveis que vamos utilizar para guardar as informações recebidas nas procedures
		DECLARE 
			@id_Produto INT,
			@qnt INT,
			@valor_Unitario DECIMAL(8,2),
			@cod VARCHAR(10), 
			@validade DATE,
			@posicao VARCHAR(30),
			@id_Produto_Compra INT,
			@id_Lote INT;

			-- Inicia o loop para ler todas as linhas da tabela temporária
			DECLARE @ultimo_Id_produtoCompra INT;
			DECLARE @ultimo_Id_lote INT;

			WHILE @linhaAtual <= @totalLinhas
			BEGIN
				SELECT 
					@id_Produto = id_produto,
					@qnt = qnt,
					@valor_Unitario = valor_Unitario,
					@cod = cod, 
					@validade = validade,
					@posicao = posicao
				FROM #ItensTemp
				WHERE linha = @linhaAtual

				-- Insert de produtos da compra
				INSERT INTO Tbl_Produto_Compra (id_Compra, id_Produto, qnt, valor_Unitario) VALUES
					(@id_Compra, @id_Produto, @qnt, @valor_Unitario);

					SET @ultimo_Id_produtoCompra = SCOPE_IDENTITY();

				-- Procedure que adiciona as informações dos lotes recebidos pelo fornecedor
				INSERT INTO Tbl_Lote (id_Produto_Compra, cod, qnt, validade) VALUES
					(@ultimo_Id_produtoCompra, @cod, @qnt, @validade);
					
					SET @ultimo_Id_Lote = SCOPE_IDENTITY();

				-- Procedure que adiciona os lotes dos produtos no estoque da farmácia
				INSERT INTO Tbl_Estoque (id_Lote, posicao) VALUES
					(@ultimo_Id_lote, @posicao);

				-- Adiciona 1 índice à variável para continuar o loop
				SET @linhaAtual += 1;
			END

			-- Deleta a tabela temporária das variáveis
			DROP TABLE #ItensTemp;

			PRINT 'Compra realizada com sucesso, itens adicionados no estoque!';

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