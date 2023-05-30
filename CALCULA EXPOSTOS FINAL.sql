CREATE OR REPLACE TABLE self-service-saude.SANDBOX_GERAC.LT_LOCALIDADE_BENEFS_LA AS 

WITH LOCALIDADE_VIDAS AS (
  SELECT  
    DISTINCT
    ANO_MES,
    COD_ANALITICO_BENEFICIARIO,
    UF_CAPITATION,
    MUNICIPIO_CAPITATION

  FROM self-service-saude.SANDBOX_GERAC.LUCAS_CAPITATION_VIDAS_2018 
  
  UNION ALL

  SELECT  
    DISTINCT
    ANO_MES,
    COD_ANALITICO_BENEFICIARIO,
    UF_CAPITATION,
    MUNICIPIO_CAPITATION

  FROM self-service-saude.SANDBOX_GERAC.LUCAS_CAPITATION_VIDAS_2019 
  
  UNION ALL
  
  SELECT  
    DISTINCT
    ANO_MES,
    COD_ANALITICO_BENEFICIARIO,
    UF_CAPITATION,
    MUNICIPIO_CAPITATION

  FROM self-service-saude.SANDBOX_GERAC.LUCAS_CAPITATION_VIDAS_2020  
  
  UNION ALL
  
  SELECT  
    DISTINCT
    ANO_MES,
    COD_ANALITICO_BENEFICIARIO,
    UF_CAPITATION,
    MUNICIPIO_CAPITATION

  FROM self-service-saude.SANDBOX_GERAC.LUCAS_CAPITATION_VIDAS_2021  
  
  UNION ALL
  
  SELECT  
    DISTINCT
    ANO_MES,
    COD_ANALITICO_BENEFICIARIO,
    UF_CAPITATION,
    MUNICIPIO_CAPITATION

  FROM self-service-saude.SANDBOX_GERAC.LUCAS_CAPITATION_VIDAS_2022  
    UNION ALL
  
  SELECT  
    DISTINCT
    ANO_MES,
    COD_ANALITICO_BENEFICIARIO,
    UF_CAPITATION,
    MUNICIPIO_CAPITATION

  FROM self-service-saude.SANDBOX_GERAC.LUCAS_CAPITATION_VIDAS_2023  
)
SELECT 
  *
FROM LOCALIDADE_VIDAS
;

