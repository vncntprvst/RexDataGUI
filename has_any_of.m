function [yesno] = has_any_of( list, valuestocheck )

yesno = 0;
if isempty( valuestocheck )
    yesno = 1;
    return;
end;

len = length( valuestocheck );
for d = 1:len
    f = find( list == valuestocheck(d) );
    if ~isempty( f )
        yesno = 1;
        return;
    end;
end;