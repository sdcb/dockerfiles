FROM sdflysha/msvc2019:latest

ARG PADDLE_VERSION

RUN git clone --depth 1 -b release/$PADDLE_VERSION https://github.com/PaddlePaddle/Paddle C:\Paddle && `
    cd C:\Paddle && `
    mkdir Build && `
    cd Build
RUN cmake .. -GNinja `
    -DWITH_AVX=OFF `
    -DWITH_MKL=OFF `
    -DWITH_GPU=OFF `
    -DON_INFER=ON `
    -DWITH_PYTHON=OFF `
    -DWITH_ONNXRUNTIME=ON `
    -DWITH_UNITY_BUILD=ON
RUN ninja all
RUN Compress-Archive -Path `
        C:\Paddle\Build\paddle_inference_c_install_dir, `
        C:\Paddle\Build\paddle_inference_install_dir `
    -DestinationPath C:\Paddle\Build\build.zip