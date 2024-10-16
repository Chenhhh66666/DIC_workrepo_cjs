# RAM学习记录

## 学习博客

[FPGA-学会使用vivado中的存储器资源RAM（IP核）-CSDN博客](https://blog.csdn.net/weixin_46897065/article/details/136325283)

[如何实现三种不同RAM？（单端口RAM、伪双端口RAM、真双端口RAM|verilog代码|Testbench|仿真结果）_伪双端口ram数据仿真-CSDN博客]()

[RAM的coe文件与简单DDS实现 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/374150942)

[Vivado使用（3）——综合属性_vivado 综合选项-CSDN博客](https://blog.csdn.net/apple_53311083/article/details/137144053)

## coe

### coe文件

文件是一种常见的初始化文件格式，用于在 FPGA 或其他硬件设计中初始化存储器（如 RAM）。它通常包含了一系列的初始化数据，这些数据在硬件设计上电或复位时被加载到存储器中。.coe 文件的全称是 "Coefficient File"，但它更多地与存储器初始化相关，而不是系数。

### coe文件通用语法格式：

```
Keyword =Value ; 注释
<Radix_Keyword> =Value ; 注释
<Data_Keyword> =Data_Value1, Data_Value2, Data_Value3;
```

### coe文件包含参数

* memory_initialization_radix：内存初始化基数，既初始化数据类型。有效值为2、10或16，既2进制、10进制与16进制。
* memory_initialization_vector：内存初始化向量，用来定义每个内存的内容，每一个值都是**低字节对齐**，该值按照memory_initialization_radix配置的基数完成初始化。

### coe举例

```
memory_initialization_radix=10;
memory_initialization_vector=
0,1,3,7,15,31,63,127,
255,511,1023,2047,4095,8191,16383,32767,
65535,131071,262143,524287,1048575,2097151,4194303,8388607;
```

### 生成coe文件的matlab代码示例

```matlab
clc;close all;clear all;
Ac = 1023;
c = 0:1/1024:1-1/1024;
s_rom = round(Ac*sin(2*pi*c));
c_rom = round(Ac*cos(2*pi*c));
file = fopen('sin.coe','w');
fprintf(file,'memory_initialization_radix = 10;\n');
fprintf(file,'memory_initialization_vector = \n');
for i = 1:length(s_rom)
if i == length(s_rom)
fprintf(file,'%d;\n',s_rom(i));
else
fprintf(file,'%d, ',s_rom(i));
end
end
fclose(file);
file = fopen('cos.coe','w');
fprintf(file,'memory_initialization_radix = 10;\n');
fprintf(file,'memory_initialization_vector = \n');
for i = 1:length(c_rom)
if i == length(s_rom)
fprintf(file,'%d;\n',c_rom(i));
else
fprintf(file,'%d, ',c_rom(i));
end
end
fclose(file);
figure;plot(s_rom);hold on;plot(c_rom,'r');
```

## Vivado中IP核可选的RAM的多种形式

![1728715111485](image/RAM记录/1728715111485.png)

## 单端口Single Port ROM

只有一个读写端口，即一组数据线和一组地址线。

读写操作不能同时进行，因为它们共用同一组数据线。

在读写操作之间可能需要等待，因为写操作可能会影响读操作的执行。

![1728723095101](image/RAM记录/1728723095101.png)

## 简单双端口simple dual port

* 简单双端口RAM有两个端口，但一个端口仅用于写入，另一个端口仅用于读取。
* 两个端口共享相同的存储资源，但读写操作可以并行进行，因为它们有独立的地址线和数据线。
* 这种类型的RAM适用于需要同时进行读写操作的应用，但**写入和读取不能发生在同一个地址**

![1728723110133](image/RAM记录/1728723110133.png)

### 读写冲突解决：

同时读写同一地址时，能读出之前存在该地址的旧数据，也能将要写的新数据正确写入到该地址，那写端口的操作模式一定要选择 `READ_FIRST`或者 `NO_CHANGE`。

如果选择 `WRITE_FIRST`，那么当读写冲突时，读出的数据是此时准备写入的数据，并不是之前存储的数据。

## 真双端口true dual port

* 真双端口RAM有两个完全独立的端口，每个端口都可以进行读写操作。
* 两个端口可以同时进行读写，且彼此互不干扰，因为它们有独立的地址线和数据线。
* **写入和读取能发生在同一个地址**

![1728723118963](image/RAM记录/1728723118963.png)

### 读写冲突解决：

1、读和写冲突：如果读和写同时有效，且读和写是同一个地址时，发生RAM读写冲突，此时会把最新的写数据直接赋给读数据，称为**写穿通到读**
2、写和写冲突：表示两个端口写使能同时有效且写地址相同，此时需要关断一个写，把两个写端口都需要更新的值处理到一个写端口上面，任何的DP RAM 都不支持写和写冲突。

# 培训完成记录

## coe文件初始化

使用py完成，代码如下

```python
import numpy as np
#参数配置
RADIX = 10 # 初始化的数据类型
AMPLITUDE = 1023  # 三角函数幅值
CYCLE = 1 #周期
def coe_write():
    with open('coe.txt', 'w') as coe_file:
        # 生成波形数据
        cycle_value = np.arange(0, 1-1/1024, 1/1024)
        sin_value = AMPLITUDE * np.sin(2 * np.pi * cycle_value)
        # cos_value = AMPLITUDE * np.cos(2 * np.pi * cycle_value)
        coe_file.write(f"memory_initialization_radix={RADIX};\n")
        coe_file.write(f"memory_initialization_vector=\n")
        for i in range(len(cycle_value)):
            if i == len(cycle_value)-1:
                coe_file.write(f"{sin_value[i]:.2f};\n")
                print(f"{sin_value[i]:.2f};\n")
            else:
                coe_file.write(f"{sin_value[i]:.2f},")
                print(f"{sin_value[i]:.2f},")
        coe_file.close()
        print(f"coe文件写入结束,共写入{len(cycle_value)}个数据")
if __name__ == "__main__":
    coe_write()
```

## 单端口IP核测试

### 仅测试读出数据功能

![1728896149715](image/RAM记录/1728896149715.png)

### 读完数据后紧接着写入

![1728896185667](image/RAM记录/1728896185667.png)

### 读写冲突时：（设置端口为写优先）

![1728896654596](image/RAM记录/1728896654596.png)

## 伪双端口IP核测试

### 设置写优先

![1728896749973](image/RAM记录/1728896749973.png)

![1728896757363](image/RAM记录/1728896757363.png)

## 真双端口IP核测试

### portA设置为写优先，读出数据收到写数据穿透影响

![1728896821410](image/RAM记录/1728896821410.png)

![1728896825961](image/RAM记录/1728896825961.png)

### portB设置读优先，写入数据并未造成影响

![1728896952422](image/RAM记录/1728896952422.png)

## 编写sv

### SingleportRAM编写

#### 写优先时

![1728978901398](image/RAM记录/1728978901398.png)

#### 读优先时

![1728978912851](image/RAM记录/1728978912851.png)

#### 保持模式

读数据保持不变，写数据正常写入。

![1728978932373](image/RAM记录/1728978932373.png)

使用**$readmemb(txt)**文件进行初始化，初始化之后再打开使能端，否则加载不出来内容。

在RAM面前加一个综合属性设置

```
    (* ram_style="distributed"*) logic [`WIDTH-1 : 0] RAM_DATA[0 : `DEPTH-1];  //RAM中存的数据
```

![1728970684865](image/RAM记录/1728970684865.png)

![1728970689852](image/RAM记录/1728970689852.png)

可以看到分布式和块状设计综合之后资源使用情况不一样，distributed形式的综合出来之后使用到了更多的LUT结构和fifo。

### simple dual port ram

#### 读优先

![1728978954147](image/RAM记录/1728978954147.png)

#### 写优先

![1728979083895](image/RAM记录/1728979083895.png)

#### 保持模式

![1728979359997](image/RAM记录/1728979359997.png)

### true dual port ram

#### 写写冲突发生

![1728997868578](image/RAM记录/1728997868578.png)

#### A读优先B写优先

![1728998153798](image/RAM记录/1728998153798.png)
