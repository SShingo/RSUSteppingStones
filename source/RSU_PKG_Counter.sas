/***********************************************************************************/
/* PROGRAM NAME : RSU_PKG_Counter.sas
/* AUTHOR : Shingo Suzuki (RSU SAS Institute Japan, shingo.suzuki@sas.com)
/* DATE WRITTEN : 2021/3/14
/*
/* NOTE: $a_i = \text{mod}\left(\lfloor\frac{b\cdot i}{d}\rfloor + a,\;m\right) + c.$
/************************************************************************************/
/*<PackageID>RSUCounter</PackageID>*/
/*<CategoryID>Cate_Misc</CategoryID>*/
/*<PackagePurpose ja_jp>自動インクリメントカウンター</PackagePurpose ja_jp>*/
/*<PackagePurpose en_us>Auto incremental counter</PackagePurpose en_us>*/
/*<PackageDesc ja_jp>等差数列に基づく数列を返す Counter 関連マクロ関数を提供するパッケージ</PackageDesc ja_jp>*/
/*<PackageDesc en_us>Collection of macro functions for counter</PackageDesc en_us>*/
/*<PkgDetail ja_jp>
等差数列に基づく整数列を生成します。
生成数列は下記で定義されます。
\begin{equation}
a_i = \text{mod}\left(\lfloor\frac{b\cdot i}{d}\rfloor + a,\;m\right) + c.
\end{equation}
</PkgDetail ja_jp>*/
/*<ConstantDesc ja_jp>配列パッケージ Prefix</ConstantDesc ja_jp>*/
%RSUSetConstant(RSUCounter, RSUCounter__)
/*<ConstantDesc ja_jp>カウンタークラス定義ファイル名</ConstantDesc ja_jp>*/
%RSUSetConstant(RSU_G_CLASS_FILE_COUNTER, RSU_PKG_Class_Counter)
/*<ConstantDesc ja_jp>プログレスバークラス定義ファイル</ConstantDesc ja_jp>*/
%RSUSetConstant(RSU_G_CLASS_FILE_PROGRESS_BAR, RSU_PKG_Class_ProgressBar)

/*<FunctionDesc ja_jp>数列を生成し、数列を1項進めます。 $a_i = \text{mod}\left(\left\lfloor\frac{b\cdot i}{d}\right\rfloor + a,\;m\right) + c.$ </FunctionDesc ja_jp>*/
/*<FunctionReturn ja_jp>数列の現在値</FunctionReturn ja_jp>*/
%macro RSUCounter__Draw(
/*<FunctionArgDesc ja_jp>初期値$a$</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Initial value of counter$a$</FunctionArgDesc en_us>*/
								i_start = 1
/*<FunctionArgDesc ja_jp>増加幅$b$</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Step width of each step$b$</FunctionArgDesc en_us>*/
								, i_step = 1
/*<FunctionArgDesc ja_jp>法$m$</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Modulus$m$</FunctionArgDesc en_us>*/
								, i_mod = 1
/*<FunctionArgDesc ja_jp>除数$d$</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Divisor$d$</FunctionArgDesc en_us>*/
								, i_div = 1
/*<FunctionArgDesc ja_jp>切片$c$</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>Intercept$c$</FunctionArgDesc en_us>*/
								, i_intercept = 0
/*<FunctionArgDesc ja_jp>表示桁数（0埋め）</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>No. of digit for displaying</FunctionArgDesc en_us>*/
								, i_digit =
/*<FunctionArgDesc ja_jp>カウンター番号の前に表示する文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>text followed by the number</FunctionArgDesc en_us>*/
								, i_prefix =
/*<FunctionArgDesc ja_jp>カウンター番号の後ろに表示する文字列</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>text follows the number</FunctionArgDesc en_us>*/
								, i_suffix =
/*<FunctionArgDesc ja_jp>インデックス最大値 </FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>max number of the index</FunctionArgDesc en_us>*/
								, i_max_index =
/*<FunctionArgDesc ja_jp>内部カウンター変数名</FunctionArgDesc ja_jp>*/
/*<FunctionArgDesc en_us>variable for internal counter</FunctionArgDesc en_us>*/
								, iovar_index =
								);
	%&RSUUtil.VerifyRequiredArgs(i_args = iovar_index)
	%if (%&RSUMacroVariable.IsBlank(&iovar_index.)) %then %do;
		%let &iovar_index. = 0;
	%end;
	%local _the_count;
	%let _the_count = %Prv_RSUCounter_CalcHelper(i_index = &&&iovar_index.
																, i_start = &i_start.
																, i_step = &i_step.
																, i_mod = &i_mod.
																, i_div = &i_div.
																, i_intercept = &i_intercept.);
	%let &iovar_index. = %eval(&&&iovar_index. + 1);
	/* Formatting */
	%if (not %&RSUMacroVariable.IsBlank(i_digit)) %then %do;
		%let _the_count = %sysfunc(putn(&_the_count., Z&i_digit.));
	%end;
	%if (not %&RSUMacroVariable.IsBlank(i_max_index)) %then %do;
		&i_prefix.&_the_count.&i_suffix. / &i_max_index.
	%end;
	%else %do;
		&i_prefix.&_the_count.&i_suffix.
	%end;
%mend RSUCounter__Draw;
