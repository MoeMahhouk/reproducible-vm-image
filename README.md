## About
This is just an attempt to create a minimal reproducible Ubuntu VM image which also includes externally built binaries.
It is currently just a playground to see how far it goes. 


## Goal
A generic way to make reproducible builds for VM based TEEs. 
This way, it will make it easier to make a reproducible measurements for attestation purposes.
As well as reduce the attack surface by minimizing the TCB.
Ultimately, it would be great to reach the most minimal VM possible. Hence, it is not oligatory to be ubuntu.

## TODOs:
- [ ] Eliminate non-deterministic factors that prevent reproducible build
- [ ] Add necessary dependencies/setup to make the VM TEE aware, such as Intel TDX or AMD SEV.  
- [ ] Add networking setup customization. Cloud init?
- [ ] Create a way to generate the measurement that is necessary for the attestation process.