-- CRIA A BASE QUE CALCULA ATIVOS E EXPOSTOS
CREATE OR REPLACE TABLE SANDBOX_GERAC.LT_RELAT_VIDAS_LA AS 
WITH AUX_ANO_MES AS (
  SELECT 
      'A' AS CHAVE
    , FORMAT_DATE('%Y%m', DATA_RANGE) AS ANO_MES
    , DATA_RANGE AS DAT_INICIAL
    , LAST_DAY(DATA_RANGE) AS DAT_FINAL
  FROM 
    UNNEST(
      GENERATE_DATE_ARRAY(DATE('2016-01-01'), 
          CAST(FORMAT_DATE('%Y-%m-01', DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)) AS DATE), INTERVAL 1 MONTH)
    ) AS DATA_RANGE
)
, CALCULA_ATIVO AS (
  SELECT
    PARSE_DATE('%m-%d-%Y',CONCAT(
                                SUBSTRING(CAST(CAL.ANO_MES AS STRING), 5, 6), '-', -- mês
                                 '01','-',                                       -- dia 
                                SUBSTRING ( CAST(CAL.ANO_MES AS STRING) , 1 , 4 )) -- ano
                ) AS ANO_MES
    , CASE WHEN BENEF.DSC_CARTEIRA IN ('PME+', 'EMPRESARIAL') THEN 'EMPRESARIAL' ELSE BENEF.DSC_CARTEIRA END AS CARTEIRA
    , BENEF.COD_PLANO
    , BENEF.NME_PLANO
    , P.NME_PLANO_AJUSTADO
    , BENEF.COD_PRODUTO
    , BENEF.DSC_PRODUTO
    , BENEF.FLG_POS_LEI_9656
    , BENEF.DSC_SEXO_BENEFICIARIO
    , UF_CAPITATION
    , MUNICIPIO_CAPITATION
    -- Cálculo de Idade do Beneficiário
    , CASE WHEN CAL.DAT_FINAL <= BENEF.DAT_NASCIMENTO THEN 0
          WHEN CAST(FORMAT_DATE('%m%d',CAL.DAT_FINAL) AS INT64) < CAST(FORMAT_DATE('%m%d',BENEF.DAT_NASCIMENTO) AS INT64)
          THEN (DATE_DIFF(CAL.DAT_FINAL,BENEF.DAT_NASCIMENTO, YEAR) - 1)
          ELSE DATE_DIFF(CAL.DAT_FINAL, BENEF.DAT_NASCIMENTO, YEAR) END AS IDADE
    -- Cálculo de Ativo 
    , SUM(CASE WHEN(BENEF.DAT_FIM_VIGENCIA >= CAL.DAT_FINAL) 
               AND BENEF.DAT_INICIO_VIGENCIA <= CAL.DAT_FINAL THEN 1 ELSE 0 END) AS ATIVO
    -- Cálculo de Exposto
    , SUM(CASE WHEN BENEF.DAT_FIM_VIGENCIA >= BENEF.DAT_INICIO_VIGENCIA 
               AND BENEF.DAT_FIM_VIGENCIA >= CAL.DAT_INICIAL AND BENEF.DAT_INICIO_VIGENCIA <= CAL.DAT_FINAL 
               THEN ((DATE_DIFF(LEAST(BENEF.DAT_FIM_VIGENCIA, CAL.DAT_FINAL), 
                               GREATEST(BENEF.DAT_INICIO_VIGENCIA, CAL.DAT_INICIAL), DAY) +1) / 
                               (DATE_DIFF(CAL.DAT_FINAL,CAL.DAT_INICIAL, DAY) +1)) 
               ELSE 0 END) AS EXPOSTO
FROM self-service-saude-prd.REF_SAUDE_BENEFICIARIO.TB_CAD_BENEFICIARIO BENEF
CROSS JOIN AUX_ANO_MES AS CAL
LEFT JOIN `self-service-saude.SANDBOX_GERAC.TB_PLANO_AJUSTADO_COM_SOMPO_LA` P
  ON BENEF.NME_PLANO = P.NME_PLANO
LEFT JOIN SANDBOX_GERAC.LT_LOCALIDADE_BENEFS AS L
  ON CAL.ANO_MES = CAST(L.ANO_MES AS STRING)
  AND BENEF.COD_ANALITICO_BENEFICIARIO = L.COD_ANALITICO_BENEFICIARIO
WHERE DSC_MOTIVO_EXCLUSAO_BENEFICIARIO NOT IN ('INCLUSAO INDEVIDA DE BENEFICIARIO')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12
)
SELECT
  ANO_MES
  , CARTEIRA
  , COD_PLANO
  , NME_PLANO
  , NME_PLANO_AJUSTADO
  , COD_PRODUTO
  , DSC_PRODUTO
  , FLG_POS_LEI_9656
  , DSC_SEXO_BENEFICIARIO
  , IDADE
  , UF_CAPITATION
  , MUNICIPIO_CAPITATION
   ,CASE 
      WHEN IDADE <= 18                                   THEN 'ATE 18 ANOS'
      WHEN IDADE >= 19 AND IDADE <= 23  THEN 'DE 19 A 23 ANOS'
      WHEN IDADE >= 24 AND IDADE <= 28  THEN 'DE 24 A 28 ANOS'
      WHEN IDADE >= 29 AND IDADE <= 33  THEN 'DE 29 A 33 ANOS'
      WHEN IDADE >= 34 AND IDADE <= 38  THEN 'DE 34 A 38 ANOS'
      WHEN IDADE >= 39 AND IDADE <= 43  THEN 'DE 39 A 43 ANOS'
      WHEN IDADE >= 44 AND IDADE <= 48  THEN 'DE 44 A 48 ANOS'
      WHEN IDADE >= 49 AND IDADE <= 53  THEN 'DE 49 A 53 ANOS'
      WHEN IDADE >= 54 AND IDADE <= 58  THEN 'DE 54 A 58 ANOS'
      WHEN IDADE >= 59 AND IDADE <= 68  THEN 'DE 59 A 68 ANOS'
      WHEN IDADE >= 69 AND IDADE <= 78  THEN 'DE 69 A 78 ANOS'
      WHEN IDADE >= 79 AND IDADE <= 88  THEN 'DE 79 A 88 ANOS'
      WHEN IDADE >= 89 AND IDADE <= 98  THEN 'DE 89 A 98 ANOS'
      WHEN IDADE >= 99                                   THEN '99 ANOS OU MAIS'
      ELSE 'NÃO INFORMADO'
       END AS DSC_FAIXA_ETARIA
    , SUM(ATIVO) AS ATIVOS
    , ROUND(CAST(SUM(EXPOSTO) AS NUMERIC),2) AS EXPOSTOS
FROM CALCULA_ATIVO
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12
HAVING ATIVOS > 0 
  OR EXPOSTOS > 0
;

-- VIDAS


CREATE OR REPLACE TABLE SANDBOX_GERAC.TB_EXPOSTOS_LA AS 
SELECT 
  FORMAT_DATE('%Y', ANO_MES) ANO
  , FORMAT_DATE('%m', ANO_MES) MES
  , FORMAT_DATE('%Y%m', ANO_MES) ANO_MES
   , CASE
  WHEN CARTEIRA = 'ADESÃO' THEN 'ADESAO'
    ELSE CARTEIRA 
  END AS CARTEIRA
  , NME_PLANO_AJUSTADO AS PLANO
  , DSC_FAIXA_ETARIA
  , SUM(EXPOSTOS) AS EXPOSTOS
FROM self-service-saude.SANDBOX_GERAC.LT_RELAT_VIDAS_LA
WHERE ANO_MES >= '2018-01-01'
GROUP BY 1,2,3,4,5,6
ORDER BY 1,2,3,4,5,6
;

CREATE OR REPLACE TABLE SANDBOX_GERAC.TB_EXPOSTOS_FINAL_LA AS 

WITH EXPOSTOS_MES AS
(SELECT 
ANO_MES
,SUM(EXPOSTOS) AS EXPOSTOS_NO_MES
FROM SANDBOX_GERAC.TB_EXPOSTOS_LA
GROUP BY 1)

SELECT
A.* 
,B.EXPOSTOS_NO_MES
,A.EXPOSTOS/B.EXPOSTOS_NO_MES AS PESO
FROM SANDBOX_GERAC.TB_EXPOSTOS_LA A
LEFT JOIN EXPOSTOS_MES B
USING(ANO_MES)
ORDER BY ANO_MES,DSC_FAIXA_ETARIA
