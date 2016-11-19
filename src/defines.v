`define ChipDisable         1'b0                    // 芯片禁止
`define ChipEnable          1'b1                    // 芯片使能
`define RstDisable          1'b0                    // 芯片禁止
`define RstEnable           1'b1                    // 芯片使能
`define ZeroWord            16'h0000                // 16位0
`define WriteEnable         1'b1                    // 使能写
`define WriteDisable        1'b0                    // 禁止写
`define ReadEnable          1'b1                    // 使能读
`define ReadDisable         1'b0                    // 禁止读
`define Stop                1'b1
`define NoStop              1'b0
`define Enable              1'b1
`define Disable             1'b0


`define InstAddrBus         15:0                    // 指令ROM地址线宽度
`define InstBus             15:0                    // 指令ROM数据线宽
`define AluOpBus            3:0                     // ALU操作码宽度

// ALU操作码
`define ALU_NOP             4'b0000                 // NOP
`define ALU_ADD             4'b0001

// 指令op段
`define OP_ADDIU3           5'b01000                // ADDIU3

`define RegAddrBus          3:0                     // 寄存器地址，4位
`define RegBus              15:0                    // 寄存器数据宽，16位
`define RegNum              16                      // 寄存器数量
`define RegZero             4'b0000                 // 0号寄存器地址

// 指令存储器
`define InstMemNum          128                     // 指令存储器ROM大小
