%% Read and Analyse data from VNA, PNA and SPA used for the course

%% v10 M. Marongiu, A. Mostacci, F. Cardelli
%% Rev. 28-04-2026

%% --- Read from HP8753 and PNA vector Analysers, HP Spectrum Anal., Rohde Spectrum Analysers---
% The following commands result in a dataStruct struct in the Matlab WorkSpace
% BoardNumber = 0;        % The Ethernet-GPIB controller card number 
%                         % used for PNA and VNA1

% BoardNumber = 1;        % The  USB-GPIB controller card number
                          %
% BoardNumber = 2;        % Additional USB-GPIB controller card number 
						  % used for ZND Vector Analyser
                           
% DeviceNumber = 8;       % HP VNA device number (VNA1)
% DeviceNumber = 10;      % Agilent VNA device number (VNA not used)
% DeviceNumber = 16;      % Agilent PNA device number (PNA) and VNA2 HP8753C

% DeviceNumber = 17;      % ENA network analyser
% DeviceNumber = 18;      % Spectrum Analyser device number (Rohde or HP)
% DeviceNumber = 20;      % Spectrum Analyser device number (Rohde or HP) and ZND Vector Analyser


%  IPaddress='192.168.0.35';  % FieldFox Network Analyzer or Spectrum Analyser 
%  IPaddress='192.168.0.32';  % Rohde & Schwarz Spectrum Analyser 
%  IPaddress='192.168.0.132';  % Siglent Spectrum Analyser 
  IPaddress='TCPIP0::localhost::hislip0'; % USB Vector Network Analyser
                                           % by changing localhost with an IP number you can
                                           % access the instrument from any computer
%  IPaddress='TCPIP0::192.168.0.37::hislip0'; % example for USB Vector Network Analyser


% New USB VNA with Windows 11 and visa command
% IPaddress=...
%    'TCPIP0::DESKTOP-6MOIKHM::hislip_PXI10_CHASSIS2_SLOT1_INDEX0::INSTR';
% to get the name of the Visa resources, you should
% resourceList = visadevlist("Timeout", 50);
% index=find(contains(resourceList.Vendor,'Keysight'),1,'first');
% visaAddress=char(resourceList{index,1});

%%%%%% DATA ACQUISITION SESSISSION %%%%%%%%%%%%                                         
%%%%%% AGILENT/HP/Keysight Vector Analysers

%%%%%% for VNA
% dataStruct=getdataNAv2(BoardNumber,DeviceNumber);    % for VNA1, VNA2, VNA3, ZND

%%%% For PNA
%%% Single trace
% dataStruct=getdataPNAv3(BoardNumber,DeviceNumber);   % for PNA
%%% Multiple Traces
%NTr=2; %Trace number of the desired measure (Read the PNA display) 
%dataStruct=getdataPNAv3(BoardNumber,DeviceNumber,NTr);   % for PNA

%%%%%% for ENA network Analyser
% dataStruct=getdataENA(BoardNumber,DeviceNumber);     % for ENA network analyser
%%%%%%%%%

%%%%%%% for USB Vector Network Analyser
%%% Single trace
 dataStruct=getdataPNAv4(IPaddress);
%%% Multiple Traces
% NTr=2; %Trace number of the desired measure (Read the VNA display) 
% dataStruct=getdataPNAv4(IPaddress,NTr);
%%%%%%%%%%%%%%%%%%

%%%%%%% for Vector Network Analyser connected with Ethernet connection
% dataStruct=getdataZVLNA(IPaddress);                  % for ZVL Rohde & Schwarz NA
% dataStruct=getdataFFPNA(IPaddress);                  % for Agilent FieldFox NA
% dataStruct=getdataZVLSPA2(IPaddress);                % for ZVL or FSP Rohde & Schwarz SPA
                                                       % and Siglent
                                                       % Spectrum Analyser

%%%%%%% for SPECTRUM Analyser connected with GPIB connection
% dataStruct=getdataHPSPA(BoardNumber,DeviceNumber);   % for Spectrum Analysers (HP)
% dataStruct=getdataRSSPAvGPIB(BoardNumber,DeviceNumber);   % for Spectrum Analysers (FSP-Rohde)
 
%%%%%%% for SPECTRUM Analyser connected with Ethernet connection
% dataStruct=getdataRSSPA(IPaddress);                  % for FSP Rohde & Schwarz SPA
% dataStruct=getdataFFSPA(IPaddress);                  % for Agilent FieldFox SPA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% ADDITIONAL INSTRUMENTS %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ---- Read data file for Rohde & Schwarz SPA when using USB pen drive -----
% The following commands result in a dataStruct struct in the Matlab WorkSpace
% Used in the acquisition from ZVL Spectrum Analyser

% Choose the datafile to be read

% [filename, pathname, filtrindex] = uigetfile('*.txt;*.TXT;*.DAT;*.dat;', 'Pick a SPA data file');
% dataFile=[pathname filename];
% 
% dataStruct=getdataRohdeSPA(dataFile);
%% ------ End of Rohde & Schwarz SPA commands when using USB pen drive -------

%% ---- Read data file for Tektronix SPA
%Choose the datafile to be read

% [filename, pathname, filterindex] = uigetfile('*.txt;*.TXT;*.DAT;*.dat;*.csv;', 'Pick a SPA data file');
% dataFile=[pathname filename];
% 
% dataStruct=getdataTekSPA(dataFile); 

%% ---- End of Read data file for Tektronix SPA

%%%%%%%%%%%%%%%%%%%%%% OLD ROUTINES %%%%%%%%%%%%%%%%%%%%
%% ---- Read data file for Agilent Field Fox Spectrum Analyser -------
% Routine usable also for Agilent Field Fox Network Analyser by saving sXp files
% The following commands result in a dataStruct in the Matlab WorkSpace is
% reading a .csv file, while in a Spramenters struct if reading a sXp file.

% [filename, pathname, filterindex] = uigetfile('*.csv;*.s2p;*.s1p', 'Pick a Field Fox data file');
% dataFile=[pathname filename];
% if strfind(dataFile,'.csv'),
%     dataStruct=getdataFieldFoxCSV(dataFile);
% elseif strfind(dataFile,'.s2p'),
%     Sparameters=DatareadS2p(dataFile);
% elseif strfind(dataFile,'.s1p'),
%     Sparameters=DatareadS1p(dataFile);
% end
%% ---- End of Agilent Field Fox commands -------