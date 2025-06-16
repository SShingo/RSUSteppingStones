%rsu_steppingstones_activate()

%macro Map__Int_ParseKVP(i_kvp =
								, ovar_key =
								, ovar_value =);
	%local _regex_kvp;
	%let _regex_kvp = %sysfunc(prxparse(/^`([^`]+)``([^`]+)`$/));
	%local /readonly _MATCHED_KVP = %sysfunc(prxmatch(&_regex_kvp., &i_kvp.));
	%let &ovar_key. = %sysfunc(prxposn(&_regex_kvp., 1, &i_kvp.));
	%let &ovar_value. = %sysfunc(prxposn(&_regex_kvp., 2, &i_kvp.));
	%syscall prxfree(_regex_kvp);
%mend Map__Int_ParseKVP;

%macro Map__Internal_Parse(i_array_info =
									, ovar_array_name =
									, ovar_array_id =
									, ovar_item_key =);
	%local _regex_array;
	%let _regex_array = %sysfunc(prxparse(/^(\w+)\[(\d+)\]$/));
	%local /readonly _MATCHED = %sysfunc(prxmatch(&_regex_array., &ivar_array_info.));
	%let &ovar_array_name. = %sysfunc(prxposn(&_regex_array., 1, &ivar_array_info.));
	%local /readonly _TMP_ARRAY_ID = &&&ovar_array_name.;
	%let &ovar_array_id. = &&&_TMP_ARRAY_ID.;
	%let &ovar_item_key. = %sysfunc(prxposn(&_regex_array, 2, &ivar_array_info.));
	%syscall prxfree(_regex_array);
%mend Map__Internal_Parse;

%macro Map__Internal_Create(i_array_id
										, i_query
										, i_variable_key
										, i_variable_value);
	%local /readonly _DSITER_MAP_SRC = %RSUDSIter__Create(&i_query.(keep = &i_variable_key. &i_variable_value.));
	%local _item_index;
	%let _item_index = 0;
	%local _item_index_formatted;
	%do %while(%RSUDSIter__Next(_DSITER_MAP_SRC));
		%let _item_index_formatted = %sysfunc(RSU_fcmp_get_sequence(&_item_index., 36, 7));
		%global &i_array_id.key_&_item_index_formatted;
		%let &i_array_id._key_&_item_index_formatted = %&RSUDSIter__Current(_DSITER_MAP_SRC[&i_variable_key.]);

		%global &i_array_id._value_&_item_index_formatted;
		%let &i_array_id._value_&_item_index_formatted = %&RSUDSIter__Current(_DSITER_MAP_SRC[&i_variable_value.]);
		%let _item_index = %eval(&_item_index. + 1);
	%end;
	%RSUDSIter__Dispose(_DSITER_MAP_SRC)
%mend Map__Internal_Create;

%macro Map__GetMacroVariableList(ivar_array =
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
%mend Map__GetMacroVariableList;

%macro Map__CreateByDataset(i_query
									, i_variable_key
									, i_variable_value);
	%local /readonly _MAP_ID = %&RSUUtil.GetSequenceId(i_prefix = g_RSU_INST_MPI_
																		, iovar_sequence = RSU_g_sequence_library
																		, i_digit = 4);
	%Map__Internal_Create(&_MAP_ID.
								, &i_query.
								, &i_variable_key
								, &i_variable_value);
	&_MAP_ID.
%mend Map__CreateByDataset;

%macro Map__Create(i_items);
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
%mend Map__Create;

%macro Map__Dispose(ivar_map);
	%local /readonly _MAP_ID_DISPOSE = &&&ivar_map.;
	%Dispose(&_MAP_ID_DISPOSE._key)
	%Dispose(&_MAP_ID_DISPOSE._value)
%mend Map__Dispose;

%macro Map__Show(ivar_map);
	%local /readonly _MAP_ID_SHOW = &&&ivar_map.;
	%local /readonly _DSITER_MAP_KEY = %RSUDSIter__Create(SASHELP.vmacro(where = (name like "&_MAP_ID_SHOW._key_%")));
	%local /readonly _DSITER_MAP_VALUE = %RSUDSIter__Create(SASHELP.vmacro(where = (name like "&_MAP_ID_SHOW._value_%")));

	%do %while(%RSUDSIter__Next(_DSITER_MAP_KEY) and %RSUDSIter__Next(_DSITER_MAP_VALUE));
		%put &ivar_map.[%RSUDSIter__Current(_DSITER_MAP_KEY)] = %RSUDSIter__Current(_DSITER_MAP_VALUE);
	%end;
	%RSUDSIter__Dispose(_DSITER_MAP_VALUE)
	%RSUDSIter__Dispose(_DSITER_MAP_KEY)
%mend Map__Show;

%macro Map__Size(ivar_map);
	%local /readonly _MAP_ID_SIZE = &&&ivar_map.;
	%&RSUDS.GetCount(SSASHELP.vmacro(where = (name like "&_MAP_ID_SIZE._key_%")))
%mend Map__Size;

%macro Map__IsEmpty(ivar_map);
	%local /readonly _MAP_ID_ISEMPTY = &&&ivar_map.;
	%eval(%&RSUDS.GetCount(SSASHELP.vmacro(where = (name like "&_MAP_ID_ISEMPTY._key_%")))) = 0)
