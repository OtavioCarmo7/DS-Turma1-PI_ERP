-- ================================================
-- Stored Procedure: sp_AddProduto
-- Descrição: Procedure para inserção de novos produtos
-- Autor: Otávio Augusto Canola do Carmo
-- Data Criação: 20/07/2026
-- ================================================

-- Criação Procedure
CREATE OR ALTER PROCEDURE sp_AddProduto
	-- Produto
	@nome VARCHAR(255),
	@descricao CHAR(11),
	@preco VARCHAR(255),
	@tarja VARCHAR(25)
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
			FROM Tbl_Produto WITH (UPDLOCK, HOLDLOCK)
			WHERE nome = @nome
		)

		BEGIN 
			
			-- Se existir ele manda a mensagem e da um rollback tran
			RAISERROR('Produto já cadastrado.', 16, 1, @nome);
		
			ROLLBACK TRAN

			RETURN 
		END
		
		-- Faz a inserção do usuário
		INSERT INTO Tbl_Produto(nome, descricao, preco, tarja) VALUES
		(@nome, @descricao, @preco, @tarja);

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