-- ================================= BANCO DE DADOS =================================
CREATE DATABASE IF NOT EXISTS dbSannus; -- Cria o banco se não existit ainda dbSannus

USE dbSannus;

-- ================================= APAGAR TABELAS =================================

DROP TABLE IF EXISTS Tbl_Produto_Venda;
DROP TABLE IF EXISTS Tbl_Pagamento_Venda;
DROP TABLE IF EXISTS Tbl_Venda;
DROP TABLE IF EXISTS Tbl_Estoque;
DROP TABLE IF EXISTS Tbl_Lote;
DROP TABLE IF EXISTS Tbl_Produto_Compra;
DROP TABLE IF EXISTS Tbl_Compra;
DROP TABLE IF EXISTS Tbl_Produto;
DROP TABLE IF EXISTS Tbl_Cliente_Endereco;
DROP TABLE IF EXISTS Tbl_Fornecedor_Endereco;
DROP TABLE IF EXISTS Tbl_Endereco;
DROP TABLE IF EXISTS Tbl_Funcionario;
DROP TABLE IF EXISTS Tbl_Cliente;
DROP TABLE IF EXISTS Tbl_Telefone_Usuario;
DROP TABLE IF EXISTS Tbl_Usuario;
DROP TABLE IF EXISTS Tbl_Telefone_Fornecedor;
DROP TABLE IF EXISTS Tbl_Fornecedor;

SET FOREIGN_KEY_CHECKS = 1;

-- ================================= TABELAS =================================

-- TABELAS Fornecedor, Telefone

