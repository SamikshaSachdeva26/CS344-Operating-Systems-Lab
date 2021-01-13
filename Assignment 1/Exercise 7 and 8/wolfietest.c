#include "types.h"
#include "stat.h"
#include "user.h"


int 
main()
{
	void *buffer = malloc(7461);

	// it returns -1 if buffer size is smaller than image size
	int bytes_read = wolfie(buffer, 7461);
	if(bytes_read > -1) 
		printf(1, "%s\n", buffer);

	exit();
} 
