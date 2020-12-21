#generate a random weight vector
import random
num_kernels = 2
size_kernel = 9

#ins: fetch_enable,kernel,ifmap outs: shift,index,valid

def generate_masks(size):
    if size != 1:
        size = size-1
        masks = generate_masks(size)
    else:
        return ["0","1"]
    masks_new = []
    for mask in masks:
        masks_new.append(mask+"1")
        masks_new.append(mask+"0")
    return masks_new

def write_to_reg(en,kernel,ifmap,out):
    #fetch_enable
    print("write to rg")
    print(kernel)
    out.append(str(en));
    out.append(str(kernel));
    out_ifmap = ""
    for i in ifmap:
        out_ifmap = out_ifmap+str(i)
    out.append(out_ifmap);

def out_dont_care(out):
    out.append("0") #dont care 
    out.append("0")
    out.append("0")

def write_out(out):
    f = open("indexselection.txt","a");
    for el in out:
        f.write(el+ " ")
    f.write('\n')
    f.close()

def generate_output(kernel,ifmaps):
    #first write the inputs to the registerbank 
    out = []
    #inital
    write_to_reg(1,kernel,ifmaps,out);
    out_dont_care(out)
    ifmaps.reverse()
    print(out)
    write_out(out)
    print(kernel)    
    kernel = kernel[-9:]+ kernel[:9]
    kernel_comp = kernel[3:9]+ kernel[-6:]
    kernel_comp = kernel_comp[::-1]
    for ifmap in ifmaps:
        ifmap_curr = ifmap[::-1]
        shift = 0;
        while shift != 9:
            out = []
            write_to_reg(0,kernel,ifmaps,out);
            discovered = False    
            for i in range(0,12):
                if ifmap_curr[i%6]== '1' and kernel_comp[i]== '1':
                    discovered = True
                    break
            if discovered == True:
                kernel_comp = kernel_comp[:i] + "0" + kernel_comp[i+1:]     
                out.append(str(shift))
                out.append(str(i))
                out.append("1")
            if discovered ==  False:
                out_dont_care(out);
                shift = shift +1
                #print("#####")
                #print(kernel)
                kernel = kernel[8]+kernel[0:8]+kernel[-1]+kernel[9:-1]
                #print(kernel) 
                kernel_comp = kernel[3:9]+ kernel[12:]
                #print(kernel_comp) 
                kernel_comp = kernel_comp[::-1]
            write_out(out)
            print(out)
                   # if discovered = 

def generate_test_cases(N):
    masks_18 = generate_masks(18)
    masks_6 = generate_masks(6)
    for i in range(N):
        kernel = random.choice(masks_18)
        print(kernel)
        ifmap1 = random.choice(masks_6) #actually in first ifmap reg
        ifmap2 = random.choice(masks_6)
        ifmap3 = random.choice(masks_6)
        ifmap = [ifmap3,ifmap2,ifmap1]
        print(ifmap)
        generate_output(kernel,ifmap)
    #kernel1 = "000000100"
#kernel2 = "110000001"

f = open("indexselection.txt","w")
f.close()

kernel1 = "111111111" #this is actually kernel 2
kernel2 = "000000000" #actually kernel 1
ifmap1 = "011010" #actually in first ifmap reg
ifmap2 = "000000" 
ifmap3 = "011110" 

kernel = kernel2 +kernel1
ifmap = [ifmap3,ifmap2,ifmap1]
generate_output(kernel,ifmap)

ifmap = [ifmap3,ifmap2,ifmap1]
generate_output(kernel,ifmap)

kernel1 = "010101010"
kernel2 = "101010101"

ifmap1 = "111111"
ifmap2 = "010101"
ifmap3 = "000000"
ifmap = [ifmap3,ifmap2,ifmap1]
generate_output(kernel,ifmap)

random.seed(2)
kernel = random.choice(generate_masks(18))
print(kernel)
ifmap1 = random.choice(generate_masks(6)) #actually in first ifmap reg
ifmap2 = random.choice(generate_masks(6))
ifmap3 = random.choice(generate_masks(6))
ifmap = [ifmap3,ifmap2,ifmap1]
print(ifmap)
generate_output(kernel,ifmap)

kernel1 = "000000000"
kernel2 = "000000000"

ifmap1 = "111111"
ifmap2 = "010101"
ifmap3 = "000000"
ifmap = [ifmap3,ifmap2,ifmap1]
generate_output(kernel,ifmap)
generate_test_cases(20)
