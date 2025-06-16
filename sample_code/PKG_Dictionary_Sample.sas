%rsu_dev_module_activate_test(i_version = 200)
%macro DicSample1;
	%local _my_dictionary;
	%&RSUDic.Add(_my_dictionary, i_key = Company, i_value = SAS)									/* "Add" 連想配列に項目を追加 */
	%&RSUDic.Add(_my_dictionary, i_key = Dept, i_value = RSU)										/* "Add" 連想配列に項目を追加 */
	%&RSUDic.Add(_my_dictionary, i_key = No of Members, i_value = 20)								/* "Add" 連想配列に項目を追加 */

	%put 項目数: %&RSUDic.GetSize(_my_dictionary);														/* "GetSet" 連想配列に項目を追加 */

	%put キー "Dept"の値 = %&RSUDic.Get(_my_dictionary, Dept);										/* "Get" 項目値取得 */
	%put キー "No of Members"の値 = %&RSUDic.Get(_my_dictionary, No of Members);				/* "Get" 項目値取得 */
	
	%&RSUDic.Set(_my_dictionary, i_key = No of Members, i_value = 30)								/* "Set" 項目値変更 */
	%put キー "No of Members"の値 = %&RSUDic.Get(_my_dictionary, No of Members);				/* "Get" 項目値取得 */
	
	%&RSUDic.Print(_my_dictionary)																			/* "Print" 連想配列の内容をログに表示 */
%mend DicSample1;
%DicSample1