# coding=utf-8
import os
import sys

ass_file = sys.argv[1] if len(sys.argv) > 1 else 'test_program.s'
bin_file = sys.argv[2] if len(sys.argv) > 2 else 'test_program.bin'
template_file = sys.argv[3] if len(sys.argv) > 3 else 'inst_rom.template.v'
output_file = sys.argv[4] if len(sys.argv) > 4 else 'inst_rom.v'

os.system(' '.join(['Assembleler.exe', ass_file, bin_file]))    # 汇编转为二进制文件
bin_file_data = []

# 读取二进制文件
with open(bin_file, 'rb') as f:
    bin_file_data = f.read()
# 转为十六进制
bin_file_data = ['0' * (2 - len(hex(ord(x))[2:])) + hex(ord(x))[2:] for x in bin_file_data]
bin_file_data = [''.join(bin_file_data[i * 2:i * 2 + 2]) for i in range(0, len(bin_file_data) / 2)]  # 合并相邻两个字为指令
# 生成case语句
inst_rom_text = []
indent = ' ' * 10
addr = 0
for hex_data in bin_file_data:
    inst_rom_text.append(indent + '16\'h{:04X}'.format(addr) + ': inst = 16\'h' +
                         (hex_data[2:] + hex_data[0:2]).upper() + ';\n')
    addr = addr + 2

# 根据模板生成verilog文件
template = ''
with open(template_file, 'r') as f:
    template = f.readlines()
insert_point = template.index('/**instructions**/\n') + 1
template[insert_point:insert_point] = inst_rom_text

with open(output_file, 'w') as f:
    f.write(''.join(template))
