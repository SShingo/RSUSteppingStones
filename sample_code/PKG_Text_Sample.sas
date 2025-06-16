%rsu_dev_module_activate_test(i_version = 200)

%macro TextSample1;
	%local _sample_string;
	%&RSUText.Append(iovar_base = _sample_string				/* "Append" 文字列連結 */
						, i_append_text = SAS
						, i_delimiter = |)
	%put 現在の文字列: &_sample_string.;
	%&RSUText.Append(iovar_base = _sample_string				/* "Append" 文字列連結 */
						, i_append_text = RSU
						, i_delimiter = |)
	%put 現在の文字列: &_sample_string.;
	
%mend TextSample1;
%TextSample1

%macro TextSample2;
	%put 文字列の長さ: %&RSUText.Length(USA);					/* "Length" 文字数カウント（漢字も1文字とカウント） */
	%put 文字列の長さ: %&RSUText.Length(日本);					/* "Length" 文字数カウント（漢字も1文字とカウント） */
	
	%put 文字列の長さ（バイト数）: %&RSUText.Byte(USA);		/* "Byte" 文字列のサイズカウント */
	%put 文字列の長さ（バイト数）: %&RSUText.Byte(日本);		/* "Byte" 文字列のサイズカウント */
%mend TextSample2;
%TextSample2

%macro TextSample3;
	%local /readonly _SAMPLE_STRING = SAS Japan リスクソリューションユニット;
	%local _left;
	%let _left = %&RSUText.Left(&_SAMPLE_STRING., 11);		/* "Left" 左から切り出し */	
	%put 左から11文字: &=_left.;
	%local _right;
	%let _right = %&RSUText.Right(&_SAMPLE_STRING., 2);	/* "Right" 右から切り出し */	
	%put 右から2文字: &=_right.;
	%local _mid;
	%let _mid = %&RSUText.Mid(&_SAMPLE_STRING., 4, 6);		/* "Mid" 部分文字列切り出し */	
	%put 中4文字目から6文字: &=_mid.;
%mend TextSample3;
%TextSample3