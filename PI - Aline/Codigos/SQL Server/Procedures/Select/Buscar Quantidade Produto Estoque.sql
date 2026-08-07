-- ================================================
-- Stored Procedure: sp_ViewQuantidadeProduto
-- Descrição: Procedure para visualizar a quantidade total de um produto no estoque
-- Autor: Otávio Augusto Canola do Carmo
-- Data Criação: 20/07/2026
-- ================================================

-- Criação Procedure
CREATE OR ALTER PROCEDURE sp_ViewQntProduto

	@id_Produto INT

AS
BEGIN

	-- SET NOCOUNT ON:
    -- Evita mensagens automáticas "X linhas afetadas"
    -- Ajuda em procedures (menos “poluição” no resultado)
	SET NOCOUNT ON;

	-- Começo TRY
	BEGIN TRY 
		
    -- Cria uma tabela rascunho que armazena as informações do produto, não sendo armazenada no banco
    WITH EstoqueOrdenado AS (
    SELECT -- Todas as colunas que a tabela vai ter
        p.nome, 
        l.qnt, 
        e.posicao, 
        l.validade, 
        p.preco,
        SUM(l.qnt) OVER(PARTITION BY p.id) AS total_qnt, /* PARTITION ele vai fazer a soma de cada produto 
        separadamente, produto por produto, não todos os produtos de uma vez juntos, diferente do GROUP BY, 
        permitindo ler a informação de validade dos lotes com o OVER */
        ROW_NUMBER() OVER(PARTITION BY p.id ORDER BY l.validade ASC) AS ID_Ordem -- Ordena por validade mais próxima do produto
    FROM Tbl_Produto p 
    INNER JOIN Tbl_Produto_Compra pc ON p.id = pc.id_Produto 
    INNER JOIN Tbl_Lote l            ON pc.id = l.id_Produto_Compra 
    INNER JOIN Tbl_Estoque e         ON l.id = e.id_Lote            
    WHERE p.id = @id_Produto
)
SELECT 
    nome,
    total_qnt AS qnt, -- Quantidade total somada de todos os lotes
    posicao,          -- Posição real do lote que vai vencer primeiro
    validade,         -- Menor validade
    preco
FROM EstoqueOrdenado
WHERE ID_Ordem = 1; -- Filtra para trazer apenas os dados do lote mais próximo de vencer


	END TRY

	-- Começo CATCH
	BEGIN CATCH

		IF @@TRANCOUNT > 0 

		DECLARE @Mensagem NVARCHAR(4000) = ERROR_MESSAGE();

		RAISERROR(@Mensagem, 16, 1)
	END CATCH
END
GO