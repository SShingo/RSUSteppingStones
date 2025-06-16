/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Array.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/4/10
/*
/* NOTE: 配列は以下のように`で囲まれた要素を連結した文字列で保持される
/* NOTE: `aaa``bbb``ccc`
/* NOTE: 配列インデックスは 1 から始まる
/* NOTE: 区切り記号 ` は、定数マクロ変数RSU_G_ARRAY_DELIMITERに格納されている
/* NOTE: 空要素も許容される
/* NOTE: 例） `AAA````CCC`（第2要素が空）
/* ! 一番使われないであろう文字 "`" を区切りに使用
/* ! 要素に "`" が含まれると正常に機能しない
/* ! 文字数は65,535文字まで（マクロ変数の限界）
/************************************************************************************/
/*<PackageID>RSUArray</PackageID>*/
/*<CategoryID>Cate_MacroVariable</CategoryID>*/
/*<PackagePurpose ja_jp>配列</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Array</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>配列機能に係るマクロ関数群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions manipulating array</PackageDesc en_us>*/
/*<PkgDetail ja_jp>
マクロ変数に対して、一般的な言語の配列のようにインデックスを用いて値を保持・取得出来るようにします。流石に``\texttt{\_my\_macro[1]}''のようなアクセス法は無理で、その代わりに``\texttt{\_my\_macro.Get(1)}''というようなアクセスを可能します。

\texttt{PKGArray}では、最初に設定した内容からの変更（値の追加、削除、更新）はサポートしていません（``\texttt{RSUList}''、``\texttt{RSUQueue}''、``\texttt{RSUStack}''を適宜利用してください）。

配列のインデックスはSASのコンベンションに合わせて{\bfseries 1始まり}です。

\paragraph{裏側}配列は以下のように`で囲まれた要素を連結した文字列で保持されています。
\begin{center}
\texttt{`aaa``bbb``ccc`}
\end{center}
</PkgDetail ja_jp>*/
/*<PkgNote ja_jp>
\begin{itemize}
\item 保持する文字列に`` \` ''（アクサングラーブ）を含めると不定な挙動となります。
\item 保持内容と接続文字数の合計が65,535文字を超えることは出来ません（SASのマクロ変数の限界）
\end{itemize}
</PkgNote ja_jp>*/

/*<ConstantDesc ja_jp>配列パッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUArray, RSUArray__)
/*<ConstantDesc ja_jp>イテレータクラス定義ファイル名</ConstantDesc ja_jp>*/
%RSUSetConstant(RSU_G_CLASS_FILE_ITERATOR, RSU_PKG_Class_IteratorArray)

/*<FunctionDesc ja_jp>配列の要素数を返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>要素数</FunctionReturn ja_jp>*/
%macro RSUArray__GetSize(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
								ivar_array
								);
	/* ! 区切り文字 ` は常に偶数個存在するものと想定（要素の前後）*/
	/* ! 区切り文字の数の半分が要素数 */
	%local _count;
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array)
	%local /readonly _RSU_ARRAY_TMP_ITEMS = &&&ivar_array.;
	%let _count = %sysfunc(count(%quote(&_RSU_ARRAY_TMP_ITEMS.), &RSU_G_ARRAY_DELIMITER.));
	%let _count = %eval(&_count. / 2);
	&_count.
%mend RSUArray__GetSize;

/*<FunctionDesc ja_jp>配列が空か否かを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>\%\&RSUBool.False: 空でない（要素あり）\quad \%\&RSUBool.True: 空</FunctionReturn ja_jp>*/
%macro RSUArray__IsEmpty(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
								ivar_array
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array)
	%if (%RSUArray__GetSize(ivar_array = &ivar_array.) = 0) %then %do;
		%&RSUBool.True
	%end;
	%else %do;
		%&RSUBool.False
	%end;
%mend RSUArray__IsEmpty;

/*<FunctionDesc ja_jp>指定要素番号の要素を返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>指定要素番号の要素</FunctionReturn ja_jp>*/
%macro RSUArray__Get(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
							ivar_array
/*<FunctionArgDesc ja_jp>要素番号</FunctionArgDesc ja_jp>*/
							, i_index
							);
