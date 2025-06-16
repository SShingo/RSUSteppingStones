/***************************************************
   RSU Development Module アクティベーションプログラム
***************************************************/

/*----------
	Used only in this file.
-----------*/
%macro PutError(i_msg =
               , i_show_sysmsg = 0);
   %put ERROR: &i_msg.;
   %if (&i_show_sysmsg. = 1) %then %do;
      %put ERROR: %sysfunc(sysmsg());
   %end;
   %abort cancel;
%mend PutError;

%macro PutMessage(i_msg);
   %if (not &g_tmp_is_silent_activation.) %then %do;
      %put &i_msg.;
   %end;
%mend PutMessage;

%macro VerifyModuleDirectory(i_dir_path = );
   %local _filref;
   %let _filref = D_%sysfunc(putn(&sysindex., HEX5));
   %local _rc;
   %let _rc = %sysfunc(filename(_filref, &i_dir_path.));
   %if (&_rc. ne 0) %then %do;
      %PutError(i_msg = Fail to make fileref for "&i_dir_path."
               , i_show_sysmsg = 1)
   %end;

   %if (not %sysfunc(fexist(&_filref.))) %then %do;
      %PutError(i_msg = Directory "&i_dir_path." not found.)
   %end;

   %local /readonly _DID = %sysfunc(dopen(&_filref.));
   %if (&_DID eq 0) %then %do;
      %PutError(i_msg = Fail to open Directory "&i_dir_path."
					, i_show_sysmsg = 1)
   %end;

   %let _rc = %sysfunc(dclose(&_DID.));
   %let _rc = %sysfunc(filename(_filref));
%mend VerifyModuleDirectory;

/* 使用モジュール決定（バージョン指定） */
%macro ChooseRSUDevelopmentModule(i_dev_module_name_body =
											, i_version =
											, ovar_rsu_dev_module_name =
											, ovar_version =);
	%local _rsu_dev_module_name;
   /* Choose target module */
	%local _version;
   %if (&i_version. = _LATEST_) %then %do;
		/* ライブラリ内に存在する最新バージョンがターゲット */
      data _null_;
         set SASHELP.vtable(where = (libname = 'L_RSUMDL')) end = eof;
			retain version_max 0;
         retain regex_version;
			regex_version = prxparse("/^&i_dev_module_name_body._V(\d{3})$/o");
         if (prxmatch(regex_version, trim(memname))) then do;
            version = input(prxposn(regex_version, 1, trim(memname)), best.);
            if (version_max < version) then do;
               version_max = version;
            end;
         end;
         if (eof) then do;
            call symputx('_version', version_max);
         end;
      run;
		%if (%sysevalf(%superq(_version)=, boolean)) %then %do;
			%PutError(i_msg = Module not found in directory "%sysfunc(pathname(L_RSUMDL))".);
		%end;
		%let _rsu_dev_module_name = %lowcase(&i_dev_module_name_body.)_v&_version.;
   %end;
   %else %do;
		/* 指定バージョンがターゲット */
		%let _version = &i_version.;
		%let _rsu_dev_module_name = %lowcase(&i_dev_module_name_body.)_v&_version.;
   %end;
	%if (not %sysfunc(exist(L_RSUMDL.&_rsu_dev_module_name))) %then %do;
		%PutError(i_msg = Module "&_rsu_dev_module_name" not found in directory "%sysfunc(pathname(L_RSUMDL))".);
	%end;

	%PutMessage("&_rsu_dev_module_name." chosen. Verifying...)
	%CheckFalsification(i_rsu_dev_module_name = &_rsu_dev_module_name.)
	%let &ovar_version. = &_version.;
	%let &ovar_rsu_dev_module_name. = &_rsu_dev_module_name.;
%mend ChooseRSUDevelopmentModule;

%macro GetRSUDevelopmentModuleInfo(i_rsu_dev_module_name =
											, i_info_key =
											, o_info =);
   %local _info;
   data _null_;
      set L_RSUMDL.&i_rsu_dev_module_name.(where = (name = "INFO_%upcase(&i_info_key.)"));
      call symputx("&o_info.", code);
   run;
%mend GetRSUDevelopmentModuleInfo;

