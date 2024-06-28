Write-Host "Executing: git clone $env:PADDLE_BRANCH from: https://github.com/PaddlePaddle/Paddle"
git clone --depth 1 -b $env:PADDLE_BRANCH https://github.com/PaddlePaddle/Paddle C:\Paddle
mkdir C:\Paddle\Build
cd C:\Paddle\Build

cmake .. -GNinja -DWITH_MKL=ON -DWITH_GPU=ON -DON_INFER=ON -DWITH_PYTHON=OFF -DWITH_UNITY_BUILD=ON -DCUDA_ARCH_NAME=Manual -DCUDA_ARCH_BIN="61;75" -DCMAKE_CUDA_ARCHITECTURES="61-real;75-real" -DWITH_ONNXRUNTIME=ON -DWITH_TENSORRT=ON -DTENSORRT_ROOT="C:\cu120"
ninja all

Compress-Archive -Path C:\Paddle\Build\paddle_inference_c_install_dir\* -DestinationPath C:\Paddle\Build\c.zip
Compress-Archive -Path C:\Paddle\Build\paddle_inference_install_dir\* -DestinationPath C:\Paddle\Build\cpp.zip
cp C:\Paddle\Build\paddle_inference_install_dir\paddle\lib\common* C:\Paddle\Build\paddle_inference_c_install_dir\paddle\lib
ls C:\Paddle\Build
