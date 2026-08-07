-- ================================================
-- Stored Procedure: sp_AddProdutoVenda
-- Descrição: Procedure para direcionar os produtos comprados a determinada compra
-- Autor: Otávio Augusto Canola do Carmo
-- Data Criação: 15/07/2026
-- ================================================

-- Criação Procedure
ALTER PROCEDURE sp_AddProdutoVenda
	
	-- Produto_Compra
	@id_Venda INT,
	@id_Produto INT,
	@qnt INT,
	@valor_Unitario DECIMAL(8,2),
	@id_Produto_Venda INT OUTPUT

AS
BEGIN

	-- SET NOCOUNT ON:
    -- Evita mensagens automáticas "X linhas afetadas"
    -- Ajuda em procedures (menos “poluição” no resultado)
	SET NOCOUNT ON;

	-- Começo TRY
	BEGIN TRY 
		
		-- Faz a inserção dos Produtos à Compra na tabela do Sistema
		INSERT INTO Tbl_Produto_Venda(id_Venda, id_Produto, qnt, valor_Unitario) VALUES
		(@id_Venda, @id_Produto, @qnt, @valor_Unitario);

		SET @id_Produto_Venda = SCOPE_IDENTITY();

	END TRY

	-- Começo CATCH
	BEGIN CATCH

		IF @@TRANCOUNT > 0 

		DECLARE @Mensagem NVARCHAR(4000) = ERROR_MESSAGE();

		RAISERROR(@Mensagem, 16, 1)
	END CATCH
END
GO