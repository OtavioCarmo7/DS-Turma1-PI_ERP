-- ================================= BANCO DE DADOS =================================
CREATE DATABASE dbSannus;

USE dbSannus;

-- ================================= TABELAS =================================

-- TABELAS Fornecedor, Telefone

CREATE TABLE Tbl_Fornecedor 
(
	id INT PRIMARY KEY IDENTITY,
	nome VARCHAR(255) NOT NULL,
	cnpj CHAR(14) NOT NULL,
	email VARCHAR(255) NOT NULL
);

CREATE TABLE Tbl_Telefone_Fornecedor
(
	id INT PRIMARY KEY IDENTITY,
	id_Fornecedor INT NOT NULL,
	telefone VARCHAR(14)
	FOREIGN KEY (id_Fornecedor) REFERENCES Tbl_Fornecedor(id)
);

-- TABELAS Usuario, Telefone_Usuario, Cliente e Funcionario

CREATE TABLE Tbl_Usuario 
(
	id INT PRIMARY KEY IDENTITY,
	nome VARCHAR(255) NOT NULL,
	cpf CHAR(11) NOT NULL,
	email VARCHAR(255) NOT NULL,
	senha VARCHAR(25) NOT NULL,
	data_Nasc DATE NOT NULL,
);

CREATE TABLE Tbl_Telefone_Usuario
(
	id INT PRIMARY KEY IDENTITY,
	id_Usuario INT NOT NULL,
	telefone CHAR(14) NOT NULL
	FOREIGN KEY (id_Usuario) REFERENCES Tbl_Usuario(id)
);

CREATE TABLE Tbl_Cliente 
(
	id INT PRIMARY KEY IDENTITY,
	id_Usuario INT NOT NULL,
	aceita_Ofertas BIT
	FOREIGN KEY (id_Usuario) REFERENCES Tbl_Usuario(id)
);

CREATE TABLE Tbl_Funcionario 
(
	id INT PRIMARY KEY IDENTITY,
	id_Usuario INT NOT NULL,
	data_Admissao DATE NOT NULL,
	cargo VARCHAR(50) NOT NULL,
	situacao VARCHAR(20) NOT NULL
	FOREIGN KEY (id_Usuario) REFERENCES Tbl_Usuario(id)
);

-- TABELAS Endereço, Fornecedor_Endereço, Cliente_Endereço

CREATE TABLE Tbl_Endereco
(
	id INT PRIMARY KEY IDENTITY,
	cep VARCHAR(9) NOT NULL,
	logradouro VARCHAR(50) NOT NULL,
	bairro VARCHAR(50) NOT NULL,
	cidade VARCHAR(100) NOT NULL,
	uf CHAR(2) NOT NULL
);

CREATE TABLE Tbl_Fornecedor_Endereco 
(
	id INT PRIMARY KEY IDENTITY,
	id_Fornecedor INT NOT NULL,
	id_Endereco INT NOT NULL,
	numero VARCHAR(5) NOT NULL,
	complemento VARCHAR(20),
	referencia VARCHAR(100)
	FOREIGN KEY (id_Endereco) REFERENCES Tbl_Endereco(id),
	FOREIGN KEY (id_Fornecedor) REFERENCES TBL_Fornecedor(id)
);

CREATE TABLE Tbl_Cliente_Endereco
(
	id INT PRIMARY KEY IDENTITY,
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
	id INT PRIMARY KEY IDENTITY,
	nome VARCHAR(100) NOT NULL,
	descricao VARCHAR(255) NOT NULL,
	preco DECIMAL(7,2) NOT NULL,
	tarja VARCHAR(20) NOT NULL
);

CREATE TABLE Tbl_Compra
(
	id INT PRIMARY KEY IDENTITY,
	id_Produto INT NOT NULL,
	id_Fornecedor INT NOT NULL,
	valor DECIMAL(8,2) NOT NULL,
	data_Compra DATE NOT NULL
	FOREIGN KEY (id_Produto) REFERENCES Tbl_Produto (id),
	FOREIGN KEY (id_Fornecedor) REFERENCES Tbl_Fornecedor(id)
);

CREATE TABLE Tbl_Lote
(
	id INT PRIMARY KEY IDENTITY,
	id_Produto INT NOT NULL,
	cod VARCHAR(10) NOT NULL,
	qnt INT NOT NULL,
	validade DATE NOT NULL
	FOREIGN KEY (id_Produto) REFERENCES Tbl_Produto(id)
);

CREATE TABLE Tbl_Estoque
(
	id INT PRIMARY KEY IDENTITY,
	id_Lote INT NOT NULL,
	posicao VARCHAR(30) NOT NULL
	FOREIGN KEY (id_Lote) REFERENCES TBL_Lote(id)
);

CREATE TABLE Tbl_Venda
(
	id INT PRIMARY KEY IDENTITY,
	id_Cliente INT NOT NULL,
	id_Funcionario INT NOT NULL,
	nfe VARCHAR(100),
	valor DECIMAL(8,2),
	data_Venda DATETIME,
	canal_Venda VARCHAR(20)
	FOREIGN KEY (id_Cliente) REFERENCES Tbl_Cliente(id),
	FOREIGN KEY (id_Funcionario) REFERENCES Tbl_Funcionario(id)
);

CREATE TABLE Tbl_Pagamento_Venda
(
	id INT PRIMARY KEY IDENTITY,
	id_Venda INT NOT NULL,
	forma_Pagamento VARCHAR(9) NOT NULL,
	situacao VARCHAR(8) NOT NULL
	FOREIGN KEY (id_Venda) REFERENCES Tbl_Venda(id)
);

CREATE TABLE Tbl_Produto_Venda
(
	id INT PRIMARY KEY IDENTITY,
	id_Venda INT NOT NULL,
	id_Produto INT NOT NULL,
	qnt INT NOT NULL
	FOREIGN KEY (id_Venda) REFERENCES Tbl_Venda (id),
	FOREIGN KEY (id_Produto) REFERENCES Tbl_Produto (id)
);

-- ================================= USUÁRIOS e LOGINS =================================

-- LOGIN
USE master;

CREATE LOGIN loginSannus
WITH PASSWORD = 'Sannus@PI',
CHECK_POLICY = OFF,
DEFAULT_DATABASE = dbSannus,
DEFAULT_LANGUAGE = Portuguese;

-- USUÁRIO
USE dbSannus;

CREATE USER userSannus FOR LOGIN loginSannus;

ALTER ROLE db_datareader ADD MEMBER userSannus;
ALTER ROLE db_datawriter  ADD MEMBER userSannus;

GRANT EXECUTE TO userSannus;