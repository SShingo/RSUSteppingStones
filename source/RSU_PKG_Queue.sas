/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Queue.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2023/12/27
/************************************************************************************/
/*<PackageID>RSUQueue</PackageID>*/
/*<CategoryID>Cate_MacroVariable</CategoryID>*/
/*<PackagePurpose ja_jp>キュー</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Queue</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>キュー機能に係るマクロ関数群を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions manipulating queue</PackageDesc en_us>*/
/*<PkgDetail ja_jp>
マクロ変数に対して、一般的な言語のキューのようにインデックスを用いて値を保持・取得出来るようにします。

キューのインデックスはSASのコンベンションに合わせて{\bfseries 1始まり}です。
</PkgDetail ja_jp>

/*<ConstantDesc ja_jp>キューパッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUQueue, RSUQueue__)

/*<FunctionDesc ja_jp>データセットからキューを生成します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>キューID</FunctionReturn ja_jp>*/
%macro RSUQueue__CreateByDataset(
/*<FunctionArgDesc ja_jp>キューの基になるデータセットクエリ</FunctionArgDesc ja_jp>*/
											i_query
/*<FunctionArgDesc ja_jp>データセットの変数</FunctionArgDesc ja_jp>*/
											, i_variable
											);
	%&RSUUtil.VerifyRequiredArgs(i_args = i_query i_variable)
	%local /readonly __QUEUE_ID_CREATE = %Prv_RSUClass_CreateInstance(i_prefix = ST
																							, i_sequence_var = RSU_g_sequence_array);
	%Int_RSUQueue_SetItemsByDS(ivar_queue = __QUEUE_ID_CREATE
											, i_query = &i_query.
											, i_variable_value = &i_variable.)
	%global &__QUEUE_ID_CREATE._index;
	%let &__QUEUE_ID_CREATE._index = 0;
	&__QUEUE_ID_CREATE.
%mend RSUQueue__CreateByDataset;

/*<FunctionDesc ja_jp>キューを生成します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>キューID</FunctionReturn ja_jp>*/
%macro RSUQueue__Create(
/*<FunctionArgDesc ja_jp>キューの項目リスト</FunctionArgDesc ja_jp>*/
								i_items
/*<FunctionArgDesc ja_jp>キューIDを保持する変数名</FunctionArgDesc ja_jp>*/
								, ovar_queue_id
/*<FunctionArgDesc ja_jp>項目の区切り文字</FunctionArgDesc ja_jp>*/
								, i_delimiter = %str( )
								);
	%local /readonly __QUEUE_ID_CREATE = %Prv_RSUClass_CreateInstance(i_prefix = AR
																							, i_sequence_var = RSU_g_sequence_array);
	%local __queue_item_index;
	%local __queue_item_value;
	%if (not %&RSUMacroVariable.IsBlank(i_items.)) %then %do;
		%do %while(%&RSUUtil.ForEach(i_items = &i_items., ovar_item = __queue_item_value, iovar_index = __queue_item_index, i_delimiter = &i_delimiter_item.));
			%global &__QUEUE_ID_CREATE._V_&__queue_item_index.;
			%let &__QUEUE_ID_CREATE._V_&__queue_item_index. = &__queue_item_value.;
		%end;
	%end;
	%global &__QUEUE_ID_CREATE._max;
	%let &__QUEUE_ID_CREATE._max = %eval(&__queue_item_index. - 1);
	%global &__QUEUE_ID_CREATE._index;
	%let &__QUEUE_ID_CREATE._index = 0;
	&__QUEUE_ID_CREATE.
%mend RSUQueue__Create;

