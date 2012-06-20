function [catrows] = cat_variable_size_row( oldrows, addrow )



szo = size( oldrows );
sza = size( addrow );
if sza( 2 ) == 1
    addrow = addrow';
    sza = size( addrow );
end;
    
catrows = [];

if isempty( oldrows )
    catrows = addrow;
elseif isempty( addrow )
    catrows = oldrows;
elseif (szo(2) == sza(2))
    catrows = cat( 1, oldrows, addrow );
elseif szo(2) > sza(2)
    newrow = NaN( 1, szo(2) ); %replaced zeros with NaN, makes it less ambiguous
    newrow( 1, 1:sza(2) ) = addrow;
    catrows = cat( 1, oldrows, newrow );
else
    newmat = NaN( szo(1), sza(2) );
    newmat( 1:szo(1), 1:szo(2) ) = oldrows;
    catrows = cat( 1, newmat, addrow );   
end;