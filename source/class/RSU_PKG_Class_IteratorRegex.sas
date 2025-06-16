/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Class_IteratorRegex.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/12/29
/*
/* <PkgParent>RSURegex<PkgParent>
/************************************************************************************/
/*<ClassID>RSU_PKG_Class_IteratorRegex</ClassID>*/
/*<ClassCreator>%&RSURegex.GetIterator</ClassCreator>*/
/*<ClassPurpose ja_jp>正規表現 matchイテレーター</ClassPurpose ja_jp>*/

%&RSUClass.DeclareVar(<instance>, m_text)
%&RSUClass.DeclareVar(<instance>, m_regex_id)
%&RSUClass.DeclareVar(<instance>, m_next_start)
%&RSUClass.DeclareVar(<instance>, m_next_stop)
%&RSUClass.DeclareVar(<instance>, m_next_pos)
%&RSUClass.DeclareVar(<instance>, m_next_len)
%&RSUClass.DeclareVar(<instance>, m_next_index)
%&RSUClass.DeclareVar(<instance>, m_matched_pos)
%&RSUClass.DeclareVar(<instance>, m_max_paren)
%&RSUClass.DeclareVar(<instance>, m_current_paren)
%&RSUClass.DeclareVar(<instance>, m_current_caupture)
%&RSUClass.DeclareVar(<instance>, m_captured_text)

/*******************************************/
/* Internal Macros
/*******************************************/
%macro Int_<instance>Initialize(i_regex =
										, i_text =);
	%let <instance>m_text = &i_text.;
	%let <instance>m_regex_id = %sysfunc(prxparse(&i_regex.));
	%<instance>Reset()
%mend Int_<instance>Initialize;

%macro Int_<instance>Release();
	%syscall prxfree(<instance>m_regex_id);
%mend Int_<instance>Release;

/*******************************************/
/* Public Macros
/*******************************************/
/*<FunctionDesc ja_jp>パターンに一致し、1つの文字列内で複数の一致が繰り返される部分文字列の位置と長さを求めます。</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0: マッチングなし\quad 1: マッチングあり</FunctionReturn ja_jp>*/
%macro <instance>Next();
	/* ! MEMO: prxnext の引数はすべて non-readonly のマクロ変数を渡す */
	%syscall prxnext(<instance>m_regex_id, <instance>m_next_start, <instance>m_next_stop, <instance>m_text, <instance>m_next_pos, <instance>m_next_len);
	%local _result;
	%if (0 < &<instance>m_next_pos.) %then %do;
		%let _result = %&RSUBool.True;
		%let <instance>m_next_index = %eval(&<instance>m_next_index. + 1);
		%let <instance>m_current_caupture = %substr(&<instance>m_text., &<instance>m_next_pos., &<instance>m_next_len.);
		%let <instance>m_current_paren = 0;
	%end;
	%else %do;
		%let _result = %&RSUBool.False;
		%let <instance>m_current_caupture =;
		%let <instance>m_current_paren =;
	%end;
	&_result.
%mend <instance>Next;

/*<FunctionDesc ja_jp>繰り返しマッチング処理を先頭に戻します。</FunctionDesc ja_jp>*/
%macro <instance>Reset();
	%let <instance>m_next_index = 0;
	%let <instance>m_next_pos = 0;
	%let <instance>m_next_start = 1;
	%let <instance>m_next_len = %length(&<instance>m_text.);
	%let <instance>m_next_stop = &<instance>m_next_len.;
	%let <instance>m_matched_pos = 0;
	%local /readonly _MATCHED_POS = %sysfunc(prxmatch(&<instance>m_regex_id., &<instance>m_text.));
	%let <instance>m_max_paren = %&RSUUtil.Choose(0 < &_MATCHED_POS., %sysfunc(prxparen(&<instance>m_regex_id.)), 0);
	%let <instance>m_current_paren = 0;
%mend <instance>Reset;

/*<FunctionDesc ja_jp>マッチングした文字列の位置を返します。</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>マッチングした文字列の位置</FunctionReturn ja_jp>*/
%macro <instance>CurrentPos();
	&<instance>m_next_pos.
%mend <instance>CurrentPos;

/*<FunctionDesc ja_jp>マッチングした文字列の長さを返します。</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>マッチングした文字列の長さ</FunctionReturn ja_jp>*/
%macro <instance>CurrentLen();
	&<instance>m_next_len.
%mend <instance>CurrentLen;

/*<FunctionDesc ja_jp>次のマッチング処理の起点を返します。</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>次のマッチング処理の起点</FunctionReturn ja_jp>*/
%macro <instance>CurrentStart();
	&<instance>m_next_start.
%mend <instance>CurrentStart;

/*<FunctionDesc ja_jp>現在のキャプチャ番号を返します。</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>現在のキャプチャ番号</FunctionReturn ja_jp>*/
%macro <instance>CurrentIndex();
	&<instance>m_next_index.
%mend <instance>CurrentIndex;

/*<FunctionDesc ja_jp>現在のキャプチャを返します。</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>現在のキャプチャ</FunctionReturn ja_jp>*/
%macro <instance>Current();
	&<instance>m_current_caupture.
%mend <instance>Current;

/*<FunctionDesc ja_jp>現在のキャプチャの括弧をイテレートします。</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0: イテレート終了\quad 1: イテレート成功</FunctionReturn ja_jp>*/
%macro <instance>NextPos();
	%local _result;
	%let <instance>m_current_paren = %eval(&<instance>m_current_paren. + 1);
	%if (&<instance>m_current_paren. <= &<instance>m_max_paren.) %then %do;
		%let _result = %&RSUBool.True;
	%end;
	%else %do;
		%let _result = %&RSUBool.False;
	%end;
	&_result.
%mend <instance>NextPos;

/*<FunctionDesc ja_jp>現在のキャプチャの現在の括弧番号を返します。</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>現在のキャプチャの現在の括弧番号</FunctionReturn ja_jp>*/
%macro <instance>CurrentPosIndex();
	&<instance>m_current_paren.
%mend <instance>CurrentPosIndex;

/*<FunctionDesc ja_jp>現在のキャプチャの現在の括弧内のテキストを返します。</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>現在のキャプチャの現在の括弧内テキスト</FunctionReturn ja_jp>*/
%macro <instance>CurrentPosText();
	%sysfunc(prxposn(&<instance>m_regex_id., &<instance>m_current_paren., &<instance>m_text.))
%mend <instance>CurrentPosText;
