
/***************************/
%let g_version = 500;
/***************************/
%rsu_steppingstones_activate_test(i_version = &g_version.)
/* Backup source code */
x mkdir -p &G_SAS_RSU_DEV_MODULE_ROOT_DIR./_prev_versions/v&g_version.;
x rm -rf "&G_SAS_RSU_DEV_MODULE_ROOT_DIR./_prev_versions/v&g_version./"*;
x cp -r "&G_SAS_RSU_DEV_MODULE_ROOT_DIR./source" "&G_SAS_RSU_DEV_MODULE_ROOT_DIR./_prev_versions/v&g_version.";
x cp "&G_SAS_RSU_DEV_MODULE_ROOT_DIR./"*.sas "&G_SAS_RSU_DEV_MODULE_ROOT_DIR./_prev_versions/v&g_version.";
/* Locate released binnary */
x rm -f "&G_SAS_RSU_DEV_MODULE_ROOT_DIR./bin/"*_v&g_version.*;
x cp &G_SAS_RSU_DEV_MODULE_ROOT_DIR./developing/&RSU_G_DEV_MODULE_NAME..sas7bdat "&G_SAS_RSU_DEV_MODULE_ROOT_DIR./bin/";
x cp &G_SAS_RSU_DEV_MODULE_ROOT_DIR./developing/&RSU_G_CLASS_TEMPLATE_DS..sas7bdat "&G_SAS_RSU_DEV_MODULE_ROOT_DIR./bin/";
x cp &G_SAS_RSU_DEV_MODULE_ROOT_DIR./developing/&RSU_G_FCMP_PACKAGE..sas7bdat "&G_SAS_RSU_DEV_MODULE_ROOT_DIR./bin/";
x cp &G_SAS_RSU_DEV_MODULE_ROOT_DIR./developing/&RSU_G_FCMP_PACKAGE..sas7bndx "&G_SAS_RSU_DEV_MODULE_ROOT_DIR./bin/";
x cp &G_SAS_RSU_DEV_MODULE_ROOT_DIR./developing/&RSU_G_MESSAGE_DS..sas7bdat "&G_SAS_RSU_DEV_MODULE_ROOT_DIR./bin/";
x cp &G_SAS_RSU_DEV_MODULE_ROOT_DIR./developing/&RSU_G_MESSAGE_DS..sas7bndx "&G_SAS_RSU_DEV_MODULE_ROOT_DIR./bin/";
