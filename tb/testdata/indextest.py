f = open("indexcomp.txt", "w")

#shift from 0 to 8
#index from 0 to 6
#row from 0-5;6-11;..33
#column from 0 to 6
#result between 0 and 33 twice
#012
#345
#678
for shift in range(0,9):
    for index in range(0,7):
        for column in range(0,7):
            for row in range(0,31,6):
                w = abs(index+shift % 9)
                if w == 0:
                    x = column -1;
                    y = row + index - 6
                if w == 1:
                    x = column
                    y = row + index -6
                if w== 2: 
                    x = column +1 
                    y = row + index -6
                if w == 3:
                    x = column -1;
                    y = row + index
                if w == 4:
                    x = column;
                    y = row + index 
                if w == 5:
                    x = column +1;
                    y = row + index
                if w == 6:
                    x = column -1;
                    y = row + index +6;
                if w == 7:
                    x = column;
                    y = row + index +6;
                if w == 8:
                    x = column +1;
                    y = row + index +6;
                if min(x,y)>0:
                    if x <7 and y < 34:
                        f.write(str(column)+ " "+ str(row)+ " "+ str(index)+ " "+ str(shift)+ " " + str(x)+ " " + str(y)+ '\n')






#f.write()


f.close()
