CREATE TABLE pacientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    data_nascimento DATE NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE especialidades (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE medicos (
    id SERIAL PRIMARY KEY,
    especialidade_id INT NOT NULL REFERENCES especialidades(id) ON DELETE RESTRICT,
    nome VARCHAR(100) NOT NULL,
    crm VARCHAR(20) UNIQUE NOT NULL,
    valor_consulta NUMERIC(10, 2) NOT NULL CHECK (valor_consulta > 0)
);

CREATE TABLE consultas (
    id SERIAL PRIMARY KEY,
    medico_id INT NOT NULL REFERENCES medicos(id) ON DELETE RESTRICT,
    paciente_id INT NOT NULL REFERENCES pacientes(id) ON DELETE CASCADE,
    data_hora TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'Agendada' CHECK (status IN ('Agendada', 'Realizada', 'Cancelada'))
);

CREATE TABLE exames_consulta (
    id SERIAL PRIMARY KEY,
    consulta_id INT NOT NULL REFERENCES consultas(id) ON DELETE CASCADE,
    nome_exame VARCHAR(100) NOT NULL,
    valor_exame NUMERIC(10, 2) NOT NULL CHECK (valor_exame >= 0)
);

INSERT INTO especialidades (nome) VALUES 
('Cardiologia'),
('Pediatria'),
('Dermatologia');

INSERT INTO medicos (especialidade_id, nome, crm, valor_consulta) VALUES 
(1, 'Dra. Carla Mendes', 'CRM/SP 123456', 350.00),
(2, 'Dr. Roberto Alves', 'CRM/SP 654321', 250.00),
(3, 'Dra. Juliana Lima', 'CRM/SP 789123', 300.00);

INSERT INTO pacientes (nome, email, cpf, data_nascimento) VALUES 
('Nicolas Marques', 'Nicolas@email.com', '11122233344', '1985-05-12'),
('Lucca Matheus', 'Luccaa@email.com', '55566677788', '2010-08-25'),
('Guilherme Ribeiro', 'Guilherme@email.com', '99900011122', '1998-11-03');

INSERT INTO consultas (medico_id, paciente_id, data_hora, status) VALUES 
(1, 1, '2026-03-10 09:00:00', 'Realizada'),
(1, 3, '2026-03-10 10:30:00', 'Realizada'),
(2, 2, '2026-03-11 14:00:00', 'Realizada'),
(3, 1, '2026-03-12 11:00:00', 'Agendada');

INSERT INTO exames_consulta (consulta_id, nome_exame, valor_exame) VALUES 
(1, 'Eletrocardiograma', 120.00),
(1, 'Ecocardiograma', 250.00),
(2, 'Hemograma Completo', 45.00),
(3, 'Exame de Urina', 30.00);

CREATE VIEW vw_relacao1 AS
SELECT 
    c.id AS consulta_id,
    c.data_hora,
    m.nome AS medico,
    e.nome AS especialidade,
    c.status
FROM consultas c
JOIN pacientes p ON c.paciente_id = p.id
JOIN medicos m ON c.medico_id = m.id
JOIN especialidades e ON m.especialidade_id = e.id
WHERE p.nome = 'Carlos Silva';

CREATE VIEW vw_relacao2 AS
SELECT 
    c.id AS consulta_id,
    p.nome AS paciente,
    m.nome AS medico,
    m.valor_consulta,
    COALESCE(SUM(ex.valor_exame), 0) AS total_exames,
    m.valor_consulta + COALESCE(SUM(ex.valor_exame), 0) AS valor_total_atendimento
FROM consultas c
JOIN pacientes p ON c.paciente_id = p.id
JOIN medicos m ON c.medico_id = m.id
LEFT JOIN exames_consulta ex ON c.id = ex.consulta_id
GROUP BY c.id, p.nome, m.nome, m.valor_consulta;

CREATE VIEW vw_relacao3 AS
SELECT 
    m.nome AS medico,
    m.crm,
    e.nome AS especialidade,
    m.valor_consulta
FROM medicos m
JOIN especialidades e ON m.especialidade_id = e.id
WHERE m.valor_consulta > 300.00;

CREATE VIEW vw_relacao4 AS
SELECT 
    e.nome AS especialidade,
    COUNT(c.id) AS quantidade_consultas,
    COALESCE(SUM(m.valor_consulta), 0) AS faturamento_consultas
FROM especialidades e
JOIN medicos m ON e.id = m.especialidade_id
LEFT JOIN consultas c ON m.id = c.medico_id AND c.status = 'Realizada'
GROUP BY e.id, e.nome;

-- Consultas do Sistema de Oficina / Veículos

CREATE VIEW vw_relacao5 AS
SELECT 
    veiculos.modelo, 
    veiculos.marca,
    veiculos.placa,
    clientes.nome,
    clientes.telefone 
FROM veiculos 
JOIN clientes ON veiculos.cliente_id = clientes.id;

CREATE VIEW vw_relacao6 AS
SELECT 
    ordens_servico.id,
    ordens_servico.status,
    ordens_servico.data_abertura,
    veiculos.placa, 
    veiculos.modelo,
    mecanicos.nome 
FROM ordens_servico 
JOIN veiculos ON ordens_servico.veiculo_id = veiculos.id 
JOIN clientes ON veiculos.cliente_id = clientes.id 
JOIN mecanicos ON ordens_servico.mecanico_id = mecanicos.id;

CREATE VIEW vw_relacao7 AS
SELECT 
    ordens_servico.id,
    ordens_servico.valor_mao_obra,
    mecanicos.nome,
    veiculos.placa
FROM ordens_servico
JOIN mecanicos ON ordens_servico.mecanico_id = mecanicos.id
JOIN veiculos ON ordens_servico.veiculo_id = veiculos.id;


--OBS: Usei a ajuda do repositorio em algumas partes