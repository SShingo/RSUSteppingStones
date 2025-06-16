/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Array.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2023/12/27
/************************************************************************************/
/*<PackageID>RSUArray</PackageID>*/
/*<CategoryID>Cate_MacroVariable</CategoryID>*/
/*<PackagePurpose ja_jp>配列</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Array</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>配列機能に係るマクロ関数群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions manipulating array</PackageDesc en_us>*/
/*<PkgDetail ja_jp>
マクロ変数に対して、一般的な言語の配列のようにインデックスを用いて値を保持・取得出来るようにします。

配列のインデックスはSASのコンベンションに合わせて{\bfseries 1始まり}です。
</PkgDetail ja_jp>

/*<ConstantDesc ja_jp>配列パッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUArray, RSUArray__)

/*<FunctionDesc ja_jp>データセットから配列を生成します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>配列ID</FunctionReturn ja_jp>*/
%macro RSUArray__CreateByDataset(
/*<FunctionArgDesc ja_jp>配列の基になるデータセットクエリ</FunctionArgDesc ja_jp>*/
											i_query
/*<FunctionArgDesc ja_jp>データセットの変数</FunctionArgDesc ja_jp>*/
											, i_variable
											);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_query i_variable)
	%local /readonly __ARRAY_ID_CREATE = %Prv_RSUClass_CreateInstance(i_prefix = AR
																							, i_sequence_var = RSU_g_sequence_array);
	%Int_RSUArray_SetItemsByDS(ivar_array = __ARRAY_ID_CREATE
										, i_query = &i_query.
										, i_variable_value = &i_variable.)
	%global &__ARRAY_ID_CREATE._term;
	%let &__ARRAY_ID_CREATE._term = %&RSUBool.False;
	%let &__ARRAY_ID_CREATE._index = 0;
	&__ARRAY_ID_CREATE.
%mend RSUArray__CreateByDataset;

/*<FunctionDesc ja_jp>配列を生成します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>配列ID</FunctionReturn ja_jp>*/
%macro RSUArray__Create(
/*<FunctionArgDesc ja_jp>配列の項目リスト</FunctionArgDesc ja_jp>*/
								i_items
/*<FunctionArgDesc ja_jp>項目の区切り文字</FunctionArgDesc ja_jp>*/
								, i_delimiter = %str( )
								);
	%local /readonly __ARRAY_ID_CREATE = %Prv_RSUClass_CreateInstance(i_prefix = AR
																							, i_sequence_var = RSU_g_sequence_array);
	%local __array_item_index;
	%local __array_item_value;
	%global &__ARRAY_ID_CREATE._max;
	%let &__ARRAY_ID_CREATE._max = 0;
	%if (not %&RSUMacroVariable.IsBlank(i_items)) %then %do;
		%do %while(%&RSUUtil.ForEach(i_items = &i_items., ovar_item = __array_item_value, iovar_index = __array_item_index, i_delimiter = &i_delimiter.));
			%global &__ARRAY_ID_CREATE._V_&__array_item_index.;
			%let &__ARRAY_ID_CREATE._V_&__array_item_index. = &__array_item_value.;
			%let &__ARRAY_ID_CREATE._max = %eval(&&&__ARRAY_ID_CREATE._max + 1);
		%end;
	%end;
	%global &__ARRAY_ID_CREATE._term;
	%let &__ARRAY_ID_CREATE._term = %&RSUBool.False;
	%global &__ARRAY_ID_CREATE._index;
	%let &__ARRAY_ID_CREATE._index = 0;
	&__ARRAY_ID_CREATE.
%mend RSUArray__Create;

/*<FunctionDesc ja_jp>値が空の配列を生成します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>配列ID</FunctionReturn ja_jp>*/
%macro RSUArray__CreateBlank(
/*<FunctionArgDesc ja_jp>配列サイズ</FunctionArgDesc ja_jp>*/
									i_size
									);
	%local /readonly __ARRAY_ID_CREATE = %Prv_RSUClass_CreateInstance(i_prefix = AR
																							, i_sequence_var = RSU_g_sequence_array);
	%local __array_item_index;
	%local __array_item_value;
	%local /readonly __ARRAY_SIZE = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(i_size), 0, &i_size.);
	%do __array_item_index = 1 %to &__ARRAY_SIZE.;
		%global &__ARRAY_ID_CREATE._V_&__array_item_index.;
		%let &__ARRAY_ID_CREATE._V_&__array_item_index. =;
	%end;
	%global &__ARRAY_ID_CREATE._max;
	%let &__ARRAY_ID_CREATE._max = &__ARRAY_SIZE.;
	%global &__ARRAY_ID_CREATE._term;
	%let &__ARRAY_ID_CREATE._term = %&RSUBool.False;
	%global &__ARRAY_ID_CREATE._index;
	%let &__ARRAY_ID_CREATE._index = 0;
	&__ARRAY_ID_CREATE.
