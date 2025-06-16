/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Array.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2023/3/7
/************************************************************************************/
/*<PackageID>RSUArrayEx</PackageID>*/
/*<CategoryID>Cate_MacroVariable</CategoryID>*/
/*<PackagePurpose ja_jp>配列</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Array</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>配列機能に係るマクロ関数群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions manipulating array</PackageDesc en_us>*/
/*<PkgDetail ja_jp>
マクロ変数に対して、一般的な言語の配列のようにインデックスを用いて値を保持・取得出来るようにします。流石に``\texttt{\_my\_macro[1]}''のようなアクセス法は無理で、その代わりに``\texttt{\_my\_macro.Get(1)}''というようなアクセスを可能します。

\texttt{PKGArray}では、最初に設定した内容からの変更（値の追加、削除、更新）はサポートしていません（``\texttt{RSUList}''、``\texttt{RSUQueue}''、``\texttt{RSUStack}''を適宜利用してください）。

配列のインデックスはSASのコンベンションに合わせて{\bfseries 1始まり}です。

配列値の長さは200バイト以内です。
</PkgDetail ja_jp>

/*<ConstantDesc ja_jp>配列パッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUArrayEx, RSUArrayEx__)

/*<FunctionDesc ja_jp>データセットから配列を生成します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>配列ID</FunctionReturn ja_jp>*/
%macro RSUArrayEx__CreateByDataset(
/*<FunctionArgDesc ja_jp>配列の基になるデータセットクエリ</FunctionArgDesc ja_jp>*/
											i_query
/*<FunctionArgDesc ja_jp>データセットの変数</FunctionArgDesc ja_jp>*/
											, i_variable
											);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_query i_variable)
	%local /readonly _ARRAY_ID = %Prv_RSUClass_CreateInstance(i_prefix = AR
																				, i_sequence_var = RSU_g_sequence_array);
	%global &_ARRAY_ID._index;
	%global &_ARRAY_ID._max;
	%global &_ARRAY_ID._term;
	%let &_ARRAY_ID._term = %&RSUBool.False;

	%local /readonly _DSIS_CREATE = %Int_RSUUtil_VerifyID(i_id = %sysfunc(open(&i_query., IN)));
	%local _item_index_formatted;
	%local _item_index;
	%let _item_index = 1;
	%local _rsu_array_create_value;
	%local _rsu_array_create_rc;
	%let _rsu_array_create_rc = %sysfunc(fetch(&_DSIS_CREATE.));
	%local /readonly _ARRAY_ITEMS_ID = &_ARRAY_ID._ARI;
	%do %while(&_rsu_array_create_rc. = 0);
		%let _rsu_array_create_value = %sysfunc(fcmp_rsu_ds_get_curr_by_name(&_DSIS_CREATE., &i_variable.));
		%let _item_index_formatted = %sysfunc(RSU_fcmp_get_sequence(&_item_index., 36, 7));
		%global &_ARRAY_ITEMS_ID._&_item_index_formatted;
		%let &_ARRAY_ITEMS_ID._&_item_index_formatted = &_rsu_array_create_value.;
		%let _item_index = %eval(&_item_index. + 1);
		%let _rsu_array_create_rc = %sysfunc(fetch(&_DSIS_CREATE.));
	%end;
	%let &_ARRAY_ID._max = %eval(&_item_index. - 1);
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(close(&_DSIS_CREATE.)))
	%RSUArrayEx__ResetIterator()
	&_ARRAY_ID.
%mend RSUArrayEx__CreateByDataset;

