# ZXMAK2-nuget
Nuget packages generator from ZXMAK2 sources. This repository contains scripts, .nuspec and .csproj files, which are required 
for package generation and compilation for different .NET frameworks. For the emulator itself please visit 
https://github.com/ZXMAK/ZXMAK2.

## Z80Cpu

This is Z80 CPU emulation code from ZX Spectrum emulator ZXMAK2. Code is taken almost unchanged. The only change is that the
TimingTool (speed benchmark) is excluded since it references Logging project of ZXMAK2 solution.

### Installation

Install from Package Manager console

```PM> Install-Package ZXMAK2.Z80Cpu -Version 1.0.0```

### Example

This example shows how to initialize Z80Cpu class and execute a simple loop
```asm
LOOP: LD A, (#0009)    ; load counter value from RAM to A
      INC A            ; increment the value of counter
      LD (#0009), A    ; and write it back
      JR LOOP          ; repeat forever
CNT:  DB 0             ; counter, the variable to increment. Its address if #0009
```

for a 100 times. It is enough to enlarge CNT cell at #0009 to the value of 25.

```C#
using System;
using ZXMAK2.Engine.Cpu.Processor;

class Program
{
	static void Main(string[] args)
	{
		var cpu = new Z80Cpu();

		var mem = new byte[10] { 0x3a, 0x09, 0x00, 0x3c, 0x32, 0x09, 0x00, 0x18, 0xf7, 0, };

		// Attach memory read/write callbacks
		cpu.WRMEM = (a, v) => mem[a] = v;
		cpu.RDMEM = a => mem[a];
		cpu.RDMEM_M1 = cpu.RDMEM;

		// Disable unwanted callbacks
		cpu.RDNOMREQ = cpu.WRNOMREQ = _ => { };
		cpu.NMIACK_M1 = cpu.INTACK_M1 = cpu.RESET = () => { };

		// Reset the CPU (or we could simply assign 0 to cpu.regs.PC)
		cpu.RST = true; cpu.ExecCycle(); cpu.RST = false;

		// Do work for 100 machine cycles
		for (int i = 0; i < 100; i++)
		{
			cpu.ExecCycle();
			Console.WriteLine(mem[9]); // print the incremented cell value
		}
	}
}

```
