-- ================================================
-- Stored Procedure: sp_AddFuncionario
-- Descrição: Procedure para inserção de novos funcionarios
-- Autor: Otávio Augusto Canola do Carmo
-- Data Criação: 28/06/2026
-- ================================================

-- Altera temporariamente o caractere finalizador de comandos do MySQL (que padrão é ;) para //
DELIMITER //

-- Remove a procedure sp_AddFuncionario do banco de dados, caso ela já exista.
DROP PROCEDURE IF EXISTS sp_AddFuncionario //

-- Criação Procedure
CREATE PROCEDURE sp_AddFuncionario
(
    -- Usuario
	IN p_nome VARCHAR(255),
	IN p_cpf CHAR(11),
	IN p_email VARCHAR(255),
	IN p_senha VARCHAR(25),
	IN p_data_Nasc DATE,

	-- Funcionario
	IN p_telefone CHAR(14),
	IN p_data_Admissao DATE,
	IN p_cargo VARCHAR(50),
	IN p_situacao VARCHAR(20)
)

BEGIN

	/* Cria uma variável local v_existe e v_ultimo_id, v_existe inicializada com 0, 
    usada para guardar o resultado da checagem de e-mail duplicado, e para guardar o ultimo id criado para o usuário*/
	DECLARE v_existe INT DEFAULT 0;
	DECLARE v_ultimo_Id INT;

	-- Handler de erro
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		RESIGNAL;
	END;

	START TRANSACTION;
			
			-- Verifica duplicação bloqueando a linha para alteração
			SELECT COUNT(1) INTO v_existe
			FROM Tbl_Usuario
			WHERE email = p_email
			FOR UPDATE; /* Isso impede que duas requisições simultâneas cadastrem o mesmo e-mail 
						exatamente ao mesmo tempo (Race Condition) */

			IF v_existe > 0 THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email já cadastrado.';
			END IF;
		
			-- Chama a procedure responsável por adicionar o usuário e telefone
			CALL sp_AddUsuario(p_nome, p_cpf, p_email, p_senha, p_data_Nasc, p_telefone, v_ultimo_Id);

			-- Se teve um elemento adicionado ele insere o telefone e adiciona como funcionario
			IF ROW_COUNT() = 1 THEN

				INSERT INTO Tbl_Funcionario (id_Usuario, data_Admissao, cargo, situacao) VALUES
					(v_ultimo_id, p_data_Admissao, p_cargo, p_situacao);

				COMMIT;
			
            ELSE
				ROLLBACK;
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Falha ao adicionar o funcionário.';
			END IF;
END //

DELIMITER ;