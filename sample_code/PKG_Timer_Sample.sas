%rsu_dev_module_activate_test(i_version = 200)

%macro TimerSample1;
	%put 現在の時刻: %&RSUTimer.GetNow;	/* "GetNow" 現在時刻を YYYY/MM/DD HH:mm:SS を形式で取得 */
%mend TimerSample1;
%TimerSample1

%macro TimerSample2;
	%local _my_timer;
	%let _my_timer = %&RSUTimer.Create;				/* Timerインスタンス作成（タイマースタート） */
	
	%&RSUTimer.ProcessSleep(i_count = 3				/* "ProcessSleep" プロセスを一定時間中断（3 * 1sec）*/
									, i_unit = 1)
	%&_my_timer.Lap										/* "Lap" 第1ラップ */
	%&RSUTimer.ProcessSleep(i_count = 5				/* "ProcessSleep" プロセスを一定時間中断（5 * 1sec）*/
									, i_unit = 1)
	%&_my_timer.Lap										/* "Lap" 第2ラップ */
	%&RSUTimer.ProcessSleep(i_count = 20			/* "ProcessSleep" プロセスを一定時間中断（20 * 0.1sec）*/
									, i_unit = 0.1)
	%&_my_timer.Stop;										/* "Stop" タイマー停止（リセット） */
	
	%&RSUClass.Dispose(_my_timer)						/* インスタンス破棄 */
%mend TimerSample2;
%TimerSample2