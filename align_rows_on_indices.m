function [aligned,shift] = align_rows_on_indices( rows, alignedindexlist )
% returns aligned rows, and shifts for each row

aligned = rows;
sz = size( rows );
shift=zeros(sz(1),1);
leni = length( alignedindexlist );
if leni ~= sz( 1 )
    s1 = sprintf( 'In align_rows_on_indices, the number of rows (%d) does not match the number of indices (%d) in the index list.', ...
        sz( 1 ), leni );
    return;
end;

mini = min( alignedindexlist );
maxi = max( alignedindexlist );

if maxi > sz(2)
    disp( 'In align_rows_on_indices, at least one of the indices is larger than the number of columns.' );
    return;
end;

% maxshift is also the amount by which we have to increase the matrix size.
maxshift = maxi - mini;
if maxshift == 0
    return;
end;

aligned = zeros( sz(1),(sz(2)+maxshift) );
for rw = 1:sz(1)
    shift(rw) = maxi - alignedindexlist( rw );
    first = shift(rw) + 1;
    last = first + sz(2) - 1;
    aligned( rw, first:last ) = rows( rw, : );
end;

