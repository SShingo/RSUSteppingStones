/***********************************************************************************
* PROGRAM NAME : RSU_DevModule_Boxing_Tool.sas
* DESCRIPTION : SAS Program to create RSU development module
* PROGRAMMER : Shingo Suzuki (RSU SAS Institute Japan)
* DATE WRITTEN : 2021/2/13
************************************************************************************/
%global g_module_info_name;
%let g_module_info_name = RSU Stepping Stones(c);
%global g_module_info_author;
%let g_module_info_author = Shingo Suzuki;
%global g_module_info_contact;
%let g_module_info_contact = shingo.suzuki@sas.com;
%global g_module_info_company;
%let g_module_info_company = SAS Institute Japan;
%global g_module_info_department;
%let g_module_info_department = Risk Solution Unit(RSU);
%global g_module_info_copyright;
%let g_module_info_copyright = 2021(c);

%macro PutError(i_msg =
               , i_show_sysmsg = 0);
   %put ERROR: &i_msg.;
   %if (&i_show_sysmsg. = 1) %then %do;
      %put ERROR: %sysfunc(sysmsg());
   %end;
   %abort cancel;
%mend PutError;

%macro VerifyDirectory(i_dir_path = );
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

   %local /readonly _did = %sysfunc(dopen(&_filref.)); 
   %if (&_did eq 0) %then %do; 
      %PutError(i_msg = Fail to open Directory "&i_dir_path."
            , i_show_sysmsg = 1)
   %end;

   %let _rc = %sysfunc(dclose(&_did.));
   %let _rc = %sysfunc(filename(_filref));
   %put "&i_dir_path." varified.;
%mend VerifyDirectory;

%macro VerifyFile(i_file_path = );
   %local _filref;
   %let _filref = F_%sysfunc(putn(&sysindex., HEX5));
   %local _rc;
   %let _rc = %sysfunc(filename(_filref, &i_file_path.));
   %if (&_rc. ne 0) %then %do;
      %PutError(i_msg = Fail to make fileref for "&i_file_path."
            , i_show_sysmsg = 1)
   %end;

   %if (not %sysfunc(fexist(&_filref.))) %then %do;
      %PutERROR(i_msg = File "&i_file_path." not found.)
   %end;

   %let _rc = %sysfunc(filename(_filref));
   %put "&i_file_path." varified.;
%mend VerifyFile;

%macro CheckIsDirEmpty(i_dir_path =
                     , i_version =);
   %put Checking if output directory "&i_dir_path." is empty;
   %local _rc;
   %local _dirref;
   %let _dirref = D_%sysfunc(putn(&sysindex., HEX5));
   %let _rc = %sysfunc(filename(_dirref, &i_dir_path.));
   %if (&_rc. ne 0) %then %do;
      %PutError(i_msg = Fail to make filere for "&i_dir_path."
            , i_show_sysmsg = 1)
   %end;

   %local _did;
   %let _did = %sysfunc(dopen(&_dirref));      
   %if (&_did. = 0) %then %do;
      %PutError(i_msg = Fail to open directory "&i_dir_path."
            , i_show_sysmsg = 1)
   %end;

   %local _no_of_entries;
   %let _no_of_entries = %sysfunc(dnum(&_did));

   %local _entry_name;
   %local _entry_path;
   %local _fileref;
   %local _index;
   %local _regex_ver;
   %let _regex_ver = %sysfunc(prxparse(/^[0-9a-zA-Z_]+_&i_version.\./));
   %local _no_of_remaining_files;
   %let _no_of_remaining_files = 0;
   %do _index = 1 %to &_no_of_entries.;
      %let _entry_name = %qsysfunc(dread(&_did, &_index));
      %if (%sysfunc(prxmatch(&_regex_ver., &_entry_name))) %then %do;
         %let _no_of_remaining_files = %eval(&_no_of_remaining_files. + 1);
      %end;
   %end;
   %syscall prxfree(_regex_ver);
   %let _rc = %sysfunc(dclose(&_did.));
   %let _rc = %sysfunc(filename(_dirref));

   %if (0 < &_no_of_remaining_files.) %then %do;
      %PutError(i_msg = Output dir. contains file(s) with version &i_version.)
   %end;
%mend CheckIsDirEmpty;

