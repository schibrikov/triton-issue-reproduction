FROM nvcr.io/nvidia/tritonserver:21.04-py3

WORKDIR /workspace

RUN apt update

# Replace Python 3.8 with Python 3.7
RUN apt install -y software-properties-common
RUN add-apt-repository -y ppa:deadsnakes/ppa
RUN apt remove -y python3.8 python3.8-minimal python3.8-dev
RUN apt install -y python3.7 python3.7-dev rapidjson-dev

# Install pip for python3.7
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python3.7 get-pip.py

# Install numpy as python backend dev dependency
RUN pip install numpy

# Install latest version of CMake, because version in APT is outdated
COPY cmake-install.sh .
RUN chmod +x cmake-install.sh
RUN mkdir /workspace/cmake
RUN ./cmake-install.sh --skip-license --prefix=/workspace/cmake
# Making fresh cmake available
ENV PATH=/workspace/cmake/bin:$PATH

# Building python backend from source according to https://github.com/triton-inference-server/python_backend/tree/r21.04#building-from-source
RUN git clone -b r21.04 https://github.com/triton-inference-server/python_backend.git
WORKDIR python_backend
RUN mkdir build
WORKDIR build
RUN cmake -DCMAKE_INSTALL_PREFIX:PATH=/opt/tritonserver -DTRITON_BACKEND_REPO_TAG=r21.04 -DTRITON_COMMON_REPO_TAG=r21.04 ..
RUN make install

# Pre-copy our test-model to test
COPY test-model /repo/test-model

