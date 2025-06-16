/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_List.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/4/10
/*
/* NOTE: Arrayをベースに以下の操作が拡張される
/* NOTE: 要素の追加、挿入、削除
/************************************************************************************/
/*<PackageID>RSUList</PackageID>*/
/*<CategoryID>Cate_MacroVariable</CategoryID>*/
/*<PackagePurpose ja_jp>リスト</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>List</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>配列をベースとしたリスト機能を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions manipulating list</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>リストパッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUList, RSUList__)

/* ベースマクロ（Array） */
/*<FunctionDesc ja_jp>リスト内の要素数を返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>要素数</FunctionReturn ja_jp>*/
%macro RSUList__GetSize(
/*<FunctionArgDesc ja_jp>リストを保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
								ivar_list
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_list)
	%RSUArray__GetSize(ivar_array = &ivar_list.)
%mend RSUList__GetSize;

/*<FunctionDesc ja_jp>リストが空か否かを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0: 要素あり\quad 1: 空</FunctionReturn ja_jp>*/
%macro RSUList__IsEmpty(
/*<FunctionArgDesc ja_jp>リストを保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
								ivar_list =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_list)
	%RSUArray__IsEmpty(ivar_array = &ivar_list.)
%mend RSUList__IsEmpty;

/*<FunctionDesc ja_jp>指定要素番号の要素を返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>指定要素番号の要素</FunctionReturn ja_jp>*/
%macro RSUList__Get(
/*<FunctionArgDesc ja_jp>リストを保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
						ivar_list =
/*<FunctionArgDesc ja_jp>要素番号</FunctionArgDesc ja_jp>*/
						, i_index =
						);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_list i_index)
	%RSUArray__Get(ivar_array = &ivar_list.
						, i_index = &i_index.)
%mend RSUList__Get;

/*<FunctionDesc ja_jp>指定要素のリスト内の要素番号を返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0: 指定要素なし\quad 0以外: 指定要素の要素番号</FunctionReturn ja_jp>*/
%macro RSUList__Find(
/*<FunctionArgDesc ja_jp>リストを保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
							ivar_list
/*<FunctionArgDesc ja_jp>検索要素</FunctionArgDesc ja_jp>*/
							, i_item =
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_list i_item)
	%RSUArray__Find(ivar_array = &ivar_list.
						, i_item = &i_item.)
%mend RSUList__Find;

/*<FunctionDesc ja_jp>指定要素がリストに含まれているか否かを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0:指定要素なし\quad 1:指定要素あり</FunctionReturn ja_jp>*/
%macro RSUList__ContainsItem(
/*<FunctionArgDesc ja_jp>リストを保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
									ivar_list =
/*<FunctionArgDesc ja_jp>検索要素</FunctionArgDesc ja_jp>*/
									, i_item =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_list)
	%RSUArray__ContainsItem(ivar_array = &ivar_list.
									, i_item = &i_item.)
%mend RSUList__ContainsItem;

/*<FunctionDesc ja_jp>リスト内の要素を連結したテキストを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>全要素を連結した文字列</FunctionReturn ja_jp>*/
%macro RSUList__GetText(
/*<FunctionArgDesc ja_jp>リストを保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
								ivar_list =
/*<FunctionArgDesc ja_jp>要素間の区切り文字</FunctionArgDesc ja_jp>*/
								, i_delimiter = %str( )
/*<FunctionArgDesc ja_jp>要素をダブルクォーテーションで囲むか否か </FunctionArgDesc ja_jp>*/
								, i_is_quoted =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_list)
	%RSUArray__GetText(ivar_array = &ivar_list.
							, i_delimiter = &i_delimiter.
							, i_is_quoted = &i_is_quoted.)
%mend RSUList__GetText;

/*<FunctionDesc ja_jp>リストの内容をログに出力します</FunctionDesc ja_jp>*/
%macro RSUList__Print(ivar_list);
/*<FunctionArgDesc ja_jp>リストを保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
	%RSUArray__Print(&ivar_list.)
%mend RSUList__Print;

/*<FunctionDesc ja_jp>リストをデータセットにエクスポートします</FunctionDesc ja_jp>*/
%macro RSUList__ExportToDS(
/*<FunctionArgDesc ja_jp>リストを保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
									ivar_list
/*<FunctionArgDesc ja_jp>エクスポート先のデータセット</FunctionArgDesc ja_jp>*/
									, ods_output_ds
/*<FunctionArgDesc ja_jp>行番号を含めるか否か</FunctionArgDesc ja_jp>*/
									, i_contain_index = 0
/*<FunctionArgDesc ja_jp>変数サイズ</FunctionArgDesc ja_jp>*/
									, i_var_length = 500
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_list ods_output_ds)
	%RSUArray__ExportToDS(ivar_array = &ivar_list.
								, ods_output_ds = &ods_output_ds.
								, i_contain_index = &i_contain_index.
								, i_var_length = &i_var_length.)
%mend RSUList__ExportToDS;

/*<FunctionDesc ja_jp>要素を走査し、値とインデックスを取得します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0: 走査終了\quad 1: 走査未完了（値取得成功）</FunctionReturn ja_jp>*/
%macro RSUList__ForEach(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
								ivar_array
/*<FunctionArgDesc ja_jp>取得した値を保持するマクロ変数</FunctionArgDesc ja_jp>*/
								, ovar_item =
/*<FunctionArgDesc ja_jp>取得したインデックスを保持するマクロ変数</FunctionArgDesc ja_jp>*/
								, iovar_index =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_list ovar_item iovar_index)
	%RSUArray__ForEach(ivar_arry = &i_var_array.
							, ovar_item = &ovar_item.
							, iovar_index = &iovar_index.)
%mend RSUList__ForEach;

/*<FunctionDesc ja_jp>イテレータを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>生成された要素イテレータのインスタンスID</FunctionReturn ja_jp>*/
%macro RSUList__GetIterator(
/*<FunctionArgDesc ja_jp>リストを保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
									ivar_list =
/*<FunctionArgDesc ja_jp>イテレータの向き（1: Forward、-1: Backward）</FunctionArgDesc ja_jp>*/
									, i_direction = 1
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_list)
	%RSUArray__GetIterator(ivar_array = &ivar_list.
								, i_direction = &i_direction.)
%mend RSUList__GetIterator;

/*<FunctionDesc ja_jp>テキストからリストを作成します（サイズ優先）</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>配列要素</FunctionReturn ja_jp>*/
%macro RSUList__Create(
/*<FunctionArgDesc ja_jp>リストサイズ</FunctionArgDesc ja_jp>*/
							i_size =
/*<FunctionArgDesc ja_jp>要素を結合した文字列</FunctionArgDesc ja_jp>*/
							, i_items =
/*<FunctionArgDesc ja_jp>要素間の区切り文字</FunctionArgDesc ja_jp>*/
							, i_delimiter = %str( )
/*<FunctionArgDesc ja_jp>要素の前後スペースを削除するか否か</FunctionArgDesc ja_jp>*/
							, i_trimmed = 1
							);
	%RSUArray__Create(i_size = &i_size.
							, i_items = &i_items.
							, i_delimiter = &i_delimiter.
							, i_trimmed = &i_trimmed.)
%mend RSUList__Create;

/*<FunctionDesc ja_jp>データセットをインポートしてリストを作成します</FunctionDesc ja_jp>*/
%macro RSUList__ImportFromDS(
/*<FunctionArgDesc ja_jp>インポート元データセット</FunctionArgDesc ja_jp>*/
									ids_input_ds =
/*<FunctionArgDesc ja_jp>インポート対象の変数名</FunctionArgDesc ja_jp>*/
									, i_value_varname =
/*<FunctionArgDesc ja_jp>順序を規定する変数名</FunctionArgDesc ja_jp>*/
									, i_order_varname =
/*<FunctionArgDesc ja_jp>リストを保持するマクロ変数</FunctionArgDesc ja_jp>*/
									, ovar_list =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_input_ds i_value_varname i_order_varname ovar_list)
	%RSUArray__ImportFromDS(ids_input_ds = &ids_input_ds.
									, i_value_varname = &i_value_varname.
									, i_order_varname = &i_order_varname.
									, ovar_array = &ovar_list.)
%mend RSUList__ImportFromDS;

/*<FunctionDesc ja_jp>指定要素番号の要素の内容を更新します</FunctionDesc ja_jp>*/
%macro RSUList__Set(
/*<FunctionArgDesc ja_jp>リストを保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
							iovar_list
/*<FunctionArgDesc ja_jp>要素番号</FunctionArgDesc ja_jp>*/
							, i_index =
/*<FunctionArgDesc ja_jp>更新内容</FunctionArgDesc ja_jp>*/
							, i_value =
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = iovar_list i_index)
	%RSUArray__Set(iovar_array = &iovar_list.
						, i_index =	&i_index.
						, i_value = &i_value.)
%mend RSUList__Set;

/*<FunctionDesc ja_jp>リストをクリアします</FunctionDesc ja_jp>*/
%macro RSUList__Clear(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
							iovar_list =
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = iovar_list)
	%RSUArray__Clear(iovar_array = &iovar_list.)
%mend RSUList__Clear;

/*<FunctionDesc ja_jp>配列から重複を取り除きます</FunctionDesc ja_jp>*/
%macro RSUList__MakeUnique(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
									iovar_list =
									);
	%RSUArray__MakeUnique(iovar_array = &iovar_list.)
%mend RSUList__MakeUnique;

/***** ! List固有操作 *****/
/*<FunctionDesc ja_jp>先頭要素を返します</FunctionDesc ja_jp>*/
%macro RSUList__First(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
							ivar_list
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_list)
	%RSUArray__Get(&ivar_list., 1)
%mend RSUList__First;

/*<FunctionDesc ja_jp>最終要素を返します</FunctionDesc ja_jp>*/
%macro RSUList__Last(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
							ivar_list
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_list)
	%RSUArray__Get(&ivar_list., %RSUArray__GetSize(&ivar_list.))
%mend RSUList__Last;

/*<FunctionDesc ja_jp>配列の末尾に要素を追加します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>追加された結果の配列サイズ</FunctionReturn ja_jp>*/
%macro RSUList__Add(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
						iovar_list
/*<FunctionArgDesc ja_jp>追加要素</FunctionArgDesc ja_jp>*/
						, i_item
						);
	%&RSUUtil.VerifyRequiredArgs(i_args = iovar_list)
	%let &iovar_list. = &&&iovar_list.&RSU_G_ARRAY_DELIMITER.&i_item.&RSU_G_ARRAY_DELIMITER.;
	%RSUArray__GetSize(&iovar_list.)
%mend RSUList__Add;

/*<FunctionDesc ja_jp>配列の指定可所に要素を挿入します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>挿入された結果の配列サイズ</FunctionReturn ja_jp>*/
%macro RSUList__Insert(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
							iovar_list =
/*<FunctionArgDesc ja_jp>挿入箇所</FunctionArgDesc ja_jp>*/
							, i_index =
/*<FunctionArgDesc ja_jp>追加要素</FunctionArgDesc ja_jp>*/
							, i_item =
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = iovar_list i_index)
	/* ! 新要素のインデックスが i_index になる */
	%Int_RSUArray_VerifyIndexRange(i_array_var = &iovar_list.
											, i_index = &i_index.)

	%local _string_former;
	%local _string_target;
	%local _string_latter;
	%Int_RSUArray_SplitString(ivar_array = &iovar_list.
										, i_index = &i_index.
										, ovar_former = _string_former
										, ovar_target = _string_target
										, ovar_latter = _string_latter)
	%local /readonly _RSU_LIST_NEW_ITEM = &RSU_G_ARRAY_DELIMITER.&i_item.&RSU_G_ARRAY_DELIMITER.;
	%let &iovar_list. = &_string_former.&_RSU_LIST_NEW_ITEM.&_string_target.&_string_latter.;
	%RSUArray__GetSize(&iovar_list.)
%mend RSUList__Insert;

/*<FunctionDesc ja_jp>指定要素番号の要素を削除します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>削除された項目</FunctionReturn ja_jp>*/
%macro RSUList__RemoveItemAt(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
									iovar_list =
/*<FunctionArgDesc ja_jp>要素番号</FunctionArgDesc ja_jp>*/
									, i_index =);
	%&RSUUtil.VerifyRequiredArgs(i_args = iovar_list i_index)
	%Int_RSUArray_VerifyIndexRange(ivar_array = &iovar_list.
											, i_index = &i_index.)
	%local _string_former;
	%local _string_target;
	%local _string_latter;
	%Int_RSUArray_SplitString(ivar_array = &iovar_list.
										, i_index = &i_index.
										, ovar_former = _string_former
										, ovar_target = _string_target
										, ovar_latter = _string_latter)
	%let &iovar_list. = &_string_former.&_string_latter.;
	%local /readonly _RSU_LIST_REMOVED_ITEM = %substr(&_string_target., 2, %length(&_string_target.) - 2);
	&_RSU_LIST_REMOVED_ITEM.
%mend RSUList__RemoveItemAt;

/*<FunctionDesc ja_jp>指定要素と同一の要素をすべて削除します</FunctionDesc ja_jp>*/
%macro RSUList__RemoveItem(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
									iovar_list =
/*<FunctionArgDesc ja_jp>削除対象要素</FunctionArgDesc ja_jp>*/
									, i_item =);
	%&RSUUtil.VerifyRequiredArgs(i_args = iovar_list)
	%local _index;
	%let _index = %RSUArray__Find(ivar_array = &iovar_list
											, i_item = &i_item.);
	%do %while(0 < &_index.);
		%RSUList__RemoveItemAt(iovar_list = &iovar_list.
									, i_index = &_index.);
		%let _index = %RSUArray__Find(ivar_array = &iovar_list
												, i_item = &i_item.);
	%end;
%mend RSUList__RemoveItem;