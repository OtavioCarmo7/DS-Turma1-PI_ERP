-- ================================================
-- Stored Procedure: sp_AddLote
-- Descrição: Procedure para fazer a criação do lote do produto comprado pela fornecedora
-- Autor: Otávio Augusto Canola do Carmo
-- Data Criação: 13/07/2026
-- ================================================

-- Criação Procedure
CREATE OR ALTER PROCEDURE sp_AddLote
	
	-- Lote
	@id_Produto_Compra INT,
	@cod VARCHAR(10),
	@qnt INT,
	@validade DATE,
	@id_Lote INT OUTPUT

AS
BEGIN

	-- SET NOCOUNT ON:
    -- Evita mensagens automáticas "X linhas afetadas"
    -- Ajuda em procedures (menos “poluição” no resultado)
	SET NOCOUNT ON;

	-- Começo TRY
	BEGIN TRY 
				
		IF EXISTS (SELECT 1 FROM Tbl_Lote WHERE cod = @cod)
		BEGIN
			RAISERROR('Código do Lote já existe.', 16, 1);
			RETURN;
		END
		
		-- Faz a inserção do Lote no Sistema
		INSERT INTO Tbl_Lote(id_Produto_Compra, cod, qnt, validade) VALUES
		(@id_Produto_Compra, @cod, @qnt, @validade);

		SET @id_Lote = SCOPE_IDENTITY();

	END TRY

	-- Começo CATCH
	BEGIN CATCH

		IF @@TRANCOUNT > 0 
			ROLLBACK TRAN

		DECLARE @Mensagem NVARCHAR(4000) = ERROR_MESSAGE();

		RAISERROR(@Mensagem, 16, 1)
	END CATCH
END
GO