CREATE TABLE Tbl_Fornecedor 
(
	id INT PRIMARY KEY AUTO_INCREMENT,
	nome VARCHAR(255) NOT NULL,
	cnpj CHAR(14) NOT NULL,
	email VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE Tbl_Telefone_Fornecedor
(
	id INT PRIMARY KEY AUTO_INCREMENT,
	id_Fornecedor INT NOT NULL,
	telefone VARCHAR(14),
	FOREIGN KEY (id_Fornecedor) REFERENCES Tbl_Fornecedor(id)
);

-- TABELAS Usuario, Telefone_Usuario, Cliente e Funcionario

CREATE TABLE Tbl_Usuario 
(
	id INT PRIMARY KEY AUTO_INCREMENT,
	nome VARCHAR(255) NOT NULL,
	cpf CHAR(11) NOT NULL,
	email VARCHAR(255) UNIQUE NOT NULL,
	senha VARCHAR(25) NOT NULL,
	data_Nasc DATE NOT NULL
);

CREATE TABLE Tbl_Telefone_Usuario
(
	id INT PRIMARY KEY AUTO_INCREMENT,
	id_Usuario INT NOT NULL,
	telefone CHAR(14) NOT NULL,
	FOREIGN KEY (id_Usuario) REFERENCES Tbl_Usuario(id)
);

CREATE TABLE Tbl_Cliente 
(
	id INT PRIMARY KEY AUTO_INCREMENT,
	id_Usuario INT NOT NULL,
	aceita_Ofertas BIT,
	FOREIGN KEY (id_Usuario) REFERENCES Tbl_Usuario(id)
);

CREATE TABLE Tbl_Funcionario 
(
	id INT PRIMARY KEY AUTO_INCREMENT,
	id_Usuario INT NOT NULL,
	data_Admissao DATE NOT NULL,
	cargo VARCHAR(50) NOT NULL,
	situacao VARCHAR(20) NOT NULL CHECK (situacao IN ('Ativo', 'Afastado', 'Demitido')),
	FOREIGN KEY (id_Usuario) REFERENCES Tbl_Usuario(id)
);

-- TABELAS Endereço, Fornecedor_Endereço, Cliente_Endereço

CREATE TABLE Tbl_Endereco
(
	id INT PRIMARY KEY AUTO_INCREMENT,
	cep VARCHAR(9) NOT NULL,
	logradouro VARCHAR(50) NOT NULL,
	bairro VARCHAR(50) NOT NULL,
	cidade VARCHAR(100) NOT NULL,
	uf CHAR(2) NOT NULL
);

CREATE TABLE Tbl_Fornecedor_Endereco 
(
	id INT PRIMARY KEY AUTO_INCREMENT,
	id_Fornecedor INT NOT NULL,
	id_Endereco INT NOT NULL,
	numero VARCHAR(5) NOT NULL,
	complemento VARCHAR(20),
	referencia VARCHAR(100),
	FOREIGN KEY (id_Endereco) REFERENCES Tbl_Endereco(id),
	FOREIGN KEY (id_Fornecedor) REFERENCES TBL_Fornecedor(id)
);
 
CREATE TABLE Tbl_Cliente_Endereco
(
	id INT PRIMARY KEY AUTO_INCREMENT,
	id_Endereco INT NOT NULL,
	id_Cliente INT NOT NULL,
	numero VARCHAR(5) NOT NULL,
	complemento VARCHAR(20),
	referencia VARCHAR(100),
	FOREIGN KEY (id_Endereco) REFERENCES Tbl_Endereco(id),
	FOREIGN KEY (id_Cliente) REFERENCES TBL_Cliente(id)
);

-- TABELAS Produto, Compra, Lote, Estoque, ProdutoVenda, Venda, Forma de Pagamento

CREATE TABLE Tbl_Produto
(
	id INT PRIMARY KEY AUTO_INCREMENT,
	nome VARCHAR(100) NOT NULL,
	descricao VARCHAR(255) NOT NULL,
	preco DECIMAL(7,2) NOT NULL,
	tarja VARCHAR(20) NOT NULL
);

CREATE TABLE Tbl_Compra
(
	id INT PRIMARY KEY AUTO_INCREMENT,
	id_Fornecedor INT NOT NULL,
	data_Compra DATE NOT NULL,
	total_Compra DECIMAL (10,2),
	FOREIGN KEY (id_Fornecedor) REFERENCES Tbl_Fornecedor(id)
);

CREATE TABLE Tbl_Produto_Compra
(
	id INT PRIMARY KEY AUTO_INCREMENT,
	id_Produto INT NOT NULL,
	id_Compra INT NOT NULL,
	qnt INT NOT NULL,
	valor_Unitario DECIMAL (8,2) NOT NULL,
	FOREIGN KEY (id_Produto) REFERENCES Tbl_Produto(id),
	FOREIGN KEY (id_Compra) REFERENCES Tbl_Compra(id)
);

CREATE TABLE Tbl_Lote
(
	id INT PRIMARY KEY AUTO_INCREMENT,
	id_Produto_Compra INT NOT NULL,
	cod VARCHAR(10) NOT NULL,
	qnt INT NOT NULL,
	validade DATE NOT NULL,
	FOREIGN KEY (id_Produto_Compra) REFERENCES Tbl_Produto_Compra(id)
);

CREATE TABLE Tbl_Estoque
(
	id INT PRIMARY KEY AUTO_INCREMENT,
	id_Lote INT NOT NULL,
	posicao VARCHAR(30) NOT NULL,
	FOREIGN KEY (id_Lote) REFERENCES TBL_Lote(id)
);

CREATE TABLE Tbl_Venda
(
	id INT PRIMARY KEY AUTO_INCREMENT,
	id_Cliente INT NOT NULL,
	id_Funcionario INT NOT NULL,
	nfe VARCHAR(100) NOT NULL,
	valor DECIMAL(8,2) NOT NULL,
	data_Venda DATETIME NOT NULL,
	canal_Venda VARCHAR(20) NOT NULL,
	FOREIGN KEY (id_Cliente) REFERENCES Tbl_Cliente(id),
	FOREIGN KEY (id_Funcionario) REFERENCES Tbl_Funcionario(id)
);

CREATE TABLE Tbl_Pagamento_Venda
(
	id INT PRIMARY KEY AUTO_INCREMENT,
	id_Venda INT NOT NULL,
	forma_Pagamento VARCHAR(9) NOT NULL,
	valor_Pago DECIMAL (10,2) NOT NULL,-- Quanto essa forma de pagamento supriu do valor da venda
	valor_Recebido DECIMAL(10,2), -- Só preenchido quando 'forma_Pagamento' = 'dinheiro'
	troco DECIMAL(10,2), -- troco = valor_Recebido - valor_Pago, só calculado quando valor_Recebido não é nulo
	situacao VARCHAR(8) NOT NULL,
	FOREIGN KEY (id_Venda) REFERENCES Tbl_Venda(id)
);

CREATE TABLE Tbl_Produto_Venda
(
	id INT PRIMARY KEY AUTO_INCREMENT,
	id_Venda INT NOT NULL,
	id_Produto INT NOT NULL,
	qnt INT NOT NULL,
	valor_Unitario DECIMAL(8,2) NOT NULL,
	FOREIGN KEY (id_Venda) REFERENCES Tbl_Venda (id),
	FOREIGN KEY (id_Produto) REFERENCES Tbl_Produto (id)
);

-- ================================= TYPES =================================

/* Tabelas temporárias que criamos para usar nas procedures, são utilizadas para quando temos um processo variável,
ou seja, um cliente que pode comprar vários produtos, e não algo fixo, onde o cliente só pode colocar um cpf, por
exemplo */

CREATE TYPE Tbl_Type_ProdutoCompra AS TABLE
(
	id_Produto INT NOT NULL,
	qnt INT NOT NULL,
	valor_Unitario DECIMAL(8,2) NOT NULL,
	cod VARCHAR(10),
	validade DATE,
	posicao VARCHAR(30)
);
GO

CREATE TYPE Tbl_Type_ProdutoVenda AS TABLE
(
	id_Produto INT NOT NULL,
	qnt INT NOT NULL,
	valor_Unitario DECIMAL(8,2) NOT NULL
)

-- ================================= TESTANDO PROCEDURES =================================

-- === AddFornecedor ==
EXEC sp_AddFornecedor 'Andre', 1231231223452, 'andre@gmail.com', 11992180909

SELECT * FROM Tbl_Fornecedor
SELECT * FROM Tbl_Telefone_Fornecedor

-- == AddFuncionario ==
EXEC sp_AddFuncionario 'Paulo', 12312312234, 'paulo@gmail.com', 11992180909, '09/11/21', 88877765456789, '07/06/24', 'gerente', 'Ativo'

SELECT * FROM Tbl_Usuario
SELECT * FROM Tbl_Telefone_Usuario
SELECT * FROM Tbl_Funcionario

-- == ReporEstoque ==

-- Para repor o estoque tenho que 
DECLARE @itens Tbl_Type_ProdutoCompra;

INSERT INTO @itens (id_Produto, qnt, valor_Unitario, cod, validade, posicao)
VALUES 
	(1, 100, 5.50, 'L004', '2027-01-15', 'A1-P5')

EXEC sp_ReporEstoque 
	@id_Fornecedor = 1,
	@total_Compra = 1195.00,
	@itens = @itens;

SELECT * FROM Tbl_Compra ORDER BY id DESC;
SELECT * FROM Tbl_Produto_Compra ORDER BY id DESC;
SELECT * FROM Tbl_Lote ORDER BY id DESC;
SELECT * FROM Tbl_Estoque ORDER BY id DESC;

-- == AddCliente ==

CALL sp_AddCliente ('Otávio', '99999999999', 'otavio.augusto@gmail.com', 'Ota_01', '02/10/2006', '11992181212', 'true');

SELECT * FROM Tbl_Cliente;
SELECT * FROM Tbl_Usuario;
SELECT * FROM Tbl_Telefone_Usuario;

-- == realizarVenda ==

-- Confirme que já existe fornecedor/produto/cliente/funcionário cadastrados antes de testar
SELECT * FROM Tbl_Produto;
SELECT * FROM Tbl_Cliente;
SELECT * FROM Tbl_Funcionario;

-- ===== TESTE 1: venda com 2 produtos, pagamento em dinheiro com troco =====
DECLARE @itens Tbl_Type_ProdutoVenda;

INSERT INTO @itens (id_Produto, qnt, valor_Unitario)
VALUES 
	(1, 2, 12.50)

-- É necessário criar a procedure de criar cliente, produto e funcionario
CALL sp_realizarVenda 
(
	1,
	3,
	'NFE-0001',
	'presencial',
	@itens,
	'dinheiro',
	50.90,
	60.00,
	'pago'
);

-- Confere os resultados
SELECT * FROM Tbl_Venda ORDER BY id DESC;
SELECT * FROM Tbl_Produto_Venda ORDER BY id DESC;
SELECT * FROM Tbl_Pagamento_Venda ORDER BY id DESC;
GO

-- ===== TESTE 2: pagamento no cartão (sem troco) =====
DECLARE @itens2 Tbl_Type_ProdutoVenda;

INSERT INTO @itens2 (id_Produto, qnt, valor_Unitario)
VALUES (1, 1, 12.50);

EXEC sp_realizarVenda
	@id_Cliente = 1,
	@id_Funcionario = 4,
	@nfe = 'NFE-0002',
	@canal_Venda = 'presencial',
	@itens = @itens2,
	@forma_Pagamento = 'cartao',
	@valor_Pago = 12.50,
	@valor_Recebido = NULL,
	@situacao = 'pago';

SELECT * FROM Tbl_Venda ORDER BY id DESC;
SELECT * FROM Tbl_Pagamento_Venda ORDER BY id DESC;
GO

-- ===== TESTE 3: erro proposital  valor recebido menor que o valor pago =====
DECLARE @itens3 Tbl_Type_ProdutoVenda;
INSERT INTO @itens3 (id_Produto, qnt, valor_Unitario) VALUES (1, 1, 12.50);

EXEC sp_realizarVenda
	@id_Cliente = 1,
	@id_Funcionario = 4,
	@nfe = 'NFE-0003',
	@canal_Venda = 'presencial',
	@itens = @itens3,
	@forma_Pagamento = 'dinheiro',
	@valor_Pago = 12.50,
	@valor_Recebido = 10.00,   -- menor que o valor pago, deve dar erro
	@situacao = 'pago';

-- Confirma que NADA foi gravado dessa tentativa (nem a venda, nem o produto_venda)

SELECT * FROM Tbl_Produto
SELECT * FROM Tbl_Lote

-- == ViewVendas ==

EXEC sp_ViewVendas

-- == ViewContaCliente ==

EXEC sp_ViewContaCliente 1

-- == ViewCliente

EXEC sp_ViewCliente 1