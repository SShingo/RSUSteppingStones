/***********************************************************************************
* PROGRAM NAME : RSU_PKG_FCMP.sas
* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
* DESCRIPTION : Collection of fcmp functions
* PROGRAMMER : Shingo Suzuki (RSU SAS Institute Japan)
* DATE WRITTEN : 2021/2/12
************************************************************************************/
options cmplib = ();

%macro RSUFCMPCompile();
	proc fcmp encrypt outlib = L_RSUMDL.&RSU_G_FCMP_PACKAGE..ds;
		function RSU_fcmp_get_curr_by_num(i_dsid, i_varnum) $;
			_vartype = vartype(i_dsid, i_varnum);
			length val $1000;
			if (upcase(_vartype) = 'C') then do;
				val = getvarc(i_dsid, i_varnum);
			end;
			else do;
				length _varfmt $49;
				_varfmt = varfmt(i_dsid, i_varnum);
				if (lengthn(compress(_varfmt)) = 0) then do;
					_varfmt = 'best.';
				end;
				_valn = getvarn(i_dsid, i_varnum);
				val = compress(putn(_valn, _varfmt));
			end;
			return (val);
		endsub;

		function fcmp_rsu_ds_get_curr_by_name(i_dsid, i_varname $) $;
			_varnum = varnum(i_dsid, i_varname);
			length _val $1000;
			if (_varnum = 0) then do;
				_rc = close(i_dsid);
				put 'Get variable number from name failed. Undefined variable name(' i_varname '). DataSet is closed.';
				_val = 'FAILED!!';
			end;
			else do;
				_val = RSU_fcmp_get_curr_by_num(i_dsid, _varnum);
			end;
			return (_val);
		endsub;

		function fcmp_rsu_ds_get_curr_n(i_dsid, i_varnum) $;
			length _varfmt $49;
			_varfmt = varfmt(i_dsid, i_varnum);
			if (lengthn(compress(_varfmt)) = 0) then do;
				_varfmt = 'best.';
			end;
			_valn = getvarn(i_dsid, i_varnum);
			val = compress(putn(_valn, _varfmt));
			return (val);
		endsub;

		function fcmp_rsu_ds_get_curr_c(i_dsid, i_varnum) $;
			length val $5000;
			val = trim(getvarc(i_dsid, i_varnum));
			return (val);
		endsub;

	run;
	quit;

	proc fcmp encrypt outlib = L_RSUMDL.&RSU_G_FCMP_PACKAGE..class;
		subroutine RSU_fcmp_write_class_def_file(i_fid, i_in_dsid, i_macro_tmp_file_name $, i_instance_name $);
			_rc = fput(i_fid, cat('%macro ', i_macro_tmp_file_name , ";"));
			_rc = fwrite(i_fid);
			length _code $1000;
			do while(fetch(i_in_dsid) = 0);
				_code = getvarc(i_in_dsid, 3);
				_code = prxchange(cats('s/<instance>/', i_instance_name, '/'), -1, _code);
				_rc = fput(i_fid, trim(_code));
				_rc = fwrite(i_fid);
			end;
			_rc = fput(i_fid, '%mend;');
			_rc = fwrite(i_fid);
		endsub;

		subroutine RSU_fcmp_instantiate(ids_source_code $, i_class_name $, i_instance_name $);
			length _code $3000;
			_dsid = open(cats(ids_source_code, "(where = (name = '", i_class_name, "'))"), 'I');
			_rc = fetch(_dsid);
			do while(_rc = 0);
				_code = tranwrd(getvarc(_dsid, 3), '<instance>', i_instance_name);
				call execute(_code);
				_rc = fetch(_dsid);
			end;
			_rc = close(_dsid);
		endsub;
	run;
	quit;

	proc fcmp encrypt outlib = L_RSUMDL.&RSU_G_FCMP_PACKAGE..utility;
		function RSU_fcmp_get_sequence(i_value, i_base, i_digits) $;
			length _nbased_value $100;
			array _ar_char[36] $;
			_ar_char[1] = '0';
			_ar_char[2] = '1';
			_ar_char[3] = '2';
			_ar_char[4] = '3';
			_ar_char[5] = '4';
			_ar_char[6] = '5';
			_ar_char[7] = '6';
			_ar_char[8] = '7';
			_ar_char[9] = '8';
			_ar_char[10] = '9';
			_ar_char[11] = 'A';
			_ar_char[12] = 'B';
			_ar_char[13] = 'C';
			_ar_char[14] = 'D';
			_ar_char[15] = 'E';
			_ar_char[16] = 'F';
			_ar_char[17] = 'G';
			_ar_char[18] = 'H';
			_ar_char[19] = 'I';
			_ar_char[20] = 'J';
			_ar_char[21] = 'K';
			_ar_char[22] = 'L';
			_ar_char[23] = 'M';
			_ar_char[24] = 'N';
			_ar_char[25] = 'O';
			_ar_char[26] = 'P';
			_ar_char[27] = 'Q';
			_ar_char[28] = 'R';
			_ar_char[29] = 'S';
			_ar_char[30] = 'T';
			_ar_char[31] = 'U';
			_ar_char[32] = 'V';
			_ar_char[33] = 'W';
			_ar_char[34] = 'X';
			_ar_char[35] = 'Y';
			_ar_char[36] = 'Z';
			q = i_value;
			_nbased_value = '';
			do while(i_base <= q);
				m = mod(q, i_base);
				q = int(q / i_base);
				_nbased_value = cats(_ar_char[m + 1], _nbased_value);
			end;  
			_nbased_value = cats(_ar_char[q + 1], _nbased_value);

			if (0 < i_digits) then do;
				do while(lengthn(_nbased_value) < i_digits);
					_nbased_value = cats('0', _nbased_value);
				end;
				if (i_digits <= lengthn(_nbased_value)) then do;
					_nbased_value = substr(_nbased_value, lengthn(_nbased_value) - i_digits + 1, i_digits);
				end;
			end;

			return (_nbased_value);
		endsub;

		function RSU_fcmp_get_excel_column(i_value) $;
			length _nbased_value $100;
			q = i_value;
			do while(0 < q);
				m = mod(q - 1, 26);
				q = int((q - 1) / 26);
				_nbased_value = cats(byte(65 + m), _nbased_value);
			end;  

			return (_nbased_value);
		endsub;
		
		function RSU_fcmp_get_excel_col_no(i_column $);
			len = length(i_column);
			col = 0;
			unit = 1;
			do index = len to 1 by -1;
				d = rank(substr(upcase(i_column), index, 1)) - rank('A') + 1;
				col = col + unit * d;
				unit = unit * 26;
			end;
			return (col);
		endsub;

		function RSU_fcmp_yyyymmdd2date(i_yyyymmdd $);
			length _date 8;
			_date = input(i_yyyymmdd, yymmdd8.);
			return (_date);
		endsub;

		function RSU_fcmp_yyyymmdd2year(i_yyyymmdd $);
			length _year 8;
			_year = year(RSU_fcmp_yyyymmdd2date(i_yyyymmdd));
			return (_year);
		endsub;

		function RSU_fcmp_yyyymmdd2month(i_yyyymmdd $);
			length _month 8;
			_month = month(RSU_fcmp_yyyymmdd2date(i_yyyymmdd));
			return (_month);
		endsub;

		function RSU_fcmp_yyyymmdd2day(i_yyyymmdd $);
			length _day 8;
			_day = day(RSU_fcmp_yyyymmdd2date(i_yyyymmdd));
			return (_day);
		endsub;

		function RSU_fcmp_yyyymmdd2weekday(i_yyyymmdd $);
			length _weekday 8;
			_weekday = weekday(RSU_fcmp_yyyymmdd2date(i_yyyymmdd));
			return (_weekday);
		endsub;

		function RSU_fcmp_yyyymmdds2date(i_yyyymmdds $);
			length _date 8;
			_date = input(i_yyyymmdds, yymmdd10.);
			return (_date);
		endsub;

		function RSU_fcmp_yyyymmdds2year(i_yyyymmdds $);
			length _year 8;
			_year = year(RSU_fcmp_yyyymmdds2date(i_yyyymmdds));
			return (_year);
		endsub;

		function RSU_fcmp_yyyymmdds2month(i_yyyymmdds $);
			length _month 8;
			_month = month(RSU_fcmp_yyyymmdds2date(i_yyyymmdds));
			return (_month);
		endsub;

		function RSU_fcmp_yyyymmdds2day(i_yyyymmdds $);
			length _day 8;
			_day = day(RSU_fcmp_yyyymmdds2date(i_yyyymmdds));
			return (_day);
		endsub;

		function RSU_fcmp_yyyymmdds2weekday(i_yyyymmdds $);
			length _weekday 8;
			_weekday = weekday(RSU_fcmp_yyyymmdds2date(i_yyyysmmdd));
			return (_weekday);
		endsub;

		function RSU_fcmp_date2yyyymmdd(i_date) $;
			length _yyyymmdd $8;
			_yyyymmdd = put(i_date, yymmddn8.);
			return (_yyyymmdd);
		endsub;

		function RSU_fcmp_date2yyyymmdds(i_date) $;
			length _yyyymmdds $10;
			_yyyymmdds = put(i_date, yymmdds10.);
			return (_yyyymmdds);
		endsub;

		function RSU_fcmp_get_weekdaystr(i_weekday
													, i_locale $
													, i_is_full) $;
			length _fmt $50;
			length _len $10;
			length _weekday_str $6;
			if (i_is_full) then do;
				_len = 'full';
			end;
			else do;
				_len = 'short';
			end;
			_fmt = cats('RSU_fmt_weekday_', i_locale, '_', _len);

			_weekday_str = putn(i_weekday, _fmt);
			return (_weekday_str);
		endsub;

		function RSU_fcmp_get_weekdaynum(i_weekday_str
													, i_locale $
													, i_is_full) $;
			length _fmt $50;
			length _len $10;
			length _weekday_num 8;
			if (i_is_full) then do;
				_len = 'full';
			end;
			else do;
				_len = 'short';
			end;
			_fmt = cats('RSU_fmt_inv_weekday_', i_locale, '_', _len);

			_weekday_num = input(putc(i_weekday_str, _fmt), best.);
			return (_weekday_num);
		endsub;
	run;
	quit;

	/* ! マクロ変数の操作では " をうまく扱えないので、fcmpで処理 */
	proc fcmp encrypt outlib = L_RSUMDL.&RSU_G_FCMP_PACKAGE..text;
		function RSU_fcmp_get_array_text(i_array_string $, i_delimiter $, i_is_quoted $) $;
			length _output_string $5000;
			length _quote_string $1;
			if (i_is_quoted = '1') then do;
				_quote_string = '"';
			end;
			else do;
				_quote_string = '';
			end;

			if (lengthn(i_array_string) = 2) then do;
				_output_string = '';
			end;
			else do;
				_output_string = substr(i_array_string, 2, klength(i_array_string) - 2);
				_output_string = transtrn(_output_string, '``', cat(compress(_quote_string), i_delimiter, compress(_quote_string)));
			end;
			_output_string = trim(cat(_quote_string, trim(_output_string), _quote_string));
			return (trim(_output_string));
		endsub;

		function GetLeftAlignedFormat(i_format $) $;
			length _format $10;
			if (missing(i_format)) then do;
				_format = 'BEST.';
			end;
			else do;
				_format = i_format;
			end;
			_format = cats(_format, '-L');
			return (_format);	
		endsub;

		function EncloseNone(i_string $) $ 30000;
			return (i_string);
		endsub;

		function EncloseWave(i_string $) $ 30000;
			return (cats('{', i_string, '}'));
		endsub;

		function EncloseWaveN(i_number, i_format $) $ 30000;
			length _format $10;
			_format = GetLeftAlignedFormat(i_format);
			return (EncloseWave(putn(i_number, _format)));
		endsub;

		function EncloseRound(i_string $) $ 30000;
			return (cats('(', i_string, ')'));
		endsub;

		function EncloseRoundN(i_number, i_format $) $ 30000;
			length _format $10;
			_format = GetLeftAlignedFormat(i_format);
			return (EncloseRound(putn(i_number, _format)));
		endsub;

		function EncloseSquare(i_string $) $ 30000;
			return (cats('[', i_string, ']'));
		endsub;

		function EncloseSquareN(i_number, i_format $) $ 30000;
			length _format $10;
			_format = GetLeftAlignedFormat(i_format);
			return (EncloseSquare(putn(i_number, _format)));
		endsub;

		function EncloseWedge(i_string $) $ 30000;
			return (cats('<', i_string, '>'));
		endsub;

		function EncloseWedgeN(i_number, i_format $) $ 30000;
			length _format $10;
			_format = GetLeftAlignedFormat(i_format);
			return (EncloseWedge(putn(i_number, _format)));
		endsub;

		function EncloseQuote(i_string $) $;
			return (cats("'", i_string, "'"));
		endsub;

		function EncloseQuoteN(i_number, i_format $) $ 30000;
			length _format $10;
			_format = GetLeftAlignedFormat(i_format);
			return (EncloseQuote(putn(i_number, _format)));
		endsub;

		function EncloseDQuote(i_string $) $ 30000;
			return (cats('"', i_string, '"'));
		endsub;

		function EncloseDQuoteN(i_number, i_format $) $ 30000;
			length _format $10;
			_format = GetLeftAlignedFormat(i_format);
			return (EncloseDQuote(putn(i_number, _format)));
		endsub;

		function EncloseGrave(i_string $) $ 30000;
			return (cats('`', i_string, '`'));
		endsub;

		function EncloseGraveN(i_number, i_format $) $ 30000;
			length _format $10;
			_format = GetLeftAlignedFormat(i_format);
			return (EncloseGrave(putn(i_number, _format)));
		endsub;

		function RemoveEnclosure(i_string $) $ 30000;
			_regex_enclosure_round = prxparse('/^\((.+)\)$/');
			_regex_enclosure_squre = prxparse('/^\[(.+)\]$/');
			_regex_enclosure_wave = prxparse('/^{(.+)}$/');
			_regex_enclosure_quote = prxparse("/^'(.+)'$/");
			_regex_enclosure_dquote = prxparse('/^"(.+)"$/');
			_regex_enclosure_grave = prxparse('/^`(.+)`$/');
			length _result $30000;
			if (prxmatch(_regex_enclosure_round, trim(i_string))) then do;
				_result = prxposn(_regex_enclosure_round, 1, trim(i_string));
			end;
			else if (prxmatch(_regex_enclosure_squre, trim(i_string))) then do;
				_result = prxposn(_regex_enclosure_squre, 1, trim(i_string));
			end;
			else if (prxmatch(_regex_enclosure_wave, trim(i_string))) then do;
				_result = prxposn(_regex_enclosure_wave, 1, trim(i_string));
			end;
			else if (prxmatch(_regex_enclosure_quote, trim(i_string))) then do;
				_result = prxposn(_regex_enclosure_quote, 1, trim(i_string));
			end;
			else if (prxmatch(_regex_enclosure_dquote, trim(i_string))) then do;
				_result = prxposn(_regex_enclosure_dquote, 1, trim(i_string));
			end;
			else if (prxmatch(_regex_enclosure_grave, trim(i_string))) then do;
				_result = prxposn(_regex_enclosure_grave, 1, trim(i_string));
			end;
			else do;
				_result = i_string;
			end;
			call prxfree(_regex_enclosure_round);
			call prxfree(_regex_enclosure_squre);
			call prxfree(_regex_enclosure_wave);
			call prxfree(_regex_enclosure_quote);
			call prxfree(_regex_enclosure_dquote);
			call prxfree(_regex_enclosure_grave);
			return (_result);
		endsub;
	run;
	quit;

	proc fcmp encrypt outlib = L_RSUMDL.&RSU_G_FCMP_PACKAGE..file;
		function RSU_fcmp_get_line(i_fid) $;
			length _rc 8; 
			length _line $5000;
			_rc = fread(i_fid);
			_rc = fget(i_fid, _line);
			return (trim(_line));
		endsub;
	run;
	quit;
%mend RSUFCMPCompile;