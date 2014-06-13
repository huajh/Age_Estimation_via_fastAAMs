function num = readnumber(str)

flagStart = 1;
flagEnd = length(str);

flag = flagStart-1;
num = [];
while flag<flagEnd
    flag = flag+1;
    c=str(flag);
    if c==45 | c==46 | (c>=48 & c<=57)
        number=[];
        number=[number, c];
        anotherFlag = 1;
        while flag<flagEnd & anotherFlag
            flag = flag+1;
            c= str(flag);
            if c==45 | c==46 | (c>=48 & c<=57) | c==69 | c==101
                number=[number, c];
            else
                anotherFlag=0;
            end;
        end;
        num = [num,str2num(number)];
    end;
end;