--DDL - Linguagem de Definição de Dados - Create, Drop, Alter
--DML - Linguagem de Manipulação de Dados - Insert, Update, Delete
--DTL – Linguagem de Transação de Dados - COMMIT, ROLLBACK
--DCL – Linguagem de Controle de Dados - GRANT, REVOKE

CREATE TABLE T_SIP_DEPARTAMENTO
(
cd_depto NUMBER (2) NOT NULL ,
nm_depto VARCHAR2 (30) NOT NULL
) ;

-- CRIAÇÃO DA CHAVE PRIMÁRIA
ALTER TABLE T_SIP_DEPARTAMENTO
ADD CONSTRAINT PK_SIP_DEPARTAMENTO PRIMARY KEY ( cd_depto );

-- CRIAÇÃO DA CONSTRAINT UNIQUE
ALTER TABLE T_SIP_DEPARTAMENTO
ADD CONSTRAINT UN_SIP_DEPTO_NOME UNIQUE ( nm_depto ) ;

--Transformação do Modelo para SQL - Comando ALTER TABLE

--Adicionando colunas
ALTER TABLE CLIENTE ADD email VARCHAR2(80) UNIQUE;

--Adicionando restrições (constraints)
ALTER TABLE CLIENTE ADD PRIMARY KEY(CDCLIENTE);

--Modificando colunas
ALTER TABLE CLIENTE MODIFY email varchar2(100) NOT NULL;

--Excluindo elementos
--Colunas
ALTER TABLE CLIENTE DROP COLUMN email;

--Alteração de nome da tabela
ALTER TABLE CLIENTE
RENAME TO CLI;

--Alteração de nome da coluna
ALTER TABLE CLIENTE
RENAME COLUMN nome_Cliente TO nmcliente;

-- INSERINDO DADOS NA TABELA DEPARTAMENTO
INSERT INTO T_EX01_DEPARTAMENTO VALUES (1,'FINANCEIRO');
INSERT INTO T_EX01_DEPARTAMENTO
(cd_departamento, nm_departamento)
VALUES (2,'MARKETING');

-- COPIANDO LINHAS DE UMA TABELA PARA OUTRA
INSERT INTO T_EX01_DEPARTAMENTO_TEMP
(cd_departamento, nm_departamento)
(SELECT cd_departamento, nm_departamento FROM T_EX01_DEPARTAMENTO);

-- ATUALIZANDO OS DADOS NA TABELA DEPARTAMENTO (TEMPORÁRIA)
UPDATE T_EX01_DEPARTAMENTO_TEMP
SET NM_DEPARTAMENTO='TESTANDO ATUALIZACAO'
WHERE CD_DEPARTAMENTO=5;

--Com SUBQUERY
-- ATUALIZANDO OS DADOS NA TABELA DEPARTAMENTO (TEMPORÁRIA)
UPDATE T_EX01_DEPARTAMENTO_TEMP
SET NM_DEPARTAMENTO=
(SELECT NM_DEPARTAMENTO FROM T_EX01_DEPARTAMENTO WHERE CD_DEPARTAMENTO=1)
WHERE CD_DEPARTAMENTO=6;

-- EXCLUINDO OS DADOS NA TABELA DEPARTAMENTO
DELETE FROM T_EX01_DEPARTAMENTO_TEMP
WHERE CD_DEPARTAMENTO = 3;

--Com SUBQUERY
-- EXCLUINDO OS DADOS NA TABELA DEPARTAMENTO (TEMPORÁRIA)
DELETE FROM T_EX01_DEPARTAMENTO_TEMP
WHERECD_DEPARTAMENTO IN
(SELECT CD_DEPARTAMENTO FROM T_EX01_DEPARTAMENTO);

-----------SUBQUERY-------------
SELECT ROWNUM "RANK" ,
 "CLIENTE" ,
 "CLIENTE COM MAIOR COMPRA"
FROM (
 SELECT C.NM_CLIENTE "CLIENTE",
 SUM(NF.VL_TOTAL_NF) "CLIENTE COM MAIOR COMPRA"
 FROM T_SPV_CLIENTE C INNER JOIN T_SPV_NOTA_FISCAL NF
 ON (C.CD_CLIENTE = NF.CD_CLIENTE)
 GROUP BY C.NM_CLIENTE
 ORDER BY "CLIENTE COM MAIOR COMPRA" DESC
 )
