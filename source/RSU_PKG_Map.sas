/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Map.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2023/12/27
/************************************************************************************/
/*<PackageID>RSUArray</PackageID>*/
/*<CategoryID>Cate_MacroVariable</CategoryID>*/
/*<PackagePurpose ja_jp>連想配列</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Array</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>連想配列機能に係るマクロ関数群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions manipulating map</PackageDesc en_us>*/
/*<PkgDetail ja_jp>
マクロ変数に対して、一般的な言語の連想配列のようにキーを用いて値を保持・取得出来るようにします。
キーの長さが半角12文字長だったり、記号や倍角文字を使う場合は\texttt{RSU_PKG_MapEx}パッケージを使用してください。
</PkgDetail ja_jp>

/*<ConstantDesc ja_jp>連想配列パッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUMap, RSUMap__)

/*<FunctionDesc ja_jp>データセットから連想配列を生成します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>連想配列ID</FunctionReturn ja_jp>*/
%macro RSUMap__CreateByDataset(
/*<FunctionArgDesc ja_jp>連想配列の基になるデータセットクエリ</FunctionArgDesc ja_jp>*/
										i_query
/*<FunctionArgDesc ja_jp>データセットの変数（キー）</FunctionArgDesc ja_jp>*/
										, i_variable_key
/*<FunctionArgDesc ja_jp>データセットの変数（値）</FunctionArgDesc ja_jp>*/
										, i_variable_value
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_query i_variable_key i_variable_value)
	%local /readonly __MAP_ID_CREATE = %Prv_RSUClass_CreateInstance(i_prefix = MP
																						, i_sequence_var = RSU_g_sequence_array);
	%local __map_item_index;
	%let __map_item_index = 0;
	%local __map_item_key;
	%local __map_item_value;
	%local /readonly __DSITER_MAP_SRC = %&RSUDSIterator.Create(&i_query.);
	%do %while(%&RSUDSIterator.Next(__DSITER_MAP_SRC));
		%let __map_item_index = %eval(&__map_item_index + 1);
		%let __map_item_key = %&RSUDSIterator.Current(__DSITER_MAP_SRC, &i_variable_key.);
		%let __map_item_value = %&RSUDSIterator.Current(__DSITER_MAP_SRC, &i_variable_value.);
		%global &__MAP_ID_CREATE._K_&__map_item_index.;
		%let &__MAP_ID_CREATE._K_&__map_item_index. = &__map_item_key.;
		%global &__MAP_ID_CREATE._V_&__map_item_index.;
		%let &__MAP_ID_CREATE._V_&__map_item_index. = &__map_item_value.;
	%end;
	%&RSUDSIterator.Dispose(__DSITER_MAP_SRC)
	%global &__MAP_ID_CREATE._max;
	%let &__MAP_ID_CREATE._max = &__map_item_index.;
	&__MAP_ID_CREATE.
%mend RSUMap__CreateByDataset;

