
#include "types.h"
#include "stat.h"
#include "user.h"

int main()
{
	int max_pid = getMaxPid();
	printf(1 , "Maximum PID(process ID) is: %d \n" , max_pid);
  	exit();
}