-- ================================================
-- Stored Procedure: sp_AddEstoque
-- Descrição: Procedure para fazer a inserção do lote comprado no estoque
-- Autor: Otávio Augusto Canola do Carmo
-- Data Criação: 13/07/2026
-- ================================================

-- Criação Procedure
CREATE OR ALTER PROCEDURE sp_AddEstoque
	
	-- Estoque
	@id_Lote INT,
	@posicao VARCHAR(30)

AS
BEGIN

	-- SET NOCOUNT ON:
    -- Evita mensagens automáticas "X linhas afetadas"
    -- Ajuda em procedures (menos “poluição” no resultado)
	SET NOCOUNT ON;

	-- Começo TRY
	BEGIN TRY 
		
		-- Faz a inserção do Lote
		INSERT INTO Tbl_Estoque(id_Lote, posicao) VALUES
		(@id_Lote, @posicao);

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