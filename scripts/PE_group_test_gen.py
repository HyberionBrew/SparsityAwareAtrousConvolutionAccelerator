#import random
from test_utils import *
import numpy as np
import random
#random.seed(420)
row = 6
col = 2
random.seed(420)
NUMBER_OF_PEs = 8


def new_ifmaps(col,row):

    ifmap_strs = []
    ifmaps_list = []
    zeroes_ifmap_list =[]
    for i in range(NUMBER_OF_PEs):
        ifmap_str, ifmaps,zeroes1 = generate_ifmaps(col,row)
        ifmap_strs.append(ifmap_str)    
        ifmaps_list.append(ifmaps)
        zeroes_ifmap_list.append(zeroes1)
    return ifmap_strs,ifmaps_list, zeroes_ifmap_list

def calc_mem_result(col,row,allkernels,ifmaps_list, zeroes_ifmap_list, zeroesk1):
    results = []
    out_indices = []
    for i in range(NUMBER_OF_PEs):
        result,out_index = calculate_response(row,col,allkernels,ifmaps_list[i], zeroes_ifmap_list[i], zeroesk1)
        results.append(result)
        out_indices.append(out_index)
    mem = np.zeros((6,33,6))
    for i in range(NUMBER_OF_PEs):
        mem = mem +  calculate_mem_response(results[i],out_indices[i])
    return mem


ifmap_strs,ifmaps, zeroes_ifmap_list = new_ifmaps(col,row)
kernel_str, allkernels, zeroesk1 = generate_kernels(col,row)
mem = calc_mem_result(col,row,allkernels,ifmaps, zeroes_ifmap_list, zeroesk1)
write_pe_group_testcase("input_pe_group_test.txt",ifmap_strs, kernel_str, mem, op = "w")



kernel_str, allkernels, zeroesk1 = generate_kernels(col,row)
mem = calc_mem_result(col,row,allkernels,ifmaps, zeroes_ifmap_list, zeroesk1)
write_pe_group_testcase("input_pe_group_test.txt",ifmap_strs, kernel_str, mem, op = "a",kernel_only=True)

for i in range(0,6):
    print("---")
    print(i)
    col = i
    row = 12
    ifmap_strs,ifmaps, zeroes_ifmap_list = new_ifmaps(col,row)
    print("IFMAPS")
    print(ifmaps)
    kernel_str, allkernels, zeroesk1 = generate_kernels(col,row)
    print("KERNELx")
    print(allkernels)
    print("KERNELx")
    mem = calc_mem_result(col,row,allkernels,ifmaps, zeroes_ifmap_list, zeroesk1)
    print(mem)
    write_pe_group_testcase("input_pe_group_test.txt",ifmap_strs, kernel_str, mem, op = "a")
    
