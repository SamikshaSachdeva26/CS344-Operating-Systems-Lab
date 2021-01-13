#include "types.h"
#include "stat.h"
#include "user.h"
#include "processInfo.h"
#include "fcntl.h"

// CPU bound process
void
random_computation()
{
    float a = 0, b=0;

    while(b<1000000)
    {
        if((int)b%2 == 0)
            a = a - (1.5*2.6);
        else
            a = a+ 1.6*4.9;
        b+=1;
    }
}

// I/O bound process
void
random_io()
{
    int i=150;
    while(i--)
    {
        printf(1,"$");
    }
    sleep(3);
    printf(1, "\n");
}

int 
main(int argc, char *argv[])
{


    // This code is for test case 3 and 4.
    // To run this code for test case 1, change random_computation to random_io in else block.
    // To run this code for test case 2, change random_io to random_computation in else block.
    int n;
    n = atoi(argv[1]);
    if (argc < 2) n=5;
    int burst_time=0;
    int pids[n];
    int returnOrder[n];    // to store completiton order
    int map[500];          // to map process id to child number
    int rand_bt[20] = {20, 17, 1, 5, 13, 11, 4, 10, 6, 3, 3, 2, 18, 7, 8, 13, 17, 8, 19, 8};
    int i=0;
    while(i<n)
    {
        if(i==2 || i==4 || i==9 || i==14)
        {
            int id = fork();
            if (id == 0)
            {
                burst_time = rand_bt[i];
                set_burst_time(burst_time);
                random_io();
                exit();    
            }
            else if (id < 0)
            {
                printf(1, "Error!! Could not be forked. \n");
                exit();
            }
            else
            {
                pids[i] = id;
                map[id]=i;
            }
        }
        else
        {
            int id = fork();
            if (id == 0)
            {
                burst_time = rand_bt[i];
                set_burst_time(burst_time);
                random_computation();
                exit();    
            }
            else if (id < 0)
            {
                printf(1, "Error!! Could not be forked. \n");
                exit();
            }
            else
            {
                pids[i] = id;
                map[id]=i;
            }
        }
        
        i++;
    }

    for (int i = 0; i < n; i++)
    {
        returnOrder[i] = wait();
    }
    printf(1, "Child No.\tPID\t\t Burst Time     \n");
    for (int i = 0; i < n; i++)
    {
        printf(1, "%d\t\t %d\t\t %d  \n", i+1, pids[i], rand_bt[i]);
    }
    printf(1, "\nCompletion Order: \n");
    printf(1, "PID\t\t Burst Time     \n");
    for (int i = 0; i < n; i++){
        printf(1, "%d\t\t %d  \n", returnOrder[i], rand_bt[map[returnOrder[i]]]);
        
    }
    exit();
}
