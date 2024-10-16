import numpy as np
import matplotlib.pyplot as plt
import struct  # 打包成二进制
from matplotlib import rcParams

rcParams['font.sans-serif'] = ['SimHei']  # 使用支持中文的字体
rcParams['axes.unicode_minus'] = False     # 确保负号显示正确

#波形数据参数
data_length = 1024
amplitude = 1024

# 辅助函数：将整数转换为补码表示的 32 位二进制字符串
def to_twos_complement(value, bit_width=32):
    if value >= 0:
        return format(value, f'0{bit_width}b')  # 正数直接转换为二进制
    else:
        return format((1 << bit_width) + value, f'0{bit_width}b')  # 负数以补码形式转换为二进制

def dds_init():
    with open('dds_init.txt', 'w') as dds_init_file:
        # 生成三角波
        triangle_wave = 4 * amplitude * np.abs(np.linspace(-0.5, 0.5, data_length)) - amplitude
        for value in triangle_wave:
            bin_value = to_twos_complement(int(value))  # 转换为32位二进制字符串
            dds_init_file.write(f"{bin_value}\n")  # 'i'表示整数
        # 生成正弦波
        x = np.linspace(0, 2 * np.pi, data_length)
        sine_wave = amplitude * np.sin(x)
        for value in sine_wave:
            bin_value = to_twos_complement(int(value))  # 转换为32位二进制字符串
            dds_init_file.write(f"{bin_value}\n")  # 'i'表示整数
        # 生成方波
        square_wave = amplitude * np.sign(np.sin(x))
        for value in square_wave:
            bin_value = to_twos_complement(int(value))  # 转换为32位二进制字符串
            dds_init_file.write(f"{bin_value}\n")  # 'i'表示整数
        dds_init_file.close()

        plt.figure(figsize=(12, 8))# 创建图形窗口和子图

        plt.subplot(3, 1, 1)# 绘制三角波
        plt.plot(triangle_wave)
        plt.title('三角波')

        plt.subplot(3, 1, 2)  # 绘制方波
        plt.plot(sine_wave)
        plt.title('正弦波')

        plt.subplot(3, 1, 3)# 绘制方波
        plt.plot(square_wave)
        plt.title('方波')

        plt.tight_layout()# 调整布局，显示图像
        plt.show()

if __name__ == "__main__":
    dds_init()