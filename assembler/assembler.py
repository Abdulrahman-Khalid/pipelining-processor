import sys
import re

bitsNum = 16
initMemAddr = 0
toMemAddr = 2**11
opCodeDict = {}
variables = {}  # have key => variable name, value => address of value of the variable


def over_write_memory(memoryTuples, ramFilePath):
    generate_empty_memory(ramFilePath)
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
        for i in range(initMemAddr, initMemAddr+4):
            f.writelines(hex(i)[2:].zfill(3)+": " + "0"*bitsNum+"\n")
        for i in range(initMemAddr+4, toMemAddr):
            f.writelines(hex(i)[2:].zfill(3)+": " + "0"*bitsNum+"\n")


def load_codes():
    with open("./imports/op_codes.txt") as f:
        for line in f:
            line = re.sub(' +', ' ', line)
            line = line.replace("\n", '')
            key, _, val = line.partition(' ')
            opCodeDict[key] = val


def check_syntax_error(instructionAddress, instruction, debugLines, instructionNum, instructions):
    word = r"(^\.[wW][oO][rR][dD]\s[0-9a-fA-F]+$)"
    hexaNum = r"(^[0-9a-fA-F]+$)"
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
    no_operand = r"(^([nN][oO][pP]|[rR][tT][iI]|[rR][eE][tT]|[hH][lL][tT])\s{0,1}$)"
    org = r"(^\.[oO][rR][gG]\s{0,1}([0-7][0-9a-fA-F]{1,2}|[0-9a-fA-F]{1,2})\s{0,1}$)"
    newAddress = instructionAddress + 1
    code = ""
    if re.match(org, instruction, flags=0):  # correct
        newAddress = int((instruction.split())[1], bitsNum)
        code = "0"*bitsNum  # to avoid
    elif re.match(hexaNum, instruction, flags=0):
        code = bin(int(instruction, bitsNum))[2:].zfill(bitsNum)
        if(len(code) == bitsNum):
            debugLines.append([instruction, "hex instruction", [
                              instructionAddress], [code]])
        else:
            raise ValueError('Syntax Error: ', instruction)
    elif re.match(no_operand, instruction, flags=0):
        code = opCodeDict[instruction]
        if(bitsNum > len(code)):
            code += "0"*(bitsNum-len(code))
        debugLines.append([instruction, "no operand instruction", [
                          instructionAddress], [code]])
    elif re.match(shift_op, instruction, flags=0):
        arrayOp = (instruction.replace(',', ' ')).split()
        op, Rsrc, imm = [x for x in arrayOp]
        numOfBitsOfImm = 5
        code = opCodeDict[op]+bin(int(imm, bitsNum)
                                  )[2:].zfill(numOfBitsOfImm)+(opCodeDict[Rsrc]*2)
        if(bitsNum > len(code)):
            code += "0"*(bitsNum-len(code))
        debugLines.append([instruction, "shift  instruction", [
                          instructionAddress], [code]])
    elif re.match(swap_op, instruction, flags=0):
        arrayOp = (instruction.replace(',', ' ')).split()
        op, Rsrc1, Rsrc2 = [x for x in arrayOp]
        code = opCodeDict[op]+opCodeDict[Rsrc1]+(opCodeDict[Rsrc2]*2)
        debugLines.append([instruction, "swap operand instruction", [
                          instructionAddress], [code]])
    elif re.match(three_operand, instruction, flags=0):
        arrayOp = (instruction.replace(',', ' ')).split()
        op, R1, R2, R3 = [x for x in arrayOp]
        code = opCodeDict[op]+opCodeDict[R1] + \
            opCodeDict[R2]+opCodeDict[R3]
        debugLines.append([instruction, "three operand instruction", [
                          instructionAddress], [code]])
    elif re.match(one_operand, instruction, flags=0):
        arrayOp = instruction.split()
        op, Rdst = [x for x in arrayOp]
        code = opCodeDict[op] + opCodeDict[Rdst]
        if(bitsNum - len(code) == 3):
            if(op != "out" or op != "push"):
                code += opCodeDict[Rdst]
            else:
                code += (bitsNum - len(code))*"0"
        debugLines.append([instruction, "one operand instruction", [
                          instructionAddress], [code]])
    elif re.match(ldd_std_op, instruction, flags=0):
        arrayOp = (instruction.replace(',', ' ')).split()
        op, R, EA = [x for x in arrayOp]
        EA = (5-len(EA))*"0" + EA
        if(op == "ldd"):
            code = opCodeDict[op] + bin(int(EA[0], bitsNum)
                                        )[2:].zfill(4) + "000" + opCodeDict[R]
        else:
            code = opCodeDict[op] + bin(int(EA[0], bitsNum)
                                        )[2:].zfill(4) + opCodeDict[R] + "000"
        instructionAddress2 = newAddress
        newAddress += 1
        code2 = bin(int(EA[1:], bitsNum))[2:].zfill(bitsNum)
        debugLines.append([instruction, "ldd or std instruction", [
                          instructionAddress, instructionAddress2], [code, code2]])
    elif re.match(ldm_op, instruction, flags=0):
        arrayOp = (instruction.replace(',', ' ')).split()
        op, R, imm = [x for x in arrayOp]
        code = opCodeDict[op]+opCodeDict[R]
        instructionAddress2 = newAddress
        newAddress += 1
        code2 = bin(int(imm, bitsNum))[2:].zfill(bitsNum)
        debugLines.append([instruction, "ldm instruction", [
                          instructionAddress, instructionAddress2], [code, code2]])
    elif re.match(iadd_op, instruction, flags=0):
        arrayOp = (instruction.replace(',', ' ')).split()
        op, R1, R2, imm = [x for x in arrayOp]
        code = opCodeDict[op] + opCodeDict[R1] + opCodeDict[R2]
        instructionAddress2 = newAddress
        newAddress += 1
        code2 = bin(int(imm, bitsNum))[2:].zfill(bitsNum)
        debugLines.append([instruction, "iadd instruction", [
                          instructionAddress, instructionAddress2], [code, code2]])
    elif len(instruction.split()) == 3:
        first, second, third = instruction.split()
        if(re.match(word, second+third, flags=0)):
            code = bin(int(third, bitsNum))[2:].zfill(bitsNum)
            if(len(code) == bitsNum):
                variables[first] = instructionAddress
                debugLines.append([instruction, "variable instruction", [
                                  instructionAddress], [code]])
                return newAddress
            else:
                raise ValueError('Syntax Error: ', instruction)
    else:
        raise ValueError('Syntax Error: ', instruction)
    if(len(code) != bitsNum):  # additional check
        print(len(code))
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
    instructionAddress = 0
    for lineNum, line in enumerate(lines):
        instruction = line.partition('#')[0]
        instruction = ' '.join(instruction.split())
        if (instruction != ''):
            instructions.append((lineNum, instruction.lower()))
            debug.writelines(instruction.lower()+'\n')
    debugLines = []
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
        if(len(debugLine[2]) == 2 and len(debugLine[3]) == 2):
            debug.writelines("(instruction = {}) (instruction type = {}) two addresses in memory\n (1- address in hex = {} , 2- address in hex = {}) (instruction code = {} and {})\n".format(
                debugLine[0], debugLine[1], hex(debugLine[2][0]).zfill(3), hex(debugLine[2][1]).zfill(3), debugLine[3][0], debugLine[3][1]))
        else:
            debug.writelines("(instruction = {}) (instruction type = {}) (address in hex = {}) (instruction code = {})\n".format(
                debugLine[0], debugLine[1], hex(debugLine[2][0]).zfill(3), debugLine[3][0]))
    debug.writelines(
        "----------------------------- END INSTUCTION INFORMATION LIST -------------------------------\n")
    debug.close()
    # check if there is a Syntax Error:
    # (address in decimal, instruction code)
    if(isFailed):
        print("Failed Compile")
        return False
    print("Successful Compile")
    memoryTuples = []
    for line in debugLines:
        for idx in range(len(line[-2])):
            memoryTuples.append((line[-2][idx], line[-1][idx]))
    return memoryTuples
