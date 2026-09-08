-- ================================================
-- Stored Procedure: sp_AddUsuario
-- Descrição: Procedure para inserção de novos Usuarios
-- Autor: Otávio Augusto Canola do Carmo
-- Data Criação: 28/06/2026
-- ================================================

-- Altera temporariamente o caractere finalizador de comandos do MySQL (que padrão é ;) para //
DELIMITER //

-- Remove a procedure sp_AddUsuario do banco de dados, caso ela já exista.
DROP PROCEDURE IF EXISTS sp_AddUsuario//

-- Criação Procedure
CREATE PROCEDURE sp_AddUsuario 
(
	-- IN: Define os parâmetros de entrada (dados que a aplicação envia para a procedure).

	-- OUT: Define um parâmetro de saída. Ele devolverá para quem chamou a procedure o código ID gerado no cadastro.
    
	IN p_nome VARCHAR(255),
	IN p_cpf CHAR(11),
	IN p_email VARCHAR(255),
	IN p_senha VARCHAR(25),
	IN p_data_Nasc DATE,
	IN p_telefone CHAR(14),
	OUT p_idUsuario INT
)
BEGIN

	/* Cria uma variável local v_existe inicializada com 0, 
    usada para guardar o resultado da checagem de e-mail duplicado. */
	DECLARE v_existe INT DEFAULT 0;
    
	-- Handler de erro
	DECLARE EXIT HANDLER FOR SQLEXCEPTION  -- É o tratamento de exceção (o equivalente ao CATCH do SQL Server).
    BEGIN
		
		ROLLBACK;
        RESIGNAL; -- Repassa a mensagem de erro original para a aplicação/back-end tratar.
	END;
		
     START TRANSACTION;

	-- Verifica duplicação bloqueando a linha para alteração
	SELECT COUNT(1) INTO v_existe
	FROM Tbl_Usuario
	WHERE email = p_email
	FOR UPDATE; /* Isso impede que duas requisições simultâneas cadastrem o mesmo e-mail 
    exatamente ao mesmo tempo (Race Condition) */

	IF v_existe > 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario já cadastrado.'; -- substitui o RAISERROR do SQL Server
	END IF;

	INSERT INTO Tbl_Usuario (nome, cpf, email, senha, data_Nasc) 
	VALUES (p_nome, p_cpf, p_email, p_senha, p_data_Nasc);

	SET p_idUsuario = LAST_INSERT_ID(); /* Captura o último ID numérico gerado pelo campo, 
    equivalente ao SCOPE_IDENTITY() do SQL Server */

	IF ROW_COUNT() = 1 THEN -- Verifica se o INSERT anterior afetou exatamente 1 linha
		INSERT INTO Tbl_Telefone_Usuario (id_Usuario, telefone) 
		VALUES (p_idUsuario, p_telefone);

		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
-- Finaliza o bloco do corpo da Stored Procedure com o delimitador temporário.
END //

-- Restaura o caractere finalizador padrão do MySQL para ;
DELIMITER ;