/* Clear exsiting files with the vesion */
%macro ClearDir(i_dir_path =);
   %put Clearing output directory "&i_dir_path.";
   %local _rc;
   %local _dirref;
   %let _dirref = D_%sysfunc(putn(&sysindex., HEX5));
   %let _rc = %sysfunc(filename(_dirref, &i_dir_path.));
   %if (&_rc. ne 0) %then %do;
      %PutError(i_msg = Fail to make filere for "&i_dir_path."
            , i_show_sysmsg = 1)
   %end;

   %local _did;
   %let _did = %sysfunc(dopen(&_dirref));      
   %if (&_did. = 0) %then %do;
      %PutError(i_msg = Fail to open directory "&i_dir_path."
            , i_show_sysmsg = 1)
   %end;

   %local _no_of_entries;
   %let _no_of_entries = %sysfunc(dnum(&_did));

   %local _entry_name;
   %local _entry_path;
   %local _fileref;
   %local _index;
   %local _regex_ver;
   %let _regex_ver = %sysfunc(prxparse(/^[0-9a-zA-Z_]+_v\d{3}\./));
   %do _index = 1 %to &_no_of_entries.;
      %let _entry_name = %qsysfunc(dread(&_did, &_index));
      %if (%sysfunc(prxmatch(&_regex_ver., &_entry_name))) %then %do;
         %let _entry_path = &i_dir_path./&_entry_name.;
         %let _fileref = F_&_index.;
         %let _rc = %sysfunc(filename(_fileref, &_entry_path.));
         %let _rc = %sysfunc(fdelete(&_fileref));
         %let _rc = %sysfunc(filename(_fileref));  
      %end;
   %end;
   %syscall prxfree(_regex_ver);
   %let _rc = %sysfunc(dclose(&_did.));
   %let _rc = %sysfunc(filename(_dirref));
%mend ClearDir;

%macro AppendData(iods_base_ds =
                  , i_dataset =);
   proc append base = &iods_base_ds. data = &i_dataset.;
   run;
   proc delete data = &i_dataset.;
   run;
%mend AppendData;

%macro WriteModuleInfo(i_module_name =
                     , i_version =
                     , i_author =
                     , i_contact =
                     , i_company =
                     , i_dept =
                     , i_copyright =
                     , iods_module_dataset =);
   data WORK.rsu_dev_module_info;
      attrib
         name length = $32.
         code length = $30000.
      ;
      name = 'INFO_MODULE_NAME';
      code = "&i_module_name.";
      output;
      name = 'INFO_VERSION';
      code = "&i_version.";
      output;
      name = 'INFO_AUTHOR';
      code = "&i_author.";
      output;
      name = 'INFO_CONTACT';
      code = "&i_contact.";
      output;
      name = 'INFO_COMPANY';
      code = "&i_company.";
      output;
      name = 'INFO_DEPARTMENT';
      code = "&i_dept.";
      output;
      name = 'INFO_COPYRIGHT';
      code = "&i_copyright.";
      output;
      name = 'INFO_BOXED_DATE';
      _now = datetime();
      _date = datepart(_now);
      _time = timepart(_now);
      code = catx(' ', put(_date, yymmdds10.), put(_time, time.));
      output;
      keep
         name
         code
      ;
   run;
   %AppendData(iods_base_ds = &iods_module_dataset.
               , i_dataset = WORK.rsu_dev_module_info);
%mend WriteModuleInfo;

%macro ReadSourceFile(i_file_path =
                     , i_program_name =
                     , iods_module_dataset =);
   data WORK.rsu_dev_module_src;
      attrib
         name length = $32.
         code length = $30000.
      ;
      infile "&i_file_path." lrecl = 3000 dlm = '07'x dsd missover end = eof;
      input code;
		code = trim(code);
      name = symget('i_program_name');
      name = compress(name);
      output;
		if (eof) then do;
			name = symget('i_program_name');
			name = compress(name);
			code = '/*<EndOfPackage/>*/';
			output;
		end;
   run;

   %AppendData(iods_base_ds = &iods_module_dataset.
               , i_dataset = WORK.rsu_dev_module_src);
   %put Info: Boxing &i_file_path. ...Done;
%mend ReadSourceFile;

%macro WriteSourceCodes(i_dir =
                        , iods_module_dataset =);
   %put ;
   %put =============================;
   %put  Boxing sas codes in &i_dir. ... Start;
   %put =============================;
   %local _filref;
   %let _filref = dir_src;
   %local _rc;
   %let _rc = %sysfunc(filename(_filref, &i_dir.));
   %local _did;
   %let _did = %sysfunc(dopen(&_filref.)); 
   %local _filename;
   %local _program_name;
   %local _no;
   %local _i;
	%local _file_len;
   %do _i = 1 %to %sysfunc(dnum(&_did.));
      %let _filename = %qsysfunc(dread(&_did., &_i.));
      %let _program_name = %scan(&_filename., 1, .);
		%let _file_len = %length(&_program_name.);
		%if (8 < &_file_len.) %then %do;
			%if (%substr(&_filename., 1, 8) = RSU_PKG_ and %upcase(%scan(&_filename., 2, .)) = SAS) %then %do;
				/* list */
				proc sql;
					insert into &iods_module_dataset.(name, code)
					values('CONF', "&_program_name.");
				quit;

				/* source */
				%ReadSourceFile(i_file_path = &i_dir./&_filename.
									, i_program_name = &_program_name.
									, iods_module_dataset = &iods_module_dataset.)
			%end;
		%end;
   %end;
   %let _rc = %sysfunc(dclose(&_did.));
   %let _rc = %sysfunc(filename(_filref));
   %put =============================;
   %put  Boxing sas codes ... End;
   %put =============================;
