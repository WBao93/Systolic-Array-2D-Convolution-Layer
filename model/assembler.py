import sys

if (len(sys.argv) == 1):
    input_file_name = 'inst.asm'
    
else:
    input_file_name = str(sys.argv[1])

input_file = open(input_file_name, "r")
output_file = open(("./hex/inst.hex"), "w")

for line in input_file:
    out_code = 0
    args_array = line.replace(","," ").rsplit()

    print(args_array)

    try:
        if(args_array[0] == "LF"):
            out_code = format(1, '01X') + format(int(args_array[1])-1, '01X') + format(int(args_array[2])-1,'01X') + format(int(args_array[3]), '05X')
            
        elif(args_array[0] == "LS"):
            out_code = format(2, '01X') + format(0, '01X') + format(int(args_array[1])-1, '03X') + format(int(args_array[2])-1, '03X');

        elif(args_array[0] == "LI"):
            out_code = format(3, '01X') + format(0, '02X') + format(int(args_array[1]), '05X');

        elif(args_array[0] == "DC"):
            out_code = format(4, '01X') + format(0, '07X')
            
        else:
            output_file.write("SYNTAX ERROR\n")
            
    except:
       print("Error")

    print(out_code)
    output_file.write(str(out_code))
    output_file.write("\n")


input_file.close()
output_file.close()
