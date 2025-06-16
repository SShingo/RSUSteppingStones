%macro Int_RSULib_GetTempLibName();
	%&RSUUtil.GetSequenceId(i_prefix = RL
									, iovar_sequence = RSU_g_sequence_library
									, i_digit = 5)
%mend Int_RSULib_GetTempLibName;