%mend RSUArray__CreateBlank;

/*<FunctionDesc ja_jp>配列を破棄します</FunctionDesc ja_jp>*/
%macro RSUArray__Dispose(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_array
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array)
	%local /readonly __ARRAY_ID_DISPOSE = &&&ivar_array.;
	%&RSUMacroVariable.Delete(i_regex = /^&__ARRAY_ID_DISPOSE._/i)
	%&RSUDS.Delete(&__ARRAY_ID_DISPOSE.)
%mend RSUArray__Dispose;

/*<FunctionArgDesc ja_jp>指定したインデックスにポインタを設定</FunctionArgDesc ja_jp>*/
%macro RSUArray__SetIndex(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_array
/*<FunctionArgDesc ja_jp>配列のインデックス</FunctionArgDesc ja_jp>*/
								, i_pos
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array i_pos)
	%local /readonly __ARRAY_ID_RESET = &&&ivar_array.;
	%let &__ARRAY_ID_RESET._term = %&RSUBool.False;
	%let &__ARRAY_ID_RESET._index = &i_pos.;
%mend RSUArray__SetIndex;

/*<FunctionDesc ja_jp>配列のサイズを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>配列のサイズ</FunctionReturn ja_jp>*/
%macro RSUArray__Size(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
							ivar_array
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array)
	%local /readonly __ARRAY_ITEMS_ID_SIZE = &&&ivar_array.;
	&&&__ARRAY_ITEMS_ID_SIZE._max
%mend RSUArray__Size;

/*<FunctionDesc ja_jp>配列が空か否かを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0: 配列は空ではない、1: 配列が空</FunctionReturn ja_jp>*/
%macro RSUArray__IsEmpty(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_array
								);
	%eval(%RSUArray__Size(&ivar_array.) = 0)
%mend RSUArray__IsEmpty;

/*<FunctionDesc ja_jp>配列の指定項目の値を返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>配列の指定項目の値</FunctionReturn ja_jp>*/
%macro RSUArray__Get(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名（インデックス込み）</FunctionArgDesc ja_jp>*/
							i_array_accessor
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_array_accessor)
	%local __array_id;
	%local __array_item_index;
	%Int_RSUArray_ParseAccessor(i_item_accessor = &i_array_accessor.
										, i_regex_accessor = /^(\w+)\[(\d+)\]$/
										, ovar_array_id = __array_id
										, ovar_item_key = __array_item_index)
	%Int_RSUArray_VerifyIndexRange(ivar_array = &__array_id.
											, i_index = &__array_item_index.)
	%local /readonly __ARRAY_ID_GET = &&&__array_id.;
	&&&__ARRAY_ID_GET._V_&__array_item_index.
%mend RSUArray__Get;

/*<FunctionDesc ja_jp>配列の指定項目の値を設定します</FunctionDesc ja_jp>*/
%macro RSUArray__Set(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名（インデックス込み）</FunctionArgDesc ja_jp>*/
							i_array_accessor
/*<FunctionArgDesc ja_jp>設定値</FunctionArgDesc ja_jp>*/
							, i_value
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_array_accessor)
	%local __array_id;
	%local __array_item_index;
	%Int_RSUArray_ParseAccessor(i_item_accessor = &i_array_accessor.
										, i_regex_accessor = /^(\w+)\[(\d+)\]$/
										, ovar_array_id = __array_id
										, ovar_item_key = __array_item_index)
	%Int_RSUArray_VerifyIndexRange(ivar_array = &__array_id.
											, i_index = &__array_item_index.)
	%local /readonly __ARRAY_ID_SET = &&&__array_id.;
	%let &__ARRAY_ID_SET._V_&__array_item_index. = &i_value.;
%mend RSUArray__Set;

