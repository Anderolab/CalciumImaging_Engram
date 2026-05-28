function [Phi] = F_ComputePhi(oo, ol, lo, ll)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
Phi = (oo.*ll-ol.*lo)./sqrt((oo+ol).*(lo+ll).*(oo+lo).*(ol+ll));
end

