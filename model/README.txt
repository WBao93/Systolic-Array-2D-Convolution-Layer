assembler.py: Assembly code compiler
    
    Input:  inst.asm                            (Assembly Language)
    
    Output: ./hex/inst.hex                      (Hex Machine Code, input to testbench)

    Usage:  python assembler.py [inst.asm]
                - [inst.asm] Can be any filename. Assembler will default to 'inst.asm' if no 
                  input filename is specified. Output will always be 'inst.hex'

simulator.py: Convolution Layer

    Input:  ./hex/inst.hex                      (Hex Machine Code)
            ./images/input.jpg                  (Input Image)
            ./filters/filters.txt               (Filters in space-delimited matrix format)
                Format: Two 2x2 filters will be formatted as a string in the file as:
                    "1 2
                     3 4
                     1 2
                     3 4"
                 
    Output: ./hex/data.hex                      (Filter and Image data, input to testbench)
                Format: The input data file is formatted with 32 bytes (256-bit) per line
            ./hex/result_expected.hex           (Expected Result, input to testbench)
                Format: The result file is formatted with one result byte per line
            ./images/input_gray.jpg             (Input Grayscale Image)
            ./images/result_expected_[i].jpg    (Expected Result Image, one per input filter)
            
    Usage:  python simulator.py [input.jpg] [filters.txt]
                - [input.jpg] Can be any filename. Assembler will default to 'input.jpg' if no 
                  input filename is specified.
                - [filters.txt] Can be any filename. Assembler will default to 'filters.txt' if no 
                  input filename is specified.

---------------------------------------------------------------------------------------------

Example Usage:

example.bat

    Use this to generate an set of example inputs to the testbench by performing convolution 
    of ./images/example.jpg with two Sobel filters:

        python ./assembler.py example.asm
        python ./simulator.py example.jpg example.txt

run.bat

    Use this to generate inputs to testbench after modifying inst.asm, ./images/input.jpg, 
    and ./filters/filter.txt to your use case. This uses default file inputs.