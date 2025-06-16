%rsu_dev_module_activate_test(i_version = 200)

%macro ArraySample1;
	%local _my_array;
	%let _my_array = %&RSUArray.Create(i_size = 5);						/* サイズ5の配列を作成*/
	%&RSUArray.Set(_my_array, i_index = 1, i_value = Hello)			/* "Set" 指定要素番号に値を設定 */
	%&RSUArray.Set(_my_array, i_index = 2, i_value = SAS)				/* "Set" 指定要素番号に値を設定 */
	%&RSUArray.Set(_my_array, i_index = 3, i_value = Deveploment)	/* "Set" 指定要素番号に値を設定 */
	%&RSUArray.Set(_my_array, i_index = 4, i_value = Module)			/* "Set" 指定要素番号に値を設定 */
	%&RSUArray.Set(_my_array, i_index = 5, i_value = Enjoy!)			/* "Set" 指定要素番号に値を設定 */
	
	%put 第1要素: %&RSUArray.Get(_my_array, 1);							/* "Get" 指定要素番号の値を取得 */
	%put 第3要素: %&RSUArray.Get(_my_array, 3);							/* "Get" 指定要素番号の値を取得 */

	%&RSUArray.ExportToDS(_my_array, WORK.array_ds)						/* "ExportToDS" 配列をデータセットに出力 */
%mend ArraySample1;
%ArraySample1

%macro ArraySample2;
	%local _my_array;
	%let _my_array = %&RSUArray.Create(i_items = %str(Hello,SAS,Development,Module,Enjoy!)		/* "," 区切りの文字列から配列を作成*/
												, i_delimiter = %str(,));		
	%put 配列サイズ: %&RSUArray.GetSize(_my_array);															/* "GetSize" 配列サイズ取得 */
	%put 第2要素: %&RSUArray.Get(_my_array, 2);																/* "Get" 指定要素番号の値を取得 */
	%put 第4要素: %&RSUArray.Get(_my_array, 4);																/* "Get" 指定要素番号の値を取得 */

	%local _index;
	%let _index = %&RSUArray.Find(_my_array, Module);
	%put "Module" は、第&_index.要素;											/* "Find" 要素検索 */

	%&RSUArray.Clear(_my_array)																					/* "Clear" 要素クリア */
	%put 配列サイズ: %&RSUArray.GetSize(_my_array);															/* "GetSize" 配列サイズ取得 */
%mend ArraySample2;
%ArraySample2

%macro ArraySample3;
	%local _my_array;
	%let _my_array = %&RSUArray.Create(i_items = %str(Hello,SAS,Development,Module,Enjoy!)		/* "," 区切りの文字列から配列を作成*/
												, i_delimiter = %str(,));		
	%local _array_iterator;
	%let _array_iterator = %&RSUArray.GetIterator(_my_array);											/* 配列のイテレータを作成 */
	
	%do %while(%&_array_iterator.Next);																			/* イテレータの反復 */
		%put 第%&_array_iterator.CurrentIndex 要素: %&_array_iterator.Current;						/* イテレータの現在のインデックスと値を取得 */
	%end;
	%&RSUClass.Dispose(_array_iterator)																			/* イテレータ破棄 */
%mend ArraySample3;
%ArraySample3

%macro ArraySample4;
	%local _my_array;
	%&RSUArray.ImportFromDS(ids_input_ds = SASHELP.class													/* "ImportFromDS" データセットから配列を作成 */
									, i_value_varname = name
									, ovar_array = _my_array)
	%put 配列サイズ: %&RSUArray.GetSize(_my_array);															/* "GetSize" 配列サイズ取得 */
	%put 要素 "Henry" を検索;
	%if (%&RSUArray.ContainsItem(_my_array, Henry)) %then %do;											/* "ContaintsItem" 指定要素が含まれているか判定 */
		%put "Henry"は配列内に見つかりました;
	%end;
	%else %do;
		%put "Henry"は配列内に見つかりませんでした;
	%end;

	%put 要素 "shingo" を検索;																						
	%if (%&RSUArray.ContainsItem(_my_array, shingo)) %then %do;											/* "ContaintsItem" 指定要素が含まれているか判定 */
		%put "shingo"は配列内に見つかりました;
	%end;
	%else %do;
		%put "shingo"は配列内に見つかりませんでした;
	%end;

	%put %&RSUArray.GetText(_my_array, i_delimiter = %str(,), i_is_quoted = 1);
%mend ArraySample4;
%ArraySample4
