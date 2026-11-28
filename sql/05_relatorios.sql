-- ENTREGAFACIL - TRABALHO FINAL DE BANCO DE DADOS
-- 05_relatorios.sql | Esquema academico
-- Executar apos a criacao e o povoamento das tabelas.
-- Consultas originais 43 a 52; somente leitura.

-- 43 - Relatorio 01: Quantas encomendas existem em cada status?
-- Agrupa e contabiliza as encomendas por status.
SELECT
    status,
    COUNT(*) AS quantidade
FROM academico.encomendas
GROUP BY status
ORDER BY quantidade DESC;

-- 44 - Relatorio 02: Quais os 20 usuarios com mais encomendas?
-- Relaciona usuarios e encomendas e calcula o total por usuario.
SELECT
    u.nome AS usuario,
    u.email,
    COUNT(e.codigo) AS total_encomendas
FROM academico.usuarios u
INNER JOIN academico.encomendas e
    ON u.id = e.usuario_id
GROUP BY u.id, u.nome, u.email
ORDER BY total_encomendas DESC, u.nome ASC
LIMIT 20;

-- 45 - Relatorio 03: Quais encomendas estao em transporte e quem as transporta?
-- Filtra encomendas em transporte e identifica entregadores e veiculos.
SELECT
    e.codigo AS codigo_encomenda,
    e.status,
    u.nome AS entregador,
    en.veiculo,
    en.placa
FROM academico.encomendas e
INNER JOIN academico.entregadores en
    ON e.entregador_id = en.id
INNER JOIN academico.usuarios u
    ON en.id = u.id
WHERE e.status = 'em_transporte'
ORDER BY e.codigo ASC
LIMIT 20;

-- 46 - Relatorio 04: Quais cidades recebem mais encomendas?
-- Considera apenas enderecos de destino e agrupa por cidade e estado.
SELECT
    en.cidade AS cidade_destino,
    en.estado,
    COUNT(e.codigo) AS total_encomendas
FROM academico.encomendas e
INNER JOIN academico.enderecos en
    ON e.codigo = en.encomenda_codigo
WHERE en.tipo = 'destino'
GROUP BY en.cidade, en.estado
ORDER BY total_encomendas DESC, cidade_destino ASC;

-- 47 - Relatorio 05: Quais tipos de veiculo concentram mais encomendas?
-- Calcula a quantidade de encomendas associadas a cada tipo de veiculo.
SELECT
    en.veiculo,
    COUNT(e.codigo) AS total_encomendas
FROM academico.entregadores en
INNER JOIN academico.encomendas e
    ON en.id = e.entregador_id
GROUP BY en.veiculo
ORDER BY total_encomendas DESC;

-- 48 - Relatorio 06: Quais sao as 20 rotas mais extensas?
-- Filtra distancias positivas e ordena da maior para a menor.
SELECT
    id AS codigo_rota,
    nome AS nome_rota,
    data,
    distancia_km
FROM academico.rotas
WHERE distancia_km > 0
ORDER BY distancia_km DESC
LIMIT 20;

-- 49 - Relatorio 07: Quais os 20 entregadores com mais rotas associadas?
-- Demonstra o relacionamento N:N por meio da tabela associativa.
SELECT
    u.nome AS entregador,
    en.veiculo,
    COUNT(er.rota_id) AS total_rotas
FROM academico.entregadores en
INNER JOIN academico.usuarios u
    ON en.id = u.id
INNER JOIN academico.entregadores_rotas er
    ON en.id = er.entregador_id
GROUP BY u.id, u.nome, en.veiculo
ORDER BY total_rotas DESC, u.nome ASC
LIMIT 20;

-- 50 - Relatorio 08: Quais as 20 encomendas com mais registros de historico?
-- Contabiliza as movimentacoes registradas por encomenda.
SELECT
    e.codigo AS codigo_encomenda,
    e.status AS status_atual,
    COUNT(h.id) AS total_movimentacoes
FROM academico.encomendas e
INNER JOIN academico.historico h
    ON e.codigo = h.encomenda_codigo
GROUP BY e.codigo, e.status
ORDER BY total_movimentacoes DESC,
         e.codigo ASC
LIMIT 20;

-- 51 - Relatorio 09: Quais os 20 usuarios com mais telefones cadastrados?
-- Demonstra a implementacao do atributo multivalorado telefone.
SELECT
    u.nome AS usuario,
    u.email,
    COUNT(t.id) AS total_telefones
FROM academico.usuarios u
INNER JOIN academico.telefones_usuarios t
    ON u.id = t.usuario_id
GROUP BY u.id, u.nome, u.email
ORDER BY total_telefones DESC, u.nome ASC
LIMIT 20;

-- 52 - Relatorio 10: Quais encomendas foram entregues e quais seus destinos?
-- Filtra entregas concluidas e enderecos de destino; exibe ate 20 registros.
SELECT
    e.codigo AS codigo_encomenda,
    u.nome AS usuario,
    e.status,
    en.cidade AS cidade_destino,
    en.estado AS estado_destino
FROM academico.encomendas e
INNER JOIN academico.usuarios u
    ON e.usuario_id = u.id
INNER JOIN academico.enderecos en
    ON e.codigo = en.encomenda_codigo
WHERE e.status = 'entregue'
  AND en.tipo = 'destino'
ORDER BY e.codigo ASC
LIMIT 20;
