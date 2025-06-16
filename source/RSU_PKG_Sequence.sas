/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Sequence.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2023/2/25
/*
/************************************************************************************/
/*<PackageID>RSUSeq</PackageID>*/
/*<CategoryID>Cate_DataHandling</CategoryID>*/
/*<PackagePurpose ja_jp>数列操作</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Manipurating Number Sequence</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>数列（時系列）データを操作する関数を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions manipulating number sequence(time series) data</PackageDesc en_us>*/

/*<ConstantDesc ja_jp>数列パッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUSequence, RSUSeq__)

/*<FunctionDesc ja_jp>数値変数に対して補間、および補外を行います</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>Interpolating or Extrapolate variable</FunctionReturn ja_jp>*/
%macro RSUSeq__FillN(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
							iods_dataset =
/*<FunctionArgDesc ja_jp>補間/補外対象変数</FunctionArgDesc ja_jp>*/
							, i_variable =
/*<FunctionArgDesc ja_jp>変数のグループ</FunctionArgDesc ja_jp>*/
							, i_variable_by =
/*<FunctionArgDesc ja_jp>補間のタイプ（空欄: 補間しない）</FunctionArgDesc ja_jp>*/
							, i_interpolation =
/*<FunctionArgDesc ja_jp>過去側補外を行うか否か</FunctionArgDesc ja_jp>*/
							, i_extrapolation_pre = %&RSUBool.False
/*<FunctionArgDesc ja_jp>未来側補外を行うか否か</FunctionArgDesc ja_jp>*/
							, i_extrapolation_post = %&RSUBool.False
							);
	%&RSUDS.AddSequenceVariable(i_query = &iods_dataset.
										, i_sequence_variable_name = __tmp_key)
	%local /readonly _TMP_DS_OUTPUT = %&RSUDS.GetTempDSName(output);
	data _null_;
	%if (not %&RSUMacroVariable.IsBlank(i_variable_by)) %then %do;
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
										, i_variables = &i_variable_by.(__prev_group))
	%end;									
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
										, i_variables = &i_variable.(__last_valid_value))
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
										, i_variables = &i_variable.(__interpolate_start_value))
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.)
		declare hash h_in(dataset: "&iods_dataset.", ordered: 'yes');
		h_in.definekey('__tmp_key');
		h_in.definedata(all: 'yes');
		h_in.definedone();
		declare hiter hi_in('h_in');
		
		call missing(__current_key);
		call missing(__gap_index);
		call missing(__interpolate_delta);
		call missing(__prev_group);
		__rc = hi_in.first();
		do while(__rc = 0);
			__current_key = __tmp_key;
		%if (%&RSUMacroVariable.IsBlank(i_variable_by)) %then %do;
			if (__current_key = 0) then do;
		%end;
		%else %do;
			if (__prev_group ne &i_variable_by.) then do;
				__prev_group = &i_variable_by.;
				if (__in_gap and &i_extrapolation_post.) then do;
					do __gap_index = 1 to __current_key - __last_valid_key;
						hi_in.setcur(key: __last_valid_key + __gap_index);
						&i_variable. = __last_valid_value;
						h_in.replace();
					end;
				end;
		%end;
				__is_series_started = %&RSUBool.False;
				call missing(__interpolate_start_value);
				__in_gap = %&RSUBool.False;
				__start_key = __current_key;
				call missing(__last_valid_key);
				call missing(__last_valid_value);
			end;
			if (not missing(&i_variable.)) then do;
				if (not __is_series_started) then do;
					__is_series_started = %&RSUBool.True;
					__interpolate_start_value = &i_variable.;
					if (&i_extrapolation_pre.) then do;
						do __gap_index = __start_key to __current_key - 1;
							hi_in.setcur(key: __gap_index);
							&i_variable. = __interpolate_start_value;
							h_in.replace();
						end;
						hi_in.setcur(key: __current_key);
					end;
				end;
				if (__in_gap) then do;
		%if (&i_interpolation. = %&RSUInterpolation.StepForward) %then %do;
					__interpolate_delta = 0;
					__interpolate_start_value = __last_valid_value;
		%end;
		%else %if (&i_interpolation. = %&RSUInterpolation.StepBackward) %then %do;
					__interpolate_delta = 0;
					__interpolate_start_value = &i_variable.;
		%end;
		%else %if (&i_interpolation. = %&RSUInterpolation.Linear) %then %do;
					__interpolate_delta = (&i_variable. - __last_valid_value) / (__current_key - __last_valid_key);
					__interpolate_start_value = __last_valid_value;
		%end;
					do __gap_index = 1 to __current_key - __last_valid_key - 1;
						hi_in.setcur(key: __last_valid_key + __gap_index);
						&i_variable. = __interpolate_start_value + __interpolate_delta * __gap_index;
						h_in.replace();
					end;
					hi_in.setcur(key: __current_key);
				end;
				__last_valid_key = __current_key;
				__last_valid_value = &i_variable.;
				__in_gap = %&RSUBool.False;
			end;
			else do;
				if (__is_series_started) then do;
					__in_gap = %&RSUBool.True;
				end;
			end;
			__rc = hi_in.next();
		end;
		if (__in_gap and &i_extrapolation_post.) then do;
			do __gap_index = 1 to __current_key - __last_valid_key;
				hi_in.setcur(key: __last_valid_key + __gap_index);
				&i_variable. = __last_valid_value;
				h_in.replace();
			end;
		end;
		__rc = h_in.output(dataset: "&_TMP_DS_OUTPUT.(drop = __tmp_key)");
	run;
	quit;
	
	%&RSUDS.Move(i_query = &_TMP_DS_OUTPUT.
					, ods_dest_ds = &iods_dataset.)
