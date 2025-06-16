/*******************************************/
/* Internal Macros
/*******************************************/
%macro Int_RSUArrayEx_ItemParse(i_array_info =
										, ovar_array_name =
										, ovar_array_id =
										, ovar_item_index =
										, ovar_item_index_formatted =);
	%local _regex_array;
	%let _regex_array = %sysfunc(prxparse(/^(\w+)(\[(\d+)\])?$/));
	%local /readonly _MATCHED = %sysfunc(prxmatch(&_regex_array., &i_array_info.));
	%let &ovar_array_name. = %sysfunc(prxposn(&_regex_array., 1, &i_array_info.));
	%local /readonly _TMP_ARRAY_ID = &&&&&&&ovar_array_name.;
	%let &ovar_array_id. = &_TMP_ARRAY_ID.;
	%let &ovar_item_index. = %sysfunc(prxposn(&_regex_array, 2, &i_array_info.));
	%let &ovar_item_index_formatted. = %sysfunc(RSU_fcmp_get_sequence(&&&ovar_item_index., 36, 7));
	%syscall prxfree(_regex_array);
	%Int_RSUArrayEx_VerifyIndexRange(ivar_array = _TMP_ARRAY_ID
											, i_index = &&&ovar_item_index.)
%mend Int_RSUArrayEx_ItemParse;

%macro Int_RSUArrayEx_VerifyIndexRange(ivar_array =
													, i_index =);
	/* 
		NOTE: インデックスの範囲検証
		NOTE: 範囲外の場合は処理終了
	*/
	%if (&i_index <= 0) %then %do;
		%&RSULogger.PutError(%&RSUMsg.INDEX_MUST_POSITIVE(&i_index.)
								, i_abort = cancel)
	%end;
	%local /readonly _RSU_ARRAY_MAX_INDEX = %RSUArrayEx__Size(ivar_array = &ivar_array.);
	%if (&_RSU_ARRAY_MAX_INDEX. < &i_index.) %then %do;
		%&RSULogger.PutError(%&RSUMsg.INDEX_OUT_OF_RANGE(&i_index., &_RSU_ARRAY_MAX_INDEX.)
									, i_abort = cancel)
	%end;
%mend Int_RSUArrayEx_VerifyIndexRange;
