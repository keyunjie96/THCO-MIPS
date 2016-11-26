`define ChipDisable         1'b0                    // 芯片禁止
`define ChipEnable          1'b1                    // 芯片使能
`define RstDisable          1'b0                    // 芯片禁止
`define RstEnable           1'b1                    // 芯片使能
`define ZeroWord            16'h0000                // 16��
`define WriteEnable         1'b1                    // 使能��
`define WriteDisable        1'b0                    // 禁止��
`define ReadEnable          1'b1                    // 使能��
`define ReadDisable         1'b0                    // 禁止��
`define Stop                1'b1
`define NoStop              1'b0
`define Enable              1'b1
`define Disable             1'b0


`define InstAddrBus         15:0                    // 指令ROM地址线宽��
`define InstBus             15:0                    // 指令ROM数据线宽
`define InstWordBus         7:0                // 指令ROM数据单字线宽
`define AluOpBus            3:0                     // ALU操作码宽��
`define MemAddrBus          15:0                    // 主存地址线宽��
`define MemBus              15:0                    // 主存数据线宽��
`define HighZWord           16'bZ
`define MemRead             1'b0
`define MemWrite            1'b1

`define SerialIOAddr        16'hBF00
`define SerialStatusAddr    16'hBF01

// ALU操作��
`define ALU_NOP             4'b0000                 // NOP
`define ALU_ADD             4'b0001

// 指令op��
`define OP_ADDIU3           5'b01000                // ADDIU3

`define RegAddrBus          3:0                     // 寄存器地址����
`define RegBus              15:0                    // 寄存器数据宽��6��
`define RegNum              16                      // 寄存器数��
`define RegZero             4'b0000                 // 0号寄存器地址

// 指令存储��
`define InstMemNum          128                     // 指令存储器ROM大小
`define InstMemNumLog2      8
`define InstHi              15:8                   //指令低位部分
`define InstLo              7:0                    //指令高位部分