%mend RSUSeq__FillN;

/*<FunctionDesc ja_jp>文字変数に対して補間、および補外を行います</FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>Interpolating or Extrapolate variable</FunctionReturn ja_jp>*/
%macro RSUSeq__FillC(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
							iods_dataset =
/*<FunctionArgDesc ja_jp>補間/補外対象変数</FunctionArgDesc ja_jp>*/
							, i_variable =
/*<FunctionArgDesc ja_jp>変数のグループ</FunctionArgDesc ja_jp>*/
							, i_variable_by =
/*<FunctionArgDesc ja_jp>補間のタイプ（空欄: 補間しない）</FunctionArgDesc ja_jp>*/
							, i_interpolation =
/*<FunctionArgDesc ja_jp>過去側補外を行うか否か</FunctionArgDesc ja_jp>*/
							, i_extrapolation_pre = %&RSUBool.False
/*<FunctionArgDesc ja_jp>未来側補外を行うか否か</FunctionArgDesc ja_jp>*/
							, i_extrapolation_post = %&RSUBool.False
							);
	%&RSUDS.AddSequenceVariable(i_query = &iods_dataset.
										, i_sequence_variable_name = __tmp_key)
	%local /readonly _TMP_DS_OUTPUT = %&RSUDS.GetTempDSName(output);
	data _null_;
	%if (not %&RSUMacroVariable.IsBlank(i_variable_by)) %then %do;
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
										, i_variables = &i_variable_by.(__prev_group))
	%end;									
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
										, i_variables = &i_variable.(__last_valid_value))
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
										, i_variables = &i_variable.(__interpolate_start_value))
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.)
		declare hash h_in(dataset: "&iods_dataset.", ordered: 'yes');
		h_in.definekey('__tmp_key');
		h_in.definedata(all: 'yes');
		h_in.definedone();
		declare hiter hi_in('h_in');
		
		call missing(__current_key);
		call missing(__gap_index);
		call missing(__prev_group);
		__rc = hi_in.first();
		do while(__rc = 0);
			__current_key = __tmp_key;
		%if (%&RSUMacroVariable.IsBlank(i_variable_by)) %then %do;
			if (__current_key = 0) then do;
		%end;
		%else %do;
			if (__prev_group ne &i_variable_by.) then do;
				__prev_group = &i_variable_by.;
				if (__in_gap and &i_extrapolation_post.) then do;
					do __gap_index = 1 to __current_key - __last_valid_key;
						hi_in.setcur(key: __last_valid_key + __gap_index);
						&i_variable. = __last_valid_value;
						h_in.replace();
					end;
				end;
		%end;
				__is_series_started = %&RSUBool.False;
				call missing(__interpolate_start_value);
				__in_gap = %&RSUBool.False;
				__start_key = __current_key;
				call missing(__last_valid_key);
				call missing(__last_valid_value);
			end;
			if (not missing(&i_variable.)) then do;
				if (not __is_series_started) then do;
					__is_series_started = %&RSUBool.True;
					__interpolate_start_value = &i_variable.;
					if (&i_extrapolation_pre.) then do;
						do __gap_index = __start_key to __current_key - 1;
							hi_in.setcur(key: __gap_index);
							&i_variable. = __interpolate_start_value;
							h_in.replace();
						end;
						hi_in.setcur(key: __current_key);
					end;
				end;
				if (__in_gap) then do;
		%if (&i_interpolation. = %&RSUInterpolation.StepForward) %then %do;
					__interpolate_start_value = __last_valid_value;
		%end;
		%else %do;
					__interpolate_start_value = &i_variable.;
		%end;
					do __gap_index = 1 to __current_key - __last_valid_key - 1;
						hi_in.setcur(key: __last_valid_key + __gap_index);
						&i_variable. = __interpolate_start_value;
						h_in.replace();
					end;
					hi_in.setcur(key: __current_key);
				end;
				__last_valid_key = __current_key;
				__last_valid_value = &i_variable.;
				__in_gap = %&RSUBool.False;
			end;
			else do;
				if (__is_series_started) then do;
					__in_gap = %&RSUBool.True;
				end;
			end;
			__rc = hi_in.next();
		end;
		if (__in_gap and &i_extrapolation_post.) then do;
			do __gap_index = 1 to __current_key - __last_valid_key;
				hi_in.setcur(key: __last_valid_key + __gap_index);
				&i_variable. = __last_valid_value;
				h_in.replace();
			end;
		end;
		__rc = h_in.output(dataset: "&_TMP_DS_OUTPUT.(drop = __tmp_key)");
	run;
	quit;
	
	%&RSUDS.Move(i_query = &_TMP_DS_OUTPUT.
					, ods_dest_ds = &iods_dataset.)
