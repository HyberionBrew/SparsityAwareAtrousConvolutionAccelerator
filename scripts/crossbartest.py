#!
import random
from bitstring import Bits

random.seed(42)

#input data to crossbar ADDR(0,17-1), TAG(0,512-1(*6)), calculated from X-Upper,y and w, DATA (18bit)
DEBUG = False
ADDR_RANGE = [0,16]
TAG_RANGE = [0,511]
DATA_SIZE = 18  #signed
DATA_RANGE = [-2**(DATA_SIZE-1), 2**(DATA_SIZE-1) -1]
PES_PER_GROUP = 8


TAG_MAX_TEST = 2**8

if DEBUG == True:
    ADDR_RANGE = [0,3]
    TAG_RANGE = [0,5]

#first fill the FIFOs
#write to th FIFO only if the valid bit is set in the DATA structure -> generate a data structure

def generateFIFO_in(tag,address):
    valid = 1#random.randint(0, 1)
    tag = tag #random.randint(TAG_RANGE[0],TAG_RANGE[1])
    address = address#random.randint(ADDR_RANGE[0],ADDR_RANGE[1])
    data = random.randint(DATA_RANGE[0],DATA_RANGE[1])
    data = Bits(int = data, length=DATA_SIZE).bin 
    return (address,data,tag,valid)     #only take if valid is tru

def stim_to_file(FIFO_in):
    f = open("crossbar_test.txt", 'w')
    for output in FIFO_in:
        for elem in output:
            f.write(str(elem)+ ' ')
        f.write('\n')
    f.close()

FIFO_in = []

for i in range(0,TAG_MAX_TEST,PES_PER_GROUP):
    for ii in range(PES_PER_GROUP):
        if ii%2 == 0:
            FIFO_in.append(generateFIFO_in(i+ii,3))
        else:
            FIFO_in.append(generateFIFO_in(i+ii,3))

#print(FIFO_in)

stim_to_file(FIFO_in)

