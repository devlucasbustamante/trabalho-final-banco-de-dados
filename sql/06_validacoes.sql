-- ENTREGAFACIL - TRABALHO FINAL DE BANCO DE DADOS
-- 06_validacoes.sql | PostgreSQL / Supabase
-- Executar apos a criacao e o povoamento do esquema academico.
-- Consultas somente de leitura.

-- 31 - Auditoria geral da quantidade de registros
-- Esperado: pelo menos 500 registros por tabela.
SELECT 'usuarios' AS tabela, COUNT(*) AS registros
FROM academico.usuarios

UNION ALL
SELECT 'entregadores', COUNT(*)
FROM academico.entregadores

UNION ALL
SELECT 'rotas', COUNT(*)
FROM academico.rotas

UNION ALL
SELECT 'encomendas', COUNT(*)
FROM academico.encomendas

UNION ALL
SELECT 'enderecos', COUNT(*)
FROM academico.enderecos

UNION ALL
SELECT 'historico', COUNT(*)
FROM academico.historico

UNION ALL
SELECT 'telefones_usuarios', COUNT(*)
FROM academico.telefones_usuarios

UNION ALL
SELECT 'entregadores_rotas', COUNT(*)
FROM academico.entregadores_rotas

ORDER BY tabela;

-- 32 - Verificar associacoes duplicadas
-- Esperado: nenhuma linha retornada.
SELECT
    entregador_id,
    rota_id,
    COUNT(*) AS quantidade
FROM academico.entregadores_rotas
GROUP BY entregador_id, rota_id
HAVING COUNT(*) > 1;

-- 35 - Validacao dos enderecos de origem e destino
-- Esperado: total_encomendas, com_origem e com_destino iguais.
SELECT
    COUNT(*) AS total_encomendas,
    COUNT(*) FILTER (
        WHERE EXISTS (
            SELECT 1
            FROM academico.enderecos en
            WHERE en.encomenda_codigo = e.codigo
              AND en.tipo = 'origem'
        )
    ) AS com_origem,
    COUNT(*) FILTER (
        WHERE EXISTS (
            SELECT 1
            FROM academico.enderecos en
            WHERE en.encomenda_codigo = e.codigo
              AND en.tipo = 'destino'
        )
    ) AS com_destino
FROM academico.encomendas e;

-- 36 - Verificacao final das tabelas
-- Esperado: oito tabelas no esquema academico.
SELECT
    schemaname AS esquema,
    tablename AS tabela
FROM pg_tables
WHERE schemaname = 'academico'
ORDER BY tablename;

-- 53 - Auditoria detalhada da estrutura das tabelas
-- Lista colunas, tipos, nulabilidade, valores padrao e identidade.
SELECT
    table_name AS tabela,
    ordinal_position AS ordem,
    column_name AS coluna,
    data_type AS tipo,
    udt_name AS tipo_postgresql,
    character_maximum_length AS tamanho,
    numeric_precision AS precisao,
    numeric_scale AS casas_decimais,
    is_nullable AS permite_nulo,
    column_default AS valor_padrao,
    is_identity AS identidade,
    identity_generation AS geracao_identidade
FROM information_schema.columns
WHERE table_schema = 'academico'
ORDER BY table_name, ordinal_position;

-- 54 - Auditoria final das chaves e restricoes
-- Lista PK, FK, UNIQUE e CHECK existentes e suas definicoes.
SELECT
    con.conrelid::regclass AS tabela,
    con.conname AS nome_restricao,
    CASE con.contype
        WHEN 'p' THEN 'PRIMARY KEY'
        WHEN 'f' THEN 'FOREIGN KEY'
        WHEN 'u' THEN 'UNIQUE'
        WHEN 'c' THEN 'CHECK'
    END AS tipo,
    pg_get_constraintdef(con.oid) AS definicao
FROM pg_constraint con
JOIN pg_namespace ns
    ON ns.oid = con.connamespace
WHERE ns.nspname = 'academico'
  AND con.contype IN ('p', 'f', 'u', 'c')
ORDER BY
    con.conrelid::regclass::text,
    con.contype,
    con.conname;
