CREATE TABLE leitores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE livros (
    id SERIAL PRIMARY KEY,
    categoria_id INT REFERENCES categorias(id),
    titulo VARCHAR(150) NOT NULL,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    taxa_diaria DECIMAL(10,2) CHECK (taxa_diaria > 0) NOT NULL,
    disponivel BOOLEAN DEFAULT TRUE
);

CREATE TABLE emprestimos (
    id SERIAL PRIMARY KEY,
    leitor_id INT REFERENCES leitores(id),
    data_emprestimo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Ativo' CHECK (status IN ('Ativo', 'Devolvido', 'Atrasado'))
);

CREATE TABLE itens_emprestimo (
    id SERIAL PRIMARY KEY,
    emprestimo_id INT REFERENCES emprestimos(id),
    livro_id INT REFERENCES livros(id),
    quantidade INT CHECK (quantidade > 0) NOT NULL,
    valor_diaria DECIMAL(10,2) CHECK (valor_diaria >= 0) NOT NULL
);

INSERT INTO categorias (nome) VALUES ('Ficção'), ('História'), ('Tecnologia');

INSERT INTO livros (categoria_id, titulo, isbn, taxa_diaria, disponivel) VALUES 
(2, 'Duna', '9788580575392', 8.50, TRUE),
(1, 'O Hobbit', '9788595084742', 5.00, TRUE),
(3, 'Código Limpo', '9788576082675', 9.00, TRUE);

INSERT INTO leitores (nome, email, cpf, telefone) VALUES 
('Manuela Martins', 'manueelalegal@email.com', '44455566677', '21988881111'),
('Nicolas', 'nicolas@email.com', '55566677788', '21977772222'),
('Rafael Oliveira', 'rafaelemail.com', '66677788899', '21966663333');

INSERT INTO emprestimos (leitor_id, status) VALUES 
(1, 'Ativo'), 
(2, 'Devolvido'), 
(2, 'Ativo'), 
(3, 'Atrasado');

INSERT INTO itens_emprestimo (emprestimo_id, livro_id, quantidade, valor_diaria) VALUES 
(1, 1, 1, 8.50),
(2, 3, 1, 9.00),
(3, 2, 2, 5.00),
(4, 1, 1, 8.50);

CREATE VIEW vw_relacao1 AS
SELECT 
    livros.titulo AS livro, 
    livros.isbn, 
    categorias.nome AS categoria, 
    livros.taxa_diaria
FROM livros
JOIN categorias ON livros.categoria_id = categorias.id;

CREATE VIEW vw_relacao2 AS
SELECT 
    emprestimos.id AS emprestimo_id, 
    emprestimos.data_emprestimo, 
    livros.titulo AS livro, 
    itens_emprestimo.quantidade, 
    emprestimos.status
FROM emprestimos
JOIN leitores ON emprestimos.leitor_id = leitores.id
JOIN itens_emprestimo ON emprestimos.id = itens_emprestimo.emprestimo_id
JOIN livros ON itens_emprestimo.livro_id = livros.id
WHERE leitores.nome = 'Carlos Silva';

CREATE VIEW vw_relacao3 AS
SELECT 
    emprestimos.id AS emprestimo_id, 
    leitores.nome AS leitor, 
    SUM(itens_emprestimo.quantidade * itens_emprestimo.valor_diaria) AS valor_total
FROM emprestimos
JOIN leitores ON emprestimos.leitor_id = leitores.id
JOIN itens_emprestimo ON emprestimos.id = itens_emprestimo.emprestimo_id
GROUP BY emprestimos.id, leitores.nome;

CREATE VIEW vw_relacao4 AS
SELECT 
    livros.*
FROM livros
JOIN categorias ON livros.categoria_id = categorias.id
WHERE categorias.nome = 'Ficção' 
  AND livros.taxa_diaria > 5.00 
  AND livros.disponivel = TRUE;

CREATE VIEW vw_relacao5 AS
SELECT 
    categorias.nome AS categoria, 
    SUM(itens_emprestimo.quantidade * itens_emprestimo.valor_diaria) AS faturamento_total
FROM itens_emprestimo
JOIN emprestimos ON itens_emprestimo.emprestimo_id = emprestimos.id
JOIN livros ON itens_emprestimo.livro_id = livros.id
JOIN categorias ON livros.categoria_id = categorias.id
WHERE emprestimos.status = 'Devolvido'
GROUP BY categorias.nome;