%macro IncludeAllSourceCode(i_rsu_dev_module_name =);
   %PutMessage(Activating all packages...)
   filename _inc temp;
	/* GlbalSettingを最初にアクティベート */
   data _null_;
      file _inc;
      put '%ActivatePackage(i_rsu_dev_module_name = &i_rsu_dev_module_name., i_package_name = RSU_PKG_GlobalSettings)';
   run;
	quit;

	data WORK.tmp_packages;
		set L_RSUMDL.&i_rsu_dev_module_name.(where = (name = 'CONF' and code ne 'RSU_PKG_GlobalSettings'));
	run;
	quit;
	proc sort data = WORK.tmp_packages;
		by
			code
		;
	run;
	quit;

   data _null_;
      file _inc mod;
      set WORK.tmp_packages;
      put '%ActivatePackage(i_rsu_dev_module_name = &i_rsu_dev_module_name., i_package_name = ' code + (-1) ')';
   run;
	quit;

   %include _inc;
   filename _inc clear;
	proc delete	data = WORK.tmp_packages;
	run;
	quit;

	%PutMessage(All packages activated successfully.)
%mend IncludeAllSourceCode;

%macro ActivatePackage(i_rsu_dev_module_name =
							, i_package_name =);
   filename _outcode temp;
   data _null_;
      set L_RSUMDL.&i_rsu_dev_module_name.(where = (name = "&i_package_name."));
      file _outcode;
      put code;
   run;
   %include _outcode;
   filename _outcode clear;
   %PutMessage(%str(        )Package "&i_package_name"... Activated.)
%mend ActivatePackage;

/*
   データセットの改竄チェック.
   ハッシュ値を作り直して、ラベルと一致するかで確認.
*/
%macro CheckFalsification(i_rsu_dev_module_name =);
   %local _attached_hash;
   data _null_;
      dsid = open("L_RSUMDL.&i_rsu_dev_module_name.");
      hash = attrc(dsid, 'label');
      call symputx('_attached_hash', hash);
      rc = close(dsid);
   run;
   quit;

   %local _recreated_hash;
   data _null_;
      attrib
         _hash format = $hex64.
         str_hash length = $32.
      ;
      set L_RSUMDL.&i_rsu_dev_module_name. end = eof;
      retain str_hash '';
      _hash = sha256(cats(str_hash, put(lineno, BEST.), name, code));
      str_hash = put(_hash, $hex64.);
      if (eof) then do;
         call symputx('_recreated_hash', str_hash);
      end;
   run;
   quit;

   %if (&_attached_hash. ne &_recreated_hash.) %then %do;
      %PutError(i_msg = Hash value does not match. The chosen module "&i_rsu_dev_module_name." may have been tempered!!)
   %end;
   %else %do;
      %PutMessage(The module dataset is verified (HASH = &_attached_hash.))
   %end;
%mend CheckFalsification;

/*------
   Helper functions
-------*/
%macro RSUSetConstant(i_name
                     , i_value);
   %if (not %symexist(&i_name.)) %then %do;
      %global /readonly &i_name. = &i_value.;
   %end;
	%else %do;
		%if ("&&&i_name." ne "&i_value.") %then %do;
			%put ERROR: Readonly macro variable "&i_name." has been defined and cannot be overwritten with different value.;
			%put ERROR: Current value: &&&i_name.;
			%put ERROR: New value: &i_value.;
			%put ERROR: **** You need to close this session and restart new session. ****;
			%abort cancel;
		%end;
	%end;
%mend RSUSetConstant;

%macro RSUShowActivationStartTitle(i_rsu_dev_module_name =);
	options nonotes;
   %local _module_name;
	%GetRSUDevelopmentModuleInfo(i_rsu_dev_module_name = &i_rsu_dev_module_name.
										, i_info_key = module_name
										, o_info = _module_name)
   %local _version;
	%GetRSUDevelopmentModuleInfo(i_rsu_dev_module_name = &i_rsu_dev_module_name.
										, i_info_key = version
										, o_info = _version)
   %local _author;
	%GetRSUDevelopmentModuleInfo(i_rsu_dev_module_name = &i_rsu_dev_module_name.
										, i_info_key = author
										, o_info = _author)
   %local _contact;
	%GetRSUDevelopmentModuleInfo(i_rsu_dev_module_name = &i_rsu_dev_module_name.
										, i_info_key = contact
										, o_info = _contact)
   %local _boxed_date;
	%GetRSUDevelopmentModuleInfo(i_rsu_dev_module_name = &i_rsu_dev_module_name.
										, i_info_key = boxed_date
										, o_info = _boxed_date)
   %local _copyright;
	%GetRSUDevelopmentModuleInfo(i_rsu_dev_module_name = &i_rsu_dev_module_name.
										, i_info_key = copyright
										, o_info = _copyright)
   %local _company;
	%GetRSUDevelopmentModuleInfo(i_rsu_dev_module_name = &i_rsu_dev_module_name.
										, i_info_key = company
										, o_info = _company)
   %local _department;
	%GetRSUDevelopmentModuleInfo(i_rsu_dev_module_name = &i_rsu_dev_module_name.
										, i_info_key = department
										, o_info = _department)
   options notes;
   %put;
   %put NOTE-**********************************************************************************;
   %put NOTE-**********************************************************************************;
   %put NOTE-  &_module_name. &_version.;
   %put;
   %put NOTE-  Author: &_author. (&_contact.);
   %put NOTE-  Boxed: &_boxed_date;
   %put;
   %put NOTE-                         &_copyright. &_company. &_department.;
   %put NOTE-**********************************************************************************;
   %put NOTE-**********************************************************************************;
   %put;
   options nonotes;