/*<FunctionDesc ja_jp>アイテムの羅列から配列を生成します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>配列ID</FunctionReturn ja_jp>*/
%macro RSUArrayEx__Create(
/*<FunctionArgDesc ja_jp>配列にセットするアイテム</FunctionArgDesc ja_jp>*/
								i_items
/*<FunctionArgDesc ja_jp>アイテムの区切り文字</FunctionArgDesc ja_jp>*/
								, i_delimiter = %str( )
								);
	%local /readonly _ARRAY_ID = %Prv_RSUClass_CreateInstance(i_prefix = AR
																				, i_sequence_var = RSU_g_sequence_array);
	%global &_ARRAY_ID._index;
	%global &_ARRAY_ID._max;
	%global &_ARRAY_ID._term;
	%let &_ARRAY_ID._term = %&RSUBool.False;
	%let &_ARRAY_ID._max = 0;

	%if (not %&RSUMacroVariable.IsBlank(i_items)) %then %do;
		%local _value;
		%local _index;
		%local _item_index_formatted;
		%local _item_index;
		%let _item_index = 1;
		%local /readonly _ARRAY_ITEMS_ID = &_ARRAY_ID._ARI;
		%do %while(%&RSUUtil.ForEach(i_items = &i_items.
											, ovar_item = _value
											, iovar_index = _index
											, i_delimiter = &i_delimiter.));
			%let _item_index_formatted = %sysfunc(RSU_fcmp_get_sequence(&_item_index., 36, 7));
			%global &_ARRAY_ITEMS_ID._&_item_index_formatted;
			%let &_ARRAY_ITEMS_ID._&_item_index_formatted = &_value.;
			%let _item_index = %eval(&_item_index. + 1);
		%end;
		%let &_ARRAY_ID._max = %eval(&_item_index. - 1);
		%&RSUDS.Delete(WORK.items)
	%end;
	%RSUArrayEx__ResetIterator()
	&_ARRAY_ID.
%mend RSUArrayEx__Create;

/*<FunctionDesc ja_jp>配列を破棄します</FunctionDesc ja_jp>*/
%macro RSUArrayEx__Dispose(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
									ivar_array
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array)
	%local /readonly _ARRAY_ID_DISPOSE = &&&ivar_array.;
	%&RSUMacroVariable.Delete(i_regex = /^&_ARRAY_ID_DISPOSE._/i)
%mend RSUArrayEx__Dispose;

/*<FunctionDesc ja_jp>配列のサイズを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>配列のサイズ</FunctionReturn ja_jp>*/
%macro RSUArrayEx__Size(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_array
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array)
	%local /readonly _ARRAY_ITEMS_ID_SIZE = &&&ivar_array.;
	%&RSUDS.GetCount(SASHELP.vmacro(where = (name like upcase("&_ARRAY_ITEMS_ID_SIZE._ARI_%"))))
%mend RSUArrayEx__Size;

/*<FunctionDesc ja_jp>配列が空か否かを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0: 配列は空ではない、1: 配列が空</FunctionReturn ja_jp>*/
%macro RSUArrayEx__IsEmpty(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
									ivar_array
									);
	%eval(%RSUArrayEx__Size(&ivar_array.) = 0)
%mend RSUArrayEx__IsEmpty;

/*<FunctionDesc ja_jp>配列の指定項目の値を返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>配列の指定項目の値</FunctionReturn ja_jp>*/
%macro RSUArrayEx__Get(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名（インデックス込み）</FunctionArgDesc ja_jp>*/
							ivar_array_info
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array_info)
	%local _array_name;
	%local _array_id;
	%local _item_index;
	%local _item_index_formatted;
	%Int_RSUArrayEx_ItemParse(i_array_info = &ivar_array_info.
									, ovar_array_name = _array_name
									, ovar_array_id = _array_id
									, ovar_item_index = _item_index
									, ovar_item_index_formatted = _item_index_formatted)
	&&&_array_id._ARI_&_item_index_formatted.
%mend RSUArrayEx__Get;