%mend RSUSeq__FillC;

/*<FunctionDesc ja_jp>変数を指定数シフトした変数（lag/lead）を作成します</FunctionDesc ja_jp>*/
%macro RSUSeq__GenerateShiftedVar(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
											iods_dataset =
/*<FunctionArgDesc ja_jp>対象変数</FunctionArgDesc ja_jp>*/
											, i_variable =
/*<FunctionArgDesc ja_jp>変数のグループ</FunctionArgDesc ja_jp>*/
											, i_variable_by =
/*<FunctionArgDesc ja_jp>シフト数（正の数: lead、負の数: lag）</FunctionArgDesc ja_jp>*/
											, i_shift_step =
/*<FunctionArgDesc ja_jp>シフトされた変数名</FunctionArgDesc ja_jp>*/
											, i_shifted_variable =
											);
	data WORK.shift_weight;
		weight_index = &i_shift_step.;
		weight = 1;
	run;
	quit;
%mend RSUSeq__GenerateShiftedVar;

/*<FunctionDesc ja_jp>移動平均変数を作成します</FunctionDesc ja_jp>*/
%macro RSUSeq__GenerateMovingAverageVar(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
													iods_dataset =
/*<FunctionArgDesc ja_jp>対象変数</FunctionArgDesc ja_jp>*/
													, i_variable =
/*<FunctionArgDesc ja_jp>変数のグループ</FunctionArgDesc ja_jp>*/
													, i_variable_by =
/*<FunctionArgDesc ja_jp>移動平均幅（``:''区切り）</FunctionArgDesc ja_jp>*/
													, i_moving_average_range =
/*<FunctionArgDesc ja_jp>平均に用いられたレコード数を保持する変数名</FunctionArgDesc ja_jp>*/
													, i_no_of_weighted_record_variable =
/*<FunctionArgDesc ja_jp>移動平均変数名</FunctionArgDesc ja_jp>*/
													, i_moving_average_variable =
													);
	%local /readonly _RANGE_ITEM_1 = %scan(&i_moving_average_range., 1, :);
	%local /readonly _RANGE_ITEM_2 = %scan(&i_moving_average_range., 2, :);
	%local _average_begin;
	%local _average_last;
	%if (%&RSUMacroVariable.IsBlank(_RANGE_ITEM_2)) %then %do;
		%let _average_begin = %sysfunc(min(&_RANGE_ITEM_1., 0));
		%let _average_last = %sysfunc(max(&_RANVE_ITEM_1, 0));
	%end;
	%else %do;
		%let _average_begin = %sysfunc(min(&_RANGE_ITEM_1., &_RANGE_ITEM_2));
		%let _average_last = %sysfunc(max(&_RANGE_ITEM_1., &_RANGE_ITEM_2));
	%end;
	%local /readonly _NO_OF_RECORDS = %eval(&_average_last. - &_average_begin. + 1);
	%local _index;
	data WORK.average_weight;
		%do _index = &_average_begin. %to &_average_last.;
			weight_index = &_index.;
			weight = 1 / &_NO_OF_RECORDS.;
			output;
		%end;
	run;
	quit;
	%Prv_RSUSeq__CalcSumProd(iods_dataset = &iods_dataset.
									, i_variable = &i_variable.
									, i_variable_by = &i_variable_by.
									, i_weighted_variable = &i_moving_average_variable.
									, i_no_of_weighted_record_variable = &i_no_of_weighted_record_variable.
									, ids_weights = WORK.average_weight)
	%&RSUDS.Delete(WORK.average_weight)
