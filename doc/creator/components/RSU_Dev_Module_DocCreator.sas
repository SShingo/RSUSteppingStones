/****************
	メイン.
****************/
%macro CreateDocment;
	%local /readonly _RSU_DEV_MODULE_DS = L_RSUMDL.rsu_stepping_stones_%&RSUSys.GetVersion;
	%&RSULogger.PutSection(Creating RSU Development Module Document, Target Module: &_RSU_DEV_MODULE_DS., Locale: &g_locale.)

	%GatherDocumentInformation(ids_module_ds = &_RSU_DEV_MODULE_DS.
										, ods_global_constants = WORK.tmp_rdm_global_constants
										, ods_global_variables = WORK.tmp_rdm_global_variables
										, ods_formats = WORK.tmp_rdm_formats
										, ods_format_components = WORK.tmp_rdm_format_components
										, ods_structures = WORK.tmp_rdm_structures
										, ods_structure_members = WORK.tmp_rdm_structure_members
										, ods_categories = WORK.tmp_rdm_categories
										, ods_packages = WORK.tmp_rdm_packages
										, ods_package_details = WORK.tmp_rdm_package_details
										, ods_package_notes = WORK.tmp_rdm_package_notes
										, ods_package_functions = WORK.tmp_rdm_package_functions
										, ods_function_definition = WORK.tmp_rdm_function_definition
										, ods_function_arguments = WORK.tmp_rdm_function_arguments
										, ods_function_details = WORK.tmp_rdm_function_details
										, ods_function_notes = WORK.tmp_rdm_function_notes
										, ods_classes = WORK.tmp_rdm_classes
										, ods_class_creators = WORK.tmp_rdm_class_cretators
										, ods_class_details = WORK.tmp_rdm_class_details
										, ods_class_notes = WORK.tmp_rdm_class_notes
										, ods_class_functions = WORK.tmp_rdm_class_functions)
	%ConvertIntoTeXCode(iods_categories = WORK.tmp_rdm_categories
								, iods_global_constants = WORK.tmp_rdm_global_constants
								, iods_global_variables = WORK.tmp_rdm_global_variables
								, iods_formats = WORK.tmp_rdm_formats
								, iods_format_components = WORK.tmp_rdm_format_components
								, iods_structures = WORK.tmp_rdm_structures
								, iods_structure_members = WORK.tmp_rdm_structure_members
								, iods_packages = WORK.tmp_rdm_packages
								, iods_package_details = WORK.tmp_rdm_package_details
								, iods_package_notes = WORK.tmp_rdm_package_notes
								, iods_package_functions = WORK.tmp_rdm_package_functions
								, iods_function_definition = WORK.tmp_rdm_function_definition
								, iods_function_arguments = WORK.tmp_rdm_function_arguments
								, iods_function_details = WORK.tmp_rdm_function_details
								, iods_function_notes = WORK.tmp_rdm_function_notes
								, iods_classes = WORK.tmp_rdm_classes
								, iods_class_creators = WORK.tmp_rdm_class_cretators
								, iods_class_details = WORK.tmp_rdm_class_details
								, iods_class_notes = WORK.tmp_rdm_class_notes
								, iods_class_functions = WORK.tmp_rdm_class_functions)
	%OutputLaTeXCode(ids_categories = WORK.tmp_rdm_categories
						, ids_global_constants = WORK.tmp_rdm_global_constants
						, ids_global_variables = WORK.tmp_rdm_global_variables
						, ids_formats = WORK.tmp_rdm_formats
						, ids_format_components = WORK.tmp_rdm_format_components
						, ids_structures = WORK.tmp_rdm_structures
						, ids_structure_members = WORK.tmp_rdm_structure_members
						, ids_packages = WORK.tmp_rdm_packages
						, ids_package_details = WORK.tmp_rdm_package_details
						, ids_package_notes = WORK.tmp_rdm_package_notes
						, ids_package_functions = WORK.tmp_rdm_package_functions
						, ids_function_definition = WORK.tmp_rdm_function_definition
						, ids_function_arguments = WORK.tmp_rdm_function_arguments
						, ids_function_details = WORK.tmp_rdm_function_details
						, ids_function_notes = WORK.tmp_rdm_function_notes
						, ids_classes = WORK.tmp_rdm_classes
						, ids_class_creators = WORK.tmp_rdm_class_cretators
						, ids_class_details = WORK.tmp_rdm_class_details
						, ids_class_notes = WORK.tmp_rdm_class_notes
						, ids_class_functions = WORK.tmp_rdm_class_functions)
