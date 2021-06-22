sudo apt install -y curl gnupg lsb-release
curl -Ls https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64,arm64] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'
sudo apt update
sudo apt install -y ros-dashing-desktop
sudo apt install -y python3-argcomplete python3-colcon-common-extensions
sudo apt install -y python-rosdep python3-vcstool