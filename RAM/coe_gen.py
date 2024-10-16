import numpy as np
import matplotlib.pyplot as plt
from matplotlib import rcParams

rcParams['font.sans-serif'] = ['SimHei']  # 使用支持中文的字体
rcParams['axes.unicode_minus'] = False     # 确保负号显示正确

#参数配置
RADIX = 10 # 初始化的数据类型
AMPLITUDE = 1023  # 三角函数幅值
CYCLE = 1 #周期

def coe_write():
    with open('coe_tb.txt', 'w') as coe_file:
        # 生成波形数据
        cycle_value = np.arange(0, 1-1/1024, 1/1024)
        sin_value = AMPLITUDE * np.sin(2 * np.pi * cycle_value)
        # cos_value = int(AMPLITUDE * np.cos(2 * np.pi * cycle_value))
        # IP能用的数据
        # coe_file.write(f"memory_initialization_radix={RADIX};\n")
        # coe_file.write(f"memory_initialization_vector=\n")  
        # for i in range(len(cycle_value)):
            # if i == len(cycle_value)-1:
                # coe_file.write(f"{int(sin_value[i])};\n")
                # print(f"{int(sin_value[i])}\n")
            # else:
                # coe_file.write(f"{int(sin_value[i])},")
                # print(f"{int(sin_value[i])},")
        # 手搓IP核能用的初始化文件
        for i in range(len(cycle_value)):
            coe_file.write(f"{int(abs(sin_value[i])):032b}\n")
            print(f"{int(abs(sin_value[i])):032b}\n")

        coe_file.close()
        print(f"coe文件写入结束,共写入{len(cycle_value)}个数据")
        #画个图展示数据
        plt.figure()
        x = range(len(cycle_value))
        y = abs(sin_value)
        plt.plot(x, y, linestyle='-', color='b', label='RAM初始化数据')
        plt.title('RAM初始化数据')
        plt.xlabel('x')
        plt.ylabel('初始化数据')
        plt.legend()
        plt.grid()
        plt.show()

if __name__ == "__main__":
    coe_write()