/*<FunctionReturn ja_jp>見つかった項目番号（見つからない場合は0）</FunctionReturn ja_jp>*/
/*<FunctionReturn ja_jp>0: 指定値が含まれない、それ以外: 項目番号</FunctionReturn ja_jp>*/
%macro RSUArray__Find(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
							ivar_array
/*<FunctionArgDesc ja_jp>検索値</FunctionArgDesc ja_jp>*/
							, i_value
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array)
	%local /readonly __ARRAY_ID_FIND = &&&ivar_array.; 
	%local __FOUND_ARRAY_ITEM_KEY;
	%let __FOUND_ARRAY_ITEM_KEY = %Int_RSUArray_FindValue(ivar_array = &ivar_array.
																			, i_value = &i_value);
	%if (%&RSUMacroVariable.IsNull(__FOUND_ARRAY_ITEM_KEY)) %then %do;
		%let __FOUND_ARRAY_ITEM_KEY = 0;
	%end;
	&__FOUND_ARRAY_ITEM_KEY.
%mend RSUArray__Find;

/*<FunctionReturn ja_jp>指定した値が配列に含まれているかを返します</FunctionReturn ja_jp>*/
/*<FunctionReturn ja_jp>0: 指定値が含まれない、1: 指定値が含まれる</FunctionReturn ja_jp>*/
%macro RSUArray__Contains(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_array
/*<FunctionArgDesc ja_jp>検索値</FunctionArgDesc ja_jp>*/
								, i_value
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array)
	%local /readonly __FOUND_ITEM_CONTAINS = %RSUArray__Find(&ivar_array.
																				, &i_value);
	%eval(not &__FOUND_ITEM_CONTAINS. = 0)
%mend RSUArray__Contains;

/*<FunctionReturn ja_jp>配列の内容をログに出力します</FunctionReturn ja_jp>*/
%macro RSUArray__Show(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
							ivar_array
							);
	%local /readonly __ARRAY_ID_SHOW = &&&ivar_array.;
	%Int_RSUArray_ShowItems(ivar_array = &ivar_array.
									, i_index_from = 1
									, i_index_to = &&&__ARRAY_ID_SHOW._max.)
%mend RSUArray__Show;

/*<FunctionDesc ja_jp>配列の末尾に項目を追加します</FunctionDesc ja_jp>*/
%macro RSUArray__Add(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
							ivar_array
/*<FunctionArgDesc ja_jp>追加項目</FunctionArgDesc ja_jp>*/
							, i_value);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array)
	%local /readonly __ARRAY_ID_ADD = &&&ivar_array.;
	%let &__ARRAY_ID_ADD._max = %eval(&&&__ARRAY_ID_ADD._max. + 1);
	%global &__ARRAY_ID_ADD._V_&&&__ARRAY_ID_ADD._max;
	%let &__ARRAY_ID_ADD._V_&&&__ARRAY_ID_ADD._max = &i_value.;
%mend RSUArray__Add;

/*<FunctionDesc ja_jp>配列項目を削除します</FunctionDesc ja_jp>*/
%macro RSUArray__Remove(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名（インデックス込み）</FunctionArgDesc ja_jp>*/
								i_array_accessor
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_array_accessor)
	%local __array_id;
	%local __array_item_index;
	%Int_RSUArray_ParseAccessor(i_item_accessor = &i_array_accessor.
										, i_regex_accessor = /^(\w+)\[(\d+)\]$/
										, ovar_array_id = __array_id
										, ovar_item_key = __array_item_index)
	%Int_RSUArray_VerifyIndexRange(ivar_array = &__array_id.
											, i_index = &__array_item_index.)

	%local /readonly __ARRAY_ID_REMOVE = &&&__array_id.;
	%local __tmp_index_src;
	%local __tmp_index_dest;
	%do __tmp_index_src = %eval(&__array_item_index. + 1) %to &&&__ARRAY_ID_REMOVE._max;
			%let __tmp_index_dest = %eval(&__tmp_index_src. - 1);
			%let &__ARRAY_ID_REMOVE._V_&__tmp_index_dest. = &&&__ARRAY_ID_REMOVE._V_&__tmp_index_src.;
	%end;
	%local /readonly __ARRAY_ITEM_MAX_INDEX = &&&__ARRAY_ID_REMOVE._max.;
	%symdel &__ARRAY_ID_REMOVE._V_&__ARRAY_ITEM_MAX_INDEX.;
	%let &__ARRAY_ID_REMOVE._max = %eval(&&&__ARRAY_ID_REMOVE._max. - 1);