/*<FunctionDesc ja_jp>配列の内容をテキストに変換します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>変換されたテキスト</FunctionReturn ja_jp>*/
%macro RSUArrayEx__GetTextLine(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
										ivar_array
/*<FunctionArgDesc ja_jp>区切り文字</FunctionArgDesc ja_jp>*/
										, i_delimiter = &RSUWhiteSpace
/*<FunctionArgDesc ja_jp>各項目を囲む文字</FunctionArgDesc ja_jp>*/
										, i_enclosure = %&RSUEnclosure.None
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array i_delimiter i_enclosure)
	%local _line_text;
	%local _item;
	%local /readonly _ENCLOSURE = &i_enclosure;
	%local /readonly _ARRAY_ID_GETTEXTLINE = &&&ivar_array.;
	%let &_ARRAY_ID_GETTEXTLINE._index = 0;
	%do %while(%RSUArrayEx__ForEach(&ivar_array., _item));
		%let _item = %sysfunc(&_ENCLOSURE.(&_item));
		%&RSUText.Append(iovar_base = _line_text
							, i_append_text = &_item.
							, i_delimiter = &i_delimiter.)
	%end;
	%let &_ARRAY_ID_GETTEXTLINE._index = 0;
	&_line_text.
%mend RSUArrayEx__GetTextLine;

/*<FunctionDesc ja_jp>配列の内容を詳細表示します</FunctionDesc ja_jp>*/
%macro RSUArrayEx__Show(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_array
/*<FunctionArgDesc ja_jp>タイトル</FunctionArgDesc ja_jp>*/
								, i_title =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array )
	%local _items_info;
	%local _item;
	%local _index;
	%let _index = 1;
	%local /readonly _ARRAY_ID_SHOW = &&&ivar_array.;
	%let &_ARRAY_ID_SHOW._index = 0;
	%do %while(%RSUArrayEx__ForEach(&ivar_array., _item));
		%let _item = [&_index]:&_item.;
		%&RSUText.Append(iovar_base = _items_info
							, i_append_text = &_item.
							, i_delimiter = &RSUComma.)
		%let _index = %eval(&_index. + 1);
	%end;
	%let &_ARRAY_ID_SHOW._index = 0;
	%if (not %&RSUMacroVariable.IsBlank(i_title)) %then %do;
		%let _items_info = &i_title.,&_items_info.;
	%end;
	%&RSULogger.PutBlock(&_items_info.)
%mend RSUArrayEx__Show;

/*<FunctionDesc ja_jp>配列の内容をデータセットに変換します</FunctionDesc ja_jp>*/
%macro RSUArrayEx__ExportToDS(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
										ivar_array
/*<FunctionArgDesc ja_jp>値変数名</FunctionArgDesc ja_jp>*/
										, i_variable_value = value
/*<FunctionArgDesc ja_jp>インデックス変数名（省略時はインデックスを出力しません）</FunctionArgDesc ja_jp>*/
										, i_variable_index =
/*<FunctionArgDesc ja_jp>出力データセット</FunctionArgDesc ja_jp>*/
										, ods_output =
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array i_variable_value ods_output)
	%local /readonly _ARRAY_ID_EXPORT_TO_DS = &&&ivar_array.;
	data &ods_output.(drop = name);
		set SASHELP.vmacro(where = (name like upcase("&_ARRAY_ID_EXPORT_TO_DS._ARI_%")) keep = name value);
		rename
			value = &i_variable_value.
		;
	%if (not %&RSUMacroVariable.IsBlank(i_variable_index)) %then %do;
		&i_variable_index. = _N_;
	%end;
	run;
	quit;
%mend RSUArrayEx__ExportToDS;

/*<FunctionDesc ja_jp>配列に指定項目が含まれているかを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0: 含まれていない、1: 含まれている</FunctionReturn ja_jp>*/
%macro RSUArrayEx__Contains(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
									ivar_array
/*<FunctionArgDesc ja_jp>検査値</FunctionArgDesc ja_jp>*/
									, i_item);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array)
	%local /readonly _ARRAY_ID_CONSTAINS = &&&ivar_array.;
	%eval(not %&RSUDS.IsDSEmpty(SASHELP.vmacro(where = (name like upcase("&_ARRAY_ID_CONSTAINS._ARI_%") and value = "&i_item."))))