%mend RSUSeq__GenerateMovingAverageVar;

/*<FunctionDesc ja_jp>変数の対数収益率を作成します</FunctionDesc ja_jp>*/
%macro RSUSeq__GenerateDiffVar(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
										iods_dataset =
/*<FunctionArgDesc ja_jp>対象変数</FunctionArgDesc ja_jp>*/
										, i_variable =
/*<FunctionArgDesc ja_jp>変数のグループ</FunctionArgDesc ja_jp>*/
										, i_variable_by =
/*<FunctionArgDesc ja_jp>対数収益率対象位置（``:''区切り、省略時は１レコード前）</FunctionArgDesc ja_jp>*/
										, i_diff_of =
/*<FunctionArgDesc ja_jp>対数収益率変数名</FunctionArgDesc ja_jp>*/
										, i_diff_variable =
										);
	%local _diff_from;
	%local _diff_to;
	%if (%&RSUMacroVariable.IsBlank(i_diff_of)) %then %do;
		%let _diff_from = -1;
		%let _diff_to = 0;
	%end;
	%else %do;
		%let _diff_from = %scan(&i_diff_of., 1, :);
		%let _diff_to = %scan(&i_diff_of., 2, ;);
		%if (%&RSUMacroVariable.IsBlank(_diff_to)) %then %do;
			%let _diff_to = 0;
		%end;
	%end;
	data WORK.shift_weight;
		weight_index = &_diff_from.;
		weight = -1;
		output;
		weight_index = &_diff_to.;
		weight = 1;
		output;
	run;
	quit;
%mend RSUSeq__GenerateDiffVar;

