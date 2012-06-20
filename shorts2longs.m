function l = shorts2longs(s)

l = double(uint8(s(1:2:end)))+256*double(uint8(s(2:2:end)));