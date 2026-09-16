CREATE TABLE clientes (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(100) not null,
	email VARCHAR(100) UNIQUE not null,
	telefone VARCHAR(15) not null,
	cpf VARCHAR(11) UNIQUE not null,
	data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

CREATE TABLE mecanicos (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(100) not null,
	especialidade VARCHAR(50) not null,
	valor_hora NUMERIC(20,2) not null check (valor_hora > 0) 

);

CREATE TABLE veiculos (

	id SERIAL PRIMARY KEY,
	cliente_id INT not null,
	placa VARCHAR(7) UNIQUE not null,
	modelo VARCHAR(100) not null,
	marca VARCHAR(50) not null,
	ano INT not null check (ano > 1886),


	CONSTRAINT fk_veiculos_cliente
	FOREIGN KEY (cliente_id)
	REFERENCES clientes(id)
	ON DELETE CASCADE

); 

CREATE TABLE ordens_servico (

	id SERIAL PRIMARY KEY,
	veiculo_id INT not null,
    mecanico_id INT not null,
	data_abertura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	valor_mao_obra INT not null check (valor_mao_obra >= 0),
	status VARCHAR(20) not null DEFAULT 'Em Aberto' CHECK (status IN('Em Aberto', 'Em Andamento', 'Concluida', 'Cancelada')), 

	CONSTRAINT fk_ordensservico_veiculos
	FOREIGN KEY (veiculo_id)
	REFERENCES veiculos(id),

	CONSTRAINT fk_ordensservico_mecanicos
	FOREIGN KEY (mecanico_id)
	REFERENCES mecanicos(id)

); 

CREATE TABLE pecas_os (

	id SERIAL PRIMARY KEY,
	os_id INT not null,
	nome_peca VARCHAR(100) not null,
	quantidade INT not null check (quantidade > 0),
	valor_unitario NUMERIC(10,2) not null check (quantidade > 0),

	CONSTRAINT fk_pecasos_ordensservico
	FOREIGN KEY (os_id)
	REFERENCES ordens_servico(id)
	ON DELETE CASCADE

); 

INSERT INTO clientes (nome, email, telefone, cpf) values
('Nicolas Marques', 'nicolas.marques@gmail.com', '(48)993431267', '16670249137'),
('Ruan Carlos', 'runaitocarlos@hotmail.com', '(48)996734312', '62028990007'),
('Tulinho Maravilha', 'tuliomaravilha@gmail.com', '(48)993436712', '89731267093');

INSERT INTO mecanicos (nome, especialidade, valor_hora) values
('Davi Pedrinho', 'Motor e Câmbio', 7.37),
('Ederson Arantes', 'runaitocarlos@hotmail.com', 20.00),
('Neymar Junior', 'Elétrica e Injeção', 14.99);

INSERT INTO ordens_servico (veiculo_id, mecanico_id, valor_mao_obra, status) VALUES 
(1, 1, 350.00, 'Concluida'),
(2, 2, 180.00, 'Concluida'),
(3, 1, 500.00, 'Em Andamento'),
(4, 3, 200.00, 'Concluida');

INSERT INTO pecas_os (os_id, nome_peca, quantidade, valor_unitario) VALUES 
(1, 'Jogo de Velas Iridium', 1, 240.00),
(1, 'Óleo Sintético 5W30 (Litro)', 4, 60.00),
(2, 'Pastilha de Freio Dianteira', 1, 150.00),
(4, 'Bateria 60Ah', 1, 420.00);


Select veiculos.modelo, 
veiculos.marca,
veiculos.placa,
clientes.nome,
clientes.telefone 
from veiculos JOIN clientes on veiculos.cliente_id = clientes.id

Select ordens_servico.id,
ordens_servico.status,
ordens_servico.data_abertura,
veiculos.placa, veiculos.modelo,
mecanicos.nome 
from ordens_servico JOIN veiculos on ordens_servico.veiculo_id = veiculos.id JOIN clientes on veiculos.cliente_id = clientes.id 
JOIN mecanicos on ordens_servico.mecanico_id = mecanicos.id 

Select ordens_servico.id,
ordens_servico.valor_mao_obra,
mecanicos.nome,
veiculos.placa


