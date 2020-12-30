import random
from bitstring import Bits


BUS_BITVEC_IFMAP = [0,60] # eklusive 30
BUS_BITVEC_KERNEL = [0,54]
BUS_OFFSET_DATA = 60

BUS_DATA_IFMAP = [60,480+60]#0-255 unsigned 30 valuesi
BUS_DATA_IFMAP_VALUES = 60
BUS_DATA_KERNEL = [BUS_OFFSET_DATA,BUS_OFFSET_DATA+432]
BUS_DATA_KERNEL_VALUES = 9*6 


BUS_ZEROS_IFMAP = [BUS_DATA_IFMAP[1],BUS_DATA_IFMAP[1]+8]
BUS_ZEROS_KERNEL = [BUS_OFFSET_DATA+432,BUS_OFFSET_DATA+432+48]
BUS_ZEROS_KERNEL_VALUE = 6

BUS_COLUM_OFFSET = 548

BUS_ROW_OFFSET = BUS_COLUM_OFFSET+3


def create_ifmap_test_case(col,row):
    #create bitvec
    bitvec_ifmap = [random.randint(0,1) for i in range(BUS_BITVEC_IFMAP[1])]

    bitvec_ifmap[0] = 1
    bitvec_ifmap[1] = 0
    bitvec_ifmap[2] = 1
    
    #create values
    data_ifmap_number = [random.randint(0,255) for i in range(BUS_DATA_IFMAP_VALUES)]
    data_ifmap = data_ifmap_number.copy()
    print("IFMAP")
    print(bitvec_ifmap)
    print(data_ifmap)
    
    
    #mask for easier debugging & create bitvalues 
    for i in range(len(data_ifmap)):
        if bitvec_ifmap[i] == 0:
            data_ifmap[i] = 'U'*8
            data_ifmap_number[i] = 'U'
        else:
            a = Bits(uint = data_ifmap[i],length = 8)
            data_ifmap[i] = a.bin
    #create ZEROS
    zeroes = [Bits(uint=random.randint(0,28),length = 8).bin]
    offset_colum = [Bits(uint = col,length = 3).bin]

    offset_row = [Bits(uint = row,length = 6).bin]
    BUS = ""
    for bitvec in bitvec_ifmap:
        BUS = str(bitvec) + BUS
    for data in data_ifmap:
        BUS = str(data)+BUS
    for zero in zeroes:
        BUS = str(zero) +BUS
    for col in offset_colum:
        BUS = str(col)+BUS 
    
    for row in offset_row:
        BUS = str(row)+BUS 
    print(zeroes)
    print("######")
    return BUS, data_ifmap_number,zeroes
    #create bus column

def padd_with_u(x,BUS): 
    for i in range(x):
        BUS = 'U' +BUS
    return BUS

def create_kernel_test_case():
    BUS = ''
    bitvec_kernel =[random.randint(0,1) for i in range(BUS_BITVEC_KERNEL[1])]

    bitvec_kernel[0] = 1
    bitvec_kernel[1] = 0
    bitvec_kernel[2] = 1

    data_kernel_number = [random.randint(-128,127) for i in range(BUS_DATA_KERNEL_VALUES)]
    data_kernel = data_kernel_number.copy()
    print("KERNEL")
    print(bitvec_kernel)
    print(data_kernel)
    for i in range(len(data_kernel)):
        if bitvec_kernel[i] == 0:
            data_kernel[i] = 'U'*8
            data_kernel_number[i] = 'U'
        else:
            a = Bits(int = data_kernel[i],length = 8)
            data_kernel[i] = a.bin
    
    zeroes = [Bits(uint=random.randint(0,28),length = 8).bin for i in range(BUS_ZEROS_KERNEL_VALUE)]
    
    for bitvec in bitvec_kernel:
        BUS = str(bitvec) + BUS
    BUS = padd_with_u(6,BUS)
    for data in data_kernel:
        BUS = str(data)+BUS
    for zero in zeroes:
        BUS = str(zero) +BUS
    BUS = padd_with_u(17,BUS)
    return BUS,data_kernel_number,zeroes


def calc_out_index(index,shift,kernel_number,row,col):
    weight_number = ((index+shift) %9)
    x = col
    y = row
    if weight_number>=0 and weight_number < 3:
        y = y - 6 + index
    if weight_number>=3 and weight_number < 6:
        y = y + index 
    if weight_number>=6:
        y = y + 6 + index
    if weight_number%3 == 0:
        x = x - 1
    if weight_number%3 == 1:
        x = x 
    
    if weight_number%3 == 2:
        x = x + 1
    return (x,y,kernel_number)
#first generate/set the bitvec

