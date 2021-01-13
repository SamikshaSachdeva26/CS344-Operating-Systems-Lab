#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return myproc()->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

// get max PID amongst the PIDs of all currently active processes in the system.
int sys_getMaxPid(void){
  return getMaxPid();      // call getMaxPid function
}

// get number of active processes in the system
int sys_getNumProc(void){
    return getNumProc();    // call getNumProc function
}

// gives info of the process
int sys_getProcInfo(void){
  int pid;
  struct processInfo *pif;
  int sz1 = sizeof(pid);
  int sz2 = sizeof(pif);
  argptr(0, (void *)&pid, sz1);        
  argptr(1, (void *)&pif, sz2); 
  return getProcInfo(pid, pif);     // call getProcInfo function
}

// set burst time of a process
int sys_set_burst_time(void)
{
  int n;
  int sz = sizeof(n);
  argptr(0, (void *)&n, sz);
  return set_burst_time(n);       // call set_burst_time function
}

// get burst time of a process
int sys_get_burst_time(void){
  return get_burst_time();        // call get_burst_time function
}

// get the state of the process
int sys_process_state(void){
  return process_state();         // call process_state function
}

int sys_inc_cpucounter(void)
{
  return inc_cpucounter();
}

int sys_dec_burstTime(void)
{
  dec_burstTime();
  return 29;
}