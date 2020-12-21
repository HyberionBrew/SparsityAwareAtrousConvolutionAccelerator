import random
from random import randint


IFMAP_IN_SIZE = 144
KERNEL_IN_SIZE = 144
IFMAP_SIZE = 6
ADDR_RANGE = IFMAP_IN_SIZE/8
KERNEL_SIZE = 9
ADDRESSES = 20
#generate input
def gen_in(SIZE):
    inlist = []
    for i in range(SIZE):
        inlist.append(randint(0,1))
    instr = ""
    for i in inlist:
        instr = instr + str(i)
    return instr

def produce_should(addrlist1, addrlist2,ifmap,kernel):
    ret = []
    res1 = []
    res2 = []
    w1 = kernel[::-1]
    w2 =ifmap[::-1]
    for addr in addrlist1:
        res1.append(w1[8*addr:8*(addr+1)][::-1])
        
    for addr in addrlist2:
        res2.append(w2[8*addr:8*(addr+1)][::-1])
    ret.append(res1)
    ret.append(res2)
    return ret

random.seed(42)

#write that to memory
ifmap = gen_in(144)
kernel = gen_in(144)


#subsequently try to read from different addresses
addrlistkernel = []
for i in range(ADDRESSES):
    addrlistkernel.append(randint(0,ADDR_RANGE-1))


addrlistifmap = []
for i in range(ADDRESSES):
    addrlistifmap.append(randint(0,ADDR_RANGE-1))


#calculate should
print(kernel)
print("#######")
should = produce_should(addrlistkernel,addrlistifmap,ifmap,kernel)
print(should)
#generate outfile
f = open("invalueextrction.txt","w")

writeenable = "1"
#writing takes two cycles for 
writing = 2
for i in range(ADDRESSES+writing):
    if writing >0:
        f.write(writeenable +" ")
        f.write(ifmap+" ")
        f.write(kernel+" ")
        f.write("0" + " ")
        f.write("0" + " ")
        f.write("0" + " ")
        f.write("0" +  '\n')
        writing = writing -1
    else:
        writeenable = "0"
        f.write(writeenable +" ")
        f.write(kernel + " ")
        f.write(ifmap + " ")
        f.write(str(addrlistkernel[i-2]) + " ")
        f.write(str(addrlistifmap[i-2]) + " ")
        print(i)
        f.write(should[0][i-2]+ " ")#should kernel
        f.write(should[1][i-2]+ '\n')#should ifmap

f.close()
