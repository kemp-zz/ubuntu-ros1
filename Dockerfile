FROM ubuntu:22.04

# 设置时区和非交互模式
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    apt-get update && apt-get install -y tzdata && \
    dpkg-reconfigure --frontend noninteractive tzdata

# 更换 Ubuntu 官方源为阿里云镜像加速
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装基础工具链
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    software-properties-common \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 添加 ROS 官方源（适配 Ubuntu 20.04）
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros-latest.list \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

# 安装 ROS Noetic 核心包
RUN apt-get update && apt-get install -y \
    ros-noetic-ros-base \
    python3-rosdep \
    python3-rosinstall-generator \
    python3-wstool \
    && rm -rf /var/lib/apt/lists/*

# 后续步骤保持不变...
# 初始化 rosdep（使用国内优化版 rosdepc）
RUN apt-get update && apt-get install -y python3-pip && \
    pip3 install rosdepc -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    rosdepc init && rosdepc update

# 配置环境变量（支持多用户场景）
ENV ROS_DISTRO=noetic \
    ROS_PYTHON_VERSION=3 \
    ROS_VERSION=1
RUN echo "source /opt/ros/noetic/setup.bash" >> /etc/bash.bashrc

# 验证安装（精简测试项）
RUN apt-get update && apt-get install -y \
    ros-noetic-turtlesim \
    && rm -rf /var/lib/apt/lists/*
CMD ["bash", "-c", "source /opt/ros/noetic/setup.bash && roscore && rosrun turtlesim turtlesim_node"]
