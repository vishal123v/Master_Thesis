

%% Make connection to database
conn = database('MS SQL Server','souren','$souren$');

%Set query to execute on the database
query = ['SELECT WsTid, ' ...
    '	WsDateTime, ' ...
    '	AVT_01_003_1BL_I1_A  ' ...
    'FROM ReEn4InPro.dbo."Wv$LiveData$AVT01" ' ...
    'WHERE WsTid > 13169140 AND WsTid < 17895310 AND WsTid %5 = 0'...
    'ORDER BY WsTid ASC'];

%% Execute query and fetch results
data = fetch(conn,query);


dates2 = datenum(data.WsDateTime,'yyyy-mm-dd HH:MM:SS');
date = cellstr(datestr(dates2,'dd/mm/yy'));
[~,~,~,hour,min] = datevec(dates2);
hour = hour+min/60;
current=abs(data.AVT_01_003_1BL_I1_A);

D.Date =date;
D.Hour = hour;
D.Current=current;
D.NumDate = dates2;

%% Saving data to MAT 
save ..\ausdata_Amp_1year D

%% Close connection to database
close(conn);

%% Clear variables
clear conn query