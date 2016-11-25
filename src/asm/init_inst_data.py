#coding=utf-8
import os
import sys

ass_file = sys.argv[1] if len(sys.argv) > 1 else 'test_program.s'
bin_file = sys.argv[2] if len(sys.argv) > 2 else 'test_program.bin'
inst_file = sys.argv[3] if len(sys.argv) > 3 else 'inst_rom.data'

os.system(' '.join(['Assembleler.exe', ass_file, bin_file])) #汇编转为二进制文件
bin_file_data = open(bin_file, 'rb').read() #读取二进制文件
bin_file_data = ['0'*(2-len(hex(ord(x))[2:]))+hex(ord(x))[2:] for x in bin_file_data] #转为十六进制
bin_file_data = [''.join(bin_file_data[i*2:i*2+2]) for i in range(0, len(bin_file_data)/2)] #合并相邻两个字为指令
ass_file_data = open(ass_file, 'r').readlines() #读取汇编源文件
print 'Instruction:'
for index in range(0, len(ass_file_data)):
    print '%s : %s' % (ass_file_data[index][:-1], bin_file_data[index]) #打印显示
with open(inst_file, 'w') as f:
    for hex_data in bin_file_data:
        f.write(''.join([hex_data[0:2],'\n',hex_data[2:4],'\n']))