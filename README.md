# Android_Build_Shell

-------------------------------------------------------

**Folder Tree**

	.
	├── Batch
	│   ├── ADB_Install_Apks
	│   │   └── adb_install_apks_v2.*.bat
	│   ├── CaptureLog
	│   │   ├── ReadMe.md
	│   │   ├── clrLog.bat
	│   │   └── getLog.bat
	│   ├── FolderAndFiles
	│   │   ├── VisitCE.bat
	│   │   └── VisitF.bat
	│   ├── ReadMe.md
	│   └── bat_template.bat
	├── Computer
	│   └── get_hardware_config.sh
	├── README.md
	├── RTC_Build_Shell
	│   ├── ReadMe.md
	│   ├── script_daily_build
	│   │   ├── Build.sh
	│   │   ├── Comps_Map.conf
	│   │   ├── Project_Config.sh
	│   │   └── ignore.list
	│   └── script_dev_build
	│       ├── Build.sh
	│       ├── Comps_Map.conf
	│       ├── Load_All_Comps.sh
	│       └── Project_Config.sh
	├── SVN_Export_Compile_And_Error_Notify_By_RTX
	│   ├── 12015_compile_daily.sh
	│   ├── 12015_compile_daily_temp.sh
	│   ├── 12015_compile_eng.sh
	│   ├── 12015_compile_qe.sh
	│   ├── 12015_compile_usr.sh
	│   ├── SVN?\226?\221?\223?\236\234RTX?\207??\212??\236?\227??\200\232?\237??\226??\210说?\230\216.pdf
	│   ├── clear.sh
	│   ├── find_str_argv.pl
	│   ├── rtx_send_msg.py
	│   ├── rtx_tst.sh
	│   ├── svn_commit_history_temp.map
	│   ├── svn_commit_history_total.map
	│   └── svn_id_2_rtx_id.map
	├── UserVersionBuildShell
	│   ├── android_prj_usr_build.sh
	│   └── build_usr.sh
	└── Utils
    	└── find_oppo_modify.sh


`UserVersionBuildShell`
	用于自动化编译Android版本，在Shell下执行。
	Eng or Usr版本。
  
`SVN_Export_Compile_And_Error_Notify_By_RTX`
	SVN自动从SVN服务器获取代码并编译，并将编译结果通过腾讯通RTX发送
	到相关负责人；如果出现编译错误，将会通知到有提交的同事。
  

  
By Long.Luo @2013/03/27