%mend RSUArray__Remove;

%macro RSUArray__RemoveItems(ivar_array
									, i_range =
									, i_regex =);
	%local __array_index_range_index;
	%if (not %&RSUMacroVariable.IsBlank(i_range)) %then %do;
		%local __array_index_from;
		%local __array_index_to;
		%Int_RSUArray_ParseIndexRange(ivar_array = &ivar_array.
												, i_range = &i_range.
												, ovar_index_from = __array_index_from
												, ovar_index_to = __array_index_to)
		%do __array_index_range_index = &__array_index_from. %to &__array_index_to.;
			%RSUArray__Remove(&ivar_array.[&__array_index_range_index.])
		%end;
	%end;
	%else %if (not %&RSUMacroVariable.IsBlank(i_regex)) %then %do;
		%local /readonly __ARRAY_ID_REMOVE_ITEMS = &&&ivar_array.;
		%do __array_index_range_index = 1 %to &&&__ARRAY_ID_REMOVE_ITEMS._max;
			%if (%sysfunc(prcmatch(&i_regex., %RSUArray__Get(&ivar_array.[&__array_index_range_index.])))) %then %do;
				%RSUArray__Remove(&ivar_array.[&__array_index_range_index.])
			%end;
		%end;
	%end;
%mend RSUArray__RemoveItems;

/*<FunctionDesc ja_jp>配列に項目を挿入します</FunctionDesc ja_jp>*/
%macro RSUArray__Insert(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名（インデックス込み）</FunctionArgDesc ja_jp>*/
								i_array_accessor
/*<FunctionArgDesc ja_jp>挿入値</FunctionArgDesc ja_jp>*/
								, i_value
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_array_accessor)
	%local __array_id;
	%local __array_item_index;
	%Int_RSUArray_ParseAccessor(i_item_accessor = &i_array_accessor.
										, i_regex_accessor = /^(\w+)\[(\d+)\]$/
										, ovar_array_id = __array_id
										, ovar_item_key = __array_item_index)
	%Int_RSUArray_VerifyIndexRange(ivar_array = &__array_id.
											, i_index = &__array_item_index.)

	%local /readonly __ARRAY_ID_INSERT = &&&__array_id.;
	%let &__ARRAY_ID_INSERT._max = %eval(&&&__ARRAY_ID_INSERT._max. + 1);
	%local /readonly __ARRAY_ITEM_MAX_INDEX = &&&__ARRAY_ID_INSERT._max.;
	%global &__ARRAY_ID_INSERT._V_&__ARRAY_ITEM_MAX_INDEX.;
	%local __tmp_index_src;
	%local __tmp_index_dest;
	%do __tmp_index_src = &&&__ARRAY_ID_INSERT._max %to &__array_item_index. %by -1;
			%let __tmp_index_dest = %eval(&__tmp_index_src. + 1);
			%let &__ARRAY_ID_INSERT._V_&__tmp_index_dest. = &&&__ARRAY_ID_INSERT._V_&__tmp_index_src.;
	%end;
	%let &__ARRAY_ID_INSERT._V_&__array_item_index. = &i_value.;
%mend RSUArray__Insert;

