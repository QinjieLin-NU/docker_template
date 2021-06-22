#install webots
cd /root/ && \
wget https://github.com/cyberbotics/webots/releases/download/R2021a/webots_2021a_amd64.deb && \
apt install -y ./webots_2021a_amd64.deb

#install web dependency
apt-get update -y && \
apt-get install -y python3 python3-pip && \
apt-get install -y xvfb && \
pip3 install websocket-client tornado nvidia-ml-py3 psutil requests distro

#download worlds
cd /root/ ;\
git clone  https://github.com/QinjieLin-NU/exoedu-robot.git