%mend Map__IsEmpty;

%macro Map__Get(ivar_map_info);
	%local _map_name;
	%local _map_id;
	%local _item_index;
	%local _item_index_formatted;
	%Map__Internal_Parse(i_array_info = &ivar_array_info.
									, ovar_map_name = _map_name
									, ovar_map_id = _map_id
									, ovar_item_index = _item_index
									, ovar_item_index_formatted = _item_index_formatted)
	&&&_map_id._value_&_item_index_formatted.
%mend Map__Get;

%macro Map__Add(ivar_map
					, i_key_value_pair);
	%local _new_item_index;
	%let _new_item_index = %eval(%Map__Size(&ivar_map.) + 1);
	%let _new_item_index = %sysfunc(RSU_fcmp_get_sequence(&_new_item_index., 36, 7));
	%local _key;
	%local _value;
	%Map__Int_ParseKVP(i_kvp = &i_key_value_pair.
							, ovar_key = _key
							, ovar_value = _value)
	%local /readonly _MAP_ID_ADD = &&&ivar_map.;
	%global &_MAP_ID_ADD._key_&_new_item_index;
	%let &_ARRAY_ID._key_&_new_item_index = &_key.;		
	%let &_ARRAY_ID._value_&_new_item_index = &_value.;		
%mend Map__Add;

%macro Map__RemoveAt(ivar_map
							, i_index);
	%local _rc;
	%local /readonly _MAP_ID_REMOVE = &&&ivar_map.;
	%local _dsid;
	%local _rc_ds;
	%let _dsid = %sysfunc(open(SASHELP.vmacro(where = (name like "&_MAP_ID_REMOVE._key_%")), IN));	
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
%mend Map__RemoveAt;