/*<FunctionDesc ja_jp>連想配列を生成します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>連想配列ID</FunctionReturn ja_jp>*/
%macro RSUMap__Create(
/*<FunctionArgDesc ja_jp>連想配列の項目リスト（key-value pair）</FunctionArgDesc ja_jp>*/
							i_items
/*<FunctionArgDesc ja_jp>項目の区切り文字</FunctionArgDesc ja_jp>*/
							, i_delimiter_item =
							);
	%local /readonly __MAP_ID_CREATE = %Prv_RSUClass_CreateInstance(i_prefix = MP
																						, i_sequence_var = RSU_g_sequence_array);
	%local __map_item_index;
	%let __map_item_index = 0;
	%local __map_item_key;
	%local __map_item_value;
	%local __map_item;
	%local __index_map_item;
	%if (not %&RSUMacroVariable.IsBlank(i_items)) %then %do;
		%local __map_item_regex;
		%let __map_item_regex = %sysfunc(prxparse(/^\[(\w+)\]:(.)$/));
		%do %while(%&RSUUtil.ForEach(i_items = &i_items., ovar_item = __map_item, iovar_index = __index_map_item, i_delimiter = &i_delimiter_item.));
			%if (%sysfunc(prxmatch(&__map_item_regex., &__map_item))) %then %do;
				%let __map_item_index = %eval(&__map_item_index + 1);
				%let __map_item_key = %sysfunc(prxposn(&__map_item_regex., 1, &__map_item.));
				%let __map_item_value = %sysfunc(prxposn(&__map_item_regex., 2, &__map_item.));
				%global &__MAP_ID_CREATE._K_&__map_item_index.;
				%let &__MAP_ID_CREATE._K_&__map_item_index. = &__map_item_key.;
				%global &__MAP_ID_CREATE._V_&__map_item_index.;
				%let &__MAP_ID_CREATE._V_&__map_item_index. = &__map_item_value.;
			%end;
		%end;
		%syscall prxfree(__map_item_regex);
	%end;
	%global &__MAP_ID_CREATE._max;
	%let &__MAP_ID_CREATE._max = &__map_item_index.;
	&__MAP_ID_CREATE.
%mend RSUMap__Create;

