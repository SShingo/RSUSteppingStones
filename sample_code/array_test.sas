%rsu_steppingstones_activate()

%macro Array__Internal_Parse(i_array_info =
									, ovar_array_name =
									, ovar_array_id =
									, ovar_item_index =
									, ovar_item_index_formatted =);
	%local _regex_array;
	%let _regex_array = %sysfunc(prxparse(/^(\w+)\[(\d+)\]$/));
	%local /readonly _MATCHED = %sysfunc(prxmatch(&_regex_array., &ivar_array_info.));
	%let &ovar_array_name. = %sysfunc(prxposn(&_regex_array., 1, &ivar_array_info.));
	%local /readonly _TMP_ARRAY_ID = &&&ovar_array_name.;
	%let &ovar_array_id. = &&&_TMP_ARRAY_ID.;
	%let &ovar_item_index. = %sysfunc(prxposn(&_regex_array, 2, &ivar_array_info.));
	%let &ovar_item_index_formatted. = %sysfunc(RSU_fcmp_get_sequence(&&&ovar_item_index., 36, 7));
	%syscall prxfree(_regex_array);
%mend Array__Internal_Parse;

%macro Array__Internal_Create(i_array_id
										, i_query
										, i_variable);
	%local _val;
	%local _dsid;
	%local _item_index;
	%let _item_index = 0;
	%local _item_index_formatted;
	%do %while(%&RSUDS.ForEach(i_query = &i_query.
										, i_vars = _val:&i_variable.
										, ovar_dsid = _dsid));
		%let _item_index_formatted = %sysfunc(RSU_fcmp_get_sequence(&_item_index., 36, 7));
		%global &i_array_id._&_item_index_formatted;
		%let &i_array_id._&_item_index_formatted = &_val.;
		%let _item_index = %eval(&_item_index. + 1);
	%end;
%mend Array__Internal_Create;

%macro Array__GetMacroVariableList(ivar_array =
											, ods_variable_list =
											, i_kept_vars =);
	%local /readonly _ARRAY_ID = &&&ivar_array.;
	data &ods_variable_list.;
		set SASHELP.vmacro(where = (name like "&_ARRAY_ID._%"));
	run;
	quit;
	proc sort data = &ods_variable_list. out = &ods_variable_list.(keep = &i_kept_vars.);
		by
			name
		;
	run;
	quit;
%mend Array__GetMacroVariableList;

%macro Array__CreateByDataset(i_query
										, i_variable);
	%local /readonly _ARRAY_ID = %&RSUUtil.GetSequenceId(i_prefix = g_RSU_INST_ARI_
																		, iovar_sequence = RSU_g_sequence_library
																		, i_digit = 4);
	%Array__Internal_Create(&_ARRAY_ID.
									, &i_query.
									, &i_variable.)
	&_ARRAY_ID.
%mend Array__CreateByDataset;

%macro Array__Create(i_items);
	%local /readonly _ARRAY_ID = %&RSUUtil.GetSequenceId(i_prefix = g_RSU_INST_ARI_
																		, iovar_sequence = RSU_g_sequence_library
																		, i_digit = 4);
	%local _val;
	%local _index;
	%local _item_index;
	%let _item_index = 0;
	%local _item_index_formatted;
	%do %while(%&RSUUtil.ForEach(i_items = &i_items.
										, ovar_item = _val
										, iovar_index = _index));
		%let _item_index_formatted = %sysfunc(RSU_fcmp_get_sequence(&_item_index., 36, 7));
		%global &_ARRAY_ID._&_item_index_formatted;
		%let &_ARRAY_ID._&_item_index_formatted = &_val.;
		%let _item_index = %eval(&_item_index. + 1);
	%end;
	&_ARRAY_ID.
%mend Array__Create;

%macro Array__Dispose(ivar_array);
	%local /readonly _ARRAY_ID_DISPOSE = &&&ivar_array.;
	%Dispose(&_ARRAY_ID_DISPOSE.)
%mend Array__Dispose;

