EXPORT DATA OPTIONS                                     
(                                   
    uri='gs://sas-bq-export-ditem-gerac/LA165808/LA165808*.csv',                                    
    format='CSV',                                   
    overwrite=true,                                 
    header=true,                                    
    field_delimiter=';'                                 
) AS

SELECT DSC_UNID_DISTRIB from self-service-saude.SANDBOX_SUCSI.TB_ITEM_PAGO_MAT_MED
