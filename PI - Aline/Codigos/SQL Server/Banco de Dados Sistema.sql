-- ================================= BANCO DE DADOS =================================
CREATE DATABASE dbSannus;
GO;

USE dbSannus;
GO;

-- ================================= TABELAS =================================

-- TABELAS Fornecedor, Telefone

CREATE TABLE Tbl_Fornecedor 
(
	id INT PRIMARY KEY IDENTITY,
	nome VARCHAR(255) NOT NULL,
	cnpj CHAR(14) NOT NULL,
	email VARCHAR(255) NOT NULL
);
GO;

CREATE TABLE Tbl_Telefone
(
	id INT PRIMARY KEY IDENTITY,
	id_Fornecedor INT NOT NULL,
	telefone VARCHAR(14)
	FOREIGN KEY (id_Fornecedor) REFERENCES Tbl_Fornecedor(id)
);
GO;

-- TABELAS Usuario, Cliente e Funcionario

CREATE TABLE Tbl_Usuario 
(
	id INT PRIMARY KEY IDENTITY,
	nome VARCHAR(255) NOT NULL,
	cpf CHAR(11) NOT NULL,
	email VARCHAR(255) NOT NULL,
	senha VARCHAR(25) NOT NULL,
	data_Nasc DATE NOT NULL,
	telefone VARCHAR(14) NOT NULL
);
GO;

CREATE TABLE Tbl_Cliente 
(
	id INT PRIMARY KEY IDENTITY,
	id_Usuario INT NOT NULL,
	aceita_Ofertas BIT
	FOREIGN KEY (id_Usuario) REFERENCES Tbl_Usuario(id)
);
GO;

CREATE TABLE Tbl_Funcionario 
(
	id INT PRIMARY KEY IDENTITY,
	id_Usuario INT NOT NULL,
	data_Admissao DATE NOT NULL,
	cargo VARCHAR(50) NOT NULL,
	situacao VARCHAR(20) NOT NULL
	FOREIGN KEY (id_Usuario) REFERENCES Tbl_Usuario(id)
);
GO;

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
GO;

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
GO;

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
GO;

-- TABELAS Produto, Compra, Lote, Estoque, ProdutoVenda, Venda, Forma de Pagamento

CREATE TABLE Tbl_Produto
(
	id INT PRIMARY KEY IDENTITY,
	nome VARCHAR(100) NOT NULL,
	descricao VARCHAR(255) NOT NULL,
	preco DECIMAL(7,2) NOT NULL,
	tarja VARCHAR(20) NOT NULL
);
GO;

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
GO;

CREATE TABLE Tbl_Lote
(
	id INT PRIMARY KEY IDENTITY,
	id_Produto INT NOT NULL,
	cod VARCHAR(10) NOT NULL,
	qnt INT NOT NULL,
	validade DATE NOT NULL
	FOREIGN KEY (id_Produto) REFERENCES Tbl_Produto(id)
);
GO;

CREATE TABLE Tbl_Estoque
(
	id INT PRIMARY KEY IDENTITY,
	id_Lote INT NOT NULL,
	posicao VARCHAR(30) NOT NULL
	FOREIGN KEY (id_Lote) REFERENCES TBL_Lote(id)
);
GO;

CREATE TABLE Tbl_Forma_Pagamento
(
	id INT PRIMARY KEY IDENTITY,
	id_Cliente INT NOT NULL,
	nome_Cartao VARCHAR(100) NOT NULL,
	cpf_Cartao CHAR(11) NOT NULL,
	tipo VARCHAR(10) NOT NULL,
	numero VARCHAR(19) NOT NULL,
	validade DATE NOT NULL,
	cvv VARCHAR (4) NOT NULL
	FOREIGN KEY (id_Cliente) REFERENCES Tbl_Cliente(id)
);
GO;

CREATE TABLE Tbl_Venda
(
	id INT PRIMARY KEY IDENTITY,
	id_Cliente INT NOT NULL,
	id_Forma_Pagamento INT NOT NULL,
	nfe VARCHAR(100),
	valor DECIMAL(8,2),
	data_Venda DATETIME,
	forma_Pagamento VARCHAR(10),
	canal_Venda VARCHAR(20)
	FOREIGN KEY (id_Cliente) REFERENCES Tbl_Cliente(id),
	FOREIGN KEY (id_Forma_Pagamento) REFERENCES Tbl_Forma_Pagamento(id)
);
GO;

CREATE TABLE Tbl_Produto_Venda
(
	id INT PRIMARY KEY IDENTITY,
	id_Venda INT NOT NULL,
	id_Produto INT NOT NULL,
	qnt INT NOT NULL
	FOREIGN KEY (id_Venda) REFERENCES Tbl_Venda (id),
	FOREIGN KEY (id_Produto) REFERENCES Tbl_Produto (id)
);
GO;

-- ================================= USUÁRIOS e LOGINS =================================