%macro Array__Show(ivar_array);
	%local /readonly _ARRAY_ID_SHOW = &&&ivar_array.;
	%local _item_index;
	%let _item_index = 0;
	%local _value;
	%local _dsid;
	%do %while(%&RSUDS.ForEach(i_query = SASHELP.vmacro(where = (name like "&_ARRAY_ID_SHOW._%"))
										, i_vars = _value:value
										, ovar_dsid = _dsid));
		%let _item_index = %eval(&_item_index. + 1);
		%put &ivar_array.[&_item_index.] = &_value.;
	%end;
%mend Array__Show;

%macro Array__Size(ivar_array);
	%local /readonly _ARRAY_ID_SIZE = &&&ivar_array.;
	%&RSUDS.GetCount(SASHELP.vmacro(where = (name like "&_ARRAY_ID_SIZE._%")))
%mend Array__Size;

%macro Array__IsEmpty(ivar_array);
	%local /readonly _ARRAY_ID_ISEMPTY = &&&ivar_array.;
	%eval(%&RSUDS.GetCount(SASHELP.vmacro(where = (name like "&_ARRAY_ID_ISEMPTY._%"))) = 0)
%mend Array__IsEmpty;

%macro Array__Get(ivar_array_info);
	%local _array_name;
	%local _array_id;
	%local _item_index;
	%local _item_index_formatted;
	%Array__Internal_Parse(i_array_info = &ivar_array_info.
									, ovar_array_name = _array_name
									, ovar_array_id = _array_id
									, ovar_item_index = _item_index
									, ovar_item_index_formatted = _item_index_formatted)
	&&&_array_id._&_item_index_formatted.
%mend Array__Get;

%macro Array__Add(ivar_array
						, item);
	%local _new_item_index;
	%let _new_item_index = %eval(%Array__Size(&ivar_array.) + 1);
	%let _new_item_index = %sysfunc(RSU_fcmp_get_sequence(&_new_item_index., 36, 7));
	%local /readonly _ARRAY_ID = &&&ivar_array.;
	%global &_ARRAY_ID._&_new_item_index;
	%let &_ARRAY_ID._&_new_item_index = &item.;		
%mend Array__Add;

%macro Array__RemoveAt(ivar_array
							, i_index);
	%local _rc;
	%local /readonly _ARRAY_ID_REMOVE = &&&ivar_array.;
	%local _dsid;
	%local _rc_ds;
	%let _dsid = %sysfunc(open(SASHELP.vmacro(where = (name like "&_ARRAY_ID_REMOVE._%")), IN));	
	%let _rc_ds = %sysfunc(fetchobs(&_dsid., &i_index.));
	%if (&_rc_ds. = 0) %then %do;
		%local /readonly _MACRO_VAR = %sysfunc(getvarc(&_dsid., 2));
		%let _rc_ds = %sysfunc(close(&_dsid.));
		%symdel &_MACRO_VAR.;
		%let _rc = %&RSUBool.True;
	%end;
	%else %do;
		%let _rc = %&RSUBool.False;
	%end;
	&_rc.
%mend Array__RemoveAt;

%macro Array__Set(ivar_array_info
						, i_value);
	%local _array_name;
	%local _array_id;
	%local _item_index;
	%local _item_index_formatted;
	%Array__Internal_Parse(i_array_info = &ivar_array_info.
									, ovar_array_name = _array_name
									, ovar_array_id = _array_id
									, ovar_item_index = _item_index
									, ovar_item_index_formatted = _item_index_formatted)

	%local /readonly _ARRAY_ID_SET = &&&ivar_array.;
	%local _dsid;
	%local _rc_ds;
	%let _dsid = %sysfunc(open(SASHELP.vmacro(where = (name like "&_ARRAY_ID_SET._%")), IN));		
	%let _rc_ds = %sysfunc(fetchobs(&_dsid., &i_index.));
	%local /readonly _MACRO_VAR = %sysfunc(getvarc(&_dsid., 2));
	%let _rc_ds = %sysfunc(close(&_dsid.));
	%let &_MACRO_VAR. = &i_value.;
	%Array__Size(&ivar_array.)
