%rsu_dev_module_activate_test(i_version = 200)

%macro ListSample1;
	%local _my_list;
	%let _my_list = %&RSUList.Create(i_size = 5);						/* サイズ5の配列を作成*/
	%&RSUList.Set(_my_list, i_index = 1, i_value = Hello)				/* "Set" 指定要素番号に値を設定 */
	%&RSUList.Set(_my_list, i_index = 2, i_value = SAS)				/* "Set" 指定要素番号に値を設定 */
	%&RSUList.Set(_my_list, i_index = 3, i_value = Deveploment)		/* "Set" 指定要素番号に値を設定 */
	%&RSUList.Set(_my_list, i_index = 4, i_value = Module)			/* "Set" 指定要素番号に値を設定 */
	%put 配列サイズ: %&RSUList.GetSize(_my_list);						/* "GetSize" 配列サイズ取得 */
	
	%put 第1要素: %&RSUList.Get(_my_list, 1);								/* "Get" 指定要素番号の値を取得 */
	%put 第3要素: %&RSUList.Get(_my_list, 3);								/* "Get" 指定要素番号の値を取得 */

	%put %&RSUList.Add(_my_list, i_value = Enjoy!)						/* "Add" 末尾に要素追加 */
	%put 先頭要素: %&RSUList.First(_my_list)								/* "First" 先頭要素を取得 */
	%put 最終要素: %&RSUList.Last(_my_list)								/* "Last" 最終要素を取得 */

	%&RSUList.ExportToDS(_my_list, WORK.list_ds)							/* "ExportToDS" 配列をデータセットに出力 */
%mend ListSample1;
%ListSample1

%macro ListSample2;
	%local _my_list;
	%let _my_list = %&RSUList.Create(i_items = %str(Hello,SAS,Development,Module,Enjoy!)		/* "," 区切りの文字列から配列を作成*/
												, i_delimiter = %str(,));		
	%put 配列サイズ: %&RSUList.GetSize(_my_list);															/* "GetSize" 配列サイズ取得 */
	%put 第2要素: %&RSUList.Get(_my_list, 2);																/* "Get" 指定要素番号の値を取得 */
	%put 第4要素: %&RSUList.Get(_my_list, 4);																/* "Get" 指定要素番号の値を取得 */

	%put "Module" は、第%&RSUList.Find(_my_list, Module)要素;											/* "Find" 要素検索 */

	%&RSUList.Clear(_my_list)																					/* "Clear" 要素クリア */
	%put 配列サイズ: %&RSUList.GetSize(_my_list);															/* "GetSize" 配列サイズ取得 */
%mend ListSample2;
%ListSample2

%macro ListSample3;
	%local _my_list;
	%let _my_list = %&RSUList.Create(i_items = %str(Hello,SAS,Development,Module,Enjoy!)		/* "," 区切りの文字列から配列を作成*/
												, i_delimiter = %str(,));		
	%local _array_iterator;
	%let _array_iterator = %&RSUList.GetIterator(_my_list);											/* 配列のイテレータを作成 */
	
	%do %while(%&_array_iterator.Next);																			/* イテレータの反復 */
		%put 第%&_array_iterator.CurrentIndex 要素: %&_array_iterator.Current;						/* イテレータの現在のインデックスと値を取得 */
	%end;
	%&RSUClass.Dispose(_array_iterator)																			/* イテレータ破棄 */
%mend ListSample3;
%ListSample3

%macro ListSample4;
	%local _my_list;
	%&RSUList.ImportFromDS(ids_input_ds = SASHELP.class													/* "ImportFromDS" データセットから配列を作成 */
									, i_value_varname = name
									, ovar_array = _my_list)
	%put 配列サイズ: %&RSUList.GetSize(_my_list);															/* "GetSize" 配列サイズ取得 */
	%if (%&RSUList.ContainsItem(_my_list, shingo)) %then %do;											/* "ContaintsItem" 指定要素が含まれているか判定 */
		%put 配列内に見つかりました;
	%end;
	%else %do;
		%put 配列内に見つかりませんでした;
	%end;

	%put %&RSUList.GetText(_my_list, i_delimiter = %str(,), i_is_quoted = 1);
%mend ListSample4;
%ListSample4
