/*******************************************/
/* Internal Macros
/*******************************************/
%macro Int_RSUArray_SetItemsByDS(ivar_array =
											, i_query =
											, i_variable_value =);
	%local /readonly __ARRAY_ID_SET_ITEMS = &&&ivar_array.;
	%local __array_item_index;
	%let __array_item_index = 0;
	%local __array_item_value;
	%local /readonly __DSITER_ARRAY_SRC = %&RSUDSIterator.Create(&i_query.);
	%do %while(%&RSUDSIterator.Next(__DSITER_ARRAY_SRC));
		%let __array_item_index = %eval(&__array_item_index + 1);
		%let __array_item_value = %&RSUDSIterator.Current(__DSITER_ARRAY_SRC, &i_variable_value.);
		%global &__ARRAY_ID_SET_ITEMS._V_&__array_item_index.;
		%let &__ARRAY_ID_SET_ITEMS._V_&__array_item_index. = &__array_item_value.;
	%end;
	%&RSUDSIterator.Dispose(__DSITER_ARRAY_SRC)
	%global &__ARRAY_ID_SET_ITEMS._max;
	%let &__ARRAY_ID_SET_ITEMS._max = &__array_item_index.;
	%global &__ARRAY_ID_SET_ITEMS._index;
%mend Int_RSUArray_SetItemsByDS;

%macro Int_RSUArray_ShowItems(ivar_array =
										, i_index_from =
										, i_index_to =);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array)
	%local /readonly __ARRAY_ID_SHOW_ITEMS = &&&ivar_array.;
	%local __item_index;
	%local __item_index_view;
	%let __item_index_view = 0;
	%put ---- ITEMS ----;
	%do __item_index = &i_index_from. %to &i_index_to.;
		%let __item_index_view = %eval(&__item_index_view. + 1);
		%put [&__item_index_view.]: &&&__ARRAY_ID_SHOW_ITEMS._V_&__item_index.;
	%end;
	%put ---------------;
%mend Int_RSUArray_ShowItems;

%macro Int_RSUArray_VerifyIndexRange(ivar_array =
												, i_index =);
	/* 
		NOTE: インデックスの範囲検証
		NOTE: 範囲外の場合は処理終了
	*/
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array i_index)
	%local /readonly __ARRAY_ID_VERIFY_RANGE = &&&ivar_array.;
	%&RSUError.AbortIf(&i_index <= 0
							, i_msg = %&RSUMsg.INDEX_MUST_POSITIVE(&i_index.))
	%&RSUError.AbortIf(&&&__ARRAY_ID_VERIFY_RANGE._max < &i_index.
							, i_msg = %&RSUMsg.INDEX_OUT_OF_RANGE(&i_index., &&&__ARRAY_ID_VERIFY_RANGE._max))
%mend Int_RSUArray_VerifyIndexRange;

%macro Int_RSUArray_ParseIndexRange(ivar_array =
												, i_range =
												, ovar_index_from =
												, ovar_index_to =);
	%local __array_index_range_regex;
	%let __array_index_range_regex = %sysfunc(prxparse(/^\[(\d+)?\s*,\s*(\d+)?]$/));
	%&RSUError.AbortIf(not %sysfunc(prxmatch(&__array_index_range_regex., &i_range.)))

	%local /readonly __ARRAY_ID_RANGE = &&&ivar_array.;
	%let &ovar_index_from. = %sysfunc(prxposn(&__array_index_range_regex., 1, &i_range.));
	%if (%&RSUMacroVariable.IsBlank(&ovar_index_from.)) %then %do;
		%let &ovar_index_from. = 1;
	%end;
	%let &ovar_index_to. = %sysfunc(prxposn(&__array_index_range_regex., 2, &i_range.));
	%if (%&RSUMacroVariable.IsBlank(&ovar_index_to.)) %then %do;
		%let &ovar_index_to. = &&&__ARRAY_ID_RANGE._max.;
	%end;
%mend Int_RSUArray_ParseIndexRange;

%macro Int_RSUArray_GetValue(ivar_array =
									, i_key =);
	/* 
		NOTE: キーの存在検証
		NOTE: 検証失敗時は処理終了
	*/
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array i_key)
	%local /readonly __ARRAY_ID_GET_VALUE = &&&ivar_array.;
	%local /readonly _ARRAY_ITEM_VALUE = %&RSUDS.GetValue(&__ARRAY_ID_GET_VALUE.(where = (__rsu_array_key = "&i_key.")), __rsu_array_value);
	&_ARRAY_ITEM_VALUE.
%mend Int_RSUArray_GetValue;

%macro Int_RSUArray_SetValue(ivar_array =
									, i_key =
									, i_value =);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array i_key)
	%local /readonly __ARRAY_ID_SET_VALUE = &&&ivar_array.;
	data &__ARRAY_ID_SET_VALUE.;
		set &__ARRAY_ID_SET_VALUE.;
		if (__rsu_array_key = "&i_key.") then do;
			__rsu_array_value = "&i_value.";
			__rsu_array_info = catx(': ', EncloseSquare(__rsu_array_key), __rsu_array_value);
		end;
	run;
	quit;
%mend Int_RSUArray_SetValue;

%macro Int_RSUArray_FindValue(ivar_array =
										, i_value =);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array)
	%local /readonly __ARRAY_ID_FIND = &&&ivar_array.;
	%local /readonly __IS_NOT_FOUND = %&RSUDS.IsDSEmpty(SASHELP.vmacro(where = (name like "&__ARRAY_ID_FIND._V_%" and value = "&i_value")));
	%local _found_key;
	%if (&__IS_NOT_FOUND.) %then %do;
		%let __found_key = &RSUVarNULL.;
	%end;
	%else %do;
		%let __found_key = %&RSUDS.GetValue(SASHELP.vmacro(where = (name like "&__ARRAY_ID_FIND._V_%" and value = "&i_value")), name);
		%let __found_key = %sysfunc(prxchange(s/^&__ARRAY_ID_FIND._V_//, -1, &__found_key));
	%end;
	&__found_key.
%mend Int_RSUArray_FindValue;

%macro Int_RSUArray_IssueItemSuffix(i_item_index =);
	%sysfunc(RSU_fcmp_get_sequence(&i_item_index., 36, 7));
%mend Int_RSUArray_IssueItemSuffix;

%macro Int_RSUArray_ParseAccessor(i_item_accessor =
											, i_regex_accessor =
											, ovar_array_id =
											, ovar_item_key =);
	%local _regex_array;
	%let _regex_array = %sysfunc(prxparse(&i_regex_accessor.));
	%local /readonly _MATCHED = %sysfunc(prxmatch(&_regex_array., &i_item_accessor.));
	%&RSUError.AbortIf(not &_MATCHED.)
	%let &ovar_array_id. = %sysfunc(prxposn(&_regex_array., 1, &i_item_accessor.));
	%let &ovar_item_key. = %sysfunc(prxposn(&_regex_array., 2, &i_item_accessor.));
	%syscall prxfree(_regex_array);
%mend Int_RSUArray_ParseAccessor;
