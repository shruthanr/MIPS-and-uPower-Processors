from mm import *
import numpy as np
from bitstring import Bits
MainMemory = {}
SymbolTable = {}
MainMemory, SymbolTable = AssemblerPass1(MainMemory, SymbolTable)
MainMemory, SymbolTable = AssemblerPass2(MainMemory, SymbolTable)

registers = [0] * 32
registers[31] = 0x7fffffff
# print(MainMemory)
# print(SymbolTable)
# print(registers)


def twosCom_binDec(bin, digit):
    while len(bin) < digit:
        bin = '0'+bin
    if bin[0] == '0':
        return int(bin, 2)
    else:
        return -1 * (int(''.join('1' if x == '0' else '0' for x in bin), 2) + 1)
SRR0 = 0x400004

cia = SymbolTable['main'] 
nia = cia + 4 
print(SymbolTable)

while (cia in MainMemory):
    inst = MainMemory[cia]
    opcode = inst[:6]
    q = int(input("Enter 1 to continue, 2 to exit: "))
    if (q == 1):
        if opcode == '001110':
            registers[int(inst[6:11], 2)] = registers[int(inst[11:16], 2)] + int(inst[16:], 2)
            # registers[int(inst[6:11], 2)] = np.binary_repr(registers[int(inst[6:11], 2)], 64)
        elif opcode == '010100':
            registers[int(inst[6:11], 2)] = registers[int(inst[6:11], 2)] + int(inst[11:], 2)
        elif opcode == '011111':
            if inst[22:31] == '100001010':
                registers[int(inst[6:11], 2)] = registers[int(inst[11:16], 2)] + registers[int(inst[16:21], 2)]
                
            elif inst[22:31] == '000101000':
                registers[int(inst[6:11], 2)] = registers[int(inst[16:21], 2)] - registers[int(inst[11:16], 2)]
            elif inst[21:31] == '0000011100':
                registers[int(inst[11:16], 2)] = registers[int(inst[6:11], 2)] & registers[int(inst[16:21], 2)]
            elif inst[21:31] == '0111011100': # Not sure if its right
                registers[int(inst[11:16], 2)] = ~(registers[int(inst[6:11], 2)] & registers[int(inst[16:21], 2)])
            elif inst[21:31] == '0110111100':
                registers[int(inst[11:16], 2)] = registers[int(inst[6:11], 2)] | registers[int(inst[16:21], 2)]
            elif inst[21:31] == '0100111100':
                registers[int(inst[11:16], 2)] = registers[int(inst[6:11], 2)] ^ registers[int(inst[16:21], 2)]

        elif opcode == '010010' and inst[31] == '0' and inst[30] == '1':
            nia = inst[6:30]

        elif opcode == '010010' and inst[31] == '0' and inst[30] == '0':
            nia = nia + Bits(bin = inst[6:30]).int
            

        elif opcode == '010010' and inst[31] == '1':
            SRR0 = nia
            nia = nia + Bits(bin=inst[6:30]).int
            
            

        elif opcode == '010011' and inst[31] == '0':
            nia = SRR0

        elif opcode == '100000':     # Load word
            RT = inst[6:11]
            RA = inst[11:16]
            D = inst[16:]
            Address = registers[int(RA, 2)] + int(D, 2) 
            # if np.binary_repr(MainMemory[Address], 8)[0] == '1':
            binarystring = np.binary_repr(MainMemory[Address], 8) + np.binary_repr(MainMemory[Address+1], 8) + np.binary_repr(MainMemory[Address+2], 8) + np.binary_repr(MainMemory[Address+3], 8)
                # print(twosCom_binDec(binarystring, 32))
            Data = twosCom_binDec(binarystring, 32)
            # else:
            #     Data = (MainMemory[Address] * (2**24)) + (MainMemory[Address+1] * (2**16)) + (MainMemory[Address+2] * (2**8)) + MainMemory[Address+3]
            
            registers[int(RT, 2)] = Data

        elif opcode == '100100':     # Store word
            RT = inst[6:11]
            RA = inst[11:16]
            D = inst[16:]
            Address = registers[int(RA, 2)] + int(D, 2)
            Data = str(np.binary_repr(registers[int(RT, 2)], 32))
            for i in range(0, 32, 8):
                MainMemory[Address + (i/8)] =  int(Data[i:i+8], 2)

        elif opcode == '110100':     # beq
            RA = int(inst[6:11], 2)
            RB = int(inst[11:16], 2)
            label = inst[16:]
            if registers[RA] == registers[RB]:
                nia = int(label, 2)
        elif opcode == '110101':     # bne
            RA = int(inst[6:11], 2)
            RB = int(inst[11:16], 2)
            label = inst[16:]
            if not(registers[RA] == registers[RB]):
                nia = int(label, 2)

        elif opcode == '111111':
            code = registers[30]
            arg = registers[29]
            if(code == 1):
                print(registers[29])
                
            elif (code == 4):
                res = ""
                while(MainMemory[arg] != 0):
                    res += chr(MainMemory[arg])
                    arg = arg + 1
                print(res)
            elif (code == 5):
                registers[28] = int(input())
            elif (code == 8):
                inputstring = input()
                registers[28] = MemAddress
                for c in inputstring:
                    MainMemory[MemAddress] = ord(c)
                    MemAddress += 1
                MainMemory[MemAddress] = ord('\0')
            elif code == 10:
                exit()   
                    
        print("[Register Contents] cia ")
        print(registers, cia)
        print()
        cia = nia
        nia = nia + 4
        q = 0
    elif q == 2:
        exit()

        
    


print("===========================================")
print("Contents of Registers (0-31)")
print(registers)
print("===========================================")

print()
print()
print("===========================================")
print("Contents of Main Memory")
for key, value in MainMemory.items():
    print(hex(key), value)
print("===========================================")
# print(SymbolTable)