%mend Array__Set;

%macro Array__Clear(ivar_array);
	%Array__Dispose(&ivar_array.);
%mend Array__Clear;

%macro Array__Insert(ivar_array
							, i_index
							, i_value);
	%local /readonly _TMP_DS_MACRO_VARIABLES_NEW = %&RSUDS.GetTempDSName();
	%Array__GetMacroVariableList(ivar_array = &ivar_array.
										, ods_variable_list = &_TMP_DS_MACRO_VARIABLES_NEW.
										, i_kept_vars = value)
	%if (%&RSUDS.IsDSEmpty(&_TMP_DS_MACRO_VARIABLES_NEW.)) %then %do;
		data &_TMP_DS_MACRO_VARIABLES_NEW.;
			if (0) then do;
				set SASHELP.vmacro(keep = value);
			end;
			value = "&i_value.";
			output;
		run;
		quit;
	%end;
	%else %do;
		data &_TMP_DS_MACRO_VARIABLES_NEW.(drop = _tmp_value);
			%RSUDS__GetVariableAttr(ids_dataset = &_TMP_DS_MACRO_VARIABLES_NEW.
										, i_variable = value
										, i_variable_new = _tmp_value);
			set &_TMP_DS_MACRO_VARIABLES_NEW.;
			if (_N_ = &i_index.) then do;
				_tmp_value = value;
				value = "&i_value.";
				output;
				value = _tmp_value;
			end;
			output;
		run;
		quit;
	%end;
	%Array__Dispose(&ivar_array.)
	%local /readonly _ARRAY_ID_INSERT = &&&ivar_array.;
	%Array__Internal_Create(&_ARRAY_ID_INSERT.
									, &_TMP_DS_MACRO_VARIABLES_NEW.
									, value)
	%&RSUDS.Delete(&_TMP_DS_MACRO_VARIABLES_NEW.)
%mend Array__Insert;

%macro Array__Pop(ivar_array);
	%local /readonly _FIST_VALUE = %Array__Peek(&ivar_array);
	%local /readonly _RC_REMOVED =%Array__RemoveAt(&ivar_array.
																, i_index = 1);
	&_FIST_VALUE.
%mend Array__Pop;

%macro Array__Push(ivar_array
						, i_value);
	%Array__Insert(&ivar_array.
						, 1
						, &i_value)
%mend Array__Push;

%macro Array__Peek(ivar_array);
	%local /readonly _ARRAY_ID_PEEK = &&&ivar_array.;
	%local _dsid;
	%local _rc_ds;
	%let _dsid = %sysfunc(open(SASHELP.vmacro(where = (name like "&_ARRAY_ID_PEEK._%")), IN));		
	%let _rc_ds = %sysfunc(fetchobs(&_dsid., 1));
	%local /readonly _MACRO_VAR = %sysfunc(getvarc(&_dsid., 2));
	%let _rc_ds = %sysfunc(close(&_dsid.));
	&&&_MACRO_VAR.
%mend Array__Peek;

%macro Array__Queue(ivar_array
						, i_value);
	%Array__Insert(&ivar_array.
						, 1
						, &i_value)
%mend Array__Queue;

%macro Array__Dequeue(ivar_array);
	%local /readonly _ARRAY_ID_PEEK = &&&ivar_array.;
	%local /readonly _LAST_ITEM_OBS = %&RSUDS.GetCount(SASHELP.vmacro(where = (name like "&_ARRAY_ID_PEEK._%")));
	%local _dsid;
	%local _rc_ds;
	%let _dsid = %sysfunc(open(SASHELP.vmacro(where = (name like "&_ARRAY_ID_PEEK._%")), IN));		
	%let _rc_ds = %sysfunc(fetchobs(&_dsid., &_LAST_ITEM_OBS.));
	%local /readonly _MACRO_VAR_DEQUEUED = %sysfunc(getvarc(&_dsid., 2));
	%let _rc_ds = %sysfunc(close(&_dsid.));
	%local /readonly _LAST_VALUE = &&&_MACRO_VAR_DEQUEUED.;
	%local /readonly _RC_REMOVED =%Array__RemoveAt(&ivar_array.
																, i_index = %Array__Size(&ivar_array.));
	&_LAST_VALUE.
