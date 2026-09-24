CREATE TABLE alunos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE planos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL,
    valor_mensal_base DECIMAL(10,2) CHECK (valor_mensal_base > 0) NOT NULL
);

CREATE TABLE modalidades (
    id SERIAL PRIMARY KEY,
    plano_id INT REFERENCES planos(id),
    nome VARCHAR(100) NOT NULL,
    sala VARCHAR(20) NOT NULL,
    capacidade_maxima INT CHECK (capacidade_maxima > 0) NOT NULL,
    disponivel BOOLEAN DEFAULT TRUE
);

CREATE TABLE matriculas (
    id SERIAL PRIMARY KEY,
    aluno_id INT REFERENCES alunos(id),
    data_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Ativa' CHECK (status IN ('Ativa', 'Cancelada', 'Trancada'))
);

CREATE TABLE itens_matricula (
    id SERIAL PRIMARY KEY,
    matricula_id INT REFERENCES matriculas(id),
    modalidade_id INT REFERENCES modalidades(id),
    duracao_meses INT CHECK (duracao_meses > 0) NOT NULL,
    valor_mensal_aplicado DECIMAL(10,2) CHECK (valor_mensal_aplicado > 0) NOT NULL,
    taxa_adesao DECIMAL(10,2) CHECK (taxa_adesao >= 0) DEFAULT 0.00
);

INSERT INTO planos (nome, valor_mensal_base) VALUES 
('VIP Premium', 220.00), 
('Fitness Standard', 140.00), 
('Basic Fit', 90.00);

INSERT INTO modalidades (plano_id, nome, sala, capacidade_maxima, disponivel) VALUES 
(1, 'Crossfit Pro', 'Arena 01', 15, TRUE),
(2, 'Pilates Avançado', 'Studio 02', 10, TRUE),
(3, 'Musculação Livre', 'Salão Principal', 50, TRUE);

INSERT INTO alunos (nome, email, cpf, telefone) VALUES 
('Carlos Silva', 'carlos@email.com', '11122233344', '11999990000'),
('Ana Lima', 'ana@email.com', '22233344455', '11988880000'),
('Beatriz Costa', 'bea@email.com', '33344455566', '11977770000');

INSERT INTO matriculas (aluno_id, status) VALUES 
(1, 'Ativa'), 
(1, 'Ativa'), 
(2, 'Ativa'), 
(3, 'Cancelada');

INSERT INTO itens_matricula (matricula_id, modalidade_id, duracao_meses, valor_mensal_aplicado, taxa_adesao) VALUES 
(1, 1, 6, 220.00, 50.00),
(2, 2, 3, 140.00, 30.00),
(3, 3, 12, 90.00, 0.00),
(4, 1, 1, 220.00, 50.00);

CREATE VIEW vw_relacao1 AS
SELECT 
    modalidades.nome AS modalidade,
    modalidades.sala,
    planos.nome AS plano,
    planos.valor_mensal * 1.10 AS valor_mensal_ajustado
FROM modalidades 
JOIN planos ON modalidades.plano_id = planos.id;

CREATE VIEW vw_relacao2 AS
SELECT 
    alunos.nome AS aluno,
    alunos.cpf,
    modalidades.nome AS modalidade,
    modalidades.sala,
    matriculas.duracao_meses,
    matriculas.data_inicio
FROM matriculas 
JOIN alunos ON matriculas.aluno_id = alunos.id
JOIN itens_matricula ON matriculas.id = itens_matricula.matricula_id
JOIN modalidades ON itens_matricula.modalidade_id = modalidades.id
WHERE matriculas.status = 'Ativa';

CREATE VIEW vw_relacao3 AS
SELECT 
    alunos.nome AS aluno, 
    COUNT(matriculas.id) AS total_matriculas, 
    SUM((itens_matricula.valor_mensal_aplicado * itens_matricula.duracao_meses) + itens_matricula.taxa_adesao) AS total_investido
FROM alunos
JOIN matriculas ON alunos.id = matriculas.aluno_id
JOIN itens_matricula ON matriculas.id = itens_matricula.matricula_id
WHERE matriculas.status = 'Ativa'
GROUP BY alunos.id, alunos.nome
HAVING SUM((itens_matricula.valor_mensal_aplicado * itens_matricula.duracao_meses) + itens_matricula.taxa_adesao) > 1000.00;

CREATE VIEW vw_relacao4 AS
SELECT 
    modalidades.*, 
    planos.nome AS plano, 
    planos.valor_mensal_base
FROM modalidades
JOIN planos ON modalidades.plano_id = planos.id
WHERE modalidades.capacidade_maxima >= 15 
  AND planos.valor_mensal_base > 100.00 
  AND modalidades.disponivel = TRUE;

CREATE VIEW vw_relacao5 AS
SELECT 
    planos.nome AS plano, 
    SUM((itens_matricula.valor_mensal_aplicado * itens_matricula.duracao_meses) + itens_matricula.taxa_adesao) AS faturamento_total,
    ROUND(AVG(itens_matricula.duracao_meses), 1) AS media_meses_contratados
FROM itens_matricula
JOIN matriculas ON itens_matricula.matricula_id = matriculas.id
JOIN modalidades ON itens_matricula.modalidade_id = modalidades.id
JOIN planos ON modalidades.plano_id = planos.id
WHERE matriculas.status = 'Ativa'
GROUP BY planos.nome;
