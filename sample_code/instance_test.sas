%rsu_steppingstones_activate_test(i_version = 300)
%&RSUDebug.Disable
%put %&RSUMsg.Test;

%macro test();
	%local /readonly _COUNTER = %&RSUCounter.Create(i_step = 1
																	, i_div = 3);

	%local /readonly _TIMER = %&RSUTimer.Create();
	
	%local /readonly _DS_ITERATOR = %&RSUDS.CreateIterator(i_query = SASHELP.class);
	%put %&_DS_ITERATOR.QueryString();
	%do %while(%&_DS_ITERATOR.Next());
		%put COUNT: %&_COUNTER.Draw();
		%put %&_DS_ITERATOR.Current(Name);
	%end;
	%&_TIMER.Lap()
	%&RSUClass.Dispose(_DS_ITERATOR)
	%&RSUClass.Dispose(_COUNTER)

	%local /readonly _FILE_READER = %&RSUFile.CreateTextReader(i_file_path = /tmp/test.txt);
	%do %while(%&_FILE_READER.Next());
		%put %&_FILE_READER.Current();
	%end;
	%&RSUClass.Dispose(_FILE_READER)
	
	%local /readonly _FILE_WRITER = %&RSUFile.CreateTextWriter(i_file_path = /tmp/writer.txt);
	%local /readonly _PROGRESS_BAR = %&RSUCounter.CreateProgressBar(i_max_count = 313);
	%local _pgb;
	%do i = 1 %to 313;
		%if (%&_PROGRESS_BAR.Progress(i_count = &i.)) %then %do;
			%let _pgb = %&_PROGRESS_BAR.GetProgressBar();
			%put &_pgb.;
			%&_FILE_WRITER.PutLine(&_pgb)
		%end;
	%end;
	%&RSUClass.Dispose(_PROGRESS_BAR)
	%&RSUClass.Dispose(_FILE_WRITER)
	
	%local /readonly _REGEX = %&RSURegex.CreateCaptureIterator(i_regex_expression = /\d{3}/
																				, i_text = 1234-234-0382-31-3124);
	%do %while(%&_REGEX.Next());
		%put %&_REGEX.Current();
	%end;
	%&RSUClass.Dispose(_REGEX)
	
	%&RSUClass.Dispose(_TIMER)
%mend;

%test();