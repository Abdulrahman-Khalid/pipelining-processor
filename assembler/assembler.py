import sys
import re

bitsNum = 16
initMemAddr = 0
toMemAddr = 2**11
opCodeDict = {}
variables = {}  # have key => variable name, value => address of value of the variable


def over_write_memory(memoryTuples, ramFilePath):
    memoryStartIndex = 0
    memBitsNum = bitsNum
    outputMemFile = open(ramFilePath, "r+")
    data = outputMemFile.readlines()
    outputMemFile.seek(0)

    if(len(data) > memoryStartIndex):
        lineLength = len(data[memoryStartIndex])
        for instructionAddress, opCode in memoryTuples:
            data[instructionAddress+memoryStartIndex] = data[instructionAddress +
                                                             memoryStartIndex][0:lineLength-(memBitsNum+1)]+opCode+'\n'
            # print(data[instructionAddress+memoryStartIndex])
        outputMemFile.writelines(data)
        outputMemFile.truncate()
        print("Successful Run")
    else:
        print("Failed Run")
    outputMemFile.close()


def generate_empty_memory(memFile):
    with open(memFile, "w") as f:
        for i in range(initMemAddr, toMemAddr):
            f.writelines(hex(i)[2:].zfill(3)+": " + "X"*bitsNum+"\n")


def load_codes():
    with open("./imports/op_codes.txt") as f:
        for line in f:
            line = re.sub(' +', ' ', line)
            line = line.replace("\n", '')
            key, _, val = line.partition(' ')
            opCodeDict[key] = val


def check_syntax_error(instructionAddress, instruction, debugLines, instructionNum, instructions):
    org = r"(^\.[oO][rR][gG]\s{0,1}[0-9a-fA-F]+$)"
    word = r"(^\.[wW][oO][rR][dD]\s{0,1}[0-9a-fA-F]+$)"
    hexaNum = r"(^\s{0,1}[0-9a-fA-F]+$)"
    # ldd std r0, 0 to fffff (2 instruction) # 32 bit
    ldd_std_op = r"(^([lL][dD][dD]|[sS][tT][dD])\s[rR][0-7]\s{0,1},\s{0,1}[0-9a-fA-F]{1,5}$)"
    # ldm r0, 0 to ffff (1 instruction) # 32 bit
    ldm_op = r"(^([lL][dD][mM])\s[rR][0-7]\s{0,1},\s{0,1}[0-9a-fA-F]{1,4}$)"
    # iadd r0,r1,0 to ffff (1 instruction) # 32 bit
    iadd_op = r"(^([iI][aA][dD][dD])\s[rR][0-7]\s{0,1},\s{0,1}[rR][0-7]\s{0,1},\s{0,1}[0-9a-fA-F]{1,4}\s{0,1}$)"
    # shl shr r0, 0 to 1f (2 instruction) # 16 bit
    shift_op = r"(^([sS][hH][lL]|[sS][hH][rR])\s[rR][0-7]\s{0,1},\s{0,1}([0-9a-fA-F]|[0-1][0-9a-fA-F])$)"
    # swap r0,r1 (1 instruction) # 16 bit
    swap_op = r"(^([sS][wW][aA][pP])\s[rR][0-7]\s{0,1},\s{0,1}[rR][0-7]\s{0,1}$)"
    # add sub and or r1,r2,r3 (4 instruction) # 16 bit
    three_operand = r"(^([aA][dD][dD]|[sS][uU][bB]|[aA][nN][dD]|[oO][rR])\s[rR][0-7]\s{0,1},\s{0,1}[rR][0-7]\s{0,1},\s{0,1}[rR][0-7]\s{0,1}$)"
    # pop push jmp jz call not inc dec out in r0 (10 instruction) # 16 bit
    one_operand = r"(^([pP][oO][pP]|[pP][uU][sS][hH]|[jJ][mM][pP]|[jJ][zZ]|[cC][aA][lL][lL]|[nN][oO][tT]|[iI][nN][cC]|[dD][eE][cC]|[oO][uU][tT]|[iI][nN])\s[rR][0-7])"
    # nop rti ret (3 instruction) # 16 bit
    nop_rti_ret = r"(^([nN][oO][pP]|[rR][tT][iI]|[rR][eE][tT])\s{0,1}$)"
    # setC clrC setZ clrZ setN clrN # 16 bit
    set_clr = r"(^([sS][eE][tT]|[cC][lL][rR])[cCzZnN]\s{0,1}$)"
    org = r"(^\.[oO][rR][gG]\s{0,1}[0-7][0-9a-fA-F]|[0-9a-fA-F]{1,2}\s{0,1}$)"
    newAddress = instructionAddress + 1
    instruction = instruction.lower()
    if len(instruction.split()) == 3:  # correct
        first, second, third = instruction.split()
        if re.match(word, second+third, flags=0):
            code = bin(int(third, bitsNum))[2:].zfill(bitsNum)
            if(len(code) == bitsNum):
                variables[first.lower()] = instructionAddress
                debugLines.append(
                    (instruction, "hex", instructionAddress, code))
                return newAddress
            else:
                raise ValueError('Syntax Error: ', instruction)
    if re.match(org, instruction, flags=0):  # correct
        newAddress = int((instruction.split())[1], bitsNum)
    elif re.match(hexaNum, instruction, flags=0):
        code = bin(int(instruction, bitsNum))[2:].zfill(bitsNum)
        if(len(code) == bitsNum):
            debugLines.append((instruction, "hex", instructionAddress, code))
        else:
            raise ValueError('Syntax Error: ', instruction)
    elif re.match(nop_rti_ret, instruction, flags=0) or re.match(set_clr, instruction, flags=0):
        code = opCodeDict[instruction]
        code += "0"*(bitsNum-len(code))
        debugLines.append(
            (instruction, "nop instruction", instructionAddress, code))
    elif re.match(shift_op, instruction, flags=0):
        arrayOp = (instruction.replace(',', ' ')).split()
        op, Rsrc, imm = [x for x in arrayOp]
        code = opCodeDict[op]+opCodeDict[Rsrc]
        code += bin(int(imm, bitsNum))[2:].zfill(bitsNum-len(code))
        code += "0"*(bitsNum-len(code))
        debugLines.append(
            (instruction, "shift instruction", instructionAddress, code))
    elif re.match(swap_op, instruction, flags=0):
        arrayOp = (instruction.replace(',', ' ')).split()
        op, Rsrc1, Rsrc2 = [x for x in arrayOp]
        code = opCodeDict[op]+opCodeDict[Rsrc1]+opCodeDict[Rsrc2]
        code += "0"*(bitsNum-len(code))
        debugLines.append(
            (instruction, "swap instruction", instructionAddress, code))
    elif re.match(three_operand, instruction, flags=0):
        arrayOp = (instruction.replace(',', ' ')).split()
        op, Rsrc1, Rsrc2, Rdst = [x for x in arrayOp]
        code = opCodeDict[op]+opCodeDict[Rsrc1] + \
            opCodeDict[Rsrc2]+opCodeDict[Rdst]
        code += "0"*(bitsNum-len(code))
        debugLines.append(
            (instruction, "three operand instruction", instructionAddress, code))
    elif re.match(one_operand, instruction, flags=0):
        arrayOp = instruction.split()
        op, Rdst = [x for x in arrayOp]
        code = opCodeDict[op] + opCodeDict[Rdst]
        code += "0"*(bitsNum-len(code))
        debugLines.append(
            (instruction, "one operand instruction", instructionAddress, code))
    elif re.match(ldd_std_op, instruction, flags=0):
        arrayOp = (instruction.replace(',', ' ')).split()
        op, R, EA = [x for x in arrayOp]
        code = opCodeDict[op]+opCodeDict[R]
        n = bitsNum-len(code)
        code += bin(int(EA[0], n))[2:].zfill(n)
        code += "0"*(bitsNum-len(code))
        instructionAddress2 = newAddress
        newAddress += 1
        if(len(EA) > 1):
            code2 = bin(int(EA[1:], bitsNum))[2:].zfill(bitsNum)
        else:
            code2 = "0"*bitsNum
        debugLines.append(
            (instruction, "ldd or std instruction", instructionAddress, code))
    elif re.match(ldm_op, instruction, flags=0):
        arrayOp = (instruction.replace(',', ' ')).split()
        op, R, imm = [x for x in arrayOp]
        code = opCodeDict[op]+opCodeDict[R]
        code += "0"*(bitsNum-len(code))
        instructionAddress2 = newAddress
        newAddress += 1
        code2 = bin(int(imm, bitsNum))[2:].zfill(bitsNum)
        debugLines.append(
            (instruction, "ldm instruction", instructionAddress, code))
    elif re.match(iadd_op, instruction, flags=0):
        arrayOp = (instruction.replace(',', ' ')).split()
        op, R1, R2, imm = [x for x in arrayOp]
        code = opCodeDict[op]+opCodeDict[R1]+opCodeDict[R2]
        code += "0"*(bitsNum-len(code))
        instructionAddress2 = newAddress
        newAddress += 1
        code2 = bin(int(imm, bitsNum))[2:].zfill(bitsNum)
        debugLines.append(
            (instruction, "iadd instruction", instructionAddress, code))
    else:
        raise ValueError('Syntax Error: ', instruction)
    return newAddress


