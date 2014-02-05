@echo off

set psql_path=%~dp0
set psql_path="%psql_path%psql\psql.exe"
set host=localhost
set port=5432
set dbname=sola

set username=postgres

set createDB=NO

set testDataPath=test-data\waiheke\
set utilitiesPath=utilities\

set /p host= Host name [%host%] :

set /p port= Port [%port%] :

set /p dbname= Database name [%dbname%] :

set /p username= Username [%username%] :

echo
echo
echo Starting Build at %time%
echo Starting Build at %time% > build.log 2>&1

echo Creating database...
echo Creating database... >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=sola.sql >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=reference_tables.sql >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=post_scripts.sql >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=sola_extension.sql >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=test_data.sql >> build.log 2>&1

echo Loading business rules...
echo Loading SOLA business rules... >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=business-rules\business_rules.sql >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=business-rules\br_generators.sql >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=business-rules\br_target_application.sql >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=business-rules\br_target_service.sql >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=business-rules\br_target_ba_unit.sql >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=business-rules\br_target_cadastre_object.sql >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=business-rules\br_target_rrr.sql >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=business-rules\br_target_source.sql >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=business-rules\br_target_bulkOperationSpatial.sql >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=business-rules\br_target_spatial_unit_group.sql >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=business-rules\br_target_public_display.sql >> build.log 2>&1

echo Loading Waiheke Shape Data...
echo Loading Waiheke Shape Data... >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=%testDataPath%sola_populate_waiheke_shapefiles.sql >NUL 2>>build.log


echo Loading Waiheke Titles...
echo Loading Waiheke Titles... >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=%testDataPath%sola_populate_waiheke_title.sql >NUL 2>>build.log


echo Loading Roles and Privileges...
echo Loading Roles and Privileges... >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=%testDataPath%add_user_role_priv.sql >NUL 2>>build.log


echo Loading Applications...
echo Loading Applications... >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=%testDataPath%sola_populate_waiheke_applications.sql >NUL 2>>build.log

echo Extracting Waiheke RRR data...
echo Extracting Waiheke RRR data... >> build.log 2>&1
%utilitiesPath%\7z.exe e -y -o%testDataPath% %testDataPath%sola_populate_waiheke_rrr.7z >> build.log 2>&1

echo Loading RRR Data...
echo Loading RRR Data... >> build.log 2>&1
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=%testDataPath%sola_populate_waiheke_rrr.sql >NUL 2>>build.log
%psql_path% --host=%host% --port=%port% --username=%username% --dbname=%dbname% --file=%testDataPath%data-fixes.sql >> build.log 2>&1

echo Finished at %time% - Check build.log for errors!
echo Finished at %time% >> build.log 2>&1
pause