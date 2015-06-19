function  filtvals = fullgauss_filtconv(vector,sigma,causal,constraint)
% Smoothing with gaussian filtering
% Same as gauss_filtconv, but with added denominator in front of the 
% exponential. Result is identical to using normpdf. 
% vector is binned data (i.e., spike train)
% sigma is SD
% causal is for using causal kernel 
% If bin size is 1 (millisecond precision: binary data), see spike_density
% or conv_raster to convert to spike rate.

% Example:
% foo = mean([poissrnd(3,1,100);sin(0:0.3:29.7)]);
% foo=foo-mean(foo);
% plot(foo)
% hold on
% c_foo=fullgauss_filtconv(foo(1,1:end),1,0);
% plot(c_foo,'r')
% c_foo=fullgauss_filtconv(foo(1,1:end),5,0);
% plot(c_foo,'k')
% cc_foo=fullgauss_filtconv(foo(1,1:end),1,1);
% plot(cc_foo,'g')

if nargin < 2 || isempty(sigma)
     sigma = 5;
     constraint = 'valid';
end
if nargin < 4
    constraint = 'valid';
end

ksize = 6*sigma;
x = linspace(-ksize / 2, ksize / 2, ksize+1);
gaussFilter = (1/(sqrt(2*pi)*sigma)) * exp(-x .^ 2 / (2 * sigma ^ 2)); % same as normpdf(x,0,sigma)
if causal
    gaussFilter(x<0)=0; % causal kernel
end
gaussFilter = gaussFilter / sum (gaussFilter); % normalize

% if size(vector,1)>1
%     gaussFilter=repmat(gaussFilter,size(vector,1),1);
% end
% filtvals = conv (vector, gaussFilter, 'same'); 

% if ~isnan(vector)
    filtvals = conv (vector, gaussFilter, constraint); % filter vector data
% else
%     filtvals = nanconv(vector, gaussFilter,'edge');
%     filtvals = filtvals(:,sigma*3+1:end-3*sigma);
% end


