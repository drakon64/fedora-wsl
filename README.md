# fedora-wsl

A simple PowerShell script to port Fedora Remix to WSL 2.

## Requirements

The script requires you to have internet access and to have WSL 2 installed, to install WSL 2 the instructions can be found [here](https://docs.microsoft.com/en-us/windows/wsl/install).

## Usage

The script has three optional parameters

* Distribution - Allows you to define the name of the distribution that will be added to WSL
* Path         - Change the path where the distribution will be located
* SetDefault   - Set Fedora to the default distribution in WSL
* Wslu         - Install the `wslu` package for Windows integration