/*<FunctionDesc ja_jp>エクセルを読み込むことで連想配列を生成します</FunctionDesc ja_jp>*/
%macro RSUMap__ImportExcel(
/*<FunctionArgDesc ja_jp>エクセルファイルのパス</FunctionArgDesc ja_jp>*/
									i_file_path =
/*<FunctionArgDesc ja_jp>読み込みシート</FunctionArgDesc ja_jp>*/
									, i_sheet_name =
/*<FunctionArgDesc ja_jp>キー列</FunctionArgDesc ja_jp>*/
									, i_variable_key =
/*<FunctionArgDesc ja_jp>値列</FunctionArgDesc ja_jp>*/
									, i_variable_value =
/*<FunctionArgDesc ja_jp>連想配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
									, ovar_map =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_file_path i_sheet_name i_variable_key i_variable_value ovar_map)
	%local /readonly _DS_IMPORTED_DATA = %&RSUDS.GetTempDSName(import);
	%&RSUExcel.Import(i_file_path = &i_file_path.
							, i_sheet_name = &i_sheet_name.
							, i_skip_header = %&RSUBool.True
							, ods_output_ds = &_DS_IMPORTED_DATA.)
	%let &ovar_map. = %RSUMap__CreateByDataset(&_DS_IMPORTED_DATA.
															, &i_variable_key.
															, &i_variable_value.);
	%&RSUDS.Delete(&_DS_IMPORTED_DATA.)
%mend RSUMap__ImportExcel;

/*<FunctionDesc ja_jp>連想配列を破棄します</FunctionDesc ja_jp>*/
%macro RSUMap__Dispose(
/*<FunctionArgDesc ja_jp>連想配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_map
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_map)
	%local /readonly __MAP_ID_DISPOSE = &&&ivar_map.;
	%&RSUMacroVariable.Delete(i_regex = /^&__MAP_ID_DISPOSE._/i)
	%&RSUDS.Delete(&__MAP_ID_DISPOSE.)
%mend RSUMap__Dispose;

/*<FunctionDesc ja_jp>連想配列のサイズを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>連想配列のサイズ</FunctionReturn ja_jp>*/
%macro RSUMap__Size(
/*<FunctionArgDesc ja_jp>連想配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
							ivar_map
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_map)
	%local /readonly __MAP_ITEMS_ID_SIZE = &&&ivar_map.;
	&&&__MAP_ITEMS_ID_SIZE._max
%mend RSUMap__Size;

/*<FunctionDesc ja_jp>連想配列が空か否かを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0: 連想配列は空ではない、1: 連想配列が空</FunctionReturn ja_jp>*/
%macro RSUMap__IsEmpty(
/*<FunctionArgDesc ja_jp>連想配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_map
								);
	%eval(%RSUMap__Size(&ivar_map.) = 0)
%mend RSUMap__IsEmpty;

/*<FunctionDesc ja_jp>連想配列の指定項目の値を返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>連想配列の指定項目の値</FunctionReturn ja_jp>*/
%macro RSUMap__Get(
/*<FunctionArgDesc ja_jp>連想配列IDを保持する変数名（インデックス込み）</FunctionArgDesc ja_jp>*/
							i_map_accessor
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_map_accessor)
	%local _map_id;
	%local _item_key;
	%Int_RSUArray_ParseAccessor(i_item_accessor = &i_map_accessor.
										, i_regex_accessor = /^(\w+)\[(\w+)\]$/
										, ovar_array_id = _map_id
										, ovar_item_key = _item_key)
	%local __map_item_key_macro_var;
	%local __map_item_value_macro_var;
	%Int_RSUMap_GetItemValueMarcoVar(ivar_map = &_map_id.
												, i_item_key = &_item_key.
												, ovar_map_item_key_macro_var = __map_item_key_macro_var
												, ovar_map_item_value_macro_var = __map_item_value_macro_var)
	&&&__map_item_value_macro_var.
%mend RSUMap__Get;

/*<FunctionDesc ja_jp>連想配列の指定項目の値を設定します</FunctionDesc ja_jp>*/
%macro RSUMap__Set(
/*<FunctionArgDesc ja_jp>連想配列IDを保持する変数名（インデックス込み）</FunctionArgDesc ja_jp>*/
						i_map_accessor
/*<FunctionArgDesc ja_jp>設定値</FunctionArgDesc ja_jp>*/
						, i_value
						);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_map_accessor)
	%local _map_id;
	%local _item_key;
	%Int_RSUArray_ParseAccessor(i_item_accessor = &i_map_accessor.
										, i_regex_accessor = /^(\w+)\[(\w+)\]$/
										, ovar_array_id = _map_id
										, ovar_item_key = _item_key)
	%local __map_item_key_macro_var;
	%local __map_item_value_macro_var;
	%Int_RSUMap_GetItemValueMarcoVar(ivar_map = &_map_id.
												, i_item_key = &_item_key.
												, ovar_map_item_key_macro_var = __map_item_key_macro_var
												, ovar_map_item_value_macro_var = __map_item_value_macro_var)
	%let &__map_item_value_macro_var. = &i_value.;
%mend RSUMap__Set;

/*<FunctionDesc ja_jp>連想配列から指定項目の値を検索します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>見つかった項目キー（見つからない場合はブランク）</FunctionReturn ja_jp>*/
%macro RSUMap__FindValue(
/*<FunctionArgDesc ja_jp>連想配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_map
/*<FunctionArgDesc ja_jp>検索値</FunctionArgDesc ja_jp>*/
								, i_value
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_map)
	%local /readonly __MAP_ID_FIND_VALUE = &&&ivar_map.; 
	%local __FOUND_MAP_ITEM_KEY;
	%let __FOUND_MAP_ITEM_KEY = %Int_RSUArray_FindValue(ivar_array = &ivar_map.
																			, i_target_variable = __rsu_array_value 
																			, i_index_from = 1
																			, i_index_to = &&&__MAP_ID_FIND_VALUE._max
																			, i_value = &i_value);
	%let __FOUND_MAP_ITEM_KEY =;
	&__FOUND_ARRAY_ITEM_KEY.
%mend RSUMap__FindValue;

%macro RSUMap__ContainsValue(
/*<FunctionArgDesc ja_jp>連想配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
									ivar_map
/*<FunctionArgDesc ja_jp>検索値</FunctionArgDesc ja_jp>*/
									, i_value
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_map)
	%local /readonly __FOUND_ITEM_CONTAINS = %RSUMap__FindValue(&ivar_map.
																				, &i_value);
	%eval(not %&RSUMacroVariable.IsBlank(&__FOUND_ITEM_CONTAINS.))
%mend RSUMap__ContainsValue;

%macro RSUMap__ContainsKey(
/*<FunctionArgDesc ja_jp>連想配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
									ivar_map
/*<FunctionArgDesc ja_jp>検索値</FunctionArgDesc ja_jp>*/
									, i_key
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_map)
	%local /readonly __MAP_ID_FIND_VALUE = &&&ivar_map.; 
	%local __FOUND_MAP_ITEM_KEY;
	%let __FOUND_MAP_ITEM_KEY = %Int_RSUArray_FindValue(ivar_array = &ivar_map.
																		, i_target_variable = __rsu_array_key
																		, i_index_from = 1
																		, i_index_to = &&&__MAP_ID_FIND_VALUE._max
																		, i_value = &i_key);
	%eval(not %&RSUMacroVariable.IsNull(&__FOUND_MAP_ITEM_KEY.))
%mend RSUMap__ContainsKey;

%macro RSUMap__Show(
/*<FunctionArgDesc ja_jp>連想配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
							ivar_map
							);
	%local /readonly __MAP_ID_SHOW_ITEMS = &&&ivar_map.;
	%local /readonly __DSITER_MAP_ITEM_KEYS = %&RSUDSIterator.Create(SASHELP.vmacro(where = (name like upcase("&__MAP_ID_SHOW_ITEMS._K_%"))));
	%local __map_item_key_macro_var;
	%local __map_item_value_macro_var;
	%put ---- ITEMS ----;
	%do %while(%&RSUDSIterator.Next(__DSITER_MAP_ITEM_KEYS));
		%let __map_item_key_macro_var = %&RSUDSIterator.Current(__DSITER_MAP_ITEM_KEYS, name);
		%let __map_item_value_macro_var = %sysfunc(prxchange(s/^&__MAP_ID_SHOW_ITEMS._K_/&__MAP_ID_SHOW_ITEMS._V_/i, -1, &__map_item_key_macro_var.));
		%put [&&&__map_item_key_macro_var.]: &&&__map_item_value_macro_var.;
	%end;
	%&RSUDSIterator.Dispose(__DSITER_MAP_ITEM_KEYS)
	%put ---------------;
%mend RSUMap__Show;

/*<FunctionDesc ja_jp>連想配列の末尾に項目を追加します</FunctionDesc ja_jp>*/
%macro RSUMap__Add(
/*<FunctionArgDesc ja_jp>連想配列IDを保持する変数名（インデックス込み）</FunctionArgDesc ja_jp>*/
						i_map_accessor
/*<FunctionArgDesc ja_jp>追加項目（key-value pair）</FunctionArgDesc ja_jp>*/
						, i_value
						);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_map_accessor)
	%local _map_id;
	%local _item_key;
	%Int_RSUArray_ParseAccessor(i_item_accessor = &i_map_accessor.
										, i_regex_accessor = /^(\w+)\[(\w+)\]$/
										, ovar_array_id = _map_id
										, ovar_item_key = _item_key)
	%Int_RSUMap_VerifyKeyNotExists(ivar_array = &_map_id.
											, i_key = &_item_key.)
	%local /readonly __MAP_ID_ADD = &&&_map_id.;
	%let &__MAP_ID_ADD._max = %eval(&&&__MAP_ID_ADD._max. + 1);
	%global &__MAP_ID_ADD._K_&&&__MAP_ID_ADD._max;
	%let &__MAP_ID_ADD._K_&&&__MAP_ID_ADD._max = &_item_key.;
	%global &__MAP_ID_ADD._V_&&&__MAP_ID_ADD._max;
	%let &__MAP_ID_ADD._V_&&&__MAP_ID_ADD._max = &i_value.;
%mend RSUMap__Add;

/*<FunctionDesc ja_jp>連想配列項目を削除します</FunctionDesc ja_jp>*/
%macro RSUMap__Remove(
/*<FunctionArgDesc ja_jp>連想配列IDを保持する変数名（インデックス込み）</FunctionArgDesc ja_jp>*/
							i_map_accessor
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_map_accessor)
	%local _map_id;
	%local _item_key;
	%Int_RSUArray_ParseAccessor(i_item_accessor = &i_map_accessor.
										, i_regex_accessor = /^(\w+)\[(\w+)\]$/
										, ovar_array_id = _map_id
										, ovar_item_key = _item_key)
	%local __map_item_key_macro_var;
	%local __map_item_value_macro_var;
	%Int_RSUMap_GetItemValueMarcoVar(ivar_map = &_map_id.
												, i_item_key = &_item_key.
												, ovar_map_item_key_macro_var = __map_item_key_macro_var
												, ovar_map_item_value_macro_var = __map_item_value_macro_var)
	%local /readonly __MAP_ID_REMOVE = &&&_map_id.;
	%symdel &__map_item_key_macro_var.;
	%symdel &__map_item_value_macro_var.;
	%let &__MAP_ID_REMOVE._max = %eval(&&&__MAP_ID_REMOVE._max. - 1);
%mend RSUMap__Remove;

/*<FunctionDesc ja_jp>連想配列項目を走査します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0:取得失敗、1:取得成功</FunctionReturn ja_jp>*/
%macro RSUMap__ForEach(
/*<FunctionArgDesc ja_jp>連想配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_map
/*<FunctionArgDesc ja_jp>キーを保持する変数名</FunctionArgDesc ja_jp>*/
								, ovar_key =
/*<FunctionArgDesc ja_jp>値を保持する変数名</FunctionArgDesc ja_jp>*/
								, ovar_value =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_map)
	%local /readonly __MAP_ID_FOREACH = &&&ivar_map.;
	%local __array_foreach_result;
	%if (&&&__MAP_ID_FOREACH._term.) %then %do;
		%let __array_foreach_result = %&RSUBool.False;
		%let &__MAP_ID_FOREACH._term = %&RSUBool.False;
		%let &__MAP_ID_FOREACH._index = 0;
		%goto __leave_array_foreach__;
	%end;
	%if (&&&__MAP_ID_FOREACH._index. = &&&__MAP_ID_FOREACH._max.) %then %do;
		%let __array_foreach_result = %&RSUBool.False;
		%let &__MAP_ID_FOREACH._term = %&RSUBool.False;
		%let &__MAP_ID_FOREACH._index = 0;
		%goto __leave_array_foreach__;
	%end;
	%let __array_foreach_result = %&RSUBool.True;
	%let &__MAP_ID_FOREACH._index = %eval(&&&__MAP_ID_FOREACH._index. + 1);
	%if (not %&RSUMacroVariable.IsBlank(ovar_key)) %then %do;
		%let &ovar_key. = &&&__MAP_ID_FOREACH._K_&__MAP_ID_FOREACH._index;
	%end;
	%if (not %&RSUMacroVariable.IsBlank(ovar_value)) %then %do;
		%let &ovar_value. = &&&__MAP_ID_FOREACH._V_&__MAP_ID_FOREACH._index;
	%end;
%__leave_array_foreach__:
	&__array_foreach_result.
%mend RSUMap__ForEach;

/*<FunctionDesc ja_jp>連想配列走査を中断します</FunctionDesc ja_jp>*/
%macro RSUMap__TerminateLoop(
/*<FunctionArgDesc ja_jp>連想配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
										ivar_map
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_map)
	%local /readonly __MAP_ID_TEMINATE = &&&ivar_map.;
	%let &__MAP_ID_TEMINATE._term = %&RSUBool.True;
%mend RSUMap__TerminateLoop;