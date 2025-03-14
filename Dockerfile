# 使用 Ubuntu 22.04 基础镜像
FROM ubuntu:22.04

# 避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 配置时区（ROS依赖可能涉及时间相关库）
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 安装基础工具和ROS依赖
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    software-properties-common \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 添加ROS Noetic源（强制兼容22.04）
RUN echo "deb [arch=amd64,trusted=yes] http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list

# 添加官方GPG key
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | apt-key add -

# 安装ROS基础包（最小化安装）
RUN apt-get update && apt-get install -y \
    ros-noetic-ros-base \
    python3-rosdep \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool \
    && rm -rf /var/lib/apt/lists/*

# 初始化rosdep（增加重试机制）
RUN rosdep init || true \
    && (rosdep update || rosdep update || rosdep update)

# 配置环境变量
RUN echo "source /opt/ros/noetic/setup.bash" >> /root/.bashrc
ENV ROS_DISTRO=noetic
ENV ROS_PYTHON_VERSION=3

# 验证安装
RUN apt-get update && apt-get install -y \
    ros-noetic-turtlesim \
    && rm -rf /var/lib/apt/lists/*

# 设置默认命令
CMD ["/bin/bash", "-c", "source /opt/ros/noetic/setup.bash && roscore"]
