/*******************************************/
/* Internal Macros
/*******************************************/
%macro Int_RSUMap_ItemParse(i_map_accessor =
									, ovar_map_name =
									, ovar_map_id =
									, ovar_item_key =
									, ovar_item_index_formatted =);
	%local _regex_map_accessor;
	%let _regex_map_accessor = %sysfunc(prxparse(/^(\w+)(\[(\w+)\])?$/));
	%local /readonly _MATCHED = %sysfunc(prxmatch(&_regex_map_accessor., &i_map_accessor.));
	%let &ovar_map_name. = %sysfunc(prxposn(&_regex_map_accessor., 1, &i_map_accessor.));
	%local /readonly _TMP_MAP_ID = &&&&&&&ovar_map_name.;
	%let &ovar_map_id. = &_TMP_MAP_ID.;
	%let &ovar_item_key. = %sysfunc(prxposn(&_regex_map_accessor, 2, &i_map_accessor.));
	%Int_RSUMap_VerifyKeyExistse(ivar_map = _TMP_MAP_ID
										, i_key = &&&ovar_item_key.)
	%let &ovar_item_key_formatted. = %&RSUDS.GetValue(SASHELP.vmacro(where = (name like upcase("&__MAP_KEY_EXISTS_ID._MK_%") and value = "&i_key.")), name);
	%syscall prxfree(_regex_map_accessor);
%mend Int_RSUMap_ItemParse;

%macro Int_RSUMap_GetItemValueMarcoVar(ivar_map =
													, i_item_key =
													, ovar_map_item_key_macro_var =
													, ovar_map_item_value_macro_var = );
	%local /readonly __MAP_ID_FIND_ITEM_INDEX = &&&ivar_map.;
	%&RSUError.AbortIf(%&RSUDS.IsDSEmpty(SASHELP.vmacro(where = (name like upcase("&__MAP_ID_FIND_ITEM_INDEX._K_%") and value = "&i_item_key.")))
							, i_msg = %&RSUMsg.NO_KEY(&i_item_key))
	%let &ovar_map_item_key_macro_var. = %&RSUDS.GetValue(SASHELP.vmacro(where = (name like upcase("&__MAP_ID_FIND_ITEM_INDEX._K_%") and value = "&i_item_key.")), name);
	%let &ovar_map_item_value_macro_var. = %sysfunc(prxchange(s/^&__MAP_ID_FIND_ITEM_INDEX._K_/&__MAP_ID_FIND_ITEM_INDEX._V_/i, -1, &&&ovar_map_item_key_macro_var.));
%mend Int_RSUMap_GetItemValueMarcoVar;

%macro Int_RSUMap_VerifyKeyExists(ivar_map =
											, i_key =);
	/* 
		NOTE: キーの存在検証
		NOTE: 範囲外の場合は処理終了
	*/
	%local /readonly __MAP_KEY_EXISTS_ID = &&&ivar_map.;
	%local /readonly __IS_NOT_EXISTS = %&RSUDS.IsDSEmpty(SASHELP.vmacro(where = (name like upcase("&__MAP_KEY_EXISTS_ID._K_%") and value = "&i_key.")));
	%if (&__IS_NOT_EXISTS.) %then %do;
		%&RSULogger.PutError(%&RSUMsg.KEY_NOT_FOUND(&i_key))
	%end;
%mend Int_RSUMap_VerifyKeyExists;

%macro Int_RSUMap_VerifyKeyNotExists(ivar_array =
												, i_key =);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array i_key)
	%local /readonly __ARRAY_ID_KEY_EXISTS = &&&ivar_array.;
	%local /readonly _IS_EMPTY = %&RSUDS.IsDSEmpty(SASHELP.vmacro(where = (name like "&__ARRAY_ID_KEY_EXISTS._K_%" and value = "&i_key.")));
	%&RSUError.AbortIf(not &_IS_EMPTY.
							, i_msg = %&RSUMsg.KEY_EXSITS(&i_key.))
%mend Int_RSUMap_VerifyKeyNotExists;
