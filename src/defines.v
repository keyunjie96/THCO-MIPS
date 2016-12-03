`define ChipDisable         1'b0                    // 芯片禁止
`define ChipEnable          1'b1                    // 芯片使能
`define RstDisable          1'b1                    // 芯片禁止
`define RstEnable           1'b0                    // 芯片使能
`define ZeroWord            16'h0000                // 16位0
`define WriteEnable         1'b1                    // 使能写
`define WriteDisable        1'b0                    // 禁止写
`define ReadEnable          1'b1                    // 使能读
`define ReadDisable         1'b0                    // 禁止读
`define Stop                1'b1
`define NoStop              1'b0
`define Enable              1'b1
`define Disable             1'b0
`define PcUnit              2'b01

`define ZHalfWord           8'bZZZZZZZZ
`define HalfWordBus         7:0

`define BadLand             16'hFFF0

`define InstAddrBus         15:0                    // 指令ROM地址线宽度
`define InstBus             15:0                    // 指令ROM数据线宽
`define InstWordBus         15:0                     // 指令ROM数据单字线宽
`define AluOpBus            3:0                     // ALU操作码宽度

`define MemAddrBus          15:0                    // 主存地址线宽
`define MemBus              15:0                    // 主存数据线宽
`define HighZWord           16'bZ
`define MemRead             1'b0
`define MemWrite            1'b1

`define FunctBus2           1:0
`define FunctBus3           2:0
`define FunctBus5           4:0
`define FunctBus8           7:0
`define FunctBus11          10:0

`define SerialIOAddr        16'hBF00
`define SerialStatusAddr    16'hBF01
`define KeyboardStatusAddr  16'hBE12
`define KeyboardIOAddr      16'hBE13
`define RandomIOAddr        16'hBE14
`define DisableRegAddr      4'hF

// ALU操作
`define ALU_NOP             4'b0000                 // NOP
`define ALU_ADD             4'b0001
`define ALU_SUB             4'b0010
`define ALU_AND             4'b0011
`define ALU_OR              4'b0100
`define ALU_NOT             4'b0101
`define ALU_SLL             4'b0110
`define ALU_SRA             4'b0111
`define ALU_SLT             4'b1000
`define ALU_CMP             4'b1001
`define ALU_SW              4'b1010
`define ALU_LW              4'b1011

// 指令op段
`define OP_NOP              5'b00001
`define OP_B                5'b00010
`define OP_BEQZ             5'b00100
`define OP_BNEZ             5'b00101
`define OP_SLL_SRA          5'b00110                //SLL SRA
`define OP_ADDIU3           5'b01000
`define OP_ADDIU            5'b01001
`define OP_SLTI             5'b01010
`define OP_BTEQZ_MTSP_ADDSP 5'b01100                //BTEQZ MTSP ADDSP
`define OP_LI               5'b01101
`define OP_CMPI             5'b01110
`define OP_LW_SP            5'b10010
`define OP_LW               5'b10011
`define OP_SW_SP            5'b11010
`define OP_SW               5'b11011
`define OP_TRINARY          5'b11100                //ADDU SUBU
`define OP_LOGIC_JUMP       5'b11101                //AND OR NOT CMP
                                                    //MFPC
                                                    //JR JRRA JALR
`define OP_MFIH_MTIH        5'b11110                //MFIH MTIH

//指令funct段
`define FUNCT_SLL           2'b00
`define FUNCT_SRA           2'b11
`define FUNCT_BTEQZ         3'b000
`define FUNCT_ADDSP         3'b011
`define FUNCT_MTSP          3'b100
`define FUNCT_ADDU          2'b01
`define FUNCT_SUBU          2'b11
`define FUNCT_AND           5'b01100
`define FUNCT_OR            5'b01101
`define FUNCT_MFPC          8'b01000000
`define FUNCT_NOT           5'b01111
`define FUNCT_CMP           5'b01010
`define FUNCT_JR            8'b00000000
`define FUNCT_JRRA          11'b00000100000
`define FUNCT_JALR	        8'b11000000
`define FUNCT_MFIH	        8'b00000000
`define FUNCT_MTIH	        8'b00000001

//特殊寄存器
// `define REG_PC              4'b1000
`define REG_SP              4'b1001
`define REG_IH              4'b1010
`define REG_RA              4'b1011
`define REG_T               4'b1100

//寄存器参数
`define RegAddrBus          3:0                     // 寄存器地址，4位
`define RegBus              15:0                    // 寄存器数据宽，16位
`define RegNum              16                      // 寄存器数量
             // 0号寄存器地址

// 暂停
`define StallRegBus         5:0
`define StallDisable        6'b000000

// 指令存储器
`define InstMemNum          128                     // 指令存储器ROM大小
`define InstMemNumLog2      8
`define InstHi              15:8                   //指令低位部分
`define InstLo              7:0                    //指令高位部分

// 串口
`define UartRegBus          7:0
//串口状态机
`define r0                  4'b0000
`define r1                  4'b0001
`define r2                  4'b0010
`define r3                  4'b0011
`define w0                  4'b1000
`define w1                  4'b1001
`define w2                  4'b1010
`define w3                  4'b1011
`define w4                  4'b1100