/*<FunctionDesc ja_jp>値が空のキューを生成します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>キューID</FunctionReturn ja_jp>*/
%macro RSUQueue__CreateBlank(
/*<FunctionArgDesc ja_jp>キューサイズ</FunctionArgDesc ja_jp>*/
										i_size
										);
	%local /readonly __QUEUE_ID_CREATE = %Prv_RSUClass_CreateInstance(i_prefix = AR
																							, i_sequence_var = RSU_g_sequence_array);
	%local __queue_item_index;
	%local __queue_item_value;
	%local /readonly __QUEUE_SIZE = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(i_size), 0, &i_size.);
	%do __queue_item_index = 1 %to &__QUEUE_SIZE.;
		%global &__QUEUE_ID_CREATE._V_&__queue_item_index.;
		%let &__QUEUE_ID_CREATE._V_&__queue_item_index. =;
	%end;
	%global &__QUEUE_ID_CREATE._max;
	%let &__QUEUE_ID_CREATE._max = &__QUEUE_SIZE.;
	%global &__QUEUE_ID_CREATE._index;
	%let &__QUEUE_ID_CREATE._index = 0;
	&__QUEUE_ID_CREATE.
%mend RSUQueue__CreateBlank;

/*<FunctionDesc ja_jp>キューを破棄します</FunctionDesc ja_jp>*/
%macro RSUQueue__Dispose(
/*<FunctionArgDesc ja_jp>キューIDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_queue
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_queue)
	%local /readonly __QUEUE_ID_DISPOSE = &&&ivar_queue.;
	%&RSUMacroVariable.Delete(i_regex = /^&__QUEUE_ID_DISPOSE._/i)
	%&RSUDS.Delete(&__QUEUE_ID_DISPOSE.)
%mend RSUQueue__Dispose;

/*<FunctionDesc ja_jp>キューのサイズを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>キューのサイズ</FunctionReturn ja_jp>*/
%macro RSUQueue__Size(
/*<FunctionArgDesc ja_jp>キューIDを保持する変数名</FunctionArgDesc ja_jp>*/
							ivar_queue
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_queue)
	%local /readonly __QUEUE_ITEMS_ID_SIZE = &&&ivar_queue.;
	%eval(&&&__QUEUE_ITEMS_ID_SIZE._max - &&&__QUEUE_ITEMS_ID_SIZE._index)
%mend RSUQueue__Size;

/*<FunctionDesc ja_jp>キューが空か否かを返します</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0: キューは空ではない、1: キューが空</FunctionReturn ja_jp>*/
%macro RSUQueue__IsEmpty(
/*<FunctionArgDesc ja_jp>キューIDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_queue
								);
	%eval(%RSUQueue__Size(&ivar_queue.) = 0)
%mend RSUQueue__IsEmpty;

/*<FunctionDesc ja_jp>キューの値を取り出します（Dequeu）</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>0:失敗、1:成功</FunctionReturn ja_jp>*/
%macro RSUQueue__Dequeue(
/*<FunctionArgDesc ja_jp>キューIDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_queue
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_queue)
	%local /readonly __QUEUE_ID_DEQUEUE = &&&ivar_queue.;
	%local __queue_dequeue_result;
	%&RSUError.AbortIf(%RSUQueue__IsEmpty(&ivar_queue.)
							, i_msg = %&RSUMsg.QUEUE_EMPTY)
	%let &__QUEUE_ID_DEQUEUE._index = %eval(&&&__QUEUE_ID_DEQUEUE._index. + 1);
	%local /readonly __QUEUE_CURRENT_INDEX = &&&__QUEUE_ID_DEQUEUE._index.;
	%local /readonly __DEQUEUED_VALUE = &&&__QUEUE_ID_DEQUEUE._V_&__QUEUE_CURRENT_INDEX.;
	%symdel &__QUEUE_ID_DEQUEUE._V_&__QUEUE_CURRENT_INDEX.;
	&__DEQUEUED_VALUE.
%mend RSUQueue__Dequeue;

/*<FunctionDesc ja_jp>キューの現在値を読み取ります</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>読み取った値</FunctionReturn ja_jp>*/
%macro RSUQueue__Peek(
/*<FunctionArgDesc ja_jp>キューIDを保持する変数名</FunctionArgDesc ja_jp>*/
							ivar_queue
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_queue)
	%local /readonly __QUEUE_ID_PEEK = &&&ivar_queue.;
	%&RSUError.AbortIf(%RSUQueue__IsEmpty(&ivar_queue.)
							, i_msg = %&RSUMsg.QUEUE_EMPTY)
	%local /readonly __QUEUE_CURRENT_INDEX = %eval(&&&__QUEUE_ID_PEEK._index. + 1);
	&&&__QUEUE_ID_PEEK._V_&__QUEUE_CURRENT_INDEX.
%mend RSUQueue__Peek;

/*<FunctionDesc ja_jp>キューの末尾に項目を追加します（Enqueue）</FunctionDesc ja_jp>*/
%macro RSUQueue__Enqueue(
/*<FunctionArgDesc ja_jp>キューIDを保持する変数名</FunctionArgDesc ja_jp>*/
							ivar_queue
/*<FunctionArgDesc ja_jp>追加項目</FunctionArgDesc ja_jp>*/
							, i_value);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_queue)
	%local /readonly __QUEUE_ID_ENQUEUE = &&&ivar_queue.;
	%let &__QUEUE_ID_ENQUEUE._max = %eval(&&&__QUEUE_ID_ENQUEUE._max. + 1);
	%global &__QUEUE_ID_ENQUEUE._V_&&&__QUEUE_ID_ENQUEUE._max;
	%let &__QUEUE_ID_ENQUEUE._V_&&&__QUEUE_ID_ENQUEUE._max = &i_value.;
%mend RSUQueue__Enqueue;

/*<FunctionReturn ja_jp>見つかった項目番号（見つからない場合は0）</FunctionReturn ja_jp>*/
%macro RSUQueue__Find(
/*<FunctionArgDesc ja_jp>キューIDを保持する変数名</FunctionArgDesc ja_jp>*/
							ivar_queue
/*<FunctionArgDesc ja_jp>検索値</FunctionArgDesc ja_jp>*/
							, i_value
							);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_queue)
	%local /readonly __QUEUE_ID_FIND = &&&ivar_queue.; 
	%local __FOUND_QUEUE_ITEM_KEY;
	%let __FOUND_QUEUE_ITEM_KEY = %Int_RSUQueue_FindValue(ivar_queue = &ivar_queue.
																			, i_value = &i_value);
	%if (%&RSUMacroVariable.IsNull(__FOUND_QUEUE_ITEM_KEY)) %then %do;
		%let __FOUND_QUEUE_ITEM_KEY = 0;
	%end;
	&__FOUND_QUEUE_ITEM_KEY.
%mend RSUQueue__Find;

%macro RSUQueue__Contains(
/*<FunctionArgDesc ja_jp>キューIDを保持する変数名</FunctionArgDesc ja_jp>*/
								ivar_queue
/*<FunctionArgDesc ja_jp>検索値</FunctionArgDesc ja_jp>*/
								, i_value
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_queue)
	%local /readonly __FOUND_ITEM_CONTAINS = %RSUQueue__Find(&ivar_queue.
																				, &i_value);
	%eval(not &__FOUND_ITEM_CONTAINS. = 0)
%mend RSUQueue__Contains;

%macro RSUQueue__Show(
/*<FunctionArgDesc ja_jp>キューIDを保持する変数名</FunctionArgDesc ja_jp>*/
							ivar_queue
							);
	%local /readonly __QUEUE_ID_SHOW = &&&ivar_queue.;
	%Int_RSUArray_ShowItems(ivar_array = &ivar_queue.
									, i_index_from = %eval(&&&__QUEUE_ID_SHOW._index. + 1)
									, i_index_to = &&&__QUEUE_ID_SHOW._max.)
%mend RSUQueue__Show;