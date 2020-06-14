from convert import *
from utils import *
import numpy as np

# SymbolTable = {}
# MainMemory = {}

filename = './test/arraysum.txt'
def AssemblerPass1(MainMemory, SymbolTable):
    with open(filename, "r") as myfile:
        Code = myfile.readlines()

    #for line in Code:
    #    words = line.split()
    #    for word in words:
    #        print(word)

    i = 0
    
    MemAddress = 0x10000000
    InstructionOffset = 0x400000
    DataSegment = False
    TextSegment = False
    InstructionCount = 0

    for Line in Code:        # Reading the code line by line
        if Line == ".data\n":
            DataSegment = True
            continue

        if Line == ".text\n":
            DataSegment = False
            TextSegment = True
            continue

        if DataSegment:
            words = Line.split()
            if words and words[0][-1] == ':':
                label = words[0][:-1]
                SymbolTable[label] = MemAddress

                DataType = words[1][1:]
                if DataType == "ascii" or DataType == "asciiz":
                    strng = ""
                    for i in range(2, len(words)-1):
                        strng = strng + words[i] + " "
                    strng = strng + words[-1]
                    for c in strng[1:-1]:
                        MainMemory[MemAddress] = ord(c)
                        MemAddress += 1
                    # MemAddress += len(strng) - 2
                    if DataType == "asciiz":
                        MainMemory[MemAddress] = ord('\0')
                        MemAddress += 1

                else:
                    Size = {"byte": 1, "half": 2,
                            "word": 4, "float": 4, "double": 8}
                    count = len(words) - 2
                    if DataType == 'byte' :
                        for i in range(count):
                            v = str(np.binary_repr(int(words[2+i].replace(",", "")), 8))
                            MainMemory[MemAddress] = int(v, 2)
                            MemAddress += 1
                    elif DataType == 'word':
                        for i in range(count):
                            v = str(np.binary_repr(int(words[2+i].replace(",", "")), 32))
                            for j in range(0, 32, 8):
                                MainMemory[MemAddress] = int(v[j:8+j], 2)
                                MemAddress += 1
                    elif DataType == 'half':
                        for i in range(count):
                            v = str(np.binary_repr(int(words[2+i].replace(",", "")), 16))
                            for j in range(0, 16, 8):
                                MainMemory[MemAddress] = int(v[j:8+j], 2)
                                MemAddress += 1

                    # MemAddress += count * Size[DataType]

        elif TextSegment:
            words = Line.split()
            if words and words[0][-1] == ':':
                label = words[0][:-1]
                SymbolTable[label] = InstructionOffset + (InstructionCount * 4)
                continue

            InstructionCount += 1

    # print(SymbolTable)
    return MainMemory, SymbolTable

def AssemblerPass2(MainMemory, SymbolTable):
    with open(filename, "r") as myfile:
        Code = myfile.readlines()

    MemAddress = 0x10000000
    InstructionOffset = 0x400000
    DataSegment = False
    TextSegment = False
    InstructionCount = 0
    Binary = []

    for Line in Code:        # Reading the code line by line
        if Line == ".data\n":
            DataSegment = True
            continue

        if Line == ".text\n":
            DataSegment = False
            TextSegment = True
            continue

        if TextSegment:
            words = Line.split()
            if(words):
                if (words[0][-1] == ':' or words[0][0] == '.'):
                    continue

                mnemonic = words[0]
                if instType[mnemonic] == 'X':
                    result = Format_X(Line)
                elif instType[mnemonic] == 'XS':
                    result = Format_XS(Line)
                elif instType[mnemonic] == 'D':
                    result = Format_D(Line)
                elif instType[mnemonic] == 'M':
                    result = Format_M(Line)
                elif instType[mnemonic] == 'B':
                    result = Format_B(Line, InstructionOffset + 4 * InstructionCount, SymbolTable)
                elif instType[mnemonic] == 'XO':
                    result = Format_XO(Line)
                elif instType[mnemonic] == 'DS':
                    result = Format_DS(Line)
                elif instType[mnemonic] == 'I':
                    result = Format_I(Line, InstructionOffset + 4 * InstructionCount, SymbolTable)
                elif instType[mnemonic] == 'LA':
                    result = Format_LA(Line, SymbolTable)
                elif instType[mnemonic] == 'BEQ':
                    result = Format_BEQ(Line, SymbolTable)
                elif instType[mnemonic] == 'XL':
                    result = Format_XL(Line)
                elif instType[mnemonic] == 'SYS':
                    result = Format_SYS(Line)

                MainMemory[InstructionOffset + 4 * InstructionCount] = result

                InstructionCount += 1

    # Writing the binary to a file
    with open("Binary.txt", "w") as myfile:
        myfile.writelines([MainMemory[InstructionOffset + 4*i] for i in range(0, InstructionCount)])

    return MainMemory, SymbolTable

# AssemblerPass1()

# AssemblerPass2()

# for key, value in MainMemory.items():
#     print(hex(key), value)
