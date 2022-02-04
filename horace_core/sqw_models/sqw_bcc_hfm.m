function weight = sqw_bcc_hfm (qh,qk,ql,en,par)
% Spectral weight for body centred cubic Heisenberg ferromagnet
%
%   >> weight = sqw_bcc_hfm (qh,qk,ql,en,par)
%
% The spectral weight is for:
%       (S/2) * (<n(en)+1>*delta(en-en(q)) + <n(en)>*delta(en+en(q)))
% broadened by the response for dampled simple harmonic oscillator with
% inverse lifetime gamma.
%
% To get the neutron scattering cross-section per site you must multiply by
%       (kf/ki) * (gyro*r0)^2 * (1 + Qz^2) * (g*F(Q)/2)^2
% where
%       kf, ki      Final and incident neutron wavevectors
%       (gyro*r0)   290.6 mbarn
%       Qz          Component of unit momentum transfer along the moment direction
%       g           Electron gyronagnetic ratio
%       F(Q)        Magnetic form factor
%
% Input:
% ------
%   qh,qk,ql    Arrays of h,k,l
%   par         Parameters [T, gamma, Seff, gap, JS_p5p5p5, JS_100,...
%                                               JS_110, JS_3p5p5p5, JS_111]
%                   T       Temperature (K)
%                   gamma   Inverse lifetime (meV)
%                   Seff        Intensity scale factor
%                   gap         Gap at zone centre
%                   JS_p5p5p5   First neighbour exchange constant
%                   JS_100      Second neighbour exchange constant
%                   JS_110      Third neighbour exchange constant
%                   JS_3p5p5p5  Fourth neighbour exchange constant
%                   JS_111      Fifth neighbour exchange constant
%
%              Note: each pair of spins in the Hamiltonian appears only once
% Output:
% -------
%   weight      Spectral weight

T = par(1);
gamma = par(2);

[wdisp,idisp] = disp_bcc_hfm (qh,qk,ql,par(3:end));

weight = idisp{1} .* (dsho_over_eps (en, wdisp{1}, gamma) .* bose_times_eps(en,T));