%mend RSUArrayEx__Contains;

/*<FunctionDesc ja_jp>配列の指定項目の値を設定します</FunctionDesc ja_jp>*/
%macro RSUArrayEx__Set(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名（インデックス込み）</FunctionArgDesc ja_jp>*/
							ivar_array_info
/*<FunctionArgDesc ja_jp>設定する値</FunctionArgDesc ja_jp>*/
							, i_value
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array_info)
	%local _array_name;
	%local _array_id;
	%local _item_index;
	%local _item_index_formatted;
	%Int_RSUArray_ItemParse(i_array_info = &ivar_array_info.
								, ovar_array_name = _array_name
								, ovar_array_id = _array_id
								, ovar_item_index = _item_index
								, ovar_item_index_formatted = _item_index_formatted)
	%let &&&_array_id_ARI_&_item_index_formatted. = &_value.;
%mend RSUArrayEx__Set;

%macro RSUArrayEx__ForEach(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
									ivar_array
/*<FunctionArgDesc ja_jp>値を保持する変数名</FunctionArgDesc ja_jp>*/
									, ovar_item
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array ovar_item)
	%local /readonly _ARRAY_ID_FOREACH = &&&ivar_array.;
	%if (&&&_ARRAY_ID_FOREACH._term.) %then %do;
		%let &_ARRAY_ID_FOREACH._term = %&RSUBool.False;
		%&RSUBool.False
		%return;
	%end;
	%let &_ARRAY_ID_FOREACH._index = %eval(&&&_ARRAY_ID_FOREACH._index. + 1);
	%if (&&&_ARRAY_ID_FOREACH._index <= &&&_ARRAY_ID_FOREACH._max) %then %do;
		%local /readonly _ITEM_INDEX_FORMATTED = %sysfunc(RSU_fcmp_get_sequence(&&&_ARRAY_ID_FOREACH._index, 36, 7));
		%let &ovar_item. = &&&_ARRAY_ID_FOREACH._ARI_&_ITEM_INDEX_FORMATTED.;
		%&RSUBool.True
	%end;
	%else %do;
		%let &ovar_item. =;
		%let &_ARRAY_ID_FOREACH._index = 0;
		%&RSUBool.False
	%end;
%mend RSUArrayEx__ForEach;

/*<FunctionArgDesc ja_jp>指定したインデックスにポインタを設定</FunctionArgDesc ja_jp>*/
%macro RSUArrayEx__ResetIterator(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
											ivar_array
/*<FunctionArgDesc ja_jp>配列のインデックス</FunctionArgDesc ja_jp>*/
											, i_pos
											);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array)
	%local /readonly _ARRAY_ID_RESET = &&&ivar_array.;
	%local /readonly _ARRAY_ID_RESET_POS = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(i_pos), 0, &i_pos.); 
	%if (0 < &_ARRAY_ID_RESET_POS.) %then %do;
		%Int_RSUArrayEx_VerifyIndexRange(ivar_array = _ARRAY_ID_RESET
												, i_index = &_ARRAY_ID_RESET_POS.)
	%end;
	%let &_ARRAY_ID_RESET._index = &_ARRAY_ID_RESET_POS.;
%mend RSUArrayEx__ResetIterator;

/*<FunctionArgDesc ja_jp>配列を走査を中断</FunctionArgDesc ja_jp>*/
%macro RSUArrayEx__TerminateLoop(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
											ivar_array
											);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array)
	%local /readonly _ARRAY_ID_TERMINATELOOP = &&&ivar_array.;
	%let &_ARRAY_ID_TERMINATELOOP._term = %&RSUBool.True;
%mend RSUArrayEx__TerminateLoop;