/*<FunctionNote ja_jp>
要素番号``\texttt{i\_index}''が範囲外の場合、エラーとなり処理が中断します。
</FunctionNote ja_jp>*/
	/* ! 例：`aa``bb````cc` => {aa, bb, , cc} */
	/* ! 区切り文字で文字列をSplitすると： _|aa|_|bb|_|_|_|cc|_
	/* ! 文字列を区切り文字で区切った場合に、(要素番号 x 2)番目のセグメントが指定要素内容 */
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array i_index)
	%Int_RSUArray_VerifyIndexRange(ivar_array = &ivar_array.
											, i_index = &i_index.)
	%local /readonly _RSU_ARRAY_TMP_ITEMS = &&&ivar_array.;
	%local /readonly _RSU_TMP_ARRAY_INDEX = %eval(&i_index. * 2);
	%scan(&_RSU_ARRAY_TMP_ITEMS., &_RSU_TMP_ARRAY_INDEX., &RSU_G_ARRAY_DELIMITER., M)
%mend RSUArray__Get;

/*<FunctionDesc ja_jp>配列内の最初に見つかった指定要素の要素番号を返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0:指定要素なし\quad 0以外:指定要素の要素番号</FunctionReturn ja_jp>*/
%macro RSUArray__Find(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
							ivar_array
/*<FunctionArgDesc ja_jp>検索要素</FunctionArgDesc ja_jp>*/
							, i_item
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array)
	%local /readonly _RSU_ARRAY_TMP_ITEMS = &&&ivar_array.;
	%local _index;
	%if (not %&RSUMacroVariable.IsBlank(i_item)) %then %do;
		/* ! 空ではない要素検索 */
		/* ! 例: 'aaa' という文字列の場所を見つける */
		%local /readonly _RSU_ARRAY_TMP_ITEM = &RSU_G_ARRAY_DELIMITER.&i_item.&RSU_G_ARRAY_DELIMITER.;
		%local /readonly _RSU_ARRAY_TMP_POS = %sysfunc(kfind(&_RSU_ARRAY_TMP_ITEMS., &_RSU_ARRAY_TMP_ITEM));

		%if (&_RSU_ARRAY_TMP_POS. = 0) %then %do;
			%let _index = 0;
		%end;
		%else %do;
			/* ! 'aaa''bbb''ccc'から 'bbb'を探索すると、pos = 6 */
			/* ! 最初の6文字 = 'aaa''（自分の要素の ` が一つ含まれる）*/
			/* ! この中に含まれる ` の数から、indexを計算 */
			%local /readonly _RSU_ARRAY_TMP_FORMER = %&RSUText.Left(&_RSU_ARRAY_TMP_ITEMS., i_length = &_RSU_ARRAY_TMP_POS.);
			%let _index = %sysfunc(count(&_RSU_ARRAY_TMP_FORMER., &RSU_G_ARRAY_DELIMITER.));
			%let _index = %eval((&_index. - 1) / 2  + 1);
		%end;
	%end;
	%else %do;
		/* ! 空要素検索 */
		%if (%length(&_RSU_ARRAY_TMP_ITEMS.) = 2) %then %do;
			/* ! 元配列が `` の場合は問答無用で 1 を返す. */
			%let _index = 1;
		%end;
		%else %do;
			/* ! ```を探す */
			/* ! `aaa````bbb` の場合 pos = 5 */
			/* ! 最初の5文字 = `aaa` */
			/* ! この中に含まれる ` の数から、indexを計算 */
			%local /readonly _RSU_ARRAY_TMP_ITEM = &RSU_G_ARRAY_DELIMITER.&RSU_G_ARRAY_DELIMITER.&RSU_G_ARRAY_DELIMITER.;
			%local /readonly _RSU_ARRAY_TMP_POS = %sysfunc(kfind(&_RSU_ARRAY_TMP_ITEMS., &_RSU_ARRAY_TMP_ITEM));

			%local /readonly _RSU_ARRAY_TMP_FORMER = %&RSUText.Left(&_RSU_ARRAY_TMP_ITEMS., i_length =  &_RSU_ARRAY_TMP_POS.);
			%let _index = %sysfunc(count(&_RSU_ARRAY_TMP_FORMER., &RSU_G_ARRAY_DELIMITER.));
			%let _index = %eval(&_index. / 2  + 1);
		%end;
	%end;
	&_index.
%mend RSUArray__Find;

