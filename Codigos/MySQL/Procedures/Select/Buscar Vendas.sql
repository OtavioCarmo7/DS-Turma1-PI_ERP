-- ================================================
-- Stored Procedure: sp_ViewVendas
-- Descrição: Procedure para visualizar as informações das vendas da farmácia
-- Autor: Otávio Augusto Canola do Carmo
-- Data Criação: 24/07/2026
-- ================================================

-- Criação Procedure
CREATE OR ALTER PROCEDURE sp_ViewVendas

AS
BEGIN

	-- SET NOCOUNT ON:
    -- Evita mensagens automáticas "X linhas afetadas"
    -- Ajuda em procedures (menos “poluição” no resultado)
	SET NOCOUNT ON;

	-- Começo TRY
	BEGIN TRY 
		
    SELECT cliente.nome AS cliente, funcionario.nome AS funcionario, p.nome, v.valor, v.data_Venda, v.canal_Venda FROM Tbl_Venda v
	INNER JOIN Tbl_Usuario cliente ON v.id_Cliente = cliente.id
	INNER JOIN Tbl_Funcionario f ON v.id_Funcionario = f.id 
	INNER JOIN Tbl_Usuario funcionario ON f.id_Usuario = funcionario.id
	INNER JOIN Tbl_Produto_Venda pv ON pv.id_Venda = v.id
	INNER JOIN Tbl_Produto p ON pv.id_Produto = p.id

	END TRY

	-- Começo CATCH
	BEGIN CATCH

		IF @@TRANCOUNT > 0 

		DECLARE @Mensagem NVARCHAR(4000) = ERROR_MESSAGE();

		RAISERROR(@Mensagem, 16, 1)
	END CATCH
END
GO