%mend writeSourceCodes;

%macro WriteClassCodes(i_dir =
                        , iods_module_dataset =);
   %put ;
   %put =====================================;
   %put  Boxing sas class codes ... Start;
   %put =====================================;
   %local _filref;
   %let _filref = dir_tmp;
   %local _rc;
   %let _rc = %sysfunc(filename(_filref, &i_dir.));
   %local _did;
   %let _did = %sysfunc(dopen(&_filref.)); 
   %local _i;
   %local _filename;
   %do _i = 1 %to %sysfunc(dnum(&_did.));
      %let _filename = %qsysfunc(dread(&_did., &_i.));
      %if (%substr(&_filename., 1, 8) = RSU_PKG_ and %upcase(%scan(&_filename., 2, .)) = SAS) %then %do;
         %ReadSourceFile(i_file_path = &i_dir./&_filename.
                        , i_program_name = %scan(&_filename., 1, .)
                        , iods_module_dataset = &iods_module_dataset.)
      %end;
   %end;
   %let _rc = %sysfunc(dclose(&_did.));
   %let _rc = %sysfunc(filename(_filref));
   %put =====================================;
   %put  Boxing sas class codes ... End;
   %put =====================================;

%mend WriteClassCodes;

%macro WriteActivationCode(i_file_path =
									, iods_module_dataset =);
   %put ;
   %put =====================================;
   %put  Boxing activation code ... Start;
   %put =====================================;
	%local _file_name;
	%let _file_name = %scan(&i_file_path., -1, /);
	%let _file_name = %scan(&i_file_path., 1, .);

	%ReadSourceFile(i_file_path = &i_file_path.
						, i_program_name = &_file_name.
						, iods_module_dataset = &iods_module_dataset.)
   %put =====================================;
   %put  Boxing activation code ... End;
   %put =====================================;
%mend WriteActivationCode;

%macro WriteMessageTable(i_message_file_path =
								, iods_module_dataset =);
   %put ;
   %put =============================;
   %put  Boxing message table ... Start;
   %put =============================;
   /* Load message definition */
	data WORK.messages;
		attrib
			key length = $32.
			en_US length = $500.
			ja_jp length = $500.
		;
		infile "&i_message_file_path" delimiter = '09'x dsd missover firstobs = 2;
		input
			key
			en_US
			ja_JP
		;
	run;

	proc sort data = WORK.messages;
      by
         key
      ;
   run;

   proc transpose data = WORK.messages out = WORK.messages_trans;
      var
         _all_
      ;
      by
         key
      ;
   run;

   data WORK.messages_trans;
      attrib
         locale length = $5.
         key length = $60.
         text length = $1200.
      ;
      set WORK.messages_trans(where = (_name_ ne 'key'));
      locale = _name_;
      text = unicodec(col1);
      drop
         _name_
         col1
      ;
   run;

   data WORK.rsu_dev_module_msg;
      attrib
         name length = $32.
         code length = $30000.
      ;
      set WORK.messages_trans;
      name = 'MESSAGE';
		if (lowcase(locale) = 'ja_jp') then do;
			locale = 'ja_JP';
		end;
      code = catx('09'x, locale, key, text);
      keep
         name
         code
      ;
   run;
   proc delete
      data = WORK.messages WORK.messages_trans;
   run;
   %AppendData(iods_base_ds = &iods_module_dataset.
               , i_dataset = WORK.rsu_dev_module_msg);
   %put Message definition file: "&i_message_file_path." imported.;
   %put =============================;
   %put  Boxing message table ... End;
   %put =============================;
%mend WriteMessageTable;

%macro EmbedHashcode(iods_module_dataset =);
   %local _hash;
   data _null_;
      attrib
         _hash format = $hex64.
         str_hash length = $32.
      ;
      set L_RSUMDL.&iods_module_dataset. end = eof;
      retain str_hash '';
      _hash = sha256(cats(str_hash, put(lineno, BEST.), name, code));
      str_hash = put(_hash, $hex64.);
      if (eof) then do;
         call symputx('_hash', str_hash);
      end;
   run;
   quit;
   proc datasets lib = L_RSUMDL nolist;
      modify &iods_module_dataset.(label = "&_hash.");
   run;
   quit;
