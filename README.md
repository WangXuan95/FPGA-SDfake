![test](https://img.shields.io/badge/test-passing-green.svg)
![docs](https://img.shields.io/badge/docs-passing-green.svg)
![platform](https://img.shields.io/badge/platform-Quartus|Vivado-blue.svg)

FPGA SDcard Simulator
===========================
FPGA 模拟 SD卡。

* **基本功能** ：**FPGA模仿SD卡行为** ，实现一个 **SDHCv2** 版本的 、**FAT32文件系统** 的 **只读卡** 。
* **兼容性强**  : 依据 **SDv2.0** 规范编写，已在 **绿联** 、 **川宇** 、 **飚王** 、**Realtek PCIe Card Reader** 等读卡器上识别。
* **RTL实现** ：完全使用 **SystemVerilog**  , 便于移植和仿真。

| ![Arty-Connection](https://github.com/WangXuan95/FPGA-SDcard-Simulator/blob/master/images/Arty-Connection.jpg) |
| :----------: |
| 图：**FPGA模拟SD卡** 与 **真实的SD卡** |

# 快速开始

* **硬件电路** : 详见 [PMOD SDcard Simulator Board For FPGA](https://github.com/WangXuan95/FPGA-SDcard-Simulator/blob/master/hardware/)

* **Xilinx 示例** : [基于 Arty-7 开发板的示例工程](https://github.com/WangXuan95/FPGA-SDcard-Simulator/blob/master/example-Vivado/)

* **Altera 示例** : [基于 Altera FPGA 的示例工程](https://github.com/WangXuan95/FPGA-SDcard-Simulator/blob/master/example-Quartus/)

* **核心代码** : 详见 [RTL目录](https://github.com/WangXuan95/FPGA-SDcard-Simulator/blob/master/RTL/)

# 相关链接

* [FPGA SD卡读取器](https://github.com/WangXuan95/FPGA-SDcard-Reader) (SD总线版本)

* [FPGA SD卡读取器](https://github.com/WangXuan95/FPGA-SDcard-Reader-SPI) (SPI总线版本)