/*<FunctionDesc ja_jp>変数の収益率を作成します</FunctionDesc ja_jp>*/
%macro RSUSeq__GenerateRatioVar(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
										iods_dataset =
/*<FunctionArgDesc ja_jp>対象変数</FunctionArgDesc ja_jp>*/
										, i_variable =
/*<FunctionArgDesc ja_jp>変数のグループ</FunctionArgDesc ja_jp>*/
										, i_variable_by =
/*<FunctionArgDesc ja_jp>収益率対象位置（``:''区切り、省略時は１レコード前）</FunctionArgDesc ja_jp>*/
										, i_log_return_of =
/*<FunctionArgDesc ja_jp>収益率変数名</FunctionArgDesc ja_jp>*/
										, i_ratio_variable =
										);
	data &iods_dataset.;
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
										, i_variables = &i_variable.(__log_value))
		__log_value = log(&i_variable.);
	run;
	quit;

	%local _diff_from;
	%local _diff_to;
	%if (%&RSUMacroVariable.IsBlank(i_diff_of)) %then %do;
		%let _diff_from = -1;
		%let _diff_to = 0;
	%end;
	%else %do;
		%let _diff_from = %scan(&i_diff_of., 1, :);
		%let _diff_to = %scan(&i_diff_of., 2, ;);
		%if (%&RSUMacroVariable.IsBlank(_diff_to)) %then %do;
			%let _diff_to = 0;
		%end;
	%end;
	data WORK.shift_weight;
		weight_index = &_diff_from.;
		weight = -1;
		output;
		weight_index = &_diff_to.;
		weight = 1;
		output;
	run;
	quit;

	data &iods_dataset.;
		set &iods_dataset.(drop = __log_value);
		i_ratio_variable = exp(&i_variable.) - 1;
	run;
	quit;
%mend RSUSeq__GenerateRatioVar;

/*<FunctionDesc ja_jp>変数の差分を作成します</FunctionDesc ja_jp>*/
%macro RSUSeq__GenerateLogReturnVar(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
												iods_dataset =
/*<FunctionArgDesc ja_jp>対象変数</FunctionArgDesc ja_jp>*/
												, i_variable =
/*<FunctionArgDesc ja_jp>変数のグループ</FunctionArgDesc ja_jp>*/
												, i_variable_by =
/*<FunctionArgDesc ja_jp>対数収益率対象位置（``:''区切り、省略時は１レコード前）</FunctionArgDesc ja_jp>*/
												, i_log_return_of =
/*<FunctionArgDesc ja_jp>対数収益率変数名</FunctionArgDesc ja_jp>*/
												, i_log_return_variable =
												);
	data &iods_dataset.;
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
										, i_variables = &i_variable.(__log_value))
		__log_value = log(&i_variable.);
	run;
	quit;

	%local _diff_from;
	%local _diff_to;
	%if (%&RSUMacroVariable.IsBlank(i_diff_of)) %then %do;
		%let _diff_from = -1;
		%let _diff_to = 0;
	%end;
	%else %do;
		%let _diff_from = %scan(&i_diff_of., 1, :);
		%let _diff_to = %scan(&i_diff_of., 2, ;);
		%if (%&RSUMacroVariable.IsBlank(_diff_to)) %then %do;
			%let _diff_to = 0;
		%end;
	%end;
	data WORK.shift_weight;
		weight_index = &_diff_from.;
		weight = -1;
		output;
		weight_index = &_diff_to.;
		weight = 1;
		output;
	run;
	quit;

	%&RSUDS.Let(i_query = &iods_dataset.(drop = __log_value)
					, ode_dest_ds = &iods_dataset.)
%mend RSUSeq__GenerateLogReturnVar;

/*<FunctionDesc ja_jp>中心化された変数を作成します</FunctionDesc ja_jp>*/
%macro RSUSeq__GenereateCenteredVar(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
												iods_dataset =
/*<FunctionArgDesc ja_jp>対象変数</FunctionArgDesc ja_jp>*/
												, i_variable =
/*<FunctionArgDesc ja_jp>変数のグループ</FunctionArgDesc ja_jp>*/
												, i_variable_by =
/*<FunctionArgDesc ja_jp>中心化された変数名</FunctionArgDesc ja_jp>*/
												, i_diff_variable =
												);
