%macro Prv_RSUDS_PutDSHelper(i_dest_file =
									, ids_src_dataset =
									, i_delimiter =
									, i_is_header_skipped =);
	%local /readonly _DELIMITER = %&RSUUtil.Choose(%eval(&i_delimiter. ne &RSUTab.), "&i_delimiter.", &RSUTab.);

	/* Header */
	%local _modifier;
	%if (not &i_is_header_skipped.) %then %do;
		%local _vars;
		%RSUDS__GetDSVariables(ids_dataset = &ids_src_dataset.
									, ovar_variables = _vars);
		/* Read text and put to dest file */
		data _null_;
			file &i_dest_file.;
			attrib
				_vars length = $10000.
			;
			_vars = tranwrd(trim("&_vars."), ' ', &_DELIMITER.);
			put _vars;
		run;	
		quit;
		%if (&i_dest_file. ne log) %then %do;
			%let _modifier = mod;
		%end;
	%end;
	data _null_;
		file &i_dest_file. delimiter = &_DELIMITER. &_modifier.;
		set &ids_src_dataset.;
		put (_all_)( +0 );
	run;
	quit;	
%mend Prv_RSUDS_PutDSHelper;

%macro Prv_RSUDS__GetDSPropertyC(ids_dataset = 
										, i_property_name =);
	%local /readonly _RSUDS_GETPROP_DSID = %Int_RSUUtil_VerifyID(i_id = %sysfunc(open(&ids_dataset., I)));
	%local /readonly _RSUDS_GETPROP_PROP = %sysfunc(attrc(&_RSUDS_GETPROP_DSID., &i_property_name.));
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(close(&_RSUDS_GETPROP_DSID.)))
	&_RSUDS_GETPROP_PROP.
%mend Prv_RSUDS__GetDSPropertyC;

%macro Prv_RSUDS__GetDSPropertyN(ids_dataset = 
										, i_property_name =);
	%local /readonly _RSUDS_GETPROP_DSID = %Int_RSUUtil_VerifyID(i_id = %sysfunc(open(&ids_dataset., I)));
	%local /readonly _RSUDS_GETPROP_PROP = %sysfunc(attrn(&_RSUDS_GETPROP_DSID., &i_property_name.));
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(close(&_RSUDS_GETPROP_DSID.)))
	&_RSUDS_GETPROP_PROP.
%mend Prv_RSUDS__GetDSPropertyN;

%macro Int_RSUDS_IsVarDefined(i_dsid =
										, i_var_name =);
	%local _varnum;
	%let _varnum = %sysfunc(varnum(&i_dsid., &i_var_name));
	%&RSUUtil.Choose(%eval(0 < &_varnum.), %&RSUBool.True, %&RSUBool.False)
%mend Int_RSUDS_IsVarDefined;

%macro Int_RSUDS_GetCurrentRecord(i_dsid =
											, i_delimiter =);
	%local _no_of_vars;
	%let _no_of_vars = %sysfunc(attrn(&i_dsid., nvars));
	%local _values;
	%local _val;
	%local _i;
	%do _i = 1 %to &i_no_of_vars.;
		%let _val = %sysfunc(RSU_fcmp_get_curr_by_num(&i_dsid., &_i.));
		%&RSUText.Append(iovar_base = _values
							, i_append_text = &_val.
							, i_delimiter = &i_delimiter.)
	%end;
	&_values.
%mend Int_RSUDS_GetCurrentRecord;

%macro Int_RSUDS_GetType(ids_dataset =
								, i_variable =
								, ovar_vartype =);
	data _null_;
		set &ids_dataset.;
		call symputx("&ovar_vartype.", VTYPE(&i_variable.));
		stop;
	run;
	quit;
%mend Int_RSUDS_GetType;

%macro Int_RSUDS_ConvertIfNumeric(i_variable_src
											, i_variable_dest
											, i_vartype);
	%if (&i_vartype. = C) %then %do;
		&i_variable_dest. = &i_variable_src.;
	%end;
	%else %do;
		&i_variable_dest. = putn(&i_variable_src., 'BEST.-L');
	%end;
%mend Int_RSUDS_ConvertIfNumeric;