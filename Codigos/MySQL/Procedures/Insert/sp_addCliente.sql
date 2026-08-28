-- ================================================
-- Stored Procedure: sp_AddCliente
-- Descrição: Procedure para inserção de novos Clientes
-- Autor: Otávio Augusto Canola do Carmo
-- Data Criação: 28/06/2026
-- ================================================

-- Criação Procedure
CREATE OR ALTER PROCEDURE sp_AddCliente
	-- Usuario
	@nome VARCHAR(255),
	@cpf CHAR(11),
	@email VARCHAR(255),
	@senha VARCHAR(25),
	@data_Nasc DATE,

	-- Telefone Usuário
	@telefone CHAR(14),

	-- Cliente
	@aceitaOfertas BIT

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
			RAISERROR('Email já cadastrado.', 16, 1, @email);
		
			ROLLBACK TRAN

			RETURN 
		END
		
		-- Declara a variável do último id adicionado
		DECLARE @ultimo_Id INT;

		-- Faz a inserção do usuário e coloca o id criado na variável que declaramos
		EXEC sp_AddUsuario 
			@nome = @nome,
			@cpf = @cpf,
			@email = @email,
			@senha = @senha,
			@data_Nasc = @data_Nasc,
			@telefone = @telefone,
			@idUsuario = @ultimo_Id OUTPUT;

		INSERT INTO Tbl_Cliente(id_Usuario, aceita_Ofertas) VALUES
				(@ultimo_Id, @aceitaOfertas);

		PRINT 'Cliente adicionado com sucesso!';

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