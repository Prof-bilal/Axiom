# NVIDIA CUDA Toolkit

## When to use
- You are building or running GPU-accelerated C/C++ code on an NVIDIA GPU under Linux.
- You need `nvcc`, the CUDA runtime, and the GPU math libraries for a project.
- You want the sample programs (deviceQuery, bandwidthTest) to check the GPU works.
- You need to match a CUDA version to a framework or library you are building against.

## How it works
- Installed from NVIDIA's repositories with `apt install cuda-toolkit` or `dnf install cuda-toolkit`, or from a `.run` file.
- Since CUDA 13.4 the toolkit does not install the GPU driver; install a compatible driver separately.
- Needs a CUDA-capable NVIDIA GPU; supported architectures are listed on NVIDIA's CUDA GPU page.
- Put `/usr/local/cuda-<version>/bin` on `PATH` and its `lib64` on `LD_LIBRARY_PATH` so `nvcc` and the libraries are found.

## Not for
- Machines without an NVIDIA GPU (AMD and Intel GPUs need other stacks).
- Runtime-only use: the pip wheel `nvidia-cuda-runtime` does not include the developer tools.

## Sources
- https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html
- https://developer.nvidia.com/cuda-toolkit
- https://developer.nvidia.com/cuda-downloads
- https://github.com/NVIDIA/cuda-samples
