
Group 17
180123040 - Samiksha Sachdeva
180101033 - Kartikay Goel
180101023 - Falak Chhikara
180101060 - Rahul Choudhary

The below implementation procedure is applicable for linux user.

Step 1: Install ZFS file system on any free partition(with size more than 4 GB). The partition can be either of the external storage device or any partition of the hard disk. 
	Command - sudo apt-get install zfsutils-linux 
Step 2: Create a storage pool.
	Command - sudo zpool create <partition name> <poolname>
	In our case, the command was - sudo zpool create /dev/sda9 group17	
Step 3: Check if the pool is created using the command - zpool list

Step 4: Switch to the directory in which vdbech is present.

Step 5: To test the deduplication feature in ZFS:
	Case 1: dedup=on 
	Commands-: sudo zfs set dedup=on group17
		   sudo ./vdbench -f example8 -o test_deduplication_zfs
		   To see the size of the allocated memory, use zpool list command.

	Case 2: dedup=off 
	Commands-: sudo zfs set dedup=off group17
		   sudo ./vdbench -f example8 -o test_deduplicationoff_zfs
		   To see the size of the allocated memory, use zpool list command.

Step 6: To test the deduplication feature in ext4
	Change the anchor variable in example9 file to the path in which you want to create the workload directory. In our case, it is set to /home/kartikay/group17. The command creates the files inside 	  the group17 directory.
	Now run the following command:
	sudo ./vdbench -f example9 -o test_deduplication_ext4
	See the size of the group17 directory using the following command-: du -sh /group17/

Step 7: To test the compression feature in ZFS
	Clear the group17 pool by going to the root directory and then to group17 directory. 
	Use the command sudo rm -rf * inside the group17 pool. 
	Set the compression algorithm to LZ4 using-: sudo zfs set compression=lz4 group17
	Run the following command to execute workload-: sudo ./vdbench -f example10 -o test_compression_zfs
	To see the size of the pool, use the following command-: sudo zpool list

Step 8: To test the compression feature in ext4
	Run the following command to execute workload-: sudo ./vdbench -f example11 -o test_compression_ext4
	Check the size of the directory created on the specified path.

All the CPU usages are present in summary.html files created in each of the output directory which we specify in the commands above( e.g. test_Deduplication_zfs)
	
	
