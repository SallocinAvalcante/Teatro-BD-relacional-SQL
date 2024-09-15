create database teatro;

USE teatro;

Create table pecas_teatro(
id_peca int auto_increment primary key,
nome_peca varchar (45) not null,
descricao varchar (45) not null);

Create table exibicao(
id_exibicao int auto_increment primary key,
id_peca int not null,
duracao int not null,
data_hora date not null,
foreign key (id_peca) References pecas_teatro(id_peca)
);

insert into pecas_teatro values (3,'fantasma da opera', 'fantasma maluco');

select * from pecas_teatro;

INSERT INTO exibicao (id_peca, duracao, data_hora) VALUES (1, 120, '2024-09-15');

select * from exibicao;
 
 DELIMITER $$
CREATE FUNCTION calcular_media_duracao(id_peca INT) RETURNS FLOAT
BEGIN
    DECLARE media_duracao FLOAT;
	
    SELECT AVG(duracao) INTO media_duracao
	FROM exibicao
	WHERE id_peca = id_peca;
    
	RETURN media_duracao;
END $$
DELIMITER ;


SELECT  calcular_media_duracao(1);

DELIMITER $$

CREATE FUNCTION verificar_disponibilidade(data_hora DATE)
RETURNS BOOLEAN
BEGIN
    DECLARE disponibilidade int;
    
    SELECT COUNT(*) INTO disponibilidade
    FROM exibicao
    WHERE data_hora = data_hora;
    
    IF disponibilidade > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END $$
DELIMITER  ;


/*DELIMITER //

CREATE FUNCTION verificar_disponibilidade(data_hora DATETIME)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE disponibilidade INT;

    SELECT COUNT(*) INTO disponibilidade
    FROM exibicao
    WHERE data_hora = data_hora;
 if disponibilidade > 0 then
    return true;
   
else 
    Return false;
end if;
END //

DELIMITER ;*/


DELIMITER $$

CREATE PROCEDURE agendar_peca(
     nome_peca VARCHAR(45),
     descricao VARCHAR(45),
    data_hora DATE,
	duracao INT
)
BEGIN
    DECLARE id_peca INT;
    DECLARE media_duracao FLOAT;

    -- Verificar disponibilidade
    IF verificar_disponibilidade(data_hora) > 0 then
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Já existe uma exibição agendada para esta data e hora.';
    ELSE
        -- Inserir nova peça na tabela pecas_teatro
        INSERT INTO pecas_teatro (nome_peca, descricao)
        VALUES (nome_peca, descricao);

        -- Obter o id da nova peça inserida
        SET id_peca = LAST_INSERT_ID();

        -- Inserir nova exibição na tabela exibicao
        INSERT INTO exibicao (id_peca, duracao, data_hora)
        VALUES (id_peca, duracao, data_hora);

        -- Calcular a média de duração
        SET media_duracao = calcular_media_duracao(id_peca);

        -- Imprimir informações sobre a peça agendada
        SELECT 
            nome_peca,
            descricao,
            data_hora AS data_hora_exibicao,
            duracao,
            media_duracao AS media_duracao
        FROM pecas_teatro
        JOIN exibicao ON pecas_teatro.id_peca = exibicao.id_peca
        WHERE pecas_teatro.id_peca = id_peca;
    END IF;
END $$

DELIMITER ;

CALL agendar_peca('Romeu e Julieta', 'Uma tragédia romântica de William Shakespeare.', '2024-09-15', 130);

CALL agendar_peca('teste', 'amostradinho', '2024-09-15', 40);

SELECT verificar_disponibilidade('2024-09-15');

CALL agendar_peca('ahh', 'grito', '2023-11-01', 50);
CALL agendar_peca('dsadas', 'sdaasda', '2025-09-04', 50);

