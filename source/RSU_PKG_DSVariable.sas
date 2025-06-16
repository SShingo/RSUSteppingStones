%RSUSetConstant(RSUDSVariable, RSUDSVar__)

/*<FunctionDesc ja_jp>元データセットに指定変数が定義されているか否かを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0:変数が定義されていない\quad 1:変数が定義されている</FunctionReturn ja_jp>*/
%macro RSUDSVar__IsDefined(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
									ids_dataset =
/*<FunctionArgDesc ja_jp>変数名</FunctionArgDesc ja_jp>*/
									, i_var_name =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset i_var_name)
	%local /readonly _RSU_DS_DSID = %Int_RSUUtil_VerifyID(i_id = %sysfunc(open(&ids_dataset., I)));
	%local /readonly _RSU_DS_RESULT = %Int_RSUDS_IsVarDefined(i_dsid = &_RSU_DS_DSID.
																				, i_var_name = &i_var_name.);
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(close(&_RSU_DS_DSID.)))
	&_RSU_DS_RESULT.
%mend RSUDSVar__IsDefined;

/*<FunctionDesc ja_jp>基となるデータセットから変数属性コピーするコードを返します。</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>変数属性を設定するコード（``\texttt{if(_N_=0) then do; set \ast\ast\ast; end;}''というコード）。</FunctionDesc ja_jp>*/
%macro RSUDSVar__CopyAttrFrom(
/*<FunctionArgDesc ja_jp>対象データセット</FunctionArgDesc ja_jp>*/
										ids_dataset =
/*<FunctionArgDesc ja_jp>取得対象変数（変数名を変更する場合は ``\texttt{aaa\_org(aaa\_new)}'' のように指定）</FunctionArgDesc ja_jp>*/
										, i_variables = 
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_dataset i_variables)
	%local _attribute_code;
	%if ("&i_variables." = "*") %then %do;
		%let _attribute_code = if(_N_ = 0) then do%str(;) set &ids_dataset.%str(;) end%str(;);
	%end;
	%else %do;	
		%local _variable_info;
		%local _index_variable_info;
		%local _variable_copy_from;
		%local _variable_copy_to;
		%local _rename_code;
		%local _keep_code;
		%local _regex_var = %sysfunc(prxparse(/(\w+)(\((\w+)\))?/));
		%do %while(%&RSUUtil.ForEach(i_items = &i_variables.
											, ovar_item = _variable_info
											, iovar_index = _index_variable_info));
			%let _is_match = %sysfunc(prxmatch(&_regex_var., &_variable_info.));
			%let _variable_copy_from = %sysfunc(prxposn(&_regex_var., 1, &_variable_info.)); 
			%let _variable_copy_to = %sysfunc(prxposn(&_regex_var., 3, &_variable_info.)); 
			%&RSUText.Append(iovar_base = _keep_code
								, i_append_text = &_variable_copy_from.)
			%if (not %&RSUMacroVariable.IsBlank(_variable_copy_to)) %then %do;
				%&RSUText.Append(iovar_base = _rename_code
									, i_append_text = &_variable_copy_from. = &_variable_copy_to.)
			%end;
		%end;
		%syscall prxfree(_regex_var);
		%let _rename_code = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(_rename_code), ,rename%str(=)(&_rename_code.));
		%local /readonly _OPTION_CODE = (keep = &_keep_code. &_rename_code.);
		%let _attribute_code = if(_N_ = 0) then do%str(;) set &ids_dataset.&_OPTION_CODE.%str(;) end%str(;);
	%end;
	&_attribute_code.
%mend RSUDSVar__CopyAttrFrom;