/*<FunctionDesc ja_jp>指定要素が配列に含まれているか否かを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>\%\&RSUBool.False: 指定要素なし\quad \%\&RSUBool.True: 指定要素あり</FunctionReturn ja_jp>*/
%macro RSUArray__ContainsItem(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
										ivar_array
/*<FunctionArgDesc ja_jp>検索要素</FunctionArgDesc ja_jp>*/
										, i_item
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array)
	%local /readonly _RSU_ARRAY_TMP_INDEX = %RSUArray__Find(ivar_array = &ivar_array.
																			, i_item = &i_item);
	%if (0 < &_RSU_ARRAY_TMP_INDEX.) %then %do;
		%&RSUBool.True
	%end;
	%else %do;
		%&RSUBool.False
	%end;
%mend RSUArray__ContainsItem;

/*<FunctionDesc ja_jp>配列内の要素を連結したテキストを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>全要素を連結した文字列</FunctionReturn ja_jp>*/
%macro RSUArray__GetText(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
								ivar_array
/*<FunctionArgDesc ja_jp>要素間の区切り文字</FunctionArgDesc ja_jp>*/
								, i_delimiter = %str( )
/*<FunctionArgDesc ja_jp>要素をダブルクォーテーションで囲むか否か </FunctionArgDesc ja_jp>*/
								, i_is_quoted =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array)
	%local _string;
	%if (0 < %RSUArray__GetSize(ivar_array = &ivar_array.)) %then %do;
		%let _string = %nrbquote(%sysfunc(RSU_fcmp_get_array_text(&&&ivar_array., &i_delimiter., &i_is_quoted.)));
	%end;
	%sysfunc(trim(&_string.))
%mend RSUArray__GetText;

/*<FunctionDesc ja_jp>配列の内容をログに出力します</FunctionDesc ja_jp>*/
%macro RSUArray__Print(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
								ivar_array
							);
	%local /readonly _RSU_ARRAY_PRINT_SIZE = %&RSUArray.GetSize(ivar_array = &ivar_array.);
	%local _rsu_array_print_index;
	%do _rsu_array_print_index = 1 %to &_RSU_ARRAY_PRINT_SIZE.;
		%put &ivar_array.[&_rsu_array_print_index.] = %&RSUArray.Get(&ivar_array., &_rsu_array_print_index.);
	%end;
%mend RSUArray__Print;

/*<FunctionDesc ja_jp>配列をデータセットにエクスポートします</FunctionDesc ja_jp>*/
%macro RSUArray__ExportToDS(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
									ivar_array
/*<FunctionArgDesc ja_jp>エクスポート先のデータセット</FunctionArgDesc ja_jp>*/
									, ods_output_ds
/*<FunctionArgDesc ja_jp>配列番号を含めるか否か</FunctionArgDesc ja_jp>*/
									, i_contain_index = %&RSUBool.False
/*<FunctionArgDesc ja_jp>変数サイズ</FunctionArgDesc ja_jp>*/
									, i_var_length = 500
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array ods_output_ds)
	data &ods_output_ds.;
		attrib
			index length = 8.
			value length = $&i_var_length.
		;
		stop;
	run;
	quit;
	%local /readonly _RSU_ARRAY_EXPDS_ITERATOR = %RSUArray__GetIterator(ivar_array = &ivar_array);
	%local _rsu_array_exp_ds_index;
	%local _rsu_array_exp_ds_item;
	%do %while(%&_RSU_ARRAY_EXPDS_ITERATOR.Next);
		%let _rsu_array_exp_ds_index = %&_RSU_ARRAY_EXPDS_ITERATOR.CurrentIndex();
		%let _rsu_array_exp_ds_item = %&_RSU_ARRAY_EXPDS_ITERATOR.Current();
		proc sql;
			insert into &ods_output_ds.(index, value)
			values(&_rsu_array_exp_ds_index., "&_rsu_array_exp_ds_item.")
			;
		quit;
	%end;
	%&RSUClass.Dispose(_RSU_ARRAY_EXPDS_ITERATOR)

	%if (&i_contain_index. ne 1) %then %do;
		data &ods_output_ds.;
			set &ods_output_ds.;
			drop
				index
			;
		run;
		quit;
	%end;
%mend RSUArray__ExportToDS;

