// to test fork executes correctly or not
#include "types.h"
#include "stat.h"
#include "user.h"

void
printf(int fd, const char *s, ...)
{
  write(fd, s, strlen(s));
}

void
forktest(void)
{
  int n=0, pid;
  printf(1, "Fork test started\n");
  while(n<1000)
  {
    pid = fork();
    if(pid < 0)
      break;
    if(pid == 0)
      exit();
    n++;
  }

  if(n == 1000)
  {
    printf(1, "fork claimed to work 1000 times!\n", 1000);
    exit();
  }

  while(n>0)
  {
    if(wait() < 0)
    {
      printf(1, "wait stopped early\n");
      exit();
    }
    n--;
  }

  if(wait() != -1)
  {
    printf(1, "wait got too many\n");
    exit();
  }

  printf(1, "OK tested.\n");
}

int
main(void)
{
  forktest();
  exit();
}
