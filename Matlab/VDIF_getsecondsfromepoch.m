function [seconds_from_epoch] = VDIF_getsecondsfromepoch(reference_epoch)
%VDIF_getsecondsfromepoch Gets the VDIF seconds from epoch field from the
% input reference epoch
% Arguments reference_epoch Reference Epoch number in VDIF header format
ref_epoch_day=1;

if (mod(reference_epoch,2)==0) % Even number, so month is January
    ref_epoch_month=1;
else                           % Odd number, so month is July
    ref_epoch_month=7;   
end

ref_epoch_year=2000+fix(reference_epoch./2); 
% After 00H 1 Jan 2032 UTC delete the previous line and uncomment the
% line below
% ref_epoch_year=2032+fix(reference_epoch./2); 

reference_epoch = datetime(ref_epoch_year, ref_epoch_month,ref_epoch_day, 'TimeZone', 'UTC'); %Reference epoch (Year, month, day)

% Obtain seconds from epoch

currentdate=datetime('now','TimeZone','UTC');
% The POSIX time is the number of seconds (including fractional
% seconds) elapsed since 00:00:00 1-Jan-1970 UTC (Universal Coordinated Time),
seconds_from_epoch= fix(posixtime(currentdate) - posixtime(reference_epoch));
end

