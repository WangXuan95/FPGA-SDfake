FPGA 模拟 SD卡 示例
===========================

该示例用FPGA模拟一个格式化好的SD卡(FAT32)。将FPGA相应引脚接在读卡器上，能识别出SD卡，如下图：

![Windows识别出的FPGA模拟SD卡](https://github.com/WangXuan95/FPGA-SDcard-Simulator/blob/master/images/FakeSDcardResult.png)

# 硬件电路

如下图，你需要想办法将 **FPGA连接到读卡器** 。笔者画了一个 **SD卡形状的PCB** ，能插入读卡器中。 当然，你可以采取飞线的方式等，电路如下图。

**注意事项** ：

* **R1电阻、C1电容** 是必要的，用于产生电源电流，有些读卡器以电源电流为SD卡插入的判据。
* **R2电阻** 是必要的，因为 DAT3 信号兼具 SD卡插入上拉检测功能。
* **SDVCC电源** 由读卡器提供， **不允许** 用于给 FPGA 系统供电， FPGA应该使用开发板自身的电源。

![硬件电路](https://github.com/WangXuan95/FPGA-SDcard-Simulator/blob/master/images/FakeSD_sch.png)

笔者的测试平台：

![测试平台](https://github.com/WangXuan95/FPGA-SDcard-Simulator/blob/master/images/FakeSD_platform.png)

# 工程说明

在编译综合前，请根据实际情况选择器件。并为 **top.sv** 分配引脚，每个引脚的具体含义见 **top.sv** 的注释

# 调试

该示例可以将SD-host发送的命令通过UART反馈出来。如果想打开调试功能，请在 **top.sv** 的开头去掉 **DEBUG_INFO** 宏的注释，分配相关引脚后重新综合工程。调试信息将会通过 **uart_tx** 引脚发送出来（波特率=115200）