WHERE ROWNUM <= 10 ;

--------SUBQUERY NO WHERE -------------------------
SELECT F.NR_NOTA_FISCAL ,
 F.DT_EMISSAO ,
 F.VL_TOTAL_NF
 FROM T_SPV_NOTA_FISCAL F
 WHERE F.VL_TOTAL_NF > (
 SELECT AVG(NF.VL_TOTAL_NF) "VALOR MÉDIO DAS VENDAS"
 FROM T_SPV_NOTA_FISCAL NF
 )
ORDER BY F.VL_TOTAL_NF DESC ;

----------- SUBQUERY------------------------------
SELECT ROWNUM RANK ,
 "NR. MATRICULA" ,
 "ALUNO" ,
 "QTDE. MESES ATIVO"
FROM
 (
 SELECT M.NR_MATRICULA "NR. MATRICULA",
 A.NM_ALUNO "ALUNO" ,
 M.DT_MATRICULA "DATA MATRÍCULA" ,
 TO_CHAR((SYSDATE - M.DT_MATRICULA)/30,'9999') || ' Meses' "QTDE.
MESES ATIVO"
 FROM T_PS2_ALUNO A INNER JOIN T_PS2_MATRICULA M
 ON (A.CD_ALUNO = M.CD_ALUNO)
 WHERE M.DT_DESLIGAMENTO IS NULL
 ORDER BY "QTDE. MESES ATIVO" DESC
 )
WHERE ROWNUM <4; 

-------------- SUBQUERY RETORNANDO APENAS UMA CONSULTA

SELECT F.NM_NOME,
F.VL_SALARIO
FROM T_EX01_FUNCIONARIO F
WHERE F.VL_SALARIO > (
SELECT F.VL_SALARIO
FROM T_EX01_FUNCIONARIO F
WHERE F.NM_NOME = 'JOSÉ MARIA'
);
RESULTADO: 
NM_NOME  |VL_SALARIO
ROSA     |2345
ANTONIA  |7654

-------------- SUBQUERY RETORNANDO APENAS UMA LINHA

SUBCONSULTA RETORNANDO APENAS UMA LINHA
SELECT F.NM_NOME,
F.VL_SALARIO
FROM T_EX01_FUNCIONARIO F
WHERE F.VL_SALARIO > (
SELECT AVG(F.VL_SALARIO)
FROM T_EX01_FUNCIONARIO F
);


-------------------SUBCONSULTAS (INLINE)

SELECT P.CD_PRODUTO,
P.VL_PRECO_UNITARIO,
QTVENDIDA.QTDEVEND
FROM T_SPV_PRODUTO P ,
(
SELECT I.CD_PRODUTO ,
COUNT (I.CD_PRODUTO) QTDEVEND
FROM T_SPV_ITEM_NOTA_FISCAL I
GROUP BY I.CD_PRODUTO
) QTVENDIDA
WHERE P.CD_PRODUTO = QTVENDIDA.CD_PRODUTO ;

--CRIANDO UMA TABELA A PARTIR DE UMA SUBCONSULTA:
CREATE TABLE T_TESTE_AULA32 AS
SELECT * FROM T_SPV_PRODUTO;

--SUBCONSULTA RETORNANDO VÁRIAS LINHAS
SELECT I.CD_IMPLANTACAO ,
I.CD_PROJETO,
I.NR_MATRICULA "FUNCI0NARIO"
FROM T_EX01_IMPLANTACAO I
WHERE I.CD_PROJETO IN
(
SELECT P.CD_PROJETO
FROM T_EX01_PROJETO P
WHERE TO_CHAR(P.DT_INICIO,'MM/YYYY') = '12/2012'

--SUBCONSULTAS (UTILIZANDO EXISTS)
--SUBCONSULTA RETORNANDO VÁRIAS LINHAS
SELECT P.CD_PRODUTO,
P.DS_PRODUTO
FROM T_SPV_PRODUTO P
WHERE EXISTS
(
SELECT I.CD_PRODUTO
FROM T_SPV_ITEM_NOTA_FISCAL I
WHERE P.CD_PRODUTO=I.CD_PRODUTO
);



		
