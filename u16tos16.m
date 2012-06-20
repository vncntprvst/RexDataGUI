function s = u16tos16(u, bits)

wrap_point = bitshift(32767, bits);
wrap_amount = bitshift(65536, bits);

n = find(u > wrap_point);

u(n) = u(n) - wrap_amount;

s = u;