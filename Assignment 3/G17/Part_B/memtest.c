#include "types.h"
#include "stat.h"
#include "user.h"
char buf[8192];
char name[3];
char *echoargv[] = { "echo", "ALL", "TESTS", "PASSED", 0 };
int stdout = 1;
#define TOTAL_MEMORY (2 << 20) + (1 << 18) + (1 << 17)

void child_proc(int c)
{
    void *m2;
    char* m1;
    int i = 0;
    for(;i<10;i++)
    {
        m2 = malloc(4096);
        if (m2 == 0){
            printf(1, "\ntest failed!\n");
            exit();
        }
        m1=(char *) m2;
        for(int j=0;j<4096;j++){
            m1[j]=c+'a';
        }
        for(int j=0;j<4096;j++){
            if(m1[j]!=c+'a'){
                printf(1, "\ntest failed!\n");
                exit();
            }
        }
    }
    printf(1, "%dth child: Test case passed \n", c);
    exit();
}

int
main(int argc, char* argv[])
{
  int i, pid;

  // As per the assignment spec, fork 20 children.
  for (i = 0; i < 20; i++) {
    pid = fork();
    if (pid == 0)
    {
            child_proc(i);
    }
    else if(pid<0)printf(1, "\nfork failed\n");
    else wait();
  }


  while(wait() >= 0);
  exit();
}