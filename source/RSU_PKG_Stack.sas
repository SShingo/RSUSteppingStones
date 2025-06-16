/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Stack.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2023/12/27
/************************************************************************************/
/*<PackageID>RSUStack</PackageID>*/
/*<CategoryID>Cate_MacroVariable</CategoryID>*/
/*<PackagePurpose ja_jp>スタック</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Stack</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>スタック機能に係るマクロ関数群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions manipulating stack</PackageDesc en_us>*/
/*<PkgDetail ja_jp>
マクロ変数に対して、一般的な言語のスタックのようにインデックスを用いて値を保持・取得出来るようにします。

スタックのインデックスはSASのコンベンションに合わせて{\bfseries 1始まり}です。
</PkgDetail ja_jp>

/*<ConstantDesc ja_jp>スタックパッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUStack, RSUStack__)

/*<FunctionDesc ja_jp>データセットからスタックを生成します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>スタックID</FunctionReturn ja_jp>*/
%macro RSUStack__CreateByDataset(
/*<FunctionArgDesc ja_jp>スタックの基になるデータセットクエリ</FunctionArgDesc ja_jp>*/
											i_query
/*<FunctionArgDesc ja_jp>データセットの変数</FunctionArgDesc ja_jp>*/
											, i_variable
											);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_query i_variable)
	%local /readonly __STACK_ID_CREATE = %Prv_RSUClass_CreateInstance(i_prefix = ST
																							, i_sequence_var = RSU_g_sequence_array);
	%Int_RSUStack_SetItemsByDS(ivar_stack = __STACK_ID_CREATE
											, i_query = &i_query.
											, i_variable_value = &i_variable.)
	&__STACK_ID_CREATE.
%mend RSUStack__CreateByDataset;

/*<FunctionDesc ja_jp>スタックを生成します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>スタックID</FunctionReturn ja_jp>*/
%macro RSUStack__Create(
/*<FunctionArgDesc ja_jp>スタックの項目リスト</FunctionArgDesc ja_jp>*/
								i_items
/*<FunctionArgDesc ja_jp>スタックIDを保持する変数名</FunctionArgDesc ja_jp>*/
								, ovar_stack_id
/*<FunctionArgDesc ja_jp>項目の区切り文字</FunctionArgDesc ja_jp>*/
								, i_delimiter = %str( )
								);
	%local /readonly __STACK_ID_CREATE = %Prv_RSUClass_CreateInstance(i_prefix = AR
																							, i_sequence_var = RSU_g_sequence_array);
	%local __stack_item_index;
	%local __stack_item_value;
	%if (not %&RSUMacroVariable.IsBlank(i_items)) %then %do;
		%do %while(%&RSUUtil.ForEach(i_items = &i_items., ovar_item = __stack_item_value, iovar_index = __stack_item_index, i_delimiter = &i_delimiter_item.));
			%global &__STACK_ID_CREATE._V_&__stack_item_index.;
			%let &__STACK_ID_CREATE._V_&__stack_item_index. = &__stack_item_value.;
		%end;
	%end;
	%global &__STACK_ID_CREATE._max;
	%let &__STACK_ID_CREATE._max = %eval(&__stack_item_index. - 1);
	&__STACK_ID_CREATE.
%mend RSUStack__Create;

/*<FunctionDesc ja_jp>値が空のスタックを生成します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>スタックID</FunctionReturn ja_jp>*/
%macro RSUStack__CreateBlank(
/*<FunctionArgDesc ja_jp>スタックサイズ</FunctionArgDesc ja_jp>*/
										i_size
										);
	%local /readonly __STACK_ID_CREATE = %Prv_RSUClass_CreateInstance(i_prefix = AR
																							, i_sequence_var = RSU_g_sequence_array);
	%local __stack_item_index;
	%local __stack_item_value;
	%local /readonly __STACK_SIZE = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(i_size), 0, &i_size.);
	%do __stack_item_index = 1 %to &__STACK_SIZE.;
		%global &__STACK_ID_CREATE._V_&__stack_item_index.;
		%let &__STACK_ID_CREATE._V_&__stack_item_index. =;
	%end;
	%global &__STACK_ID_CREATE._max;
	%let &__STACK_ID_CREATE._max = &__STACK_SIZE.;
	&__STACK_ID_CREATE.
%mend RSUStack__CreateBlank;

