/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Class_Counter.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/3/14
/*
/************************************************************************************/
/*<ClassID>RSU_PKG_Class_Counter</ClassID>*/
/*<ClassCreator>%&RSUCounter.Create</ClassCreator>*/
/*<ClassPurpose ja_jp>Counter クラス</ClassPurpose ja_jp>*/

/*<MemberVarDesc ja_jp>数列の項番号$i$</MemberVarDesc ja_jp>*/
%&RSUClass.DeclareVar(<instance>, m_index)
/*<MemberVarDesc ja_jp>数列の初期値</MemberVarDesc ja_jp>*/
%&RSUClass.DeclareVar(<instance>, m_start)
/*<MemberVarDesc ja_jp>数列の乗数$c$</MemberVarDesc ja_jp>*/
%&RSUClass.DeclareVar(<instance>, m_step)
/*<MemberVarDesc ja_jp>数列の法$m$</MemberVarDesc ja_jp>*/
%&RSUClass.DeclareVar(<instance>, m_mod)
/*<MemberVarDesc ja_jp>数列の除数$d$</MemberVarDesc ja_jp>*/
%&RSUClass.DeclareVar(<instance>, m_div)
/*<MemberVarDesc ja_jp>数列の切片$b$</MemberVarDesc ja_jp>*/
%&RSUClass.DeclareVar(<instance>, m_intercept)
/*<MemberVarDesc ja_jp>出力の際の前添え字</MemberVarDesc ja_jp>*/
%&RSUClass.DeclareVar(<instance>, m_prefix)
/*<MemberVarDesc ja_jp>出力の際の後ろ添え字</MemberVarDesc ja_jp>*/
%&RSUClass.DeclareVar(<instance>, m_suffix)
/*<MemberVarDesc ja_jp>出力の際の数字部分の桁数</MemberVarDesc ja_jp>*/
%&RSUClass.DeclareVar(<instance>, m_digit)
/*<MemberVarDesc ja_jp>数列の最大項数</MemberVarDesc ja_jp>*/
%&RSUClass.DeclareVar(<instance>, m_max_index)
/*<MemberVarDesc ja_jp>数列の現在値</MemberVarDesc ja_jp>*/
%&RSUClass.DeclareVar(<instance>, m_current_value)

/*******************************************/
/* Internal Macros
/*******************************************/
%macro Int_<instance>Initialize(i_start =
										, i_step =
										, i_div =
										, i_mod =
										, i_intercept =
										, i_prefix =
										, i_suffix =
										, i_digit =
										, i_max_index =);
	%let <instance>m_index = 0;
	%let <instance>m_start = &i_start;
	%let <instance>m_step = &i_step;
	%let <instance>m_mod = &i_mod;
	%let <instance>m_div = &i_div;
	%let <instance>m_intercept = &i_intercept;
	%let <instance>m_prefix = &i_prefix;
	%let <instance>m_suffix = &i_suffix;
	%let <instance>m_digit = &i_digit.;
	%let <instance>m_max_index = &i_max_index.;
	%<instance>Reset()
%mend Int_<instance>Initialize;

/*******************************************/
/* Public Macros
/*******************************************/
/*<FunctionDesc ja_jp>Counter の現在値を返し、項を進めます</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>Counter の現在値</FunctionReturn ja_jp>*/
%macro <instance>Draw();
	%let <instance>m_index = %eval(&<instance>m_index. + 1);
	%let <instance>m_current_value = %Prv_RSUCounter_CalcHelper(i_index = &<instance>m_index.
																					, i_start = &<instance>m_start.
																					, i_step = &<instance>m_step.
																					, i_mod = &<instance>m_mod.
																					, i_div = &<instance>m_div.
																					, i_intercept = &<instance>m_intercept.);
	&<instance>m_current_value.
%mend <instance>Draw;

/*<FunctionDesc ja_jp>Counter の現在値を返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>Counter の現在値</FunctionReturn ja_jp>*/
%macro <instance>Peek();
	&<instance>m_current_value.
%mend <instance>Peek;

/*<FunctionDesc ja_jp>Counter の現在の項番を返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>Counter の現在のインデクス</FunctionReturn ja_jp>*/
%macro <instance>CurrentIndex();
	&<instance>m_index.
%mend <instance>CurrentIndex;

/*<FunctionDesc ja_jp>Counter を初期値に戻します</FunctionDesc ja_jp>*/
%macro <instance>Reset();
	%let <instance>m_index = 0;
	%let <instance>m_current_value =;
%mend <instance>Reset;
