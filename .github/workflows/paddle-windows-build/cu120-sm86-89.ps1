Write-Host "Executing: git clone $env:PADDLE_BRANCH from: https://github.com/PaddlePaddle/Paddle"
git clone --depth 1 -b $env:PADDLE_BRANCH https://github.com/PaddlePaddle/Paddle C:\Paddle
mkdir C:\Paddle\Build
cd C:\Paddle\Build

cmake .. -GNinja -DWITH_MKL=ON -DWITH_GPU=ON -DON_INFER=ON -DWITH_PYTHON=OFF -DWITH_UNITY_BUILD=ON -DCUDA_ARCH_NAME=Manual -DCUDA_ARCH_BIN="86;89" -DCMAKE_CUDA_ARCHITECTURES="86-real;89-real" -DWITH_ONNXRUNTIME=ON -DWITH_TENSORRT=ON -DTENSORRT_ROOT="C:\cu120"
ninja all

cp C:\Paddle\Build\paddle_inference_install_dir\paddle\lib\common* C:\Paddle\Build\paddle_inference_c_install_dir\paddle\lib
Compress-Archive -Path C:\Paddle\Build\paddle_inference_c_install_dir\* -DestinationPath C:\Paddle\Build\c.zip
Compress-Archive -Path C:\Paddle\Build\paddle_inference_install_dir\* -DestinationPath C:\Paddle\Build\cpp.zip
ls C:\Paddle\Build