def compile_code(lines, debugFileDir):
    # reset labels and variables first
    variables.clear()
    isFailed = False
    instructions = []

    debug = open(debugFileDir, "w")
    debug.writelines(
        "----------------------------- START CODE -----------------------------\n")
    # remove all white spaces and comments
    debugLines = []
    instructionAddress = 0
    for lineNum, line in enumerate(lines):
        instruction = line.partition('#')[0]
        instruction = ' '.join(instruction.split())
        if (instruction != ''):
            instructions.append((lineNum, instruction.lower()))
            debug.writelines(instruction.lower()+'\n')
    # if there is no hlt at the end of the program just add it
    if(instructions[-1][1] != "hlt"):
        instructions.append((instructions[-1][0]+1, "hlt"))
    for instructionNum, instructionTuple in enumerate(instructions):
        try:
            instructionAddress = check_syntax_error(
                instructionAddress, instructionTuple[1], debugLines, instructionNum, instructions)
        except ValueError:
            isFailed = True
            print("Error in line: {} with instruction: {}".format(
                instructionTuple[0]+1, instructionTuple[1]))
    debug.writelines(
        "----------------------------- END CODE -------------------------------\n")
    debugLines.sort(key=lambda tup: tup[2])
    debug.writelines(
        "----------------------------- START INSTUCTION INFORMATION LIST -----------------------------\n")
    for debugLine in debugLines:
        debug.writelines("(instruction = {}) (instruction type = {}) (address in hex = {}) (instruction code = {})\n".format(
            debugLine[0], debugLine[1], hex(debugLine[2]).zfill(3), debugLine[3]))
    debug.writelines(
        "----------------------------- END INSTUCTION INFORMATION LIST -------------------------------\n")
    debug.close()
    # check if there is a Syntax Error:
    # (address in decimal, instruction code)
    if(isFailed):
        print("Failed Compile")
        return False

    print("Successful Compile")
    memoryTuples = [(x[-2], x[-1]) for x in debugLines]
    return memoryTuples
