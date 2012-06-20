function [yesno] = has_all_of( list, valuestocheck )

yesno = 1;
if isempty( valuestocheck )
    yesno = 1;
    return;
end;
len = length( valuestocheck );
for d = 1:len
    f = find( list == valuestocheck(d) );
    if isempty( f )
        yesno = 0;
        return;
    end;
end;