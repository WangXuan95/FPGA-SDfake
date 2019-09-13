FPGA 模拟 SD卡 示例 （基于 Arty 开发板)
===========================

该示例用FPGA模拟一个格式化好的SD卡(FAT32)。效果如下图：

| ![Windows识别出的FPGA模拟SD卡](https://github.com/WangXuan95/FPGA-SDcard-Simulator/blob/master/images/FakeSDcardResult.png) |
| :------: |
| 图：Windows识别出的FPGA模拟SD卡 |

# 硬件连接

准备 [SDcard Simulator 转接板](https://github.com/WangXuan95/FPGA-SDcard-Simulator/blob/master/hardware/) 一个。焊接排针时，应使用 **2x6双排弯针** ，并且请 **焊接在背面**，见下图

| ![排针焊接的方向](https://github.com/WangXuan95/FPGA-SDcard-Simulator/blob/master/images/welding.png) |
| :------: |
| 图：排针焊接方向 |

将转接板插在 Arty开发板的 JD PMOD 上，请注意方向，如下图。

| ![Arty 连接](https://github.com/WangXuan95/FPGA-SDcard-Simulator/blob/master/images/Arty-Connection.jpg) |
| :------: |
| 图：Arty开发板 与 转接板 的连接示意图 |

# 下载 FPGA

打开 Vivado 工程 **Arty-FakeSD.xpr** , 笔者使用的是 Vivado2018.3 , 综合并烧录。

# 测试

如下图，SD卡转接板插入读卡器后，会在 Windows 中识别出SD卡设备。

| ![Arty 测试](https://github.com/WangXuan95/FPGA-SDcard-Simulator/blob/master/images/Arty-test.jpg) |
| :------: |
| 图：Arty开发板测试 |

# 调试

该示例可以将SD-host发送的命令通过UART反馈出来。如果想打开调试功能，请在 **top.sv** 的开头去掉 **DEBUG_INFO** 宏的注释，重新综合工程并下载FPGA。调试信息将会Arty开发板自带的UART转USB口发送到PC机上（波特率=115200）