%mend RSUShowActivationStartTitle;

%macro RSUShowActivationEndTitle(i_rsu_dev_module_name =);
   options nonotes;
   %local _module_name;
	%GetRSUDevelopmentModuleInfo(i_rsu_dev_module_name = &i_rsu_dev_module_name.
										, i_info_key = module_name
										, o_info = _module_name)
   %local _version;
	%GetRSUDevelopmentModuleInfo(i_rsu_dev_module_name = &i_rsu_dev_module_name.
										, i_info_key = version
										, o_info = _version)
   %local _company;
	%GetRSUDevelopmentModuleInfo(i_rsu_dev_module_name = &i_rsu_dev_module_name.
										, i_info_key = company
										, o_info = _company)
   %local _department;
	%GetRSUDevelopmentModuleInfo(i_rsu_dev_module_name = &i_rsu_dev_module_name.
										, i_info_key = department
										, o_info = _department)
   options notes;
   %put;
   %put NOTE-***************************************************************************************;
   %put NOTE-  &_module_name. &_version. Activated Successfully.;
   %put NOTE-                    Enjoy!!! from &_company. &_department. with LOVE;
   %put NOTE-***************************************************************************************;
   %put;
   %put;
	options nonotes;
%mend RSUShowActivationEndTitle;

%macro Int_InsertDirSASOptionHelper(i_option =
												, i_new_option =);
   %local /readonly _REGISTERED_DIRS = %nrbquote(%sysfunc(getoption(&i_option.)));
   %local _new_option_str;
	%let _new_option_str = %sysfunc(transtrn(&i_new_option., /, \/));
	%let _new_option_str = %sysfunc(transtrn(&_new_option_str., ., \.));
   %local _regex_dir;
	%let _regex_dir = %sysfunc(prxparse(/"&_new_option_str."/));
   %if (not %sysfunc(prxmatch(&_regex_dir., &_REGISTERED_DIRS.))) %then %do;
      options insert = (&i_option. = ("&i_new_option."));
   %end;
   %syscall prxfree(_regex_dir);
%mend Int_InsertDirSASOptionHelper;

%macro SetBinDir(i_dir =);
	%local _searched_bin_dir;
	%if (%sysevalf(%superq(i_dir)=, boolean)) %then %do;
		%if (not %symexist(G_SAS_RSU_DEV_MODULE_ROOT_DIR)) %then %do;
			%put ERROR- Cannot search the module. You need to specify search path by giving it as argument "i_dir" (or set global macro variable "G_SAS_RSU_DEV_MODULE_ROOT_DIR" to the path to root directory path of RSU Development Module.).;
			%abort cancel;
		%end;
		%let _searched_bin_dir = &G_SAS_RSU_DEV_MODULE_ROOT_DIR./bin;
	%end;
	%else %do;
		%let _searched_bin_dir = &i_dir.;
	%end;

   %VerifyModuleDirectory(i_dir_path = &_searched_bin_dir.)
/*<ConstantDesc ja_jp>クラスファイルが作られるディレクトリパス</ConstantDesc ja_jp>*/
/*<AltValue ja_jp>環境依存（例：\texttt{/sas/RSU/RSU\_DevModule}）</AltValue ja_jp>*/
	%RSUSetConstant(RSU_G_CLASS_DEFINITION_DIR, &_searched_bin_dir.)
%mend SetBinDir;

/*******************************************
	Activation
*******************************************/
%macro rsu_steppingstones_activate(i_dir =							/* モジュール保存ディレクトリパス */
											, i_version = _LATEST_			/* 使用バージョン（整数3桁）*/
											, i_always_reload = 1			/* 常にモジュールを再読み込みするか否か */
											, i_execution_mode = RELEASE	/* 実行モード */
											, i_recreate_suppl_ds = 0		/* 補助データセット生成フラグ */
											, i_is_silent_mode = 0);		/* サイレントモードでアクティベーションするか否か */
