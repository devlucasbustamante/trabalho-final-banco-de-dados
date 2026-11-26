-- TRABALHO FINAL: SISTEMA DE GERENCIAMENTO E RASTREAMENTO DE ENCOMENDAS
-- Reconstrucao documental baseada nos CSVs de colunas e restricoes do Supabase.
-- ATENCAO: script para documentacao ou uso em banco vazio; NAO execute no projeto atual.
-- Dependencias: PostgreSQL com funcao gen_random_uuid() disponivel.

-- Pré-requisito: executar 01_criacao_schema.sql em um banco vazio.

-- Tabela: usuarios
CREATE TABLE academico.usuarios (
    id UUID DEFAULT gen_random_uuid() NOT NULL,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL,
    criado_em TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT usuarios_pkey PRIMARY KEY (id),
    CONSTRAINT usuarios_email_key UNIQUE (email)
);

-- Tabela: entregadores
CREATE TABLE academico.entregadores (
    id UUID NOT NULL,
    veiculo VARCHAR(100),
    placa VARCHAR(10),
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT fk_entregador_usuario FOREIGN KEY (id) REFERENCES academico.usuarios(id),
    CONSTRAINT entregadores_pkey PRIMARY KEY (id)
);

-- Tabela: rotas
CREATE TABLE academico.rotas (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    nome VARCHAR(100) NOT NULL,
    data DATE NOT NULL,
    distancia_km NUMERIC(10,2) NOT NULL,
    CONSTRAINT rotas_distancia_km_check CHECK ((distancia_km >= (0)::numeric)),
    CONSTRAINT rotas_pkey PRIMARY KEY (id)
);

-- Tabela: encomendas
CREATE TABLE academico.encomendas (
    codigo TEXT DEFAULT (gen_random_uuid())::text NOT NULL,
    descricao TEXT NOT NULL,
    status VARCHAR(30) DEFAULT 'pendente'::character varying NOT NULL,
    usuario_id UUID NOT NULL,
    entregador_id UUID,
    criado_em TIMESTAMPTZ DEFAULT now(),
    atualizado_em TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT fk_encomenda_entregador FOREIGN KEY (entregador_id) REFERENCES academico.entregadores(id),
    CONSTRAINT fk_encomenda_usuario FOREIGN KEY (usuario_id) REFERENCES academico.usuarios(id),
    CONSTRAINT encomendas_pkey PRIMARY KEY (codigo)
);

-- Tabela: enderecos
CREATE TABLE academico.enderecos (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    encomenda_codigo TEXT NOT NULL,
    rua VARCHAR(150) NOT NULL,
    numero VARCHAR(20) NOT NULL,
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    cep VARCHAR(9) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado CHAR(2) NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    CONSTRAINT chk_tipo_endereco CHECK (((tipo)::text = ANY ((ARRAY['origem'::character varying, 'destino'::character varying])::text[]))),
    CONSTRAINT fk_endereco_encomenda FOREIGN KEY (encomenda_codigo) REFERENCES academico.encomendas(codigo),
    CONSTRAINT enderecos_pkey PRIMARY KEY (id),
    CONSTRAINT uq_endereco_tipo UNIQUE (encomenda_codigo, tipo)
);

-- Tabela: historico
CREATE TABLE academico.historico (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    encomenda_codigo TEXT NOT NULL,
    data TIMESTAMPTZ DEFAULT now(),
    status VARCHAR(30) NOT NULL,
    observacao TEXT,
    CONSTRAINT fk_historico_encomenda FOREIGN KEY (encomenda_codigo) REFERENCES academico.encomendas(codigo),
    CONSTRAINT historico_pkey PRIMARY KEY (id)
);

-- Tabela: telefones_usuarios
CREATE TABLE academico.telefones_usuarios (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    usuario_id UUID NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    CONSTRAINT fk_telefone_usuario FOREIGN KEY (usuario_id) REFERENCES academico.usuarios(id),
    CONSTRAINT telefones_usuarios_pkey PRIMARY KEY (id)
);

-- Tabela: entregadores_rotas
CREATE TABLE academico.entregadores_rotas (
    entregador_id UUID NOT NULL,
    rota_id BIGINT NOT NULL,
    CONSTRAINT fk_er_entregador FOREIGN KEY (entregador_id) REFERENCES academico.entregadores(id),
    CONSTRAINT fk_er_rota FOREIGN KEY (rota_id) REFERENCES academico.rotas(id),
    CONSTRAINT pk_entregadores_rotas PRIMARY KEY (entregador_id, rota_id)
);
