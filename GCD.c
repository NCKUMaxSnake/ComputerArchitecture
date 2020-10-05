#include<stdio.h>
#include<stdlib.h>
int main()
{
	int in1,in2;
	printf("Please enter 2 numbers:");
	scanf("%d %d",&in1,&in2);
	printf("%d is the GCD of %d and %d\n",GCD(in1,in2),in1,in2);
	return;
}
int GCD(int a, int b)
{
	if(!b)
		return a;	
	return GCD(b, a%b);
}