/*<FunctionDesc ja_jp>要素を走査し、値とインデックスを取得します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>\%\&RSUBool.False: 値取得失敗（走査終了）\quad \%\&RSUBool.True: 値取得成功</FunctionReturn ja_jp>*/
%macro RSUArray__ForEach(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
								ivar_array
/*<FunctionArgDesc ja_jp>取得した値を保持するマクロ変数</FunctionArgDesc ja_jp>*/
								, ovar_item =
/*<FunctionArgDesc ja_jp>取得したインデックスを保持するマクロ変数</FunctionArgDesc ja_jp>*/
								, iovar_index =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array ovar_item iovar_index)
	%if (%&RSUMacroVariable.IsBlank(&iovar_index.) or &&&iovar_index. < 0) %then %do;
		%let &iovar_index. = 0;
	%end;
	%local _result;
	%let &iovar_index. = %eval(&&&iovar_index. + 1);
	%if (%RSUArray__GetSize(&ivar_array.) < &&&iovar_index.) %then %do;
		%let _result = %&RSUBool.False;
		%let &ovar_item. =;
		%let &iovar_index. = 0;
	%end;
	%else %do;
		%let _result = %&RSUBool.True;
		%let &ovar_item. = %RSUArray__Get(&ivar_array., &&&iovar_index.);
	%end;
	&_result.
%mend RSUArray__ForEach;

/*<FunctionDesc ja_jp>イテレータを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>要素イテレータ</FunctionReturn ja_jp>*/
%macro RSUArray__GetIterator(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
									ivar_array =
/*<FunctionArgDesc ja_jp>イテレータの向き（\%\&RSUDirection.Forward: Forward、\%\&RSUDirection.Backward: Backward）</FunctionArgDesc ja_jp>*/
									, i_direction = 1
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_array)
	%local /readonly __TMP_ARRAY_ITERATOR__ = %Int_RSUClass_Instantiate(i_template_name = &RSU_G_CLASS_FILE_ITERATOR.);
	%Int_&__TMP_ARRAY_ITERATOR__.Initialize(ivar_array = &ivar_array.
											, i_direction = &i_direction)
	&__TMP_ARRAY_ITERATOR__.
%mend RSUArray__GetIterator;

/*<FunctionDesc ja_jp>テキストから配列を作成します（サイズ優先）</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>配列</FunctionReturn ja_jp>*/
%macro RSUArray__Create(
/*<FunctionArgDesc ja_jp>配列サイズ</FunctionArgDesc ja_jp>*/
								i_size =
/*<FunctionArgDesc ja_jp>要素を結合した文字列</FunctionArgDesc ja_jp>*/
								, i_items =
/*<FunctionArgDesc ja_jp>要素間の区切り文字</FunctionArgDesc ja_jp>*/
								, i_delimiter = %str( )
/*<FunctionArgDesc ja_jp>要素の前後スペースを削除するか否か</FunctionArgDesc ja_jp>*/
								, i_trimmed = %&RSUBool.True
								);
/*<FunctionDetail ja_jp>
サイズ``\texttt{i\_size}''と要素``\texttt{i\_items}''の両方を指定した場合は、\texttt{i\_size}で指定されたサイズの配列が生成されます（要素が足りない場合は空欄要素が生成されます）。
</FunctionDetail ja_jp>*/
	/* ! 配列サイズが優先 */
	%local _array_items;
	%local _index;
	%let _index = 1;
	%local _item;
	%if (%&RSUMacroVariable.IsBlank(i_size)) %then %do;
		%if (not %&RSUMacroVariable.IsBlank(i_items)) %then %do;
			%let _item = %scan(&i_items., &_index., %quote(&i_delimiter));
			%do %while(not %&RSUMacroVariable.IsBlank(_item));
				%&RSUText.Append(iovar_base = _array_items
									, i_append_text = &RSU_G_ARRAY_DELIMITER.&_item.&RSU_G_ARRAY_DELIMITER.
									, i_delimiter =)
				%let _index = %eval(&_index. + 1);
				%let _item = %scan(&i_items., &_index., %quote(&i_delimiter));
			%end;
		%end;
	%end;
	%else %do;
		%do _index = 1 %to &i_size.;
			%let _item = %scan(&i_items., &_index., %quote(&i_delimiter));
			%&RSUText.Append(iovar_base = _array_items
								, i_append_text = &RSU_G_ARRAY_DELIMITER.&_item.&RSU_G_ARRAY_DELIMITER.
								, i_delimiter =)
		%end;
	%end;
	&_array_items.
