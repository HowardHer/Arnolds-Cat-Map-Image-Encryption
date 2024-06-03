# Hardware ASIC for Arnold's Cat Map Encryption / Decryption

Our prime motivation for this project is to create a robust and secure image encryption / decryption system using hardware, so that the efficiency in performance can be greatly improved, thus encouraging the integration of image security in various applications. Specifically, we decide to leverage chaotic maps in our encryption using the Arnold’s Cat Map algorithm.

The system that we envisioned has the ability to improve data security and privacy for images, which has proliferated over the past few years with its widespread applications. Therefore, the need for secure and robust image encryption is essential to ensure the confidentiality and integrity of this data. Some use cases we envisioned that would require good image security include medical images and records. Additionally, there has been an increase in the use of digital images online as training data for generative AI applications, where some users may find it beneficial to be able to encrypt their photos shared on social media.

Most notably, the decryption of these encrypted images requires large computational overhead when implemented in software such as Python. In this case, our dedicated accelerator using Arnold’s Cat Map for both encryption and decryption enables performance efficiency beyond what software can attain.



## Contents
We have implemented both Encryption and Decryption algorithms for Arnold's Cat Map using Software (Python, C) and Hardware (Verilog RTL). We have provided all the codes we have used to perform the software vs. hardware performance improvement.



## Getting Started

In terminal, clone the repository and its submodules: [ee477-hammer-cad](https://github.com/bsg-external/ee477-hammer-cad)

```
git clone --recurse-submodules git@github.com:HowardHer/Arnolds-Cat-Map-Image-Encryption.git
```
If you already cloned the project and forgot `--recurse-submodules`, you can use the following commands to initialize, fetch, and checkout any nested submodules. 

```
git submodule update --init --recursive
```



## Install Python Dependences

Install following dependencies needed for [python-based testbench](#ASIC/encryptor/bsg_acm/py/final_proj_pre_sim.py).
```
pip install yaml
pip install numpy
pip install tqdm
```


## ASIC `make` Commands

Go into the directory you want to run design flow (e.g. Encryptor's [bsg_acm](#ASIC/encryptor/bsg_acm/)):

Perform simulation verification with Synopsys VCS.
```
make sim-rtl
```
Perform synthesis with Cadence Genus and simulate with Synopsys VCS.
```
make syn
make sim-syn
```
Perform place-and-route(P&R) with Cadence Innovus and simulate with Synopsys VCS.
```
make par
make sim-par
```

Clean or remove entire build directory.
```
make clean-build
```

Redo any action such as synthesis or place-and-route.
```
make redo-<action>
make redo-syn
make redo-par
```
_More commands can be found in the [hammer-cad repository](https://github.com/bsg-external/ee477-hammer-cad?tab=readme-ov-file#summary-of-make-targets)._

## References Consulted

- Encryptor and Decryptor template that includes python testbench frameworks leveraging trace replay: [ee478-designs-project](https://github.com/bsg-external/ee478-designs-project)
- Submodule for VLSI design flow: [ee477-hammer-cad](https://github.com/bsg-external/ee477-hammer-cad)