%mend RSUSeq__GenereateCenteredVar;

/*<FunctionDesc ja_jp>標準化された変数を作成します</FunctionDesc ja_jp>*/
%macro RSUSeq__GenerateStandardizedVar(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
													iods_dataset =
/*<FunctionArgDesc ja_jp>対象変数</FunctionArgDesc ja_jp>*/
													, i_variable =
/*<FunctionArgDesc ja_jp>変数のグループ</FunctionArgDesc ja_jp>*/
													, i_variable_by =
/*<FunctionArgDesc ja_jp>標準化された変数名</FunctionArgDesc ja_jp>*/
													, i_diff_variable =
													);
%mend RSUSeq__GenerateStandardizedVar;

/*<FunctionDesc ja_jp>差分を累積した変数を作成します</FunctionDesc ja_jp>*/
%macro RSUSeq__AccumurateDiff(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
										iods_dataset =
/*<FunctionArgDesc ja_jp>対象変数</FunctionArgDesc ja_jp>*/
										, i_variable =
/*<FunctionArgDesc ja_jp>変数のグループ</FunctionArgDesc ja_jp>*/
										, i_variable_by =
/*<FunctionArgDesc ja_jp>欠損値も値を埋めるか否か</FunctionArgDesc ja_jp>*/
										, i_is_null_as_zero =
/*<FunctionArgDesc ja_jp>累積された変数名</FunctionArgDesc ja_jp>*/
										, i_accum_variable =
										);
	data &iods_dataset.;
	%if (not %&RSUMacroVariable.IsBlank(i_variable_by)) %then %do;
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
										, i_variables = &i_variable_by.(__current_group))
	%end;									
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
										, i_variables = &i_variable.(__last_value))
		set &iods_dataset.;
		call missing(__current_group);
		call missing(__last_valid_value);
		if (&i_variable_by. ne __current_group) then do;
			&i_accum_variable. = 0;
			__current_group = &i_variable_by.;
			if (&i_is_null_as_zero.) then do;
				__last_valid_value = 0;
			end;
		end;
		if (not missing(&i_variable.)) then do;
			&i_accum_variable. = &i_accum_variable. + &i_variable.;
			__last_value = &i_accum_variable.;
		end;
		else do;
			if (&i_is_null_as_zero.) then do;
				&i_accum_variable. = __last_valid_value;
			end;
		end;
	run;
	quit;
%mend RSUSeq__AccumurateDiff;

/*<FunctionDesc ja_jp>収益率を累積した変数を作成します</FunctionDesc ja_jp>*/
%macro RSUSeq__AccumurateRatio(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
										iods_dataset =
/*<FunctionArgDesc ja_jp>対象変数</FunctionArgDesc ja_jp>*/
										, i_variable =
/*<FunctionArgDesc ja_jp>変数のグループ</FunctionArgDesc ja_jp>*/
										, i_variable_by =
/*<FunctionArgDesc ja_jp>欠損値も値を埋めるか否か</FunctionArgDesc ja_jp>*/
										, i_is_null_as_zero =
/*<FunctionArgDesc ja_jp>累積された変数名</FunctionArgDesc ja_jp>*/
										, i_accum_variable =
										);
	data &iods_dataset.;
	%if (not %&RSUMacroVariable.IsBlank(i_variable_by)) %then %do;
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
										, i_variables = &i_variable_by.(__current_group))
	%end;									
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
										, i_variables = &i_variable.(__last_value))
		set &iods_dataset.;
		call missing(__current_group);
		call missing(__last_valid_value);
		if (&i_variable_by. ne __current_group) then do;
			&i_accum_variable. = 1;
			__current_group = &i_variable_by.;
			if (&i_is_null_as_zero.) then do;
				__last_valid_value = 1;
			end;
		end;
		if (not missing(&i_variable.)) then do;
			&i_accum_variable. = &i_accum_variable. * (1 + &i_variable.);
			__last_value = &i_accum_variable.;
		end;
		else do;
			if (&i_is_null_as_zero.) then do;
				&i_accum_variable. = __last_valid_value;
			end;
		end;
	run;
	quit;
