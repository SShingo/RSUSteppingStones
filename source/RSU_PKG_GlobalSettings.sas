/********************************
	定数定義
********************************/
/*<ConstantDesc ja_jp>配列要素の区切り文字</ConstantDesc ja_jp>*/
/*<AltValue ja_jp>\texttt{`}</AltValue ja_jp>*/
%RSUSetConstant(RSU_G_ARRAY_DELIMITER, `)
/*<ConstantDesc ja_jp>インスタンス名に付与されるprefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSU_G_INSTANCE_PREFIX, RI_)
/*<ConstantDesc ja_jp>インスタンス名に付与されるprefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSU_G_GLOBAL_INSTANCE_PREFIX, RSU_g_INST)
/*<ConstantDesc ja_jp>インスタンス名のID部の桁数</ConstantDesc ja_jp>*/
%RSUSetConstant(RSU_G_INSTANCE_ID_DIGIT, 4)
/*<ConstantDesc ja_jp>データベース名のID部の桁数</ConstantDesc ja_jp>*/
%RSUSetConstant(RSU_G_DATASET_ID_DIGIT, 6)
/*<ConstantDesc ja_jp>クラス定義用一時ファイル名</ConstantDesc ja_jp>*/
%RSUSetConstant(RSU_G_MACRO_DEF_TMP_FILE, rsu_class_instantiate)
/*<ConstantDesc ja_jp>平文表示時のインデント</ConstantDesc ja_jp>*/
/*<AltValue ja_jp>\texttt{␣␣␣␣␣␣␣␣}</AltValue ja_jp>*/
%RSUSetConstant(RSU_G_MSG_INDENT_PLANE, %str(        ))
/*<ConstantDesc ja_jp>Note 表示時のインデント</ConstantDesc ja_jp>*/
/*<AltValue ja_jp>\texttt{␣␣␣␣␣␣␣␣}</AltValue ja_jp>*/
%RSUSetConstant(RSU_G_MSG_INDENT_NOTE, %str(        ))
/*<ConstantDesc ja_jp>Warning 表示時のインデント</ConstantDesc ja_jp>*/
%RSUSetConstant(RSU_G_MSG_INDENT_WARNING, WARNING-)
/*<ConstantDesc ja_jp>Error 表示時のインデント</ConstantDesc ja_jp>*/
/*<AltValue ja_jp>\texttt{ERROR-␣␣␣␣}</AltValue ja_jp>*/
%RSUSetConstant(RSU_G_MSG_INDENT_ERROR, ERROR-%str(  ))
/*<ConstantDesc ja_jp>連想配列の検索キーのPrefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSU_G_KEY_PREFIX, #KEY:)
/*<ConstantDesc ja_jp>パスのセパレータ</ConstantDesc ja_jp>*/
%RSUSetConstant(RSU_G_PATH_SEPARATOR, /)
/*<ConstantDesc ja_jp>複数行表示の際の改行記号</ConstantDesc ja_jp>*/
%RSUSetConstant(RSULf, |)
/*<ConstantDesc ja_jp>ログメッセージに','を表示する場合に使用する記号</ConstantDesc ja_jp>*/
%RSUSetConstant(RSULogComma, <__RSU_COMMA__>)
/*<ConstantDesc ja_jp>ログメッセージに'%'を表示する場合に使用する記号</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUPercent, %nrstr(% ))
/*<ConstantDesc ja_jp>ログメッセージに'&'を表示する場合に使用する記号</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUAnd, %nrstr(& ))
/*<ConstantDesc ja_jp>区切り文字コンマ</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUComma, %str(,))
/*<ConstantDesc ja_jp>区切り文字スペース</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUWhiteSpace, %str( ))
/*<ConstantDesc ja_jp>区切り文字タブ（09x）</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUTab, '09'x)
/*<ConstantDesc ja_jp>区切り文字Null（00x）</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUNULL, '00'x)
/*<ConstantDesc ja_jp>マクロ変数における「欠損地」</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUVarNULL, `NULL`)
/*<ConstantDesc ja_jp>Execlの日付とSASの日付の原点のオフセット</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUExcelDateOffset, 21916)
/*<ConstantDesc ja_jp>読み込みの際、スキップするカラムの指定</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUSkipCol, -)
/*<ConstantDesc ja_jp>ダミー変数名</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUSkippedVar, __skipped_var__)
/*<ConstantDesc ja_jp>デバッグコードの終端文字列</ConstantDesc ja_jp>*/
%RSUSetConstant(__debug, /)
/*<ConstantDesc ja_jp>リリースコードの終端文字列</ConstantDesc ja_jp>*/
%RSUSetConstant(__release, /)
/*<ConstantDesc ja_jp>分析コードの終端文字列</ConstantDesc ja_jp>*/
%RSUSetConstant(__diag, /)

/* Pre-Defined Structure */
/*<StructureDesc ja_jp>Boolean構造体</StructureDesc ja_jp>*/
%RSUSetConstant(RSUBool, RSUBoolean__)
/*<StructMemberDesc ja_jp>Boolean 真値</StructMemberDesc ja_jp>*/
%macro RSUBoolean__True;
	1
%mend RSUBoolean__True;
/*<StructMemberDesc ja_jp>Boolean 偽値</StructMemberDesc ja_jp>*/
%macro RSUBoolean__False;
	0
%mend RSUBoolean__False;
/*<FunctionDesc ja_jp>引数が構造体メンバー値であるかを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>\%\&RSUBool.False: メンバーでない\quad \%\&RSUBool.True: メンバーである</FunctionReturn ja_jp>*/
%macro RSUBoolean__IsMember(
/*<FunctionArgDesc ja_jp>判定される値</FunctionArgDesc ja_jp>*/
									i_value
									);
	%eval(&i_value. in (%RSUBoolean__True, %RSUBoolean__False))
%mend RSUBoolean__IsMember;
/*<EndOfStructure>*/

/*<StructureDesc ja_jp>Direction構造体</StructureDesc ja_jp>*/
%RSUSetConstant(RSUDirection, RSUDirection__)
/*<StructMemberDesc ja_jp>イテレータの向き: 前進</StructMemberDesc ja_jp>*/
%macro RSUDirection__Forward;
	1
%mend RSUDirection__Forward;
/*<StructMemberDesc ja_jp>イテレータの向き: 後進</StructMemberDesc ja_jp>*/
%macro RSUDirection__Backward;
	-1
%mend RSUDirection__Backward;
/*<FunctionDesc ja_jp>引数が構造体メンバー値であるかを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>\%\&RSUBool.False: メンバーでない\quad \%\&RSUBool.True: メンバーである</FunctionReturn ja_jp>*/
%macro RSUDirection__IsMember(
/*<FunctionArgDesc ja_jp>判定される値</FunctionArgDesc ja_jp>*/
										i_value
										);
	%eval(&i_value. in (%RSUDirection__Forward, %RSUDirection__Backward))
%mend RSUDirection__IsMember;
/*<EndOfStructure>*/

/*<StructureDesc ja_jp>ソート順構造体</StructureDesc ja_jp>*/
%RSUSetConstant(RSUSortOrder, RSUSortOrder__)
/*<StructMemberDesc ja_jp>ソート順: 昇順</StructMemberDesc ja_jp>*/
%macro RSUSortOrder__Asc;
	ascending
%mend RSUSortOrder__Asc;
/*<StructMemberDesc ja_jp>ソート順: 降順</StructMemberDesc ja_jp>*/
%macro RSUSortOrder__Dsc;
	descending
%mend RSUSortOrder__Dsc;
/*<FunctionDesc ja_jp>引数が構造体メンバー値であるかを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>\%\&RSUBool.False: メンバーでない\quad \%\&RSUBool.True: メンバーである</FunctionReturn ja_jp>*/
%macro RSUSortOrder__IsMember(
/*<FunctionArgDesc ja_jp>判定される値</FunctionArgDesc ja_jp>*/
										i_value
										);
	%eval(&i_value. in (%RSUSortOrder__Asc, %RSUSortOrder__Dsc))
%mend RSUSortOrder__IsMember;
/*<EndOfStructure>*/

/*<StructureDesc ja_jp>ファイル種別構造体</StructureDesc ja_jp>*/
%RSUSetConstant(RSUFileType, RSUFileType__)
/*<StructMemberDesc ja_jp>ファイル種別: ファイル</StructMemberDesc ja_jp>*/
%macro RSUFileType__File;
	F
%mend RSUFileType__File;
/*<StructMemberDesc ja_jp>ファイル種別: ディレクトリ</StructMemberDesc ja_jp>*/
%macro RSUFileType__Directory;
	D
%mend RSUFileType__Directory;
/*<StructMemberDesc ja_jp>ファイル種別: すべて（ファイル、ディレクトリ）</StructMemberDesc ja_jp>*/
%macro RSUFileType__Both;
	B
%mend RSUFileType__Both;
/*<FunctionDesc ja_jp>引数が構造体メンバー値であるかを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>\%\&RSUBool.False: メンバーでない\quad \%\&RSUBool.True: メンバーである</FunctionReturn ja_jp>*/
%macro RSUFileType__IsMember(
/*<FunctionArgDesc ja_jp>判定される値</FunctionArgDesc ja_jp>*/
										i_value
										);
	%eval(&i_value. in (%RSUFileType__File, %RSUFileType__Directory, %RSUFileType__Both))
%mend RSUFileType__IsMember;
/*<EndOfStructure>*/

/*<StructureDesc ja_jp>実行モード構造体</StructureDesc ja_jp>*/
%RSUSetConstant(RSUExecMode, RSUExecMode__)
/*<StructMemberDesc ja_jp>実行モード: デバッグモード</StructMemberDesc ja_jp>*/
%macro RSUExecMode__Debug;
	DEBUG
%mend RSUExecMode__Debug;
/*<StructMemberDesc ja_jp>実行モード: リリースモード</StructMemberDesc ja_jp>*/
%macro RSUExecMode__Release;
	RELEASE
%mend RSUExecMode__Release;
/*<FunctionDesc ja_jp>引数が構造体メンバー値であるかを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>\%\&RSUBool.False: メンバーでない\quad \%\&RSUBool.True: メンバーである</FunctionReturn ja_jp>*/
%macro RSUExecMode__IsMember(
/*<FunctionArgDesc ja_jp>判定される値</FunctionArgDesc ja_jp>*/
										i_value
										);
	%eval(&i_value. in (%RSUExecMode__Debug, %RSUExecMode__Release))
%mend RSUExecMode__IsMember;

/*<StructureDesc ja_jp>ソート時抽出データタイプ構造体</StructureDesc ja_jp>*/
%RSUSetConstant(RSUPickup, RSUPickup__)
/*<StructMemberDesc ja_jp>抽出タイプ: 第一レコード</StructMemberDesc ja_jp>*/
%macro RSUPickup__First;
	1
%mend RSUPickup__First;
/*<StructMemberDesc ja_jp>抽出タイプ: 最終レコード</StructMemberDesc ja_jp>*/
%macro RSUPickup__Last;
	0
%mend RSUPickup__Last;
/*<FunctionDesc ja_jp>引数が構造体メンバー値であるかを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>\%\&RSUBool.False: メンバーでない\quad \%\&RSUBool.True: メンバーである</FunctionReturn ja_jp>*/
%macro RSUPickup__IsMember(
/*<FunctionArgDesc ja_jp>判定される値</FunctionArgDesc ja_jp>*/
										i_value
										);
	%eval(&i_value. in (%RSUPickup__First, %RSUPickup__Last))
%mend RSUPickup__IsMember;

/*<StructureDesc ja_jp>補間タイプ構造体</StructureDesc ja_jp>*/
%RSUSetConstant(RSUInterpolation, RSUInterp__)
/*<StructMemberDesc ja_jp>線形補間</StructMemberDesc ja_jp>*/
%macro RSUInterp__Linear;
	0
%mend RSUInterp__Linear;
/*<StructMemberDesc ja_jp>階段補間（前進）</StructMemberDesc ja_jp>*/
%macro RSUInterp__StepForward;
	1
%mend RSUInterp__StepForward;
/*<StructMemberDesc ja_jp>階段補間（後進）</StructMemberDesc ja_jp>*/
%macro RSUInterp__StepBackward;
	-1
%mend RSUInterp__StepBackward;
/*<FunctionDesc ja_jp>引数が構造体メンバー値であるかを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>\%\&RSUBool.False: メンバーでない\quad \%\&RSUBool.True: メンバーである</FunctionReturn ja_jp>*/
%macro RSUInterp__IsMember(
/*<FunctionArgDesc ja_jp>判定される値</FunctionArgDesc ja_jp>*/
									i_value
									);
	%eval(&i_value. in (%RSUInterp__Linear, %RSUInterp__StepForward, %RSUInterp__StepBackward))
%mend RSUInterp__IsMember;
/*<EndOfStructure>*/

/*<StructureDesc ja_jp>ソート時抽出データタイプ構造体</StructureDesc ja_jp>*/
%RSUSetConstant(RSUEnclosure, RSUEnclose__)
/*<StructMemberDesc ja_jp>囲み文字タイプ: なし</StructMemberDesc ja_jp>*/
%macro RSUEnclose__None;
	EncloseNone
%mend RSUEnclose__None;
/*<StructMemberDesc ja_jp>囲み文字タイプ: 丸括弧</StructMemberDesc ja_jp>*/
%macro RSUEnclose__Round;
	EncloseRound
%mend RSUEnclose__Round;
/*<StructMemberDesc ja_jp>囲み文字タイプ: 角括弧</StructMemberDesc ja_jp>*/
%macro RSUEnclose__Square;
	EncloseSquare
%mend RSUEnclose__Square;
/*<StructMemberDesc ja_jp>囲み文字タイプ: 波括弧</StructMemberDesc ja_jp>*/
%macro RSUEnclose__Wave;
	EncloseWave
%mend RSUEnclose__Wave;
/*<StructMemberDesc ja_jp>囲み文字タイプ: カギ括弧</StructMemberDesc ja_jp>*/
%macro RSUEnclose__Wedge;
	EncloseWedge
%mend RSUEnclose__Wedge;
/*<StructMemberDesc ja_jp>囲み文字タイプ: クォーテーション</StructMemberDesc ja_jp>*/
%macro RSUEnclose__Quote;
	EncloseQuote
%mend RSUEnclose__Quote;
/*<StructMemberDesc ja_jp>囲み文字タイプ: ダブルクォーテーション</StructMemberDesc ja_jp>*/
%macro RSUEnclose__DQuote;
	EncloseDQuote
%mend RSUEnclose__DQuote;
/*<StructMemberDesc ja_jp>囲み文字タイプ: アクサングラーブ</StructMemberDesc ja_jp>*/
%macro RSUEnclose__Grave;
	EncloseGrave
%mend RSUEnclose__Grave;
/*<FunctionDesc ja_jp>引数が構造体メンバー値であるかを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>\%\&RSUBool.False: メンバーでない\quad \%\&RSUBool.True: メンバーである</FunctionReturn ja_jp>*/
%macro RSUEnclose__IsMember(
/*<FunctionArgDesc ja_jp>判定される値</FunctionArgDesc ja_jp>*/
										i_value
										);
	%eval(&i_value. in (%RSUEnclose__None, %RSUEnclose__Round, %RSUEnclose__Square, %RSUEnclose__Wave, %RSUEnclose__Quote, %RSUEnclose__DQuote, %RSUEnclose__Grave))
%mend RSUEnclose__IsMember;

/*<StructureDesc ja_jp>曜日構造体</StructureDesc ja_jp>*/
%RSUSetConstant(RSUDayWeek, RSUDayWeek__)
/*<StructMemberDesc ja_jp>日曜日</StructMemberDesc ja_jp>*/
%macro RSUDayWeek__Sun;
	1
%mend RSUDayWeek__Sun;
/*<StructMemberDesc ja_jp>月曜日</StructMemberDesc ja_jp>*/
%macro RSUDayWeek__Mon;
	2
%mend RSUDayWeek__Mon;
/*<StructMemberDesc ja_jp>火曜日</StructMemberDesc ja_jp>*/
%macro RSUDayWeek__Tue;
	3
%mend RSUDayWeek__Tue;
/*<StructMemberDesc ja_jp>水曜日</StructMemberDesc ja_jp>*/
%macro RSUDayWeek__Wed;
	4
%mend RSUDayWeek__Wed;
/*<StructMemberDesc ja_jp>木曜日</StructMemberDesc ja_jp>*/
%macro RSUDayWeek__Thu;
	5
%mend RSUDayWeek__Thu;
/*<StructMemberDesc ja_jp>金曜日</StructMemberDesc ja_jp>*/
%macro RSUDayWeek__Fri;
	6
%mend RSUDayWeek__Fri;
/*<StructMemberDesc ja_jp>土曜日</StructMemberDesc ja_jp>*/
%macro RSUDayWeek__Sat;
	7
%mend RSUDayWeek__Sat;
/*<FunctionDesc ja_jp>引数が構造体メンバー値であるかを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>\%\&RSUBool.False: メンバーでない\quad \%\&RSUBool.True: メンバーである</FunctionReturn ja_jp>*/
%macro RSUDayWeek__IsMember(
/*<FunctionArgDesc ja_jp>判定される値</FunctionArgDesc ja_jp>*/
										i_value
										);
	%eval(&i_value. in (%RSUDayWeek__Sun, %RSUDayWeek__Mon, %RSUDayWeek__Tue, %RSUDayWeek__Wed, %RSUDayWeek__Thu, %RSUDayWeek__Fri, %RSUDayWeek__Sat))
%mend RSUDayWeek__IsMember;
/*<EndOfStructure>*/

/* セッション内で変更されるグローバル変数 */
/* 連番 */
/*<GlobalVariableDesc ja_jp>クラスインスタンス名用連番</GlobalVariableDesc ja_jp>*/
%global RSU_g_sequence_instance;
%let RSU_g_sequence_instance = 0;
/*<GlobalVariableDesc ja_jp>ライブラリ名用連番</GlobalVariableDesc ja_jp>*/
%global RSU_g_sequence_library;
%let RSU_g_sequence_library = 0;
/*<GlobalVariableDesc ja_jp>ディレクトリ名用連番</GlobalVariableDesc ja_jp>*/
%global RSU_g_sequence_directory;
%let RSU_g_sequence_directory = 0;
/*<GlobalVariableDesc ja_jp>データセット名用連番</GlobalVariableDesc ja_jp>*/
%global RSU_g_sequence_dataset;
%let RSU_g_sequence_dataset = 0;
/*<GlobalVariableDesc ja_jp>データセットイテレータ用連番</GlobalVariableDesc ja_jp>*/
%global RSU_g_sequence_dataset_iterator;
%let RSU_g_sequence_dataset_iterator = 0;
/*<GlobalVariableDesc ja_jp>配列用連番</GlobalVariableDesc ja_jp>*/
%global RSU_g_sequence_array;
%let RSU_g_sequence_array = 0;
/*<GlobalVariableDesc ja_jp>連想配列用連番</GlobalVariableDesc ja_jp>*/
%global RSU_g_sequence_map;
%let RSU_g_sequence_map = 0;
/*<GlobalVariableDesc ja_jp>File writer用連番</GlobalVariableDesc ja_jp>*/
%global RSU_g_sequence_file_writer;
%let RSU_g_sequence_file_writer = 0;
/*<GlobalVariableDesc ja_jp>File Reader用連番</GlobalVariableDesc ja_jp>*/
%global RSU_g_sequence_file_reader;
%let RSU_g_sequence_file_reader = 0;
/*<GlobalVariableDesc ja_jp>Timer用連番</GlobalVariableDesc ja_jp>*/
%global RSU_g_sequence_timer;
%let RSU_g_sequence_timer = 0;
/*<GlobalVariableDesc ja_jp>Progress Bar用連番</GlobalVariableDesc ja_jp>*/
%global RSU_g_sequence_prgbar;
%let RSU_g_sequence_prgbar = 0;
/*<GlobalVariableDesc ja_jp>Regex用連番</GlobalVariableDesc ja_jp>*/
%global RSU_g_sequence_regex;
%let RSU_g_sequence_regex = 0;
/*<GlobalVariableDesc ja_jp>RESTAPI用連番</GlobalVariableDesc ja_jp>*/
%global RSU_g_sequence_rest_api;
%let RSU_g_sequence_rest_api = 0;

/* Logger */
/*<GlobalVariableDesc ja_jp>現在のログの出力先<Global ja_jp> */
%global RSU_g_current_log_dest;
%let RSU_g_current_log_dest =;
/*<GlobalVariableDesc ja_jp>マクロ呼び出しトレースを表示するか</GlobalVariableDesc ja_jp>*/
%global RSU_g_log_conf_show_macro;
%let RSU_g_log_conf_show_macro = %&RSUBool.False;
/*<GlobalVariableDesc ja_jp>マクロ呼び出しトレースにおいて引数を表示するか</GlobalVariableDesc ja_jp>*/
%global RSU_g_log_conf_show_arguments;
%let RSU_g_log_conf_show_arguments = %&RSUBool.False;
/* <GlobalMacroDesc ja_jp>マクロ深度の現在値<GlobalMacroDesc ja_jp> */
%global RSU_g_current_macro_depth;
%let RSU_g_current_macro_depth = 0;

/* Debugging */
/* <GlobalMacroDesc ja_jp>実行モード（DEBUG/RELEASE）<GlobalMacroDesc ja_jp> */
%global RSU_g_execution_mode;
%let RSU_g_execution_mode = %&RSUExecMode.Release;
/* <GlobalMacroDesc ja_jp>分析フラグ<GlobalMacroDesc ja_jp> */
%global RSU_g_is_diag_on;
%let RSU_g_is_diag_on = %&RSUBool.False;
/* <GlobalMacroDesc ja_jp>デバッグコード開始文字列（利便性を考え、あえて規約違反）<GlobalMacroDesc ja_jp> */
%global debug__;
%let debug__ = *;
/* <GlobalMacroDesc ja_jp>リリースコード開始文字列（利便性を考え、あえて規約違反）<GlobalMacroDesc ja_jp> */
%global release__;
%let release__ = * */;
/* <GlobalMacroDesc ja_jp>分析コード開始文字列（利便性を考え、あえて規約違反）<GlobalMacroDesc ja_jp> */
%global diag__;
%let diag__ = *;
/*<GlobalVariableDesc ja_jp>デバッグ用フットプリント用連番</GlobalVariableDesc ja_jp>*/
%global RSU_g_sequence_footpint;
%let RSU_g_sequence_footpint = %&RSUBool.True;
/*<GlobalVariableDesc ja_jp>マクロスナップショット用連番</GlobalVariableDesc ja_jp>*/
%global RSU_g_sequence_macro_snapshot;
%let RSU_g_sequence_macro_snapshot = %&RSUBool.True;
/*<GlobalVariableDesc ja_jp>データセットスナップショット用連番</GlobalVariableDesc ja_jp>*/
%global RSU_g_sequence_ds_snapshot;
%let RSU_g_sequence_ds_snapshot = %&RSUBool.True;

/*<GlobalVariableDesc ja_jp>データセット書き込み禁止設定用（Dictionary）</GlobalVariableDesc ja_jp>*/
%global RSU_g_map_write_protected;

/*<GlobalVariableDesc ja_jp>例外が投げられたか？</GlobalVariableDesc ja_jp>*/
%global RSU_g_is_exception_thrown;
/*<GlobalVariableDesc ja_jp>警告をエラー扱いするか否か</GlobalVariableDesc ja_jp>*/
%global RSU_g_is_warning_error;
%let RSU_g_is_warning_error = %&RSUBool.False;

/* 固定フォーマット */
proc format;
/*<FormatDesc ja_jp>曜日数値 \ding{224} 曜日英語</FormatDesc ja_jp>*/
	value RSU_fmt_weekday_en_long
		1 = "Sunday"
		2 = "Monday"
		3 = "Tuesday"
		4 = "Wednesday"
		5 = "Thursday"
		6 = "Friday"
		7 = "Saturday"
	;

/*<FormatDesc ja_jp>曜日数値 \ding{224} 曜日日本語</FormatDesc ja_jp>*/
	value RSU_fmt_weekday_jp_long
		1 = "日曜日"
		2 = "月曜日"
		3 = "火曜日"
		4 = "水曜日"
		5 = "木曜日"
		6 = "金曜日"
		7 = "土曜日"
	;

/*<FormatDesc ja_jp>曜日数値 \ding{224} 曜日英語略称</FormatDesc ja_jp>*/
	value RSU_fmt_weekday_en_short
		1 = "Sun"
		2 = "Mon"
		3 = "Tues"
		4 = "Wed"
		5 = "Thu"
		6 = "Fri"
		7 = "Sat"
	;

/*<FormatDesc ja_jp>曜日数値 \ding{224} 曜日日本語略称</FormatDesc ja_jp>*/
	value RSU_fmt_weekday_jp_short
		1 = "日"
		2 = "月"
		3 = "火"
		4 = "水"
		5 = "木"
		6 = "金"
		7 = "土"
	;

/*<FormatDesc ja_jp>曜日英語 \ding{224} 曜日数値</FormatDesc ja_jp>*/
	value $RSU_fmt_inv_weekday_en_long
		"SUNDAY" = "1"
		"MONDAY" = "2"
		"TUESDAY" = "3"
		"WEDNESDAY" = "4"
		"THURSDAY" = "5"
		"FRIDAY" = "6"
		"SATURDAY" = "7"
	;

/*<FormatDesc ja_jp>曜日日本語 \ding{224} 曜日数値</FormatDesc ja_jp>*/
	value $RSU_fmt_inv_weekday_jp_long
		"日曜日" = "1"
		"月曜日" = "2"
		"火曜日" = "3"
		"水曜日" = "4"
		"木曜日" = "5"
		"金曜日" = "6"
		"土曜日" = "7"
	;

/*<FormatDesc ja_jp>曜日英語略称 \ding{224} 曜日数値</FormatDesc ja_jp>*/
	value $RSU_fmt_inv_weekday_en_short
		"SUN" = "1"
		"MON" = "2"
		"TUE" = "3"
		"WED" = "4"
		"THU" = "5"
		"FRI" = "6"
		"SAT" = "7"
	;

/*<FormatDesc ja_jp>曜日日本語略称 \ding{224} 曜日数値</FormatDesc ja_jp>*/
	value $RSU_fmt_inv_weekday_jp_short
		"日" = "1"
		"月" = "2"
		"火" = "3"
		"水" = "4"
		"木" = "5"
		"金" = "6"
		"土" = "7"
	;

/*<FormatDesc ja_jp>月番号 \ding{224} 英語月名</FormatDesc ja_jp>*/
	value RSU_fmt_month_name_en
		1 = "Junuary"
		2 = "February"
		3 = "March"
		4 = "April"
		5 = "May"
		6 = "June"
		7 = "July"
		8 = "August"
		9 = "September"
		10 = "October"
		11 = "November"
		12 = "December"
	;

/*<FormatDesc ja_jp>月番号 \ding{224} 英語月名（略）</FormatDesc ja_jp>*/
	value RSU_fmt_month_name_en_short
		1 = "Jun"
		2 = "Feb"
		3 = "Mar"
		4 = "Apr"
		5 = "May"
		6 = "Jun"
		7 = "Jul"
		8 = "Aug"
		9 = "Sep"
		10 = "Oct"
		11 = "Nov"
		12 = "Dec"
	;

/*<FormatDesc ja_jp>月番号 \ding{224} 日本語月名</FormatDesc ja_jp>*/
	value RSU_fmt_month_name_jp
		1 = "1月"
		2 = "2月"
		3 = "3月"
		4 = "4月"
		5 = "5月"
		6 = "6月"
		7 = "7月"
		8 = "8月"
		9 = "9月"
		10 = "10月"
		11 = "11月"
		12 = "12月"
	;

/*<FormatDesc ja_jp>Boolean数値 \ding{224} Boolean 英語</FormatDesc ja_jp>*/
	value RSU_fmt_boolean_en
		0 = "True"
		1 = "False"
	;

/*<FormatDesc ja_jp>Boolean数値 \ding{224} Boolean 日本語</FormatDesc ja_jp>*/
	value RSU_fmt_boolean_jp
		0 = "真"
		1 = "偽"
	;
run;
quit;