%mend Array__Dequeue;

%macro Array__Concat();
%mend Array__Concat;

%macro Array__Union();
%mend Array__Union;

%macro Array__Intersection();
%mend Array__Intersection;

%macro Array__Subtract();
%mend Array__Subtract;

%macro Array__Exists(ivar_array
							, i_value);
	%local /readonly _ARRAY_ID_EXISTS = &&&ivar_array.;
	%eval(not %&RSUDS.IsDSEmpty(SASHELP.vmacro(where = (name like "&_ARRAY_ID_EXISTS._%" and value = "&i_value."))))
%mend Array__Exists;

%macro Array__IndexOf(ivar_array
							, i_value);
%mend Array__IndexOf;

%macro Array__Find(ivar_array
						, i_condition);
%mend Array__Find;

%macro Array__FindAll(ivar_array
							, i_value);
%mend Array__FindAll;

%macro Array__CopyTo(ivar_array_src
							, ovar_array_dest);
%mend Array__CopyTo;

%macro Array__CopyToDS(ivar_array_src
							, ods_dest_ds
							, i_variable_name = value);
	%Array__GetMacroVariableList(ivar_array = &ivar_array_src.
										, ods_variable_list = &ods_dest_ds.
										, i_kept_vars = value)
	%&RSUDS.Let(i_query = &ods_dest_ds.
					, ods_dest_ds = &ods_dest_ds.(rename = (value = &i_variable_name.)))
%mend Array__CopyToDS;

%macro Array__Text(ivar_array_src
						, ovar_text
						, i_delimiter = %str( ));
	%local /readonly _ARRAY_ID_SHOW = &&&ivar_array_src.;
	%local _item_index;
	%let _item_index = 0;
	%local _value;
	%local _dsid;
	%let &ovar_text. =;
	%do %while(%&RSUDS.ForEach(i_query = SASHELP.vmacro(where = (name like "&_ARRAY_ID_SHOW._%"))
										, i_vars = _value:value
										, ovar_dsid = _dsid));
		%&RSUText.Append(iovar_base = &ovar_text.
							, i_append_text = &_value.
							, i_delimiter = &i_delimiter.)
	%end;
%mend Array__Text;

%macro test();
	%local /readonly _ARRAY = %Array__CreateByDataset(SASHELP.class
																	, i_variable = name);
	%Array__Show(_ARRAY)
	%put %Array__Size(_ARRAY);
	%put %Array__Get(_ARRAY[3]);
	%put add;
	%Array__Add(_ARRAY
						, mari)
	%Array__Show(_ARRAY)
	%put remove;
	%put %Array__RemoveAt(_ARRAY
						, 12);
	%put %Array__RemoveAt(_ARRAY
						, 4);
	%put %Array__Size(_ARRAY);
	%Array__Show(_ARRAY)
	%put insert;
	%Array__Insert(_ARRAY, 10, test)
	%Array__Show(_ARRAY)
	%put %Array__Size(_ARRAY);
	%local _text;
	%Array__Text(_ARRAY
						, ovar_text = _text)
	%put &_text.;
	%Array__CopyToDS(_ARRAY
							, ods_dest_ds = WORK.aaa)
	%put shingo: %Array__Exists(_ARRAY, shingo);
	%put mari: %Array__Exists(_ARRAY, mari);
	%put pop;

	%do %while(not %Array__IsEmpty(_ARRAY));
		%put popped %Array__Pop(_ARRAY);
	%end;
	%Array__Show(_ARRAY)

	%Array__Queue(_ARRAY
					, shingo)
	%Array__Queue(_ARRAY
					, machiko)
	%Array__Queue(_ARRAY
					, mari)
	%Array__Show(_ARRAY)
	%do %while(not %Array__IsEmpty(_ARRAY));
		%put dequeued %Array__Dequeue(_ARRAY);
	%end;
	%Array__Dispose(_ARRAY)
%mend;
%test
