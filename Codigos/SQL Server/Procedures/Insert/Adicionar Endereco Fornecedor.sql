-- ================================================
-- Stored Procedure: sp_AddEnderecoFornecedor
-- Descrição: Procedure para inserção dos endereços dos Fornecedores
-- Autor: Otávio Augusto Canola do Carmo
-- Data Criação: 14/07/2026
-- ================================================

-- Criação Procedure
CREATE OR ALTER PROCEDURE sp_AddEnderecoFornecedor
	-- Telefone Usuario
	@id_Endereco INT,
	@id_Fornecedor INT,
	@numero VARCHAR(5),
	@complemento VARCHAR(20),
	@referencia VARCHAR(100)

AS
BEGIN

	-- SET NOCOUNT ON:
    -- Evita mensagens automáticas "X linhas afetadas"
    -- Ajuda em procedures (menos “poluição” no resultado)
	SET NOCOUNT ON;

	-- Começo TRY
	BEGIN TRY 
		
		BEGIN TRAN

		-- Verifica se já existe o endereço para o fornecedor
		IF EXISTS (
			SELECT 1 
			FROM Tbl_Fornecedor_Endereco WITH (UPDLOCK, HOLDLOCK)
			WHERE id_Fornecedor = @id_Fornecedor AND numero = @numero AND complemento = @complemento AND referencia = @referencia
		)

		BEGIN
			
			RAISERROR('Endereço já cadastrado para o fornecedor', 16, 1);

			ROLLBACK TRAN;

			RETURN;
		
		END

		-- Faz a inserção do Endereço do Usuario
		INSERT INTO Tbl_Fornecedor_Endereco(id_Fornecedor, id_Endereco, numero, complemento, referencia) VALUES
		(@id_Fornecedor, @id_Endereco, @numero, @complemento, @referencia);

		PRINT 'Endereço do fornecedor adicionado com sucesso!';

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