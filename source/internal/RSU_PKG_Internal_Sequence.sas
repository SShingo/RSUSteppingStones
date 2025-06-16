%macro Prv_RSUSeq__CalcSumProd(iods_dataset =
										, i_variable =
										, i_variable_by =
										, i_weighted_variable =
										, i_no_of_weighted_record_variable =
										, ids_weights =);
	%&RSUUtil.VerifyRequiredArgs(i_args = iods_dataset i_variable i_weighted_variable i_no_of_weighted_record_variable ids_weights)
	%local /readonly _VARIABLE_NAME_NO_REC = %&RSUUtil.Choose(%&RSUMacroVariable.IsBlank(i_no_of_weighted_record_variable), __dummy_no_of_rec, &i_no_of_weighted_record_variable.);
	%&RSUDS.AddSequenceVariable(i_query = &iods_dataset.
										, i_sequence_variable_name = __tmp_key)
	data &iods_dataset.;
	%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
									, i_variables = &i_variable.(&i_weighted_variable.))
		attrib
			&_VARIABLE_NAME_NO_REC. length = 8.
		;
		set &iods_dataset.;
	run;
	quit;

	%local _series_group_variable;
	%local _drop_code;
	%if (%&RSUMacroVariable.IsBlank(i_variable_by)) %then %do;
		%&RSUDS.AddConstantVariable(iods_dataset = &iods_dataset.
											, i_variable_name = __dummy_series_group_id
											, i_variable_len = 3.
											, i_variable_value = 1)
		%let _series_group_variable = __dummy_series_group_id;
		%let _drop_code = __tmp_key __dummy_series_group_id;
	%end;
	%else %do;
		%let _series_group_variable = &i_variable_by.;
		%let _drop_code = __tmp_key;
	%end;
	
	%local /readonly _TMP_DS_OUTPUT = %&RSUDS.GetTempDSName(output);

	%local _weight_index_min;
	%local _weight_index_max;
	proc sql noprint;
		select
			min(weight_index)
			, max(weight_index) into :_weight_index_min, :_weight_index_max
		from
			&ids_weights.
		;
	quit;

	%local _max_index;
	proc sql noprint;
		select
			max(__tmp_key) into :_max_index
		from
			&iods_dataset.
		;
	run;
	quit;

	data _null_;
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.
										, i_variables = &_series_group_variable.(__current_group))
		%&RSUDS.GetVariableAttr(ids_dataset = &iods_dataset.)
		if (0) then do;
			set &ids_weights.;
		end;
		declare hash h_weights(dataset: "&ids_weights.");
		h_weights.definekey('weight_index');
		h_weights.definedata('weight_index');
		h_weights.definedata('weight');
		h_weights.definedone();
		declare hiter hi_weights('h_weights');

		declare hash h_in(dataset: "&iods_dataset.", ordered: 'yes');
		h_in.definekey('__tmp_key');
		h_in.definedata(all: 'yes');
		h_in.definedone();
		declare hiter hi_in('h_in');
		
		call missing(weight_index);
		__rc = hi_in.first();
		do while(__rc = 0);
			__current_index = __tmp_key;
			__current_group = &_series_group_variable.;
			__tmp_weighted_value = 0;
			__tmp_no_of_weighted_record = 0;
			__rc_weight = hi_weights.first();
			do while(__rc_weight = 0);
				if (0 <= __current_index + weight_index and __current_index + weight_index <= &_max_index.) then do;
					hi_in.setcur(key: __current_index + weight_index);
					if (&_series_group_variable. = __current_group and not missing(&i_variable.)) then do;
						__tmp_weighted_value = __tmp_weighted_value + (&i_variable. * weight);
						__tmp_no_of_weighted_record = __tmp_no_of_weighted_record + 1;
					end;
				end;
				__rc_weight = hi_weights.next();
			end;
			hi_in.setcur(key: __current_index);
			&i_weighted_variable. = __tmp_weighted_value;
			&_VARIABLE_NAME_NO_REC. = __tmp_no_of_weighted_record;
			h_in.replace();
			__rc = hi_in.next();
		end;
		__rc = h_in.output(dataset: "&_TMP_DS_OUTPUT.(drop = &_drop_code.)");
	run;
	quit;
	%&RSUDS.Move(i_query = &_TMP_DS_OUTPUT.
					, ods_dest_ds = &iods_dataset.)
%mend Prv_RSUSeq__CalcSumProd;