/*<FunctionDesc ja_jp>配列項目を走査します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0:取得失敗、1:取得成功</FunctionReturn ja_jp>*/
%macro RSUArray__ForEach(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_array
/*<FunctionArgDesc ja_jp>項目値を保持する変数名</FunctionArgDesc ja_jp>*/
								, ovar_item
/*<FunctionArgDesc ja_jp>走査対象を指定する正規表現</FunctionArgDesc ja_jp>*/
								, i_regex =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array ovar_item)
	%local /readonly __ARRAY_ID_FOREACH = &&&ivar_array.;
	%local __array_foreach_result;
	%local __array_item_index;
	%do %while(1);
		%if (&&&__ARRAY_ID_FOREACH._term.) %then %do;
			%let __array_foreach_result = %&RSUBool.False;
			%let &__ARRAY_ID_FOREACH._term = %&RSUBool.False;
			%let &__ARRAY_ID_FOREACH._index = 0;
			%let &ovar_item. =;
			%goto __leave_array_foreach__;
		%end;
		%if (&&&__ARRAY_ID_FOREACH._index. = &&&__ARRAY_ID_FOREACH._max.) %then %do;
			%let __array_foreach_result = %&RSUBool.False;
			%let &__ARRAY_ID_FOREACH._term = %&RSUBool.False;
			%let &__ARRAY_ID_FOREACH._index = 0;
			%let &ovar_item. =;
			%goto __leave_array_foreach__;
		%end;
		%let &__ARRAY_ID_FOREACH._index = %eval(&&&__ARRAY_ID_FOREACH._index. + 1);
		%let __array_item_index = &&&__ARRAY_ID_FOREACH._index.;
		%let &ovar_item. = &&&__ARRAY_ID_FOREACH._V_&__array_item_index.;
		%if (%&RSUMacroVariable.IsBlank(i_regex)) %then %do;
			%let __array_foreach_result = %&RSUBool.True;
			%goto __leave_array_foreach__;
		%end;
		%if (%sysfunc(prxmatch(&i_regex., &&&ovar_item.))) %then %do;
			%let __array_foreach_result = %&RSUBool.True;
			%goto __leave_array_foreach__;
		%end;
	%end;
%__leave_array_foreach__:
	&__array_foreach_result.
%mend RSUArray__ForEach;

/*<FunctionDesc ja_jp>配列走査を中断します</FunctionDesc ja_jp>*/
%macro RSUArray__TerminateLoop(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
										ivar_array
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array)
	%local /readonly __ARRAY_ID_TEMINATE = &&&ivar_array.;
	%let &__ARRAY_ID_TEMINATE._term = %&RSUBool.True;
%mend RSUArray__TerminateLoop;

/*<FunctionDesc ja_jp>配列の内容を連結します</FunctionDesc ja_jp>*/
%macro RSUArray__Concat(
/*<FunctionArgDesc ja_jp>配列IDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_array
/*<FunctionArgDesc ja_jp>区切り文字</FunctionArgDesc ja_jp>*/
								, i_delimiter = %str( )
/*<FunctionArgDesc ja_jp>文字の囲みタイプ</FunctionArgDesc ja_jp>*/
								, i_enclosure =
/*<FunctionArgDesc ja_jp>走査対象を指定する正規表現</FunctionArgDesc ja_jp>*/
								, i_regex =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array)
	%local __item_value;
	%local __concatenated_text;
	%do %while(%RSUArray__ForEach(&ivar_array, __item_value, i_regex = &i_regex.));
		%let __item_value = %Int_RSUText_EncloseText(i_text = &__item_value.
																	, i_enclosure = &i_enclosure.);
		%&RSUText.Append(iovar_base = __concatenated_text
							, i_append_text = &__item_value.
							, i_delimiter = &i_delimiter.)
	%end;
	&__concatenated_text.
%mend RSUArray__Concat;

%macro RSUArray__SliceByValue(ivar_array =
										, i_regex =
										, i_remove_original =
										, ovar_array =);
	%local &ovar_array. = %RSUArray__CreateBlank();
	%local __array_item;
	%do %while(%RSUArray__ForEach(&ivar_array., &i_regex., __array_item));
		%RSUArray__Add(&&&ovar_array.
						, &__array_item.)
	%end;
	%if (&i_remove_original.) %then %do;
		%RSUArray__RemoveItems(&ivar_array.
									, i_regex = &i_regex.)
	%end;
%mend RSUArray__SliceByValue;

%macro RSUArray__SliceByRange(ivar_array =
										, i_range =
										, i_remove_original =
										, ovar_array =);
	%local __array_index_from;
	%local __array_index_to;
	%Int_RSUArray_ParseIndexRange(ivar_array = &ivar_array.
												, i_range = &i_range.
												, ovar_index_from = __array_index_from
												, ovar_index_to = __array_index_to)
	%local &ovar_array. = %RSUArray__CreateBlank();
	%local __array_item;
	%do __array_index = &__array_index_from %to &__array_index_to.;
		%let __array_item = %RSUArray__Get(&ivar_array[&__array_index.]);
		%RSUArray__Add(&&&ovar_array.
						, &__array_item.)
	%end;	
	%if (&i_remove_original.) %then %do;
		%RSUArray__RemoveItems(&ivar_array.
									, i_range = &i_range.)
	%end;
%mend RSUArray__SliceByRange;