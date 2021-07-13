from utils import *
from mm import *
import numpy as np


def Format_SYS(Line):
    words = Line.split()
    mnemonic = words[0]
    result = opcode[mnemonic] + '00000000000000000000000000'
    return result

def Format_I(Line, Address, SymbolTable):
    words = Line.split()
    mnemonic = words[0]
    label = words[1]
    
    if label == "ba":
        Offset = str(np.binary_repr(SymbolTable[label], 24))
        AA = "1"
    else:
        Offset = str(np.binary_repr(SymbolTable[label] - Address - 4 , 24))
        print(Offset)
        AA = "0"
    binary = opcode[mnemonic] + Offset + AA
    if mnemonic == "bl":
        LK = "1"
        
    else:
        LK = "0"
    binary = binary + LK
    
    return binary

def Format_B(Line, Address, SymbolTable):
    words = Line.split()
    mnemonic = words[0]
    label = words[3]
    if label == "bc":
        Offset = str(np.binary_repr(SymbolTable[label] - Address - 4, 14))
        AA = "0"
    elif label == "bca":
        Offset = str(np.binary_repr(SymbolTable[label], 14)) 
        AA = "1"
    
    BO = str(np.binary_repr(int(words[1][:-1]), 5)) 
    BI = str(np.binary_repr(int(words[2][:-1]), 5)) 

    binary = opcode[mnemonic] + BO + BI + Offset + AA + "0"

    return binary

def Format_XO(inst):
    output = ""
    parts = inst.split()
    parts_strip = []
    for e in parts:
        parts_strip.append(e.replace(",", ""))
    # Opcode
    output += opcode[parts_strip[0]] 
    # RT
    rt = str(bin(int(parts_strip[1])))[2:]
    output += rt.rjust(5, '0') 
    # RA
    ra = str(bin(int(parts_strip[2])))[2:]
    output += ra.rjust(5, '0') 
    # RB
    rb = str(bin(int(parts_strip[3])))[2:]
    output += rb.rjust(5, '0') 
    # OE
    output += '0'  
    # XO
    output += extendedOpcodes[parts_strip[0]]
    # Rc
    output += '0' 

    return output


# print(len(get_bin_XO("add 2, 3, 4")))
# print(get_bin_XO("add 2, 3, 4"))

def Format_X(Line):
    words = Line.split()
    mnemonic = words[0]
    result = opcode[mnemonic]
    RA = str(np.binary_repr(int(words[1][:-1]), 5))
    RS = str(np.binary_repr(int(words[2][:-1]), 5))
    if mnemonic == "extsw":
        RB = "00000"
    else:
        RB = str(np.binary_repr(int(words[3]), 5))
    # extsw has no RB
    
    result = result + RS + RA + RB + extendedOpcodes[mnemonic] + "0"

    return result
    
def Format_DS(Line):
    Line = Line.replace(",", "")
    Line = Line.replace("(", " ")
    Line = Line.replace(")", " ")
    words = Line.split()
    
    mnemonic = words[0]
    RT = str(np.binary_repr(int(words[1]), 5))
    RA = str(np.binary_repr(int(words[3]), 5))
    DS = str(np.binary_repr(int(words[2]), 14))
    
    binary = opcode[mnemonic] + RT + RA + DS + extendedOpcodes[mnemonic]


def Format_D(inst):
    output = ""
    inst = inst.replace(",", "")

    if inst.count('(') > 0:         # If instruction is of the form : lw RT, D(RA)
        inst = inst.replace("(", " ")
        inst = inst.replace(")", " ")
        parts_strip = inst.split()
        parts_strip[2], parts_strip[3] = parts_strip[3], parts_strip[2]     # Swapping
    else:
        parts_strip = inst.split()
    
    # Opcode
    output += opcode[parts_strip[0]] 
    # RT
    rt = str(bin(int(parts_strip[1])))[2:]
    output += rt.rjust(5, '0') 
    # RA
    ra = str(bin(int(parts_strip[2])))[2:]
    output += ra.rjust(5, '0') 

    si = parts_strip[3]
    if (si[0] == '-'):
        n = str(np.binary_repr(int(si), 16))
   
    else:
        n = str(bin(int(si)))[2:]
        n = n.rjust(16, '0')
    output += n

    return output

# print(len(get_bin_D("addi 2, 3, -4")))
# print(get_bin_D("addi 2, 3, 3"))


def Format_XS(Line):
    words = Line.split()
    mnemonic = words[0]
    result = opcode[mnemonic]
    RA = str(np.binary_repr(int(words[1][:-1]), 5))
    RS = str(np.binary_repr(int(words[2][:-1]), 5))
    sh1 = str(np.binary_repr(int(words[3]), 5))
    sh2 = sh1[4]

    result = result + RS + RA + sh1 + extendedOpcodes[mnemonic] + sh2 + "0"

    return result

def Format_M(Line):
    words = Line.split()
    mnemonic = words[0]
    result = opcode[mnemonic]

    RA = str(np.binary_repr(int(words[1][:-1]), 5))
    RS = str(np.binary_repr(int(words[2][:-1]), 5))
    sh = str(np.binary_repr(int(words[3][:-1]), 5))
    MB = str(np.binary_repr(int(words[4][:-1]), 5))
    ME = str(np.binary_repr(int(words[5]), 5))

    result = result + RS + RA + sh + MB + ME + "0"

    return result


def Format_LA(Line, SymbolTable):
    words = Line.split()
    mnemonic = words[0]
    result = opcode[mnemonic]
    RX = str(np.binary_repr(int(words[1].replace(",", "")), 5))
    address = SymbolTable[words[2]]
    v = str(np.binary_repr(address, 32))

    result += RX + v
    return result

def Format_BEQ(Line, SymbolTable):
    words = Line.split()
    mnemonic = words[0]
    result = opcode[mnemonic]
    RA = str(np.binary_repr(int(words[1].replace(",", "")), 5))
    RB = str(np.binary_repr(int(words[2].replace(",", "")), 5))
    address = SymbolTable[words[3]]
    v = str(np.binary_repr(address, 32))

    result = result + RA + RB + v
    return result


def Format_XL(Line):
    words = Line.split()
    mnemonic = words[0]
    result = opcode[mnemonic]

    result = result + '00000000000000000000000000'
    # result = str(np.binary_repr(int(result, 2), 32))

    return result
