#include "types.h"
#include "stat.h"
#include "user.h"

int main()
{

  printf(1 , "Burst Time before setting burst time: %d \n" , get_burst_time());
  set_burst_time(15);
  printf(1 , "Burst Time after setting burst time: %d \n" , get_burst_time());
  exit();
}