/*%&RSUDS.Delete(
	WORK.tmp_rdm_categories
	WORK.tmp_rdm_global_constants
	WORK.tmp_rdm_global_variables
	WORK.tmp_rdm_packages
	WORK.tmp_rdm_package_details
	WORK.tmp_rdm_package_notes
	WORK.tmp_rdm_package_functions
	WORK.tmp_rdm_function_definition
	WORK.tmp_rdm_function_arguments
	WORK.tmp_rdm_function_details
	WORK.tmp_rdm_function_notes
	WORK.tmp_rdm_formats
	WORK.tmp_rdm_format_components
	WORK.tmp_rdm_structures
	WORK.tmp_rdm_structure_members
	WORK.tmp_rdm_classes
	WORK.tmp_rdm_class_cretators
	WORK.tmp_rdm_class_details
	WORK.tmp_rdm_class_notes
	WORK.tmp_rdm_class_functions
)*/
%mend CreateDocment;

/*****************************************************************************************/
%macro GatherDocumentInformation(ids_module_ds =
											, ods_global_constants =
											, ods_global_variables =
											, ods_formats =
											, ods_format_components =
											, ods_structures =
											, ods_structure_members =
											, ods_categories =
											, ods_packages =
											, ods_package_details =
											, ods_package_notes =
											, ods_package_functions =
											, ods_function_definition =
											, ods_function_arguments =
											, ods_function_details =
											, ods_function_notes =
											, ods_classes =
											, ods_class_creators =
											, ods_class_details =
											, ods_class_notes =
											, ods_class_functions =);
	%&Cate.GatherDocInformation(ods_categories = &ods_categories.)
	%&Pkg.GatherDocInformation(ids_module_ds = &ids_module_ds.
										, ods_packages = &ods_packages.
										, ods_package_details = &ods_package_details.
										, ods_package_notes = &ods_package_notes.)
	%&PkgFunc.GatherDocInformation(ids_module_ds = &ids_module_ds.
											, ods_package_functions = &ods_package_functions.
											, ods_class_functions = &ods_class_functions.
											, ods_function_definition = &ods_function_definition.
											, ods_function_arguments = &ods_function_arguments.
											, ods_function_details = &ods_function_details.
											, ods_function_notes = &ods_function_notes.)
	%&Const.GatherDocInformation(ids_module_ds = &ids_module_ds.
										, ods_constants = &ods_global_constants.)
	%&GlbVar.GatherDocInformation(ids_module_ds = &ids_module_ds.
											, ods_global_variables = &ods_global_variables.)
	%&Format.GatherDocInformation(ids_module_ds = &ids_module_ds.
											, ods_formats = &ods_formats.
											, ods_format_components = &ods_format_components.)
	%&Struct.GatherDocInformation(ids_module_ds = &ids_module_ds.
											, ods_structures = &ods_structures.
											, ods_structure_members = &ods_structure_members.)
	%&Class.GatherDocInformation(ids_module_ds = &ids_module_ds.
											, ods_classes = &ods_classes.
											, ods_class_creators = &ods_class_creators.
											, ods_class_details = &ods_class_details.
											, ods_class_notes = &ods_class_notes.)
%mend GatherDocumentInformation;

