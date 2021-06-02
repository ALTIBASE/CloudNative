#1st test for 1RW/nR Altibase servers 

1. Proxy setup 
	Need to check a proxy loadbalance (HAProxy)

2. 1RW 
	host : C1
	Instance: C1(20300)
3. nR 
	host : C1, C2, C3
	Instance: C1(20301, 20302, 20303, 20304)
	Instance: C2(20301, 20302, 20303, 20304)
	Instance: C3(20301, 20302, 20303, 20304)

4. Replication
	1RW/C1(20300) -> nR(C1,C2,C3(20301,20302,20303)

5. Test case
	Standard BMT
	TPCH

