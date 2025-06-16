%macro Prv_RSULogger_SetOpion(i_option =
										, i_is_enable =);
	%local _pre;
	%if (&i_is_enable. = 0) %then %do;								 
		%let _pre = no; 
	%end; 
	%put &RSU_G_MSG_INDENT_PLANE.%&RSUMsg.SET_SYSTEM_OPTION(&_pre.&i_option.);
	options &_pre.&i_option.;
%mend;

%macro Prv_RSULogger_PutMultLine(i_msg =
											, i_header =);
	%local _line;
	%local _index_line;
	%do %while(%&RSUUtil.ForEach(i_items = %nrbquote(&i_msg.), ovar_item = _line, iovar_index = _index_line, i_delimiter = %str(,)));
		%let _line = %sysfunc(tranwrd(&_line., &RSULogComma., %str(,)));
		%put &i_header.&_line.;
	%end;
%mend Prv_RSULogger_PutMultLine;

%macro Prv_RSULogger_GetHierLine(i_depth_adj =);
	%local _hier_line;
	%if (&RSU_g_log_conf_show_macro.) %then %do;
		%do _depth = 0 %to &RSU_g_current_macro_depth. - &i_depth_adj.;
			%let _hier_line = &_hier_line.%str(| );
		%end;
	%end;
	&_hier_line.
%mend Prv_RSULogger_GetHierLine;

%macro Prv_RSULogger_OutputMsg(i_msg =
										, i_msg_header_key =
										, i_log_type =);
	%local _header;
	%let _header = %sysfunc(sasmsg(L_RSUMDL.&RSU_G_MESSAGE_DS., &i_msg_header_key., noquote));
	%put &i_log_type.%Prv_RSULogger_GetHierLine(i_depth_adj = 0)&_header. (%&RSUTimer.GetNow) &i_msg.;
%mend Prv_RSULogger_OutputMsg;

%macro Prv_RSULogger_GetDelimiterLine(i_msg =
												, i_char =
												, i_buffer_length = 2
												, ovar_delimiter_line =);
	%local _byte_count;
	%local _byte_count_max;
	%local _letter_count;
	%local _letter_count_max;
	%let _byte_count_max = 0;
	%let _letter_count_max = 0;
	%local _line;
	%local _index_line;
	%do %while(%&RSUUtil.ForEach(i_items = %nrbquote(&i_msg.)
											, ovar_item = _line
											, iovar_index = _index_line
											, i_delimiter = %str(,)));
		%let _line = %sysfunc(tranwrd(&_line., &RSULogComma., %str(,)));
		%let _byte_count = %length(&_line.);
		%if (&_byte_count_max. < &_byte_count.) %then %do;
			%let _byte_count_max = &_byte_count.;
		%end;
		%let _letter_count = %klength(&_line.);
		%if (&_letter_count_max. < &_letter_count.) %then %do;
			%let _letter_count_max = &_letter_count.;
		%end;
	%end;
	%local /readonly _LINE_LENGTH = %eval(&_byte_count_max. - (&_byte_count_max. - &_letter_count_max.) / 2 + &i_buffer_length.);
	%local _line_length_count;
	%do _line_length_count = 1 %to &_LINE_LENGTH.;
		%let &ovar_delimiter_line. = &&&ovar_delimiter_line.&i_char.;
	%end;
%mend Prv_RSULogger_GetDelimiterLine;

%macro Int_RSULogger_PutTerminate;
	%put ERROR- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;
	%put ERROR- &RSU_G_MSG_INDENT_PLANE.%&RSUMsg.CRITICAL_ERROR;
	%put ERROR- &RSU_G_MSG_INDENT_PLANE.%&RSUDebug.GetBreadcrumbs.;
	%put ERROR- &RSU_G_MSG_INDENT_PLANE.%&RSUMsg.SESSION_CLOSED;
	%put ERROR- &RSU_G_MSG_INDENT_PLANE.%&RSUMsg.BYE;
	%put ERROR- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<;
%mend Int_RSULogger_PutTerminate;

%macro Int_RSULogger_PutAbort;
	%put ERROR- ***************************************************************************;
	%put ERROR- &RSU_G_MSG_INDENT_PLANE.%&RSUMsg.EMERGENCY_STOP;
	%put ERROR- &RSU_G_MSG_INDENT_PLANE.%&RSUDebug.GetBreadcrumbs.;
	%put ERROR- ***************************************************************************;
%mend Int_RSULogger_PutAbort;
