/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Class_IteratorArray.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/4/10
/*
/*<PkgParent>RSUList RSUQueue RSUStack<PkgParent>
/*
/* NOTE: Array由来の配列に対するイテレータ
/* NOTE: 現在のポイントを保持するために疑似クラス化
/************************************************************************************/
/*<ClassID>RSU_PKG_Class_IteratorArray</ClassID>*/
/*<ClassCreator>%&RSUArray.GetIterator</ClassCreator>*/
/*<ClassCreator>%&RSUList.GetIterator</ClassCreator>*/
/*<ClassCreator>%&RSUQueue.GetIterator</ClassCreator>*/
/*<ClassCreator>%&RSUStack.GetIterator</ClassCreator>*/
/*<ClassPurpose ja_jp>配列イテレーター</ClassPurpose ja_jp>*/

%&RSUClass.DeclareVar(<instance>, m_items)
%&RSUClass.DeclareVar(<instance>, m_count)
%&RSUClass.DeclareVar(<instance>, m_index)
%&RSUClass.DeclareVar(<instance>, m_direction)
%&RSUClass.DeclareVar(<instance>, m_is_terminated)

/*******************************************/
/* Internal Macros
/*******************************************/
%macro Int_<instance>Initialize(ivar_array =
										, i_direction =);
	%let <instance>m_items = &&&ivar_array.;
	%let <instance>m_count = %RSUArray__GetSize(ivar_array = <instance>m_items);
	%let <instance>m_direction = &i_direction.;
	%<instance>Reset()
%mend Int_<instance>Initialize;

/*******************************************/
/* Public Macros
/*******************************************/
/*<FunctionDesc ja_jp>イテレータを進行させます</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0: 配列末端に到達、または反復停止\quad 1: 移動成功</FunctionReturn ja_jp>*/
%macro <instance>Next();
	%local _result;
	%if (not &<instance>m_is_terminated.) %then %do;
		%let <instance>m_index = %eval(&<instance>m_index. + &<instance>m_direction.);
		%if (&<instance>m_direction. = %&RSUDirection.Forward) %then %do;
			%let _result = %eval(&<instance>m_index. <= &<instance>m_count.);
		%end;
		%else %do;
			%let _result = %eval(0 <= &<instance>m_index.);
		%end;
	%end;
	%else %do;
		%let _result = %&RSUBool.False;
		%<instance>Reset()
	%end;
	&_result.
%mend <instance>Next;

/*<FunctionDesc ja_jp>現在のポインタにおける配列の要素値を返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>現在のポインタにおける配列の要素値</FunctionReturn ja_jp>*/
%macro <instance>Current();
	%RSUArray__Get(ivar_array = <instance>m_items. 
						, i_index = &<instance>m_index.)
%mend <instance>Current;

/*<FunctionDesc ja_jp>現在のポインタの位置を表すインデックスを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>現在のポインタの位置</FunctionReturn ja_jp>*/
%macro <instance>CurrentIndex();
	&<instance>m_index.
%mend <instance>CurrentIndex;

/*<FunctionDesc ja_jp>イテレータをリセットします</FunctionDesc ja_jp>*/
%macro <instance>Reset();
	%if (&<instance>m_direction. = %&RSUDirection.Forward) %then %do;
		%let <instance>m_index = 0;
	%end;
	%else %do;
		%let <instance>m_index = %eval(&<instance>m_count. + 1);
	%end;
	%let <instance>m_is_terminated = %&RSUBool.False;
%mend <instance>Reset;

/*<FunctionDesc ja_jp>反復を中止します</FunctionDesc ja_jp>*/
%macro <instance>Terminate();
	%let <instance>m_is_terminated = %&RSUBool.True;
%mend <instance>Terminate;