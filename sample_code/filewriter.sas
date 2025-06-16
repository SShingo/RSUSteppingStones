%rsu_steppingstones_activate()
%global RSU_g_sequence_file_writer;
%let RSU_g_sequence_file_writer = 0;

%macro FileWriter__Create(i_file_path =
								, i_is_append = %&RSUBool.False);
	%if (&i_is_append.) %then %do;
		%&RSUFile.VerifyExists(&i_file_path.)
	%end;
	%local /readonly _FWRITER_ID = %&RSUUtil.GetSequenceId(i_prefix = &RSU_G_GLOBAL_INSTANCE_PREFIX._FW_
																			, iovar_sequence = RSU_g_sequence_file_writer
																			, i_digit = 4);
	%global &_FWRITER_ID._fref;
	%let &_FWRITER_ID._fref = %&RSUFile.GetFileRef(&i_file_path.);
	%global &_FWRITER_ID._fid;
	%let &_FWRITER_ID._fid = %Int_RSUUtil_VerifyID(i_id = %sysfunc(fopen(&&&_FWRITER_ID._fref., %&RSUUtil.Choose(&i_is_append., a, o), 0)));
	&_FWRITER_ID.
%mend FileWriter__Create;

%macro FileWriter__Dispose(ivar_filewriter);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_filewriter)
	%local /readonly _FWRITER_ID_DISPOSE = &&&ivar_filewriter.;
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(fclose(&&&_FWRITER_ID_DISPOSE._fid.)))
	%&RSUFile.ClearFileRef(&_FWRITER_ID_DISPOSE._fref)
	%&RSUMacroVariable.Delete(i_regex = /^&_FWRITER_ID_DISPOSE._/i)
%mend FileWriter__Dispose;

%macro FileWriter__PutLine(ivar_filewriter
									, i_line);
	%&RSUUtil.VerifyRequiredArgs(i_args = ivar_filewriter)
	%local /readonly _FWRITER_ID_PUTLINE = &&&ivar_filewriter.;
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(fput(&&&_FWRITER_ID_PUTLINE._fid., &i_line.)))
	%Int_RSUUtil_VerifyRC(i_rc = %sysfunc(fwrite(&&&_FWRITER_ID_PUTLINE._fid., +)))
%mend FileWriter__PutLine;

%macro test();
	%local /readonly _FILE_WRITER = %FileWriter__Create(i_file_path = /tmp/test.txt);
	%FileWriter__PutLine(_FILE_WRITER, this is test)
	%FileWriter__Dispose(_FILE_WRITER)
%mend test;
%test