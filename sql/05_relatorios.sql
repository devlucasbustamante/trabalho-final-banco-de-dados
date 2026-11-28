
-- ============================================================
-- ENTREGA FACIL - TRABALHO FINAL DE BANCO DE DADOS
-- Arquivo: 05_relatorios.sql
-- Banco de dados: PostgreSQL / Supabase
-- Esquema: academico
-- Executar apos a criacao e o povoamento das tabelas.
-- Consultas 43 a 52 - Somente leitura.
-- ============================================================


-- 43 - Relatorio 01
-- Quantas encomendas existem em cada status?
-- Relaciona encomendas e usuarios e contabiliza por status.

SELECT
    e.status,
    COUNT(e.codigo) AS quantidade
FROM academico.encomendas e
INNER JOIN academico.usuarios u
    ON e.usuario_id = u.id
WHERE e.status IS NOT NULL
GROUP BY e.status
ORDER BY quantidade DESC;


-- 44 - Relatorio 02
-- Quais os 20 usuarios com mais encomendas?
-- Relaciona usuarios e encomendas e calcula o total por usuario.

SELECT
    u.nome AS usuario,
    u.email,
    COUNT(e.codigo) AS total_encomendas
FROM academico.usuarios u
INNER JOIN academico.encomendas e
    ON u.id = e.usuario_id
WHERE e.status IS NOT NULL
GROUP BY u.id, u.nome, u.email
ORDER BY total_encomendas DESC, u.nome ASC
LIMIT 20;


-- 45 - Relatorio 03
-- Quais encomendas estao em transporte e quem as transporta?
-- Identifica entregadores e veiculos das encomendas em transporte.

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


-- 46 - Relatorio 04
-- Quais cidades recebem mais encomendas?
-- Considera apenas enderecos de destino.

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


-- 47 - Relatorio 05
-- Quais tipos de veiculo concentram mais encomendas?
-- Contabiliza encomendas por tipo de veiculo informado.

SELECT
    en.veiculo,
    COUNT(e.codigo) AS total_encomendas
FROM academico.entregadores en
INNER JOIN academico.encomendas e
    ON en.id = e.entregador_id
WHERE en.veiculo IS NOT NULL
GROUP BY en.veiculo
ORDER BY total_encomendas DESC;


-- 48 - Relatorio 06
-- Quais sao as 20 rotas mais extensas?
-- Apresenta as distancias e a quantidade de entregadores.
-- LEFT JOIN permite incluir rotas sem entregadores associados.

SELECT
    r.id AS codigo_rota,
    r.nome AS nome_rota,
    r.data,
    r.distancia_km,
    COUNT(er.entregador_id) AS total_entregadores
FROM academico.rotas r
LEFT JOIN academico.entregadores_rotas er
    ON r.id = er.rota_id
WHERE r.distancia_km > 0
GROUP BY r.id, r.nome, r.data, r.distancia_km
ORDER BY r.distancia_km DESC, r.id ASC
LIMIT 20;


-- 49 - Relatorio 07
-- Quais os 20 entregadores ativos com mais rotas associadas?
-- Demonstra o relacionamento N:N pela tabela associativa.

SELECT
    u.nome AS entregador,
    en.veiculo,
    COUNT(er.rota_id) AS total_rotas
FROM academico.entregadores en
INNER JOIN academico.usuarios u
    ON en.id = u.id
INNER JOIN academico.entregadores_rotas er
    ON en.id = er.entregador_id
WHERE en.ativo = TRUE
GROUP BY u.id, u.nome, en.veiculo
ORDER BY total_rotas DESC, u.nome ASC
LIMIT 20;


-- 50 - Relatorio 08
-- Quais as 20 encomendas com mais movimentacoes?
-- Contabiliza registros de historico com status informado.

SELECT
    e.codigo AS codigo_encomenda,
    e.status AS status_atual,
    COUNT(h.id) AS total_movimentacoes
FROM academico.encomendas e
INNER JOIN academico.historico h
    ON e.codigo = h.encomenda_codigo
WHERE h.status IS NOT NULL
GROUP BY e.codigo, e.status
ORDER BY total_movimentacoes DESC,
         e.codigo ASC
LIMIT 20;


-- 51 - Relatorio 09
-- Quais os 20 usuarios com mais telefones cadastrados?
-- Demonstra a implementacao do atributo multivalorado telefone.

SELECT
    u.nome AS usuario,
    u.email,
    COUNT(t.id) AS total_telefones
FROM academico.usuarios u
INNER JOIN academico.telefones_usuarios t
    ON u.id = t.usuario_id
WHERE t.telefone IS NOT NULL
GROUP BY u.id, u.nome, u.email
ORDER BY total_telefones DESC, u.nome ASC
LIMIT 20;


-- 52 - Relatorio 10
-- Quais encomendas foram entregues e quais seus destinos?
-- Filtra entregas concluidas e enderecos de destino.

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


-- ============================================================
-- FIM DOS 10 RELATORIOS
-- ============================================================
