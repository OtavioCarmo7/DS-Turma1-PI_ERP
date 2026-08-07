-- ================================================
-- Stored Procedure: sp_AddFuncionario
-- Descrição: Procedure para inserção de novos funcionarios
-- Autor: Otávio Augusto Canola do Carmo
-- Data Criação: 28/06/2026
-- ================================================

-- Criação Procedure
CREATE OR ALTER PROCEDURE sp_AddFuncionario
	-- Usuario
	@nome VARCHAR(255),
	@cpf CHAR(11),
	@email VARCHAR(255),
	@senha VARCHAR(25),
	@data_Nasc DATE,

	-- Funcionario
	@telefone CHAR(14),
	@data_Admissao DATE,
	@cargo VARCHAR(50),
	@situacao VARCHAR(20)

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
			FROM Tbl_Usuario WITH (UPDLOCK, HOLDLOCK)
			WHERE email = @email
		)

		BEGIN 
			
			-- Se existir ele manda a mensagem e da um rollback tran
			RAISERROR('Funcionário já cadastrado.', 16, 1, @cpf);
		
			ROLLBACK TRAN

			RETURN 
		END
		
		-- Declara a variável do último id adicionado
		DECLARE @ultimo_Id INT;

		-- Faz a inserção do usuário
		INSERT INTO Tbl_Usuario(nome, cpf, email, senha, data_Nasc) VALUES
		(@nome, @cpf, @email, @senha, @data_Nasc);

		-- Define o valor do último id na variável que criamos
		SET @ultimo_Id = SCOPE_IDENTITY();

		-- Se teve um elemento adicionado ele insere o telefone e adiciona como funcionario
		IF @@ROWCOUNT = 1
		BEGIN 
		
			INSERT INTO Tbl_Telefone_Usuario (id_Usuario, telefone) VALUES 
					(@ultimo_Id, @telefone);

			INSERT INTO Tbl_Funcionario (id_Usuario, data_Admissao, cargo, situacao) VALUES
				(@ultimo_Id, @data_Admissao, @cargo, @situacao);

			PRINT 'Funcionário adicionado com sucesso!';

			COMMIT TRAN;

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