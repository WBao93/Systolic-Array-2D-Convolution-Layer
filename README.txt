########################################################################
#                                                                      #
#       UCSD CSE 240D WI19: Accelerator Design for Deep Learning       #
#                                                                      #
#   A systolic array-based single convolution later in SystemVerilog   #
#                   by William Bao and Dylan Vizcarra                  #
#                                                                      #
########################################################################

Description: 

This is a fully working synthesizable hardware single convolution layer 
in SystemVerilog. We intend this design to be an example for future 
students taking this class or a similar Machine Learning hardware-
acceleration course. This design can be used as either inspiration
or as a foundation for building a more complicated design.

Contents:

Please refer to the Final Report pdf for all documentation. The ./source/
folder contains all of the SystemVerilog source code and cycle-accurate 
testbench as well as ModelSim project files. The ./model/ folder contains 
the Python Assembly compiler (aka assembler) and the non-cycle accurate 
Python model/simulator which generates input and test vectors for the 
testbench. The "Simulation Framework" section of the Final Report explains
this folder structure and usage in more detail and will guide you through
an example simulation run. 

Dependencies:

- A SystemVerilog simulator such as ModelSim. Note that not all HDL 
  simulators are SystemVerilog compatible.

- Python 2.7 or 3.4+ with imageio and numpy. Note that this dependency is
  not required if you decide not to use our provided simulation framework
  and decide to manually generate your own input and test vectors for the 
  testbench.