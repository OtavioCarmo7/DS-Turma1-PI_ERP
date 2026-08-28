-- ================================================
-- Stored Procedure: sp_ViewContaCliente
-- Descrição: Procedure para visualizar as informações da conta do cliente logado
-- Autor: Otávio Augusto Canola do Carmo
-- Data Criação: 24/07/2026
-- ================================================

-- Criação Procedure
CREATE OR ALTER PROCEDURE sp_ViewContaCliente

	@id_Cliente INT

AS
BEGIN

	-- SET NOCOUNT ON:
    -- Evita mensagens automáticas "X linhas afetadas"
    -- Ajuda em procedures (menos “poluição” no resultado)
	SET NOCOUNT ON;

	-- Começo TRY
	BEGIN TRY 
		
    SELECT u.nome, u.email, t.telefone, u.cpf, u.data_Nasc FROM Tbl_Usuario u
	INNER JOIN Tbl_Telefone_Usuario t ON t.id_Usuario = u.id 
	INNER JOIN Tbl_Cliente c ON c.id_Usuario = u.id
	WHERE u.id = @id_Cliente

	END TRY

	-- Começo CATCH
	BEGIN CATCH

		IF @@TRANCOUNT > 0 

		DECLARE @Mensagem NVARCHAR(4000) = ERROR_MESSAGE();

		RAISERROR(@Mensagem, 16, 1)
	END CATCH
END
GO