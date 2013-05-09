#!/bin/bash
#
#


#
#RTX_SDK_SERVER="172.16.101.201:8012"
RTX_SDK_SERVER="192.168.1.153:8012"
RTX_NOTIFY_RECEIVER="test"
#

#--------------------------------------------------------------------------------------------
check_exit()
{
    EXIT=$?    
    echo EXIT=$EXIT
}

fn_get_svn()
{

}

fn_send_rtx_notify()
{
	echo "	fn_send_rtx_notify...: ${1}"
	echo "<<< RTX_NOTIFY=${RTX_NOTIFY}"
	RTX_NOTIFY=${1}
	echo ">>> RTX_NOTIFY=${RTX_NOTIFY}"
	echo "./rtx_send_msg.py -s ${RTX_SDK_SERVER} -u ${RTX_NOTIFY_RECEIVER} -m ${RTX_NOTIFY}"
	
	./rtx_send_msg.py -s ${RTX_SDK_SERVER} -u ${RTX_NOTIFY_RECEIVER} -m ${RTX_NOTIFY}
	check_exit
	
	./rtx_send_msg.py -s ${RTX_SDK_SERVER} -u 1011 -m ${RTX_NOTIFY}
	check_exit
}

fn_use()
{
	echo "	fn_use..."
	fn_send_rtx_notify "MyTest..."
}

#--------------------------------------------------------------------------------------------
echo "------------- start -------------"
fn_use
echo "------------- end -------------"
