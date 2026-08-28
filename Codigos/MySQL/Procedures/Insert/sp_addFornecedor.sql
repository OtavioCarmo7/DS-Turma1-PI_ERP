-- ================================================
-- Stored Procedure: sp_AddFornecedor
-- Descrição: Procedure para inserção de novos fornecedores
-- Autor: Otávio Augusto Canola do Carmo
-- Data Criação: 03/07/2026
-- ================================================

-- Criação Procedure
CREATE OR ALTER PROCEDURE sp_AddFornecedor
	-- Fornecedor
	@nome VARCHAR(255),
	@cnpj CHAR(14),
	@email VARCHAR(255),
	@telefone VARCHAR(14),

	-- Endereço
	@cep VARCHAR(9),
	@logradouro VARCHAR(50),
	@bairro VARCHAR(50),
	@cidade VARCHAR(100),
	@uf CHAR(2), 

	-- Endereço Fornecedor
	@id_Fornecedor INT,
	@id_Endereco INT,
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

		-- Se existir já um fornecedor cadastrado com o mesmo cnpj ele manda a mensagem
		IF EXISTS (
			SELECT 1
			FROM Tbl_Fornecedor WITH (UPDLOCK, HOLDLOCK)
			WHERE cnpj = @cnpj
		)

		BEGIN 

			RAISERROR('Fornecedor com cnpj $s já cadastrado.', 16, 1, @cnpj);
		
			ROLLBACK TRAN

			RETURN 
		END
		
		-- Declara a variável do último id adicionado na tabela
		DECLARE @ultimo_Id INT;

		-- Adiciona o fornecedor
		INSERT INTO Tbl_Fornecedor (nome, cnpj, email) VALUES
		(@nome, @cnpj, @email);

		-- Coloca o valor do último id na variável criada
		SET @ultimo_Id = SCOPE_IDENTITY();

		-- Se adicionar o fornecedor, já adiciona o telefone e o endereço dele
		IF @@ROWCOUNT = 1
		BEGIN 
		
			INSERT INTO Tbl_Telefone_Fornecedor (id_Fornecedor, telefone) VALUES 
					(@ultimo_Id, @telefone)

			INSERT INTO Tbl_Fornecedor_Endereco (id_Fornecedor, id_Endereco, numero, complemento, referencia) VALUES
				(@id_Fornecedor, @id_Endereco, @numero, @complemento, @referencia);

			PRINT 'Fornecedor adicionado com sucesso!'

			COMMIT TRAN;

		END

		ELSE
		BEGIN
			ROLLBACK TRAN;
			RAISERROR('Falha ao adicionar o fornecedor', 16, 1);
			RETURN;
		END
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