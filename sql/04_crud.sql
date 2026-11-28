
-- ============================================================
-- ENTREGAFACIL - TRABALHO FINAL DE BANCO DE DADOS
-- 04_crud.sql - Demonstracao das operacoes CRUD
-- Esquema: academico | Tabela: rotas
-- Consultas originais: 38 a 42
-- O ID da rota de teste e capturado automaticamente.
-- Execute o script completo na mesma sessao.
-- ============================================================

BEGIN;

-- Tabela temporaria para armazenar o ID gerado.
CREATE TEMP TABLE controle_crud (
    id BIGINT PRIMARY KEY
) ON COMMIT DROP;

-- 38 - CREATE: inserir uma rota ficticia de teste.
WITH nova_rota AS (
    INSERT INTO academico.rotas
        (nome, data, distancia_km)
    VALUES
        ('Rota Teste CRUD', CURRENT_DATE, 125.50)
    RETURNING id
)
INSERT INTO controle_crud (id)
SELECT id FROM nova_rota;

-- Exibir a rota criada.
SELECT *
FROM academico.rotas
WHERE id = (SELECT id FROM controle_crud);

-- 39 - READ: consultar a rota inserida.
SELECT
    id,
    nome,
    data,
    distancia_km
FROM academico.rotas
WHERE id = (SELECT id FROM controle_crud);

-- 40 - UPDATE: alterar a distancia da rota.
UPDATE academico.rotas
SET distancia_km = 150.00
WHERE id = (SELECT id FROM controle_crud)
  AND nome = 'Rota Teste CRUD'
RETURNING *;

-- 41 - DELETE: excluir somente a rota de teste.
DELETE FROM academico.rotas
WHERE id = (SELECT id FROM controle_crud)
  AND nome = 'Rota Teste CRUD'
RETURNING *;

-- 42 - Validacao: verificar a exclusao.
-- Resultado esperado: zero linhas.
SELECT *
FROM academico.rotas
WHERE id = (SELECT id FROM controle_crud);

COMMIT;