%mend EmbedHashcode;

%macro DoBoxing(i_module_root_dir =
               , i_module_dataset_name =
               , i_version =
               , i_is_doc_generated =);

   proc optsave out = WORK.options_org;
   run;

   options nonotes nosource nosource2 nomlogic nomprint noquotelenmax;
   %local /readonly _MODULE_SOURCE_DIR = &i_module_root_dir./source;
   %local /readonly _MODULE_OUTPUT_DIR = &i_module_root_dir./developing;
   %local /readonly _MODULE_OUTPUT_DS = &i_module_dataset_name._&i_version.;
   options notes;
   %put ;
   %put NOTE-***************************************************************;
   %put NOTE-***************************************************************;
   %put ;
   %put NOTE-SAS Source file boxing tool.   &g_module_info_copyright. &g_module_info_company.;
   %put NOTE-Author: &g_module_info_author.;
   %put ;
   %put NOTE-***************************************************************;
   %put NOTE-***************************************************************;
   %put Parameters:;
   %put %str(        )- Module output dataset: &_MODULE_OUTPUT_DS.;
   %put %str(        )- Module version: &i_version.;
   %put %str(        )- Module root dir: &i_module_root_dir.;
   %put %str(        )- Module source file dir: &_MODULE_SOURCE_DIR.;
   %put %str(        )- Module output dir: &_MODULE_OUTPUT_DIR.;
   %put ;
   options nonotes;
   %VerifyDirectory(i_dir_path = &_MODULE_SOURCE_DIR.);
   %VerifyDirectory(i_dir_path = &_MODULE_OUTPUT_DIR.);
   %VerifyDirectory(i_dir_path = &_MODULE_SOURCE_DIR./class);
   %VerifyDirectory(i_dir_path = &_MODULE_SOURCE_DIR./internal);
   %VerifyFile(i_file_path = &_MODULE_SOURCE_DIR./messages.txt);
   %ClearDir(i_dir_path = &_MODULE_OUTPUT_DIR.)
   /* Create module dataset */
   libname L_RSUMDL "&_MODULE_OUTPUT_DIR." compress = yes;
   data L_RSUMDL.&_MODULE_OUTPUT_DS.;
      attrib
         name length = $32.
         code length = $30000.
      ;
      stop;
   run;
   /* Module info */
   %WriteModuleInfo(i_module_name = &g_module_info_name.
                  , i_version = &i_version.
                  , i_author = &g_module_info_author.
                  , i_contact = &g_module_info_contact.
                  , i_company = &g_module_info_company.
                  , i_dept = &g_module_info_department.
                  , i_copyright = &g_module_info_copyright.
                  , iods_module_dataset = L_RSUMDL.&_MODULE_OUTPUT_DS.)
   /* Public Source code */
   %WriteSourceCodes(i_dir = &_MODULE_SOURCE_DIR.
                     , iods_module_dataset = L_RSUMDL.&_MODULE_OUTPUT_DS.)
   /* Internal Source code */
   %WriteSourceCodes(i_dir = &_MODULE_SOURCE_DIR./internal
                     , iods_module_dataset = L_RSUMDL.&_MODULE_OUTPUT_DS.)
   /* Class code */
   %WriteClassCodes(i_dir = &_MODULE_SOURCE_DIR./class
                     , iods_module_dataset = L_RSUMDL.&_MODULE_OUTPUT_DS.)
   /* activtion code */
   %WriteActivationCode(i_file_path = &i_module_root_dir./rsu_steppingstones_activate.sas
                     , iods_module_dataset = L_RSUMDL.&_MODULE_OUTPUT_DS.)
   /* Message defintiion */
   %WriteMessageTable(i_message_file_path = &_MODULE_SOURCE_DIR./messages.txt
                     , iods_module_dataset = L_RSUMDL.&_MODULE_OUTPUT_DS.)
	data L_RSUMDL.&_MODULE_OUTPUT_DS.;
		attrib
			lineno length = 8.
		;
		set L_RSUMDL.&_MODULE_OUTPUT_DS.;
		lineno = _N_;
	run;
	quit;

   /* 改竄防止ハッシュコード付与 */
	%EmbedHashcode(iods_module_dataset = &_MODULE_OUTPUT_DS.)

   libname L_RSUMDL clear;
   options notes;
   %put ;
   %put NOTE-***************************************************************;
   %put NOTE-* Boxing finished successfully;
   %put NOTE-***************************************************************;
   %put ;
	options nonotes;
   proc optload data = WORK.options_org;
   run;
   proc delete
            data = WORK.options_org
         ;
   run;
%mend DoBoxing;