/*<FunctionDesc ja_jp>スタックを破棄します</FunctionDesc ja_jp>*/
%macro RSUStack__Dispose(
/*<FunctionArgDesc ja_jp>スタックIDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_stack
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_stack)
	%local /readonly __STACK_ID_DISPOSE = &&&ivar_stack.;
	%&RSUMacroVariable.Delete(i_regex = /^&__STACK_ID_DISPOSE._/i)
	%&RSUDS.Delete(&__STACK_ID_DISPOSE.)
%mend RSUStack__Dispose;

/*<FunctionDesc ja_jp>スタックのサイズを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>スタックのサイズ</FunctionReturn ja_jp>*/
%macro RSUStack__Size(
/*<FunctionArgDesc ja_jp>スタックIDを保持する変数名</FunctionArgDesc ja_jp>*/
							ivar_stack
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_stack)
	%local /readonly __STACK_ITEMS_ID_SIZE = &&&ivar_stack.;
	&&&__STACK_ITEMS_ID_SIZE._max
%mend RSUStack__Size;

/*<FunctionDesc ja_jp>スタックが空か否かを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0: スタックは空ではない、1: スタックが空</FunctionReturn ja_jp>*/
%macro RSUStack__IsEmpty(
/*<FunctionArgDesc ja_jp>スタックIDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_stack
								);
	%eval(%RSUStack__Size(&ivar_stack.) = 0)
%mend RSUStack__IsEmpty;

/*<FunctionDesc ja_jp>スタックの値を取り出します（Pop）</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>取り出した値</FunctionReturn ja_jp>*/
%macro RSUStack__Pop(
/*<FunctionArgDesc ja_jp>スタックIDを保持する変数名</FunctionArgDesc ja_jp>*/
							ivar_stack
/*<FunctionArgDesc ja_jp>囲みタイプ</FunctionArgDesc ja_jp>*/
							, i_enclosure =
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_stack)
	%local /readonly __STACK_ID_POP = &&&ivar_stack.;
	%local __stack_pop_result;
	%&RSUError.AbortIf(%RSUStack__IsEmpty(&ivar_stack.)
							, i_msg = %&RSUMsg.STACK_EMPTY)
	%local /readonly __STACK_CURRENT_INDEX = &&&__STACK_ID_POP._max.;
	%let &__STACK_ID_POP._max = %eval(&&&__STACK_ID_POP._max. - 1);
	%local /readonly __POPED_VALUE = %Int_RSUText_EncloseText(i_text = &&&__STACK_ID_POP._V_&__STACK_CURRENT_INDEX.
																				, i_enclosure = &i_enclosure.);
	%symdel &__STACK_ID_POP._V_&__STACK_CURRENT_INDEX.;
	&__POPED_VALUE.
%mend RSUStack__Pop;

/*<FunctionDesc ja_jp>スタックの現在値を読み取ります</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>読み取った値</FunctionReturn ja_jp>*/
%macro RSUStack__Peek(
/*<FunctionArgDesc ja_jp>スタックIDを保持する変数名</FunctionArgDesc ja_jp>*/
							ivar_stack
/*<FunctionArgDesc ja_jp>囲みタイプ</FunctionArgDesc ja_jp>*/
							, i_enclosure =
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_stack)
	%local /readonly __STACK_ID_PEEK = &&&ivar_stack.;
	%&RSUError.AbortIf(%RSUStack__IsEmpty(&ivar_stack.)
							, i_msg = %&RSUMsg.STACK_EMPTY)
	%local /readonly __STACK_CURRENT_INDEX = %eval(&__STACK_ID_POP._max.);
	%Int_RSUText_EncloseText(i_text = &&&__STACK_ID_PEEK._V_&__STACK_CURRENT_INDEX.
									, i_enclosure = &i_enclosure.)
%mend RSUStack__Peek;

/*<FunctionDesc ja_jp>スタックの末尾に項目を追加します（Push）</FunctionDesc ja_jp>*/
%macro RSUStack__Push(
/*<FunctionArgDesc ja_jp>スタックIDを保持する変数名</FunctionArgDesc ja_jp>*/
							ivar_stack
/*<FunctionArgDesc ja_jp>追加項目</FunctionArgDesc ja_jp>*/
							, i_value);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_stack)
	%local /readonly __STACK_ID_PUSH = &&&ivar_stack.;
	%let &__STACK_ID_PUSH._max = %eval(&&&__STACK_ID_PUSH._max. + 1);
	%global &__STACK_ID_PUSH._V_&&&__STACK_ID_PUSH._max;
	%let &__STACK_ID_PUSH._V_&&&__STACK_ID_PUSH._max = &i_value.;
	%put %RSUStack__Size(&ivar_stack.);
%mend RSUStack__Push;

/*<FunctionReturn ja_jp>見つかった項目番号（見つからない場合は0）</FunctionReturn ja_jp>*/
%macro RSUStack__Find(
/*<FunctionArgDesc ja_jp>スタックIDを保持する変数名</FunctionArgDesc ja_jp>*/
							ivar_stack
/*<FunctionArgDesc ja_jp>検索値</FunctionArgDesc ja_jp>*/
							, i_value
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_stack)
	%local /readonly __STACK_ID_FIND = &&&ivar_stack.; 
	%local __FOUND_STACK_ITEM_KEY;
	%let __FOUND_STACK_ITEM_KEY = %Int_RSUStack_FindValue(ivar_stack = &ivar_stack.
																			, i_value = &i_value);
	%if (%&RSUMacroVariable.IsNull(__FOUND_STACK_ITEM_KEY)) %then %do;
		%let __FOUND_STACK_ITEM_KEY = 0;
	%end;
	&__FOUND_STACK_ITEM_KEY.
%mend RSUStack__Find;

%macro RSUStack__Contains(
/*<FunctionArgDesc ja_jp>スタックIDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_stack
/*<FunctionArgDesc ja_jp>検索値</FunctionArgDesc ja_jp>*/
								, i_value
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_stack)
	%local /readonly __FOUND_ITEM_CONTAINS = %RSUStack__Find(&ivar_stack.
																				, &i_value);
	%eval(not &__FOUND_ITEM_CONTAINS. = 0)
%mend RSUStack__Contains;

%macro RSUStack__Show(
/*<FunctionArgDesc ja_jp>スタックIDを保持する変数名</FunctionArgDesc ja_jp>*/
							ivar_stack
							);
	%local /readonly __STACK_ID_SHOW = &&&ivar_stack.;
	%Int_RSUArray_ShowItems(ivar_array = &ivar_stack.
									, i_index_from = 1
									, i_index_to = &&&__STACK_ID_SHOW._max.)
%mend RSUStack__Show;