options nonotes nosource nomlogic nomprint;
%rsu_steppingstones_activate_test(i_version = 200)
%&RSUDebug.Disable

%global g_locale;
%let g_locale = ja_jp;
%global g_rsu_dev_module_doc_root;
%let g_rsu_dev_module_doc_root = /sas/RSU/RSU_DevModule/doc; 
%global g_template_dir;
%let g_template_dir = &g_rsu_dev_module_doc_root./creator/resources/latex_templates;
%global g_latex_source_dir;
%let g_latex_source_dir = &g_rsu_dev_module_doc_root./latex/sources/&g_locale.;
%&RSUFile.IncludeSASCodeIn(&g_rsu_dev_module_doc_root./creator/components)
proc fcmp outlib = WORK.doc_functions.latex_conv;
	function make_texttt_string(i_org_string $) $;
		length _latex_code $30000;
		_latex_code = i_org_string;
		_latex_code = prxchange('s/([_#\$\%\&])/\\$1/o', -1, _latex_code);
		_latex_code = cats('\texttt{', _latex_code, '}');
		return (_latex_code);
	endsub;
run;
quit;
%&RSUUtil.InsertDirSASOption(i_option = cmplib
									, i_new_option = WORK.doc_functions)

%CreateDocment
