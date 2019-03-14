#A non-cycle accurate model that emulates the expected output given specified inputs
import sys
import os, glob
import numpy as np
import imageio
import re

#default if no arguments are supplied
if (len(sys.argv) == 1):
    image_file_name  = './images/input.jpg'
    filter_file_name = './filters/filters.txt'
    
else:
    image_file_name  = './images/' + str(sys.argv[1])
    filter_file_name = './filters/' + str(sys.argv[2])

def performConv(img, filt):
    h = img.shape[0] - (filt.shape[0]-1)
    w = img.shape[1] - (filt.shape[1]-1)
    convolution = np.zeros((h,w))
    for row in range(h):
        for col in range(w):
            for filt_row in range(filt.shape[0]):
                for filt_col in range(filt.shape[1]):
                    convolution[row][col] += img[row+filt_row][col+filt_col]*filt[filt_row][filt_col]
    convolution = convolution.clip(0,255)   #out value is 0 to 255 bit value
    convolution = np.floor(convolution + 0.5)      #round to nearest int
    return convolution.astype('uint8')

#default values
kernel_size = 2
num_filters = 2
kernel_stride = 1 
image_height = 256
image_width = 256
filter_starting_addr = 0
image_starting_addr = 10

#Get Filters
file_filter_matrix = np.loadtxt(filter_file_name)

#Get Image as array    
img_array = np.asarray(imageio.imread(image_file_name, as_gray=True), dtype='uint8')

#Get Instructions
file_instr = np.loadtxt('./hex/inst.hex', dtype=str)

#decode instructions
for instr in file_instr:

    if(instr[0] == '1'):   #Load Filter
        kernel_size = int(instr[1], 16) + 1
        num_filters = int(instr[2], 16) + 1
        filter_starting_addr = int(instr[3:8], 16)
        print ("Kernel Size :", kernel_size)
        print ("Kernel Num  :", num_filters)
        print ("Kernel Addr :", filter_starting_addr)

    elif (instr[0] == '2'):    #Load Size
        image_height = int(instr[2:5],16) + 1
        image_width = int(instr[5:8],16) + 1
        print ("Image Height:", image_height)
        print ("Image Width :", image_width)
        
    elif (instr[0] == '3'):    #Load Image
        image_starting_addr = int(instr[3:8], 16)
        print ("Image Addr  :", image_starting_addr)
        
    elif (instr[0] == '4'):    #Do Convolution
        print("Do convolution")
    else:
        print("Something went wrong")
        
#Validate filter sizing
if(kernel_size*num_filters != file_filter_matrix.shape[0]):
    print("ERROR: Incorrent number of filters")
    exit()
    
#Validate image sizing
if((image_height != img_array.shape[0]) or (image_width != img_array.shape[1])):
    print("ERROR: Size of image provided does not match size defined by instructions")
    exit()
    
#Validate image and kernel placement
if(image_starting_addr <= filter_starting_addr):
    print("ERROR: For this simulator, image must be placed after filter data")
    print("       This is a simulator constraint, not a hardware contraint")
    exit()
    
#Validate image and kernel do not overlap
if(image_starting_addr <= (filter_starting_addr + (kernel_size*kernel_size*num_filters)//32)):
    print("ERROR: Image placement overlaps with filter")
    print("       Replace and try again")
    exit()

imageio.imwrite("./images/input_gray.png", img_array.astype('uint8'))

hex_file = open("./hex/data.hex", "w")
result_file = open("./hex/result_expected.hex", "w")
result_str = ""
output_filter_string = ""

print("Wait...")

for filename in glob.glob("./images/result_expected*"):
    os.remove(filename) 

for i in range(0, num_filters):
    row_index = (i)*file_filter_matrix.shape[1]
    filter_matrix = file_filter_matrix[row_index:row_index+kernel_size, : ]     #Read one filter //+1 because kernel size is n-1
    
    #round filter data to nearest 1/8th of decimal value
    filter_matrix = (np.around(filter_matrix/.125, decimals=0)*.125)

    #Convert to Hex string and append to total string
    filter_string = (filter_matrix*8).astype('int8')
    filter_string = ("{:0>2X}" * len(filter_string.flatten())).format(*tuple(filter_string.flatten() & (2**8-1)))
    output_filter_string += filter_string
    
    #perform convolution
    result = performConv(img_array, filter_matrix)

    #Write Result File
    result_str += ("{:0>2X}" * len(result.flatten())).format(*tuple(result.flatten()))
    
    str_result = "./images/result_expected_" + str(i) + ".png"
    imageio.imwrite(str_result, result)
    
result_str = re.sub("(.{2})", "\\1\n", result_str, 0, re.DOTALL)
result_file.write(result_str)
result_file.close()

current_line = 0;
while(current_line < filter_starting_addr):
    hex_file.write('0000000000000000000000000000000000000000000000000000000000000000\n')
    current_line += 1;

while((len(output_filter_string)%64) != 0):
    output_filter_string += '0'
output_filter_string = re.sub("(.{64})", "\\1\n", output_filter_string, 0, re.DOTALL)
hex_file.write(output_filter_string)
current_line += len(output_filter_string)/64

img_array_str = ("{:0>2X}" * len(img_array.flatten())).format(*tuple(img_array.flatten()))

while(current_line < image_starting_addr):
    hex_file.write('0000000000000000000000000000000000000000000000000000000000000000\n')
    current_line += 1;
#write image data
while((len(img_array_str)%64) != 0):
    img_array_str += '0'
img_array_str = re.sub("(.{64})", "\\1\n", img_array_str, 0, re.DOTALL)
hex_file.write(img_array_str)

hex_file.close()



