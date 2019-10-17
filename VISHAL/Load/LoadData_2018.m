

%% Make connection to database
conn = database('MS SQL Server','souren','$souren$');

%Set query to execute on the database
query = ['SELECT WsTid, ' ...
    '	WsDateTime, ' ...
    '	AVT_01_004_1BL_P_kW ' ...
    'FROM ReEn4InPro.dbo."Wv$LiveData$AVT01" ' ...
    'WHERE WsTid > 13169140 AND WsTid < 13344190 AND WsTid %5 = 0'...
    'ORDER BY WsTid ASC'];

%% Execute query and fetch results
data = fetch(conn,query);


dates2 = datenum(data.WsDateTime,'yyyy-mm-dd HH:MM:SS');
date = cellstr(datestr(dates2,'dd/mm/yy'));
[~,~,~,hour,min] = datevec(dates2);
hour = hour+min/60;
power=data.AVT_01_004_1BL_P_kW;

D.Date =date;
D.Hour = hour;
D.Power=power;
D.NumDate = dates2;

%% Saving data to MAT 
save ..\ausdata_2018 D

%% Close connection to database
close(conn);

%% Clear variables
clear conn query