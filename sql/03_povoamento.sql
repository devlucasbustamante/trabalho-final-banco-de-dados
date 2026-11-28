-- ============================================================
-- ENTREGA FACIL - TRABALHO FINAL DE BANCO DE DADOS
-- 03_povoamento.sql | PostgreSQL / Supabase
-- Esquema: academico
-- Executar apos 01_criacao_schema.sql e 02_criacao_tabelas.sql
-- Destinado ao povoamento inicial. Nao reexecutar na base pronta.
-- Total previsto: 5000 registros em 8 tabelas.
-- ============================================================

-- 1. Usuarios (consulta 12): completar 500 registros
INSERT INTO academico.usuarios (nome, email)
SELECT
    'Usuario Academico ' || numero,
    'aluno.teste.' ||
        replace(gen_random_uuid()::text, '-', '') ||
        '@example.com'
FROM generate_series(
    1,
    GREATEST(0, 500 - (
        SELECT COUNT(*)::integer FROM academico.usuarios
    ))
) AS numero;

-- 2. Entregadores (consulta 14): relacionamento 1:1 com usuarios
INSERT INTO academico.entregadores (id, veiculo, placa, ativo)
SELECT
    u.id,
    CASE
        WHEN ROW_NUMBER() OVER (ORDER BY u.id) % 3 = 0 THEN 'Moto'
        WHEN ROW_NUMBER() OVER (ORDER BY u.id) % 3 = 1 THEN 'Carro'
        ELSE 'Van'
    END,
    'TST' || LPAD(ROW_NUMBER() OVER (ORDER BY u.id)::TEXT, 4, '0'),
    TRUE
FROM academico.usuarios u
WHERE NOT EXISTS (
    SELECT 1 FROM academico.entregadores e WHERE e.id = u.id
)
LIMIT 500;

-- 3. Rotas (consulta 16): completar 500 registros
INSERT INTO academico.rotas (nome, data, distancia_km)
SELECT
    'Rota Academica ' || numero,
    CURRENT_DATE - (numero % 90),
    (10 + (numero % 300))::DECIMAL(10,2)
FROM generate_series(
    1,
    GREATEST(0, 500 - (
        SELECT COUNT(*)::INTEGER FROM academico.rotas
    ))
) AS numero;

-- 4. Encomendas (consulta 18): vincular usuarios e entregadores
WITH usuarios_numerados AS (
    SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS numero
    FROM academico.usuarios
),
entregadores_numerados AS (
    SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS numero
    FROM academico.entregadores
),
quantidade AS (
    SELECT GREATEST(0, 500 - COUNT(*)::INTEGER) AS faltantes
    FROM academico.encomendas
)
INSERT INTO academico.encomendas (descricao, status, usuario_id, entregador_id)
SELECT
    'Encomenda Academica ' || n.numero,
    CASE n.numero % 4
        WHEN 0 THEN 'pendente'
        WHEN 1 THEN 'em_preparacao'
        WHEN 2 THEN 'em_transporte'
        ELSE 'entregue'
    END,
    u.id,
    e.id
FROM quantidade q
CROSS JOIN LATERAL generate_series(1, q.faltantes) AS n(numero)
JOIN usuarios_numerados u ON u.numero = ((n.numero - 1) % 500) + 1
JOIN entregadores_numerados e ON e.numero = ((n.numero - 1) % 500) + 1;

-- 5. Enderecos (consulta 20): origem e destino por encomenda
WITH encomendas_numeradas AS (
    SELECT codigo, ROW_NUMBER() OVER (ORDER BY codigo) AS numero
    FROM academico.encomendas
)
INSERT INTO academico.enderecos (
    encomenda_codigo, rua, numero, complemento, bairro, cep, cidade, estado, tipo
)
SELECT
    e.codigo,
    'Rua Academica ' || e.numero,
    (100 + e.numero)::TEXT,
    NULL,
    'Bairro Teste',
    '14400000',
    CASE WHEN t.tipo = 'origem' THEN 'Franca' ELSE 'Ribeirao Preto' END,
    'SP',
    t.tipo
FROM encomendas_numeradas e
CROSS JOIN (VALUES ('origem'), ('destino')) AS t(tipo)
WHERE NOT EXISTS (
    SELECT 1 FROM academico.enderecos en
    WHERE en.encomenda_codigo = e.codigo AND en.tipo = t.tipo
);

-- 6. Historico (consulta 22): registro inicial de cada encomenda
INSERT INTO academico.historico (encomenda_codigo, data, status, observacao)
SELECT
    e.codigo,
    e.criado_em,
    e.status,
    'Registro inicial da encomenda academica'
FROM academico.encomendas e
WHERE NOT EXISTS (
    SELECT 1 FROM academico.historico h WHERE h.encomenda_codigo = e.codigo
);

-- 7. Telefones (consulta 26 corrigida): atributo multivalorado
WITH usuarios_numerados AS (
    SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS numero
    FROM academico.usuarios
)
INSERT INTO academico.telefones_usuarios (usuario_id, telefone, tipo)
SELECT
    u.id,
    '119' || LPAD(u.numero::TEXT, 8, '0'),
    CASE WHEN u.numero % 2 = 0 THEN 'celular' ELSE 'comercial' END
FROM usuarios_numerados u
WHERE NOT EXISTS (
    SELECT 1 FROM academico.telefones_usuarios t WHERE t.usuario_id = u.id
);

-- 8. Entregadores e rotas (consulta 29): relacionamento N:N
WITH entregadores_numerados AS (
    SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS numero
    FROM academico.entregadores
),
rotas_numeradas AS (
    SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS numero
    FROM academico.rotas
),
associacoes AS (
    SELECT e.id AS entregador_id, r.id AS rota_id
    FROM entregadores_numerados e
    JOIN rotas_numeradas r ON r.numero IN (e.numero, (e.numero % 500) + 1)
)
INSERT INTO academico.entregadores_rotas (entregador_id, rota_id)
SELECT a.entregador_id, a.rota_id
FROM associacoes a
WHERE NOT EXISTS (
    SELECT 1 FROM academico.entregadores_rotas er
    WHERE er.entregador_id = a.entregador_id AND er.rota_id = a.rota_id
);