/*<ConstantDesc ja_jp>RSU Stepping Stones の module 本体名</ConstantDesc ja_jp>*/
	%RSUSetConstant(RSU_G_DEV_MODULE_NAME_BODY, RSU_STEPPING_STONES)

	options linesize = max;
	proc printto;
	run;
	quit;

   proc optsave out = WORK.tmp_options_org;
   run;
	quit;
   options nonotes nosource nosource2 nomlogic nomprint noquotelenmax;

	%global g_tmp_is_silent_activation;
	%let g_tmp_is_silent_activation = &i_is_silent_mode;

	%put RSU Development Module Activating...;
	%SetBinDir(i_dir = &i_dir.);
   libname L_RSUMDL "&RSU_G_CLASS_DEFINITION_DIR." compress = yes;

	%local _chosen_version;
	%local _chosen_dev_module_name;
   %ChooseRSUDevelopmentModule(i_dev_module_name_body = &RSU_G_DEV_MODULE_NAME_BODY.
										, i_version = &i_version.
										, ovar_rsu_dev_module_name = _chosen_dev_module_name
										, ovar_version = _chosen_version)
/*<ConstantDesc ja_jp>選択された RSU Develoment Module 本体名</ConstantDesc ja_jp>*/
/*<AltValue ja_jp>環境依存（例：\texttt{rsu\_dev\_module\_v200}）</AltValue ja_jp>*/
   %RSUSetConstant(RSU_G_DEV_MODULE_NAME, &_chosen_dev_module_name.)
/*<ConstantDesc ja_jp>Quasi Obgject テンプレートコード</ConstantDesc ja_jp>*/
	%RSUSetConstant(RSU_G_CLASS_TEMPLATE_DS, rsu_class_templates_v&_chosen_version.)
/*<ConstantDesc ja_jp>FCMPデータセット名</ConstantDesc ja_jp>*/
	%RSUSetConstant(RSU_G_FCMP_PACKAGE, rsu_package_fcmp_v&_chosen_version.)
/*<ConstantDesc ja_jp>デフォルトメッセージ定義データセット名</ConstantDesc ja_jp>*/
	%RSUSetConstant(RSU_G_MESSAGE_DS, rsu_messages_v&_chosen_version.)
	/*-------
		Start loading codes
	--------*/
	%if (not %symexist(RSU_G_ACTIVATED) or &i_always_reload.) %then %do;
		%RSUShowActivationStartTitle(i_rsu_dev_module_name = &RSU_G_DEV_MODULE_NAME.)
		/* Include Source files */
		%IncludeAllSourceCode(i_rsu_dev_module_name = &RSU_G_DEV_MODULE_NAME.)
		%if (&i_recreate_suppl_ds.) %then %do;
			%PutMessage(Compiling FCMP functions...);
			%RSUFCMPCompile()

			%PutMessage(Initializing RSU stepping stones messages...);
			%Int_RSUMsg_Initialize(i_rsu_dev_module_name = &RSU_G_DEV_MODULE_NAME.)
		%end;
	%end;

	/* Initialize System */
   %Int_InsertDirSASOptionHelper(i_option = cmplib
											, i_new_option = L_RSUMDL.&RSU_G_FCMP_PACKAGE.)
   %Int_InsertDirSASOptionHelper(i_option = sasautos
											, i_new_option = &RSU_G_CLASS_DEFINITION_DIR.)
   %PutMessage(Cleanup debries of macros and macro variables...);
   %&RSUClass.CleanupAll()

   /* Intialize Error */
   %PutMessage(Initilalize Error System)
	%&RSUError.Initialize()

	/* Generate Message Macros */
   %PutMessage(Initilalize Messaging System)
	%Int_RSUMsg_DefineMsgFunction(ids_message_ds = L_RSUMDL.&RSU_G_MESSAGE_DS.
											, i_massage_prefix = RSUMsg__)
	
	/* Intialize Logger */
   %&RSULogger.Initialize(i_conf_id = MID)

   /* Set Execution Mode */
   %if (%upcase(&i_execution_mode.) = DEBUG) %then %do;
      %&RSUDebug.Enable()
   %end;
   %else %do;
      %&RSUDebug.Disable()
   %end;

	%symdel g_tmp_is_silent_activation;
   proc optload data = WORK.tmp_options_org(where = (upcase(optname) ne 'CMPLIB' and upcase(optname) ne 'SASAUTOS' and upcase(optname) ne 'NOTES' and upcase(optname) ne 'SOURCE' and upcase(optname) ne 'SOURCE2' and upcase(optname) ne 'MPRINT' and upcase(optname) ne 'MLOGIC'));
   run;
   quit;
	proc delete	data = WORK.tmp_options_org;
	run;
	quit;

/*<ConstantDesc ja_jp>RSU Stepping Stones起動状態</ConstantDesc ja_jp>*/
	%RSUSetConstant(RSU_G_ACTIVATED, 1)

	%RSUShowActivationEndTitle(i_rsu_dev_module_name = &RSU_G_DEV_MODULE_NAME.)
%mend rsu_steppingstones_activate;
