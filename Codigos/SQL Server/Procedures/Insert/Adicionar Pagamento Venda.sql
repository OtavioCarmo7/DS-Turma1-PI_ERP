-- ================================================
-- Stored Procedure: sp_AddPagamentoVenda
-- Descrição: Procedure para processar o pagamento da venda
-- Autor: Otávio Augusto Canola do Carmo
-- Data Criação: 16/07/2026
-- ================================================

-- Criação Procedure
CREATE OR ALTER PROCEDURE sp_AddPagamentoVenda
	
	-- Pagamento_Venda
	@id_Venda INT,
	@forma_Pagamento VARCHAR(9),
	@valor_Pago DECIMAL (10,2),-- Quanto essa forma de pagamento supriu do valor da venda
	@valor_Recebido DECIMAL(10,2) = NULL, -- Só preenchido quando 'forma_Pagamento' = 'dinheiro'
	@situacao VARCHAR(8)

AS
BEGIN

	-- SET NOCOUNT ON:
    -- Evita mensagens automáticas "X linhas afetadas"
    -- Ajuda em procedures (menos “poluição” no resultado)
	SET NOCOUNT ON;

	-- Começo TRY
	BEGIN TRY 

		-- Cria a variável troco para colocarmos o valor do troco
		DECLARE @troco DECIMAL(10,2) = NULL -- troco = valor_Recebido - valor_Pago, só calculado quando valor_Recebido não é nulo

		-- Faz a condição do pagamento em dinheiro
		IF @forma_Pagamento = 'dinheiro'
		BEGIN 
			-- Valida se o valor recebido foi informado
			IF @valor_Recebido IS NULL
			BEGIN
				RAISERROR('Valor recebido é obrigatório para pagamento em dinheiro.', 16, 1);
				RETURN;
			END

			-- Valida se o cliente deu dinheiro suficiente
			IF @valor_Recebido < @valor_Pago
			BEGIN
				RAISERROR('Valor recebido é menor do que o valor do produto.', 16, 1);
				RETURN;
			END

			-- Valida se o cliente deu dinheiro igual ao valor do produto, ficando sem troco
			IF @valor_Recebido = @valor_Pago
			BEGIN
				INSERT INTO Tbl_Pagamento_Venda(id_Venda, forma_Pagamento, valor_Pago, valor_Recebido, situacao) VALUES
					(@id_Venda, @forma_Pagamento, @valor_Pago, @valor_Recebido, @situacao)
				
				PRINT 'Compra efetuada com sucesso.'
			END
			
			-- Se o cliente deu dinheiro a mais do que o produto faz o processo com o troco
			SET @troco = @valor_Recebido - @valor_Pago; -- Calcula o troco

			-- Faz a inserção dos Produtos à Compra na tabela do Sistema, com o troco
			INSERT INTO Tbl_Pagamento_Venda(id_Venda, forma_Pagamento, valor_Pago, valor_Recebido, troco, situacao) VALUES
				(@id_Venda, @forma_Pagamento, @valor_Pago, @valor_Recebido, @troco, @situacao);

			PRINT 'Compra efetuada com sucesso, receba seu troco de ' + CAST(@troco AS VARCHAR(20)); /* CAST muda
			o valor de um dado para outro */
		END

		-- Faz a condição do caminho se o pagamento é com o cartão
		ELSE IF @forma_Pagamento = 'cartao'
		BEGIN
			
			IF @valorRecebido < @valorTotal
			BEGIN 
				PRINT 'Valor recebido é menor do que o valor do produto.'
			END

			ELSE
			BEGIN
				INSERT INTO Tbl_Pagamento_Venda(id_Venda, forma_Pagamento, valor_Pago, situacao) VALUES
					(@id_Venda, @forma_Pagamento, @valor_Pago, @situacao) 
				PRINT 'Compra efetuada com sucesso!'
		END

		ELSE
		BEGIN
			-- Cobre qualquer forma de pagamento não prevista
			RAISERROR('Forma de pagamento não reconhecida.', 16, 1);
			RETURN;
		END
	END TRY

	-- Começo CATCH
	BEGIN CATCH

		IF @@TRANCOUNT > 0 

		DECLARE @Mensagem NVARCHAR(4000) = ERROR_MESSAGE();

		RAISERROR(@Mensagem, 16, 1)
	END CATCH
END
GO