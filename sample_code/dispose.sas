%macro Dispose(i_global_macro_variable_body =);
	%local /readonly _DS_ITER_MACRO_VARS = %RSUDSIter__Create(SASHELP.vmacro(where = (name like "&i_global_macro_variable_body._%") keep = name));
	%local _macro_name;
	%do %while(%RSUDSIter__Next(_DS_ITER_MACRO_VARS));
		%symdel %RSUDSIter__Current(_DS_ITER_MACRO_VARS[name]);
	%end;
	%&RSUDS.Delete(&_TMP_DS_MACRO_VARIABLES.)
%mend Dispose;