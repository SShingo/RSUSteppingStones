%macro Int_RSUText_EncloseText(i_text =
										, i_enclosure =);
	%if (&i_enclosure. = %&RSUEnclosure.Wave) %then %do;
		%let __item_value = %sysfunc(EncloseWave(&i_text.));
	%end;
	%else %if (&i_enclosure. = %&RSUEnclosure.Round) %then %do;
		%let __item_value = %sysfunc(EncloseRound(&i_text.));
	%end;
	%else %if (&i_enclosure. = %&RSUEnclosure.Square) %then %do;
		%let __item_value = %sysfunc(EncloseSquare(&i_text.));
	%end;
	%else %if (&i_enclosure. = %&RSUEnclosure.Wedge) %then %do;
		%let __item_value = %sysfunc(EncloseWedge(&i_text.));
	%end;
	%else %if (&i_enclosure. = %&RSUEnclosure.Quote) %then %do;
		%let __item_value = %sysfunc(EncloseQuote(&i_text.));
	%end;
	%else %if (&i_enclosure. = %&RSUEnclosure.DQuote) %then %do;
		%let __item_value = %sysfunc(EncloseDQuote(&i_text.));
	%end;
	%else %if (&i_enclosure. = %&RSUEnclosure.Grave) %then %do;
		%let __item_value = %sysfunc(EncloseGrave(&i_text.));
	%end;
	&i_text.
%mend Int_RSUText_EncloseText;