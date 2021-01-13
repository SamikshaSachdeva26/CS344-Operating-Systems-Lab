#include "types.h"
#include "stat.h"
#include "user.h"
#include "processInfo.h"

int main()
{
    int pid=2;                        // choose yourself  
    struct processInfo pif;
    int tmp=getProcInfo(pid, &pif);   //stores the info of process in pif
    if(tmp==-1){
        printf(1, "No process found, return value %d \n",tmp );            //No Process Found as -1 returned
    }
    else{
        printf(1, "Process Info: \n  Parent PID is: %d \n ", pif.ppid);
        printf(1, "Size of the process: %d \n", pif.psize);
        printf(1, "Number of context switches: %d \n", pif.numberContextSwitches);
    }
    exit(); 
}