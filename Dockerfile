# 使用 Ubuntu 22.04 基础镜像
FROM ubuntu:22.04

# 强制指定时区（避免tzdata交互式提示）
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    apt-get update && apt-get install -y tzdata && \
    dpkg-reconfigure --frontend noninteractive tzdata

# 安装基础工具链（增加国内镜像源配置）
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    software-properties-common \
    build-essential \
    python3-yaml \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 添加 Autolabor 的 ROS Noetic 源（适配 Ubuntu 22.04 的核心修改）
RUN echo "deb [arch=amd64 trusted=yes] http://deb.repo.autolabor.com.cn jammy main" > /etc/apt/sources.list.d/autolabor.list && \
    curl -sSL http://deb.repo.autolabor.com.cn/autolabor.gpg | apt-key add -

# 安装 ROS Noetic 核心组件（网页1提供的兼容方案）
RUN apt-get update && apt-get install -y \
    ros-noetic-autolabor \
    python3-rosdep \
    python3-rosinstall-generator \
    python3-wstool \
    && rm -rf /var/lib/apt/lists/*

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
