-- ================================================
-- Stored Procedure: sp_AddUsuario
-- Descrição: Procedure para inserção de novos Usuarios
-- Autor: Otávio Augusto Canola do Carmo
-- Data Criação: 28/06/2026
-- ================================================

-- Criação Procedure
ALTER PROCEDURE sp_AddUsuario
	-- Usuario
	@nome VARCHAR(255),
	@cpf CHAR(11),
	@email VARCHAR(255),
	@senha VARCHAR(25),
	@data_Nasc DATE,
	@telefone CHAR(14),
	@idUsuario INT = NULL OUTPUT 

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
			RAISERROR('Usuario já cadastrado.', 16, 1, @email);
		
			ROLLBACK TRAN

			RETURN 
		END
		
		-- Faz a inserção do usuário
		INSERT INTO Tbl_Usuario(nome, cpf, email, senha, data_Nasc) VALUES
		(@nome, @cpf, @email, @senha, @data_Nasc);

		-- Define o valor do último id na variável que criamos
		SET @idUsuario = SCOPE_IDENTITY();

		-- Se teve um elemento adicionado ele insere o telefone
		IF @@ROWCOUNT = 1
		BEGIN 
			INSERT INTO Tbl_Telefone_Usuario(id_Usuario, telefone) VALUES
			(@idUsuario, @telefone);

			COMMIT TRAN;
		END

		ELSE
		BEGIN
			ROLLBACK TRAN;
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