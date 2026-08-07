-- ================================================
-- Stored Procedure: sp_AddTelefoneFornecedor
-- Descrição: Procedure para inserção de novos Usuários
-- Autor: Otávio Augusto Canola do Carmo
-- Data Criação: 28/06/2026
-- ================================================

-- Criação Procedure
CREATE OR ALTER PROCEDURE sp_AddTelefoneFornecedor
	-- Telefone Usuario
	@idFornecedor INT,
	@telefone CHAR(14)

AS
BEGIN

	-- SET NOCOUNT ON:
    -- Evita mensagens automáticas "X linhas afetadas"
    -- Ajuda em procedures (menos “poluição” no resultado)
	SET NOCOUNT ON;

	-- Começo TRY
	BEGIN TRY 
		
		BEGIN TRAN

		-- Verifica se existe já existe o usuário com o email cadastrado
		IF EXISTS (
			SELECT 1
			FROM Tbl_Telefone_Fornecedor WITH (UPDLOCK, HOLDLOCK)
			WHERE telefone = @telefone
		)

		BEGIN 
			
			-- Se existir ele manda a mensagem e da um rollback tran
			RAISERROR('Telefone já cadastrado no sistema.', 16, 1, @telefone);
		
			ROLLBACK TRAN

			RETURN 
		END
		
		-- Faz a inserção do Telefone do Usuario
		INSERT INTO Tbl_Telefone_Fornecedor(id_Fornecedor, telefone) VALUES
		(@idUsuario, @telefone);

		PRINT 'Telefone do fornecedor adicionado com sucesso!';

		COMMIT TRAN;

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