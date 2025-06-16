%rsu_dev_module_activate_test(i_version = 200)

%macro QueueSample1;
	%local _my_queue;
	%local _count;
	%let _count = %&RSUQueue.Enqueue(_my_queue, SAS);							/* "Enqueue" キューに要素を追加 */
	%let _count = %&RSUQueue.Enqueue(_my_queue, Development Module);		/* "Enqueue" キューに要素を追加 */
	%let _count = %&RSUQueue.Enqueue(_my_queue, Enjoy!);						/* "Enqueue" キューに要素を追加 */
	%put 要素数: %&RSUQueue.GetSize(_my_queue);									/* "GetSize" キューの要素数取得 */
	
	%put 次に取り出される要素: %&RSUQueue.Peek(_my_queue);				/* "Peek" 次に取り出される要素取得 */
	%local _item;
	%do %while(%&RSUQueue.Dequeue(_my_queue, ovar_item = _item));			/* "Dequeue" キューから要素を取り出す */
		%put 取り出された要素: &=_item.;
	%end;
	%put 要素数: %&RSUQueue.GetSize(_my_queue);									/* "GetSize" キューの要素数取得 */
%mend QueueSample1;
%QueueSample1