def generate_ifmaps(col,row):
    ifmap_str,data_ifmap1,zeroes1 = create_ifmap_test_case(col,row)
   # test_case_if2, data_ifmap2,zeroes1 = create_ifmap_test_case(col,row)
    zeroes1 = [Bits(bin = zero).uint for zero in zeroes1]

    ifmaps = []
    [ifmaps.append(data_ifmap1[i:i+6]) for i in range(0,len(data_ifmap1),6)]
    #[ifmaps.append(data_ifmap2[i:i+6]) for i in range(0,len(data_ifmap2),6)]
    return ifmap_str, ifmaps, zeroes1

def generate_kernels():

    kernel_str,data_kernel,zeroes_kernel = create_kernel_test_case()
   # test_kernel2,data_kernel2,zeroesk2 = create_kernel_test_case()
    #prepare zeroes
    zeroes = [Bits(bin = zero).uint for zero in zeroes_kernel]
    
    sim_kernels = 3
    allkernels = []
    sim1kernel = []
    sim2kernel = []
    [sim1kernel.append(data_kernel[i:i+9]) for i in range(0,27,9)]
    [sim2kernel.append(data_kernel[i+27:i+9+27]) for i in range(0,27,9)]
    allkernels.append(sim1kernel)
    allkernels.append(sim2kernel)

    return kernel_str, allkernels, zeroes

def calculate_response(allkernels, ifmaps, zeroes1, zeroesk1, debug = False):
    result= []
    count_kernel_offs = 0
    br = False
    out_index = []
    for simkernels in allkernels:
        if br == True:
            break
        
        for ifmap in ifmaps:
            if br == True:
                break
            for shift in range(9):
                #debug
                if br == True:
                    break
                #debug
                if count_kernel_offs == 0:
                    count_kernel = 0
                else:
                    count_kernel = 3
                for kernel in simkernels:
                    for i in range(len(ifmap)):
                        if ifmap[i]!= 'U' and kernel[i] != 'U':
                            result.append((ifmap[i]-zeroes1[0])*(kernel[i]-zeroesk1[count_kernel]))
                            out_index.append(calc_out_index(i,shift,count_kernel,row,col))
                            if debug == True:    
                                print("####")
                                print(i)
                                print(shift)
                                print(count_kernel)
                                print(row)
                                print(col)
                                print(out_index[-1])
                            #print(result)
                    count_kernel = count_kernel +1
                if debug == True:    
                    br = True
                    break
            #readjust kernels/shift
                new_kernels = []
                for kernel in simkernels:
                    new_kernel= []
                    for i in range(1,9):
                        new_kernel.append(kernel[i])
                    new_kernel.append(kernel[0])
                    new_kernels.append(new_kernel)
                simkernels = new_kernels
     #       break
        count_kernel_offs = 1
    return result,out_index
#    break

def write_test_case(ifmap_str, kernel_str, result, out_index, op = "a", kernel_only = False):
    
    f = open("input_pe_test.txt",op)
    if kernel_only== False:
        f.write(str("1")+ '\n')
        f.write(ifmap_str+ '\n')
    else:
        f.write(str("0")+ '\n')
    
    f.write(kernel_str+ '\n')
    f.write(str(len(result))+'\n')
    i = 0
    for res in result:
        f.write(str(res)+ ' ')
        f.write(str(out_index[i][0])+ ' ')
        f.write(str(out_index[i][1])+ ' ')
        f.write(str(out_index[i][2])+ '\n')
        i = i+1
    f.write(str(-999999) + '\n')
    f.close()

random.seed(42)
row = 6
col = 2

ifmap_str, ifmaps,zeroes1 = generate_ifmaps(col,row)
kernel_str, allkernels, zeroesk1 = generate_kernels()
print("GENERATE")
print(len(ifmap_str))
print(len(kernel_str))

result,out_index = calculate_response(allkernels,ifmaps, zeroes1, zeroesk1)
write_test_case(ifmap_str, kernel_str, result, out_index, op = "w")

##only new kernels, control of this is done in tb! a little bit not so fancy but whatever
kernel_str, allkernels, zeroesk1 = generate_kernels()

result, out_index = calculate_response(allkernels,ifmaps, zeroes1, zeroesk1,debug = False)
write_test_case(ifmap_str, kernel_str, result, out_index,op = "a",kernel_only=True)


kernel_str, allkernels, zeroesk1 = generate_kernels()

result, out_index = calculate_response(allkernels,ifmaps, zeroes1, zeroesk1,debug = False)
write_test_case(ifmap_str, kernel_str, result, out_index,op = "a",kernel_only=True)

col = 4
row = 12
ifmap_str, ifmaps,zeroes1 = generate_ifmaps(col,row)
kernel_str, allkernels, zeroesk1 = generate_kernels()
result,out_index = calculate_response(allkernels,ifmaps, zeroes1, zeroesk1)
write_test_case(ifmap_str, kernel_str, result, out_index, op = "a")
#prepare ifmaps

#prepare kernels

#print(result)
#print(zeroesk1)
#print(zeroes1)