%macro Map__Set(ivar_array_info
						, i_value);
	%local _array_name;
	%local _array_id;
	%local _item_index;
	%local _item_index_formatted;
	%Map__Internal_Parse(i_array_info = &ivar_array_info.
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
	%Map__Size(&ivar_array.)
%mend Map__Set;

%macro Map__Clear(ivar_array);
	%Map__Dispose(&ivar_array.);
%mend Map__Clear;

%macro Map__Insert(ivar_array
							, i_index
							, i_value);
	%local /readonly _TMP_DS_MACRO_VARIABLES_NEW = %&RSUDS.GetTempDSName();
	%Map__GetMacroVariableList(ivar_array = &ivar_array.
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
	%Map__Dispose(&ivar_array.)
	%local /readonly _ARRAY_ID_INSERT = &&&ivar_array.;
	%Map__Internal_Create(&_ARRAY_ID_INSERT.
									, &_TMP_DS_MACRO_VARIABLES_NEW.
									, value)
	%&RSUDS.Delete(&_TMP_DS_MACRO_VARIABLES_NEW.)
%mend Map__Insert;

%macro Map__Pop(ivar_array);
	%local /readonly _FIST_VALUE = %Map__Peek(&ivar_array);
	%local /readonly _RC_REMOVED =%Map__RemoveAt(&ivar_array.
																, i_index = 1);
	&_FIST_VALUE.
%mend Map__Pop;

%macro Map__Push(ivar_array
						, i_value);
	%Map__Insert(&ivar_array.
						, 1
						, &i_value)
%mend Map__Push;

%macro Map__Peek(ivar_array);
	%local /readonly _ARRAY_ID_PEEK = &&&ivar_array.;
	%local _dsid;
	%local _rc_ds;
	%let _dsid = %sysfunc(open(SASHELP.vmacro(where = (name like "&_ARRAY_ID_PEEK._%")), IN));		
	%let _rc_ds = %sysfunc(fetchobs(&_dsid., 1));
	%local /readonly _MACRO_VAR = %sysfunc(getvarc(&_dsid., 2));
	%let _rc_ds = %sysfunc(close(&_dsid.));
	&&&_MACRO_VAR.
%mend Map__Peek;

%macro Map__Queue(ivar_array
						, i_value);
	%Map__Insert(&ivar_array.
						, 1
						, &i_value)
%mend Map__Queue;

%macro Map__Dequeue(ivar_array);
	%local /readonly _ARRAY_ID_PEEK = &&&ivar_array.;
	%local /readonly _LAST_ITEM_OBS = %&RSUDS.GetCount(SASHELP.vmacro(where = (name like "&_ARRAY_ID_PEEK._%")));
	%local _dsid;
	%local _rc_ds;
	%let _dsid = %sysfunc(open(SASHELP.vmacro(where = (name like "&_ARRAY_ID_PEEK._%")), IN));		
	%let _rc_ds = %sysfunc(fetchobs(&_dsid., &_LAST_ITEM_OBS.));
	%local /readonly _MACRO_VAR_DEQUEUED = %sysfunc(getvarc(&_dsid., 2));
	%let _rc_ds = %sysfunc(close(&_dsid.));
	%local /readonly _LAST_VALUE = &&&_MACRO_VAR_DEQUEUED.;
	%local /readonly _RC_REMOVED =%Map__RemoveAt(&ivar_array.
																, i_index = %Map__Size(&ivar_array.));
	&_LAST_VALUE.
%mend Map__Dequeue;

%macro Map__Concat();
%mend Map__Concat;

%macro Map__Union();
%mend Map__Union;

%macro Map__Intersection();
%mend Map__Intersection;

%macro Map__Subtract();
%mend Map__Subtract;

%macro Map__Exists(ivar_array
							, i_value);
	%local /readonly _ARRAY_ID_EXISTS = &&&ivar_array.;
	%eval(not %&RSUDS.IsDSEmpty(SASHELP.vmacro(where = (name like "&_ARRAY_ID_EXISTS._%" and value = "&i_value."))))
%mend Map__Exists;

%macro Map__IndexOf(ivar_array
							, i_value);
%mend Map__IndexOf;

%macro Map__Find(ivar_array
						, i_condition);
%mend Map__Find;

%macro Map__FindAll(ivar_array
							, i_value);
%mend Map__FindAll;

%macro Map__CopyTo(ivar_array_src
							, ovar_array_dest);
%mend Map__CopyTo;

%macro Map__CopyToDS(ivar_array_src
							, ods_dest_ds
							, i_variable_name = value);
	%Map__GetMacroVariableList(ivar_array = &ivar_array_src.
										, ods_variable_list = &ods_dest_ds.
										, i_kept_vars = value)
	%&RSUDS.Let(i_query = &ods_dest_ds.
					, ods_dest_ds = &ods_dest_ds.(rename = (value = &i_variable_name.)))
%mend Map__CopyToDS;

%macro Map__Text(ivar_array_src
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
%mend Map__Text;

%macro test();
	%local /readonly _ARRAY = %Map__CreateByDataset(SASHELP.class
																	, i_variable = name);
	%Map__Show(_ARRAY)
	%put %Map__Size(_ARRAY);
	%put %Map__Get(_ARRAY[3]);
	%put add;
	%Map__Add(_ARRAY
						, mari)
	%Map__Show(_ARRAY)
	%put remove;
	%put %Map__RemoveAt(_ARRAY
						, 12);
	%put %Map__RemoveAt(_ARRAY
						, 4);
	%put %Map__Size(_ARRAY);
	%Map__Show(_ARRAY)
	%put insert;
	%Map__Insert(_ARRAY, 10, test)
	%Map__Show(_ARRAY)
	%put %Map__Size(_ARRAY);
	%local _text;
	%Map__Text(_ARRAY
						, ovar_text = _text)
	%put &_text.;
	%Map__CopyToDS(_ARRAY
							, ods_dest_ds = WORK.aaa)
	%put shingo: %Map__Exists(_ARRAY, shingo);
	%put mari: %Map__Exists(_ARRAY, mari);
	%put pop;

	%do %while(not %Map__IsEmpty(_ARRAY));
		%put popped %Map__Pop(_ARRAY);
	%end;
	%Map__Show(_ARRAY)

	%Map__Queue(_ARRAY
					, shingo)
	%Map__Queue(_ARRAY
					, machiko)
	%Map__Queue(_ARRAY
					, mari)
	%Map__Show(_ARRAY)
	%do %while(not %Map__IsEmpty(_ARRAY));
		%put dequeued %Map__Dequeue(_ARRAY);
	%end;
	%Map__Dispose(_ARRAY)
%mend;
%test
