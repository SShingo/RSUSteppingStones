%macro Prv_RSUMsg_CreateMsgDSHelper(i_libname =
												, iods_message_ds =);
	proc sort data = &i_libname..&iods_message_ds.;
		by
			locale
			key
			descending lineno
		;
	run;

	proc datasets lib = &i_libname. nodetails nolist
		memtype = data;
		modify &iods_message_ds.;
		index create indx = (locale key);
	run;
	quit;
%mend Prv_RSUMsg_CreateMsgDSHelper;

%macro Int_RSUMsg_Initialize(i_rsu_dev_module_name =);
	/* Load message definition */
	data L_RSUMDL.&RSU_G_MESSAGE_DS.;
		attrib
			locale length = $5.
			key length = $60.
			text length = $1200.
		;
		set L_RSUMDL.&i_rsu_dev_module_name.(where = (name = 'MESSAGE'));
		locale = scan(code, 1, &RSUTab.);
		key = scan(code, 2, &RSUTab.);
		text = scan(code, 3, &RSUTab.);
		keep
			locale
			key
			lineno
			text
		;
	run;
	quit;
	%Prv_RSUMsg_CreateMsgDSHelper(i_libname = L_RSUMDL
											, iods_message_ds = &RSU_G_MESSAGE_DS.)
%mend Int_RSUMsg_Initialize;

%macro Int_RSUMsg_DefineMsgFunction(ids_message_ds =
												, i_massage_prefix =);
	/* Generate Message Macros */
	%local /readonly RSU_MSG_TMP_MESSAGE_KEYS = %RSUDS__GetTempDSName();
	%&RSUDS.GetUniqueList(i_query = &ids_message_ds.(keep = key)
								, i_by_variables = key
								, ods_output_ds = &RSU_MSG_TMP_MESSAGE_KEYS.)
	/* Generate code */
	%local _message_key;
	%local /readonly _DS_ITER_MESSAGE = %&RSUDSIterator.Create(&RSU_MSG_TMP_MESSAGE_KEYS.);
	%do %while(%&RSUDSIterator.Next(_DS_ITER_MESSAGE));
		%let _message_key = %&RSUDSIterator.Current(_DS_ITER_MESSAGE, key);
		data _null_;
			attrib
				code length = $5000.
			;
			code = "%nrstr(%%)macro &RSUMsg.&_message_key.(i_args) / parmbuff;";
			code = cats(code, "%nrstr(%%)local _message;");
			code = cats(code, "%nrstr(%%)local _cmpressed_args;");
			code = cats(code, "%nrstr(%%)let _cmpressed_args = %nrstr(%%)cmpres(%nrstr(&)syspbuff.);");
			code = cats(code, "%nrstr(%%)if (2 < %nrstr(%%)length(%nrstr(&)_cmpressed_args.)) %nrstr(%%)then %nrstr(%%)do;");
			code = cats(code, "%nrstr(%%)local _parms;");
			code = cats(code, "%nrstr(%%)let _parms = %nrstr(%%)qsubstr(%nrstr(&)syspbuff., 2, %nrstr(%%)length(%nrstr(&)syspbuff.) - 2);");
			code = cats(code, "%nrstr(%%)Let _parms = %nrstr(%%)unquote(%nrstr(&)_parms.);");
			code = cats(code, "%nrstr(%%)let _message = %nrstr(%%)sysfunc(sasmsg(L_RSUMDL.&RSU_G_MESSAGE_DS., &_message_key., noquote, %nrstr(&)_parms.));");
			code = cats(code, "%nrstr(%%)end;");
			code = cats(code, "%nrstr(%%)else %nrstr(%%)do;");
			code = cats(code, "%nrstr(%%)let _message = %nrstr(%%)sysfunc(sasmsg(L_RSUMDL.&RSU_G_MESSAGE_DS., &_message_key., noquote));");
			code = cats(code, "%nrstr(%%)end;");
			code = cats(code, "%nrstr(%%)quote(%nrstr(&)_message.)");
			code = cats(code, "%nrstr(%%)mend;");
			call execute(code);
		run;
		quit;
	%end;
	%&RSUDSIterator.Dispose(_DS_ITER_MESSAGE)
	%&RSUDS.Delete(&RSU_MSG_TMP_MESSAGE_KEYS.)
%mend Int_RSUMsg_DefineMsgFunction;