%mend RSUArray__Create;

/*<FunctionDesc ja_jp>データセットをインポートして配列を作成します</FunctionDesc ja_jp>*/
%macro RSUArray__ImportFromDS(
/*<FunctionArgDesc ja_jp>インポート元データセット</FunctionArgDesc ja_jp>*/
										ids_input_ds =
/*</FunctionArgDesc ja_jp>インポート対象の変数名</FunctionArgDesc ja_jp>*/
										, i_value_varname =
/*<FunctionArgDesc ja_jp>順序を規定する変数名</FunctionArgDesc ja_jp>*/
										, i_order_varname =
/*<FunctionArgDesc ja_jp>配列を保持するマクロ変数</FunctionArgDesc ja_jp>*/
										, ovar_array =
										);
	%&RSUUtil.VerifyRequiredArgs(i_args = ids_input_ds i_value_varname ovar_array)
	%local _items;
	proc sql noprint;
		select
			&i_value_varname. into :_items separated by "&RSU_G_ARRAY_DELIMITER.&RSU_G_ARRAY_DELIMITER."
		from
			&ids_input_ds.
	%if (not %&RSUMacroVariable.IsBlank(i_order_varname)) %then %do;
		order by
			&i_order_varname.
	%end;
		;
	quit;
	%let &ovar_array. = &RSU_G_ARRAY_DELIMITER.&_items.&&RSU_G_ARRAY_DELIMITER.;
%mend RSUArray__ImportFromDS;

/*<FunctionDesc ja_jp>指定要素番号の要素の内容を更新します</FunctionDesc ja_jp>*/
%macro RSUArray__Set(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
							iovar_array
/*<FunctionArgDesc ja_jp>要素番号</FunctionArgDesc ja_jp>*/
							, i_index =
/*<FunctionArgDesc ja_jp>更新内容</FunctionArgDesc ja_jp>*/
							, i_value =
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = iovar_array i_index)
	%Int_RSUArray_VerifyIndexRange(ivar_array = &iovar_array.
											, i_index = &i_index.)

	%local _string_former;
	%local _string_target;
	%local _string_latter;
	%Int_RSUArray_SplitString(ivar_array = &iovar_array.
										, i_index = &i_index.
										, ovar_former = _string_former
										, ovar_target = _string_target
										, ovar_latter = _string_latter)
	%local /readonly _RSU_ARRAY_MODIFIED_ITEM = &RSU_G_ARRAY_DELIMITER.&i_value.&RSU_G_ARRAY_DELIMITER.;
	%let &iovar_array. = &_string_former.&_RSU_ARRAY_MODIFIED_ITEM.&_string_latter.;
%mend RSUArray__Set;

/*<FunctionDesc ja_jp>配列をクリアします</FunctionDesc ja_jp>*/
%macro RSUArray__Clear(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
								iovar_array
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = iovar_array)
	%let &iovar_array. =;
%mend RSUArray__Clear;

/*<FunctionDesc ja_jp>配列から重複を取り除きます</FunctionDesc ja_jp>*/
%macro RSUArray__MakeUnique(
/*<FunctionArgDesc ja_jp>配列を保持しているマクロ変数名</FunctionArgDesc ja_jp>*/
									iovar_array =
									);
	%&RSUUtil.VerifyRequiredArgs(i_args = iovar_array)
	%local /readonly _RSU_ARRAY_UNIQUE_DS_NAME = %&RSUDS.GetTempDSName();
	%RSUArray__ExportToDS(ivar_array = &iovar_array
								, ods_output_ds = &_RSU_ARRAY_UNIQUE_DS_NAME.
								, i_contain_index = %&RSUBool.True)
	proc sort data = &_RSU_ARRAY_UNIQUE_DS_NAME. nodupkey;
		by
			value
		;
	run;
	quit;

	%RSUArray__ImportFromDS(ids_input_ds = &_RSU_ARRAY_UNIQUE_DS_NAME.
									, i_value_varname = value
									, i_order_varname = index
									, ovar_array = &iovar_array.)
	%&RSUDS.Delete(&_RSU_ARRAY_UNIQUE_DS_NAME.)
%mend RSUArray__MakeUnique;