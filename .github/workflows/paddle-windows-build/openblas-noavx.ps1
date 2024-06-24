Write-Host "Executing: git clone release/$env:PADDLE_VERSION from: https://github.com/PaddlePaddle/Paddle"
git clone --depth 1 -b release/$env:PADDLE_VERSION https://github.com/PaddlePaddle/Paddle C:\Paddle
mkdir C:\Paddle\Build
cd C:\Paddle\Build

cmake .. -GNinja -DWITH_AVX=OFF -DWITH_MKL=OFF -DWITH_GPU=OFF -DON_INFER=ON -DWITH_PYTHON=OFF -DWITH_ONNXRUNTIME=ON -DWITH_UNITY_BUILD=ON
ninja all

Compress-Archive -Path C:\Paddle\Build\paddle_inference_c_install_dir, C:\Paddle\Build\paddle_inference_install_dir -DestinationPath C:\Paddle\Build\build.zip
ls C:\Paddle\Build
