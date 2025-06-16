%rsu_dev_module_activate_test(i_version = 200)

%macro StackSample1;
	%local _my_stack;
	%local _count;
	%let _count = %&RSUStack.Push(_my_stack, SAS);							/* "Push" スタックに要素を追加 */
	%let _count = %&RSUStack.Push(_my_stack, Development Module);		/* "Push" スタックに要素を追加 */
	%let _count = %&RSUStack.Push(_my_stack, Enjoy!);						/* "Push" スタックに要素を追加 */
	%put 要素数: %&RSUStack.GetSize(_my_stack);								/* "GetSize" スタックの要素数取得 */
	
	%put 次に取り出される要素: %&RSUStack.Peek(_my_stack);				/* "Peek" 次に取り出される要素取得 */
	%local _item;
	%do %while(%&RSUStack.Pop(_my_stack, ovar_item = _item));			/* "Pop" スタックから要素を取り出す */
		%put 取り出された要素: &=_item.;
	%end;
	%put 要素数: %&RSUStack.GetSize(_my_stack);								/* "GetSize" スタックの要素数取得 */
%mend StackSample1;
%StackSample1