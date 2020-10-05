# Lab1: R32I Simulator
###### tags: `RISC-V`

## Problem description
[Greatest common divisor](https://en.wikipedia.org/wiki/Greatest_common_divisor)(GCD)
The **GCD** of two or more integers is the **largest positive integer** that divides each of the integers.

example:
Divisors of 24 are:<font color = "RED">1</font>,<font color = "RED">2</font>,3,<font color = "RED">4</font>,6,<font color = "RED">8</font>,12,24
Divisors of 16 are:<font color = "RED">1</font>,<font color = "RED">2</font>,<font color = "RED">4</font>,<font color = "RED">8</font>,16
<font color = "RED">Red</font> number are the common divisor, so 8 is the greatest common divisor.

### How to solve this problem?
**Euclidean algorithm** is a common easily method to solve GCD of two numbers.
Formally, the algorithm can be descibe as below:

$gcd(a,0) = a$
$gcd(a,b) = gcd(b,a \ mod \ b)$

#### GCD in C Code
```
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

```

And we can write the GCD code with Assembly as below:
## RISC-V asssmbly code
```
.data
in1: .word 24
in2: .word 16

.text
main:
	lw a0, in1
	lw a1, in2
	jal GCD
	li a7,1
	ecall
	j end

GCD:
	beqz a1,return      # if(a1 = 0)  t0 = 0;
	#blt a0, a1, swap   # if(a0 > a1) goto SWAP;
	rem a0, a0, a1      # a0 = a0 % a1;
swap:
	mv t1, a0
	mv a0, a1
	mv a1, t1
	j GCD
return:
	jr ra
end:
```
The Assembly mainly can be devided into Main and GCD.
### main
Load input 1, input 2 to a1, a2 register,and jump to GCD function.
After GCD function，print the GCD of input1 and input2.
### GCD
The GCD consist of four parts:
1. Determine wheather a1 register value is equal to zero.
2. Determine wheather a0 register value is greater than a1.
3. Subtraction loop.
4. Swap a0 and a1 register value.

## Detailed observation in RIPES
### Special instruction execution in pipeline
**line9** ```jal GCD```
1. ***EX* stage**: instruction address (beqz a1,return) corresponding to <GCD> label will be send to PC register and be fetch in the next cycle, IF/ID and ID/EX register will be clear to avoid execution of instrctions that should not be executed.
![](https://i.imgur.com/i6Jn9Zu.png)
![](https://i.imgur.com/J93AuZF.png)
2. ***WB* stage**: write back the return address to reg **ra** at *WB* stage.

![](https://i.imgur.com/w7C3lmw.png)

\
\
**line15** ```beqz a1,return```
beqz is one pseudo instrction, ```beq x11 x0 24 <return>``` is executed actually in pipeline)
1. ***EX* stage**: branch unit determine whether reg a1 and x0(0) are not equal.
(1)If not equal, do nothing.
(2)If equal, send the instruction address of sum of PC and offset to PC and execute at next cycle, clear IF/ID、ID/EX register at the same time.
![](https://i.imgur.com/yvKLmb2.png)

---
### Data hazard
* line17 **<font color = "BLUE">rem</font> a0, a0, a1** and line19 **<font color = "RED">addi</font> t1 a0 0**(mv t1, a0)
Because a0 will be updated to new value by **<font color = "BLUE">rem</font>** , but  **<font color = "RED">addi</font>**'s a0 value is old value which will cause the computational error.
So when **<font color = "BLUE">rem</font>** go to MEM stage, it will forward the newest value of a0 to **<font color = "RED">addi</font>** which in EX stage.
![](https://i.imgur.com/z7nD8Xs.png)

\
* line19 **<font color = "BLUE">addi</font> x6 x10 0**(```mv t1, a0```) and line21 **<font color = "RED">addi</font> x11 x6 0**(```mv a1, t1```)
![](https://i.imgur.com/UVJ2bem.png)
Similarly, because reg t1 will be update by first **<font color = "BLUE">addi</font>**, and second **<font color = "RED">addi</font>** got the old t1 value before, so **<font color = "BLUE">addi</font>** forward the newest value of reg t1 to  **<font color = "RED">addi</font>**.
![](https://i.imgur.com/WgdYTto.png)

---
### Jal and J
We can find that difference between jal instr and j instr in Ripes as below,
   * **jal GCD  ->  jal x1 0x20 <GCD>**
   * **j GCD ->  jal x0 0x20 <GCD>**
The register number is placed behind the op code(jal in here), the address which be executed after return that will be saved in the reg, but **j** saved the address in reg x0(saved nothing), and **jal** save the address in x1(ra).

---
### Other ideas
* Branch and Jump instruction are used in the program, so we need to waste much more cycles to execute NOP. Therefore, if you can reduce the use of branch and jemp instructions, you can reduce unnecssary NOPs.
* I have tried to narrow the program, but it increase cycles of the program.
It represents the program execution time is mainly affected by permutation of instructions and program writing skill but not length or size of the program.


