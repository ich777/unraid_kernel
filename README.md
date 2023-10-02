# Unraid Kernel

This repository contains:
- pre-compiled Kernels for Unraid in the [Releases section](https://github.com/ich777/unraid_kernel/releases) (starting with Unraid 6.12.0)
- Docker containers for using the pre-compiled Kernels in the [Packages section](https://github.com/ich777/unraid_kernel/pkgs/container/unraid_kernel)
- A template for Unraid in the [template directory](https://github.com/ich777/unraid_kernel/tree/master/template)
- Example scripts in the [examples directory](https://github.com/ich777/unraid_kernel/tree/master/examples)

## Docker container:

This container enables you to compile drivers for your very own Unraid instance, create driver packages and even to upload them to GitHub.

By default it ships with a SSH server that you can connect to on port 8022 with the user 'root' and password 'secret' (password is of course changable).  

In the default configuration the container will try to download and extract a pre-compiled Kernel version for your running Unraid version.  
After that the container is prepared so that you can connect through the console or SSH and start compiling your driver(s).  
Please watch your container log, it will tell you when everything is done or if a error occoured.

**ATTENTION:** Please choose the correct container image that matches the description on GitHub for your pre-compiled Unraid version (eg: all pre-compiled Unraid Kernels for Unraid 6.12.x are based on gcc_11.2.0).

For more information please contact me on the Unraid forums (Username: ich777) or open up a GitHub issue.

## Third party software:
This container includes `github-release` from [this](https://github.com/github-release/github-release) repository.
