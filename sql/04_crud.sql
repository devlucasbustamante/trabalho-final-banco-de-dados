-- ============================================================
-- ENTREGAFACIL - TRABALHO FINAL DE BANCO DE DADOS
-- 04_crud.sql - Demonstracao das operacoes CRUD
-- Esquema: academico | Tabela: rotas
-- Consultas originais: 38 a 42
-- ATENCAO: o ID 501 corresponde ao teste original.
-- Em uma nova demonstracao, execute a insercao separadamente,
-- confira o ID retornado e substitua 501 nas consultas seguintes.
-- Nao execute este arquivo integralmente em uma base ja povoada.
-- ============================================================

-- 38 - CREATE: inserir uma rota ficticia de teste.
INSERT INTO academico.rotas
    (nome, data, distancia_km)
VALUES
    ('Rota Teste CRUD', CURRENT_DATE, 125.50)
RETURNING *;

-- 39 - READ: consultar a rota inserida.
SELECT
    id,
    nome,
    data,
    distancia_km
FROM academico.rotas
WHERE id = 501;

-- 40 - UPDATE: alterar a distancia da rota de teste.
UPDATE academico.rotas
SET distancia_km = 150.00
WHERE id = 501
RETURNING *;

-- 41 - DELETE: excluir a rota de teste, conferindo ID e nome.
DELETE FROM academico.rotas
WHERE id = 501
  AND nome = 'Rota Teste CRUD'
RETURNING *;

-- 42 - Validacao: verificar a exclusao (esperado: zero linhas).
SELECT *
FROM academico.rotas
WHERE id = 501;
