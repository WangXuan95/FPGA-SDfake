![test](https://img.shields.io/badge/test-passing-green.svg)
![docs](https://img.shields.io/badge/docs-passing-green.svg)

FPGA SDcard Simulator
===========================
FPGA 模拟 SD卡。

* **基本功能** ：**FPGA模仿SD卡行为** ，实现一个 **SDHCv2** 版本的 、**FAT32文件系统** 的 **只读卡** 。
* **兼容性**  : 已在绿联、川宇等多种品牌的读卡器上识别
* **RTL实现** ：完全使用 **SystemVerilog**  , 便于移植和仿真。

# 目录组织

* **核心代码** : 详见 [RTL目录](https://github.com/WangXuan95/FPGA-SDcard-Simulator/blob/master/RTL/ "RTL目录") 。

* **示例工程** : 详见 [Quartus 示例](https://github.com/WangXuan95/FPGA-SDcard-Simulator/blob/master/example-Quartus/ "Quartus 示例") (基于Altera FPGA的示例) 。

# 相关链接

* [FPGA SD卡读取器 (SD总线版本)](https://github.com/WangXuan95/FPGA-SDcard-Reader/ "SD总线版本")

* [FPGA SD卡读取器 (SPI总线版本)](https://github.com/WangXuan95/FPGA-SDcard-Reader-SPI/ "SPI版本")
