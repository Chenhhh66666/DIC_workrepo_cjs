# 设计任务：RAM&DDS

## 	任务一：RAM设计

1.  使用Xilinx的IP

​	使用脚本语言生成初始化RAM的coe文件。 学习单端口，simple dual port和true dual port的工作原理。分别写testbench进行测试。

要求深度1024位宽32。

​	学习RAM读写冲突的读优先、写优先、保持处理模式，在testbench中产生读写冲突进行测试。

2. 使用sv写上述三种RAM

- 设计深度、位宽可配置，读写冲突可配置的单端口，simple dual port和true dual port RAM，学习**综合属性**的相关内容，怎么通过代码指导让ide综合出不同实现形式的RAM。要求设计可配置实现形式（distributed 和 block）

- 使用脚本语言生成初始化RAM的文件，在代码中实现RAM的初始化。

- 完成测试



## 	任务二：DDS设计

​	学习DDS原理，使用任务一完成的RAM设计一个初始相位可调；步长可调；正弦波、方波、三角波可切换的DDS。深度不小于1024，位宽自行决定。

​	完成测试

\*附加：优化DDS的存储方式，只存储半周期或四分之一周期的波形数据，通过算法完成波形恢复。