%macro ConvertIntoTeXCode(iods_categories =
								, iods_global_constants =
								, iods_global_variables =
								, iods_formats =
								, iods_format_components =
								, iods_structures =
								, iods_structure_members =
								, iods_packages =
								, iods_package_details =
								, iods_package_notes =
								, iods_package_functions =
								, iods_function_definition =
								, iods_function_arguments =
								, iods_function_details =
								, iods_function_notes =
								, iods_classes =
								, iods_class_creators =
								, iods_class_details =
								, iods_class_notes =
								, iods_class_functions =);
	%&Cate.ConvertIntoTeXCode(iods_categories = &iods_categories.)
	%&Pkg.ConvertIntoTeXCode(iods_packages = &iods_packages.
										, iods_package_details = &iods_package_details.
										, iods_package_notes = &iods_package_notes)
	%&PkgFunc.ConvertIntoTeXCode(iods_package_functions = &iods_package_functions.
										, iods_class_functions = &iods_class_functions.
										, iods_function_definition = &iods_function_definition.
										, iods_function_arguments = &iods_function_arguments.
										, iods_function_details = &iods_function_details.
										, iods_function_notes = &iods_function_notes.)
	%&Const.ConvertIntoTeXCode(iods_constants = &iods_global_constants.)
	%&GlbVar.ConvertIntoTeXCode(iods_global_variables = &iods_global_variables.)
	%&Format.ConvertIntoTeXCode(iods_formats = &iods_formats.
										, iods_format_components = &iods_format_components.)
	%&Struct.ConvertIntoTeXCode(iods_structures = &iods_structures.
										, iods_structure_members = &iods_structure_members.)
	%&Class.ConvertIntoTeXCode(iods_classes = &iods_classes.
										, iods_class_creators = &iods_class_creators.
										, iods_class_details = &iods_class_details.
										, iods_class_notes = &iods_class_notes)
%mend ConvertIntoTeXCode;

