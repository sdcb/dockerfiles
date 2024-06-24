## msvc2019-cu120

This dockerfile contains following content:
1. cuda_12.0.1_528.33_windows.exe
2. cudnn-windows-x86_64-8.9.7.29_cuda12-archive.zip
3. TensorRT-8.6.1.6.Windows10.x86_64.cuda-12.0.zip

All extracted into `C:\cu120` folder.

Also set following environment variables:
* CUDA_TOOLKIT_ROOT_DIR: `C:\cu120`
* CUDA_PATH: `C:\cu120`
* PATH: `%PATH%; %CUDA_TOOLKIT_ROOT_DIR%\bin; %CUDA_TOOLKIT_ROOT_DIR%\libnvvp`