%mend RSUSeq__AccumurateRatio;

/*<FunctionDesc ja_jp>対数収益率を累積した変数を作成します</FunctionDesc ja_jp>*/
%macro RSUSeq__AccumurateLogReturn(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
												iods_dataset =
/*<FunctionArgDesc ja_jp>対象変数</FunctionArgDesc ja_jp>*/
												, i_variable =
/*<FunctionArgDesc ja_jp>変数のグループ</FunctionArgDesc ja_jp>*/
												, i_variable_by =
/*<FunctionArgDesc ja_jp>欠損値も値を埋めるか否か</FunctionArgDesc ja_jp>*/
												, i_is_null_as_zero =
/*<FunctionArgDesc ja_jp>累積された変数名</FunctionArgDesc ja_jp>*/
												, i_accum_variable =
												);
	data &iods_dataset.;
	%if (not %&RSUMacroVariable.IsBlank(i_variable_by)) %then %do;
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
										, i_variables = &i_variable_by.(__current_group))
	%end;									
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
										, i_variables = &i_variable.(__last_value))
		set &iods_dataset.;
		call missing(__current_group);
		call missing(__last_valid_value);
		if (&i_variable_by. ne __current_group) then do;
			&i_accum_variable. = 1;
			__current_group = &i_variable_by.;
			if (&i_is_null_as_zero.) then do;
				__last_valid_value = 1;
			end;
		end;
		if (not missing(&i_variable.)) then do;
			&i_accum_variable. = &i_accum_variable. * exp( &i_variable.);
			__last_value = &i_accum_variable.;
		end;
		else do;
			if (&i_is_null_as_zero.) then do;
				&i_accum_variable. = __last_valid_value;
			end;
		end;
	run;
	quit;
%mend RSUSeq__AccumurateLogReturn;

/*<FunctionDesc ja_jp>文字列を累積（連結）した変数を作成します</FunctionDesc ja_jp>*/
%macro RSUSeq__AccumurateChar(
/*<FunctionArgDesc ja_jp>データセット</FunctionArgDesc ja_jp>*/
										ids_dataset =
/*<FunctionArgDesc ja_jp>対象変数</FunctionArgDesc ja_jp>*/
										, i_variable =
/*<FunctionArgDesc ja_jp>変数のグループ</FunctionArgDesc ja_jp>*/
										, i_variable_by =
/*<FunctionArgDesc ja_jp>累積された変数名</FunctionArgDesc ja_jp>*/
										, i_accum_variable =
/*<FunctionArgDesc ja_jp>累積された変数の長さ</FunctionArgDesc ja_jp>*/
										, i_len_accum_variable =
/*<FunctionArgDesc ja_jp>連結時区切り文字列</FunctionArgDesc ja_jp>*/
										, i_delimiter =
/*<FunctionArgDesc ja_jp>出力データセット</FunctionArgDesc ja_jp>*/
										, ods_output =
										);
	data &ods_output.;
	%if (not %&RSUMacroVariable.IsBlank(i_variable_by)) %then %do;
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
										, i_variable = &i_variable_by.(__current_group))
	%end;
		attrib
			&i_accum_variable. length = &i_len_accum_variable.
		;
		set &iods_dataset. end = eof;
		call missing(__current_group);
		retain &i_accum_variable. '';
		if (&i_variable_by. ne __current_group) then do;
			if (not missing(__current_group)) then do;
				output;
			end;
			&i_accum_variable. = '';
			__current_group = &i_variable_by.;
		end;
		if (not missing(&i_variable.)) then do;
			&i_accum_variable. = catx("&i_delimiter.", &i_accum_variable., &i_variable.);
		end;
		if (eof) then do;
			if (not missing(__current_group)) then do;
				output;
			end;
		end;
	run;
	quit;
%mend RSUSeq__AccumurateChar;