%macro OutputLaTeXCode(ids_categories =
							, ids_global_constants =
							, ids_global_variables =
							, ids_formats =
							, ids_format_components =
							, ids_structures =
							, ids_structure_members =
							, ids_packages =
							, ids_package_details =
							, ids_package_notes =
							, ids_package_functions =
							, ids_function_definition =
							, ids_function_arguments =
							, ids_function_details =
							, ids_function_notes =
							, ids_classes =
							, ids_class_creators =
							, ids_class_details =
							, ids_class_notes =
							, ids_class_functions =);
	/* ロケール対応LaTeXマクロコマンド定義 */
	%&LaTeX.CreateLaTeXCommand(i_command_template_path = &g_rsu_dev_module_doc_root./creator/resources/doc_messages.txt
										, i_latex_source_path = &g_latex_source_dir./message_command.tex
										, i_locale = &g_locale.)

	/* Title */
	%&LaTeX.CreateTitle(i_latex_source_path = &g_latex_source_dir./title.tex);

	%&RSUDS.Delete(WORK.latex_source_code_full)
	/* Static LaTeX code */
	%&LaTeX.StaticLaTeXCode(iods_latex_source_code_ds = WORK.latex_source_code_full
									, i_locale = &g_locale.)

	/* Dynamical LaTeX code */
	/* カテゴリー一覧 */
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = category_table_row
											, i_file_name_def = "category_table_rows"
											, ids_source_ds = &ids_categories.
											, i_sort_keys = category_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	/* グローバル定数一覧 */
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = global_constant_table_row
											, i_file_name_def = "global_constant_table_rows"
											, ids_source_ds = &ids_global_constants.
											, i_sort_keys = global_constant_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	/* グローバル変数一覧 */
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = global_variable_table_row
											, i_file_name_def = "global_variable_table_rows"
											, ids_source_ds = &ids_global_variables.
											, i_sort_keys = global_variable_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	/* フォーマット/フォーマット成分 */
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = format_section
											, i_file_name_def = "format_sections"
											, ids_source_ds = &ids_formats.
											, i_sort_keys = format_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = format_component_table_row
											, i_file_name_def = cats("format_component_table_rows_in_", format_id)
											, ids_source_ds = &ids_format_components.
											, i_sort_keys = format_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	/* 構造体/構造体メンバー*/
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = structure_section
											, i_file_name_def = "structure_sections"
											, ids_source_ds = &ids_structures.
											, i_sort_keys = structure_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = structure_member_table_row
											, i_file_name_def = cats("structure_member_table_rows_in_", structure_id)
											, ids_source_ds = &ids_structure_members.
											, i_sort_keys = structure_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	/* カテゴリー別パッケージ一覧 */
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = category_section
											, i_file_name_def = "category_sections"
											, ids_source_ds = &ids_categories.
											, i_sort_keys = category_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = category_package_table_row
											, i_file_name_def = cats("category_package_table_rows_in_", category_id)
											, ids_source_ds = &ids_packages.
											, i_sort_keys = category_id package_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = package_section
											, i_file_name_def = cats("package_sections_", category_id)
											, ids_source_ds = &ids_packages.
											, i_sort_keys = category_id package_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	/* パッケージ/パッケージ内関数/パッケージ詳細/パッケージ注意 */
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = package_function_table_row
											, i_file_name_def = cats("package_function_table_rows_in_", package_id)
											, ids_source_ds = &ids_package_functions.
											, i_sort_keys = package_id function_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = function_definition
											, i_file_name_def = cats("function_definition_of_", function_id)
											, ids_source_ds = &ids_function_definition.
											, i_sort_keys = function_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = function_argument_table_row
											, i_file_name_def = cats("function_argument_table_rows_of_", function_id)
											, ids_source_ds = &ids_function_arguments.
											, i_sort_keys = function_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = function_detail_item
											, i_file_name_def = cats("function_detail_items_of_", function_id)
											, ids_source_ds = &ids_function_details.
											, i_sort_keys = function_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = function_note_item
											, i_file_name_def = cats("function_note_items_of_", function_id)
											, ids_source_ds = &ids_function_notes.
											, i_sort_keys = function_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = function_section
											, i_file_name_def = cats("function_sections_in_", package_id)
											, ids_source_ds = &ids_package_functions.
											, i_sort_keys = package_id function_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	/* クラス/クラス内関数/クラス詳細/クラス注意 */
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = class_table_row
											, i_file_name_def = "class_table_rows"
											, ids_source_ds = &ids_classes.
											, i_sort_keys = class_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = class_creator
											, i_file_name_def = cats("class_creator_of_", class_id)
											, ids_source_ds = &ids_class_creators.
											, i_sort_keys = class_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = class_section
											, i_file_name_def = "class_sections"
											, ids_source_ds = &ids_classes.
											, i_sort_keys = class_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = class_function_table_row
											, i_file_name_def = cats("class_function_table_rows_in_", class_id)
											, ids_source_ds = &ids_class_functions.
											, i_sort_keys = class_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = class_detail_item
											, i_file_name_def = cats("class_detail_items_of_", class_id)
											, ids_source_ds = &ids_class_details.
											, i_sort_keys = class_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = class_note_item
											, i_file_name_def = cats("class_note_items_of_", class_id)
											, ids_source_ds = &ids_class_notes.
											, i_sort_keys = class_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	%&LaTeX.CreateDynamicLaTeXCode(i_template_filename_body = function_section
											, i_file_name_def = cats("function_sections_in_", class_id)
											, ids_source_ds = &ids_class_functions.
											, i_sort_keys = class_id
											, iods_latex_source_code_ds = WORK.latex_source_code_full)
	/* 最終生成 */
	%&LaTeX.CreateIntegratedDocument(i_file_path = &g_template_dir./outline.txt
												, ids_latex_source_code_ds = WORK.latex_source_code_full)
	%&RSUDS.Delete(WORK.latex_source_code_full)
%mend OutputLaTeXCode;

%macro SetAggregation(iods_base =
							, ids_source =
							, i_agg_var =
							, i_flag_var =);

	proc sql;
		create table WORK.aggregated
		as
		select
			distinct &i_agg_var.
		from
			&ids_source.
		;
	quit;
	
	proc sort data = WORK.aggregated;
		by
			&i_agg_var.
		;
	run;
	quit;

	data &iods_base.;
		merge
			&iods_base.(in = in1)
			WORK.aggregated(in = in2)
		;
		by
			&i_agg_var.
		;
		if (in2) then do;
			&i_flag_var. = 1;
		end;
		else do;
			&i_flag_var. = 0;
		end;
		if (in1) then do;
			output;
		end;
	run;
	quit;

	%&RSUDS.Delete(WORK.aggregated)
%mend SetAggregation;
