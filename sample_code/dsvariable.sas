%macro RSUDSVar__Find();
%mend RSUDSVar__Find;
%macro RSUDSVar__Add();
%mend RSUDSVar__Add;
%macro RSUDSVar__Drop();
%mend RSUDSVar__Drop;
%macro RSUDSVar__HasCommonVars();
%mend RSUDSVar__HasCommonVars;
%macro RSUDSVar__RetrieveColumns();
%mend RSUDSVar__RetrieveColumns;
%macro RSUDSVar__Find();
%mend RSUDSVar__Find;
%macro RSUDSVar__RetrieveAttrCode(ids_dataset =
											, i_variables =
											, ovar_attribute_code =);
	data _null_;
		attrib
			%&RSUDSVar.RetrieveAttrCode()
			_attrib_code length = $5000.
			_attrib_code_var length = 200.
		;
		set SASHELP.vcolumn(where = (libname = "" and memname = ""));
		retain _attrib_code;
		_name
		_length
		_label
		_format
		_attrib_code_var = catx(' ', _name, _length, _label, _format);
		_attrib_code = catx(' ', _attrib_code, _attrib_code_var);
		if (eof) then do;
			call symputx("&ovar_attribute_code.", _attrib_code);
		end;
	run;
	quit;
%mend RSUDSVar__RetrieveAttrCode;
