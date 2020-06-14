instType = {
    "add" : 'XO',
    'addi' : 'D',
    'addis' : 'D',
    'and' : 'X',
    'andi' : 'D',
    'extsw' : 'X',
    'nand' : 'X',
    'or' : 'X',
    'ori' : 'D',
    'subf' : 'XO',
    'xor' : 'X',
    'xori' : 'D',
    'ld' : 'DS',
    'lwz' : 'D',
    'std' : 'DS',
    'stw' : 'D',
    'stwu' : 'D',
    'lhz' : 'D',
    'lha' : 'D',
    'sth' : 'D',
    'lbz' : 'D',
    'stb' : 'D',
    'rlwinm' : 'M',
    'sld' : 'X',
    'srd' : 'X',
    'srad' : 'X',
    'sradi' : 'XS',
    'b' : 'I',
    'ba' : 'I',
    'bl' : 'I',
    'bclr' : 'XL',
    'bc' : 'B',
    'bca' : 'B',
    'cmp' : 'X',
    'cmpi' : 'D',
    'sc' : 'SC',
    'la' : 'LA',
    'beq' : 'BEQ',
    'sys' : 'SYS',
    'bne' : 'BEQ'
    
}


opcode = {
    "add" : '011111',
    'addi' : '001110',
    'addis' : '001111',
    'and' : '011111',
    'andi' : '011100',
    'extsw' : '011111',
    'nand' : '011111',
    'or' : '011111',
    'ori' : '011000',
    'subf' : '011111',
    'xor' : '011111',
    'xori' : '011010',
    'ld' : '111010',
    'lwz' : '100000',
    'std' : '111110',
    'stw' : '100100',
    'stwu' : '100101',
    'lhz' : '101000',
    'lha' : '101010',
    'sth' : '101100',
    'lbz' : '100010',
    'stb' : '100110',
    'rlwinm' : '010101',
    'sld' : '011111',
    'srd' : '011111',
    'srad' : '011111',
    'sradi' : '011111',
    'b' : '010010',
    'ba' : '010010',
    'bl' : '010010',
    'bclr' : '010011',
    'bc' : '010011',
    'bca' : '010011',
    'cmp' : '011111',
    'cmpi' : '001011',
    'sc' : '010001',
    'la' : '010100',
    'beq' : '110100',
    'sys' : '111111',
    'bne' : '110101'
}





extendedOpcodes = {
    'add' : '100001010',
    'and' : '0000011100',
    'extsw' : '1111011010',
    'nand' : '0111011100',
    'or' : '0110111100',
    'subf' : '000101000',
    'xor': '0100111100',
    'ld' : '00',
    'std' : '00',
    'sld' : '0000011011',
    'srd': '1000011011',
    'srad' : '1100011010',
    'sradi': '110011101',
    'cmp' : '0000000000'
}

for e in opcode.values():
    if (len(e) != 6):
        print("Opcode Error")

for k, v in extendedOpcodes.items():
    if ((instType[k] == 'X' and len(v) != 10) or ((instType[k] == 'XS' or instType[k] == 'XO') and len(v) != 9)):
        print("Extended opcode error")




