#include "types.h"
#include "stat.h"
#include "user.h"

int main()
{
  int num = getNumProc();	
  printf(1 , "Number of active processes(in either state): %d \n" , num);
  exit();
}