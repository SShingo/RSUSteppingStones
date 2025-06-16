
%macro Int_RSUStruct__DefineElement(i_struct_name =
												, i_element_name =
												, i_value =);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_struct_name i_element_name)
	%local /readonly _RSU_STRUCT_FULL = &i_struct_name.__&i_element_name.;
	%if (32 < %length(&_struct_full.)) %then %do;
		%&RSULogger.PutError(%&RSUMsg.STRUCT_TOO_LONG(&_RSU_STRUCT_FULL.))
	%end;

	%local /readonly _RSU_STRUCT_TMP_MACRO = %&RSUDS.GetTempDSName();
	proc catalog cat = WORK.sasmac1;
		contents out = &_RSU_STRUCT_TMP_MACRO.(where = (upcase(name) like upcase("&_RSU_STRUCT_FULL")));
	run;
	%if (not %&RSUDS.IsDSEmpty(&_RSU_STRUCT_TMP_MACRO.)) %then %do;
		%&RSULogger.PutWarning(%&RSUMsg.STRUCT_ALREADY_DEFINED(&_RSU_STRUCT_FULL.))
	%end;

	%local _struct_definition_fref;
	%let _struct_definition_fref = %&RSUFile.GetFileRef;
	data _null_;
		attrib
			code length = $1000.
		;
		file &_struct_definition_fref.;
		put "%macro &_RSU_STRUCT_FULL.;&i_value.%mend;";
	run;
	quit;
	%include &_struct_definition_fref.;
	%&RSUFile.ClearFileRef(_struct_definition_fref)
%mend Int_RSUStruct__DefineElement;