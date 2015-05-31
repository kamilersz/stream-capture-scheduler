program streamripper;
uses
	classes,unix,dos,sysutils;
type
	schedule = record
		day,hour,minute,duration : word;
	end;
	
const
  DayStr:array[0..6] of string[3]=('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
  MonthStr:array[1..12] of string[3]=('Jan','Feb','Mar','Apr','May','Jun',
                                      'Jul','Aug','Sep','Oct','Nov','Dec');

var
	n : word;
	jadwal : array[0..200] of schedule;
	mulai : word;
	endSIG : boolean;
	command : AnsiString;
	now : array[0..7] of word;
	
function stoint(s : schedule) : word;
begin
	stoint := (s.day * 24 + s.hour) * 60 + s.minute;
end;

procedure parseSchedule;
var
	i : word;
	myfile : TextFile;
	CC : char = #0;
S : String;
begin
	n := 0;

  GetDir (0,S);
  Writeln ('Current directory is : ',S);
	assign(myfile,'schedule.txt');
	reset(myfile);
	for i:=0 to 6 do
	begin
		while CC <> #10 do
		begin
			read(myfile,jadwal[n].hour);
			read(myfile,CC);
			read(myfile,jadwal[n].minute);
			read(myfile,CC);
			read(myfile,jadwal[n].duration);
			read(myfile,CC);
			jadwal[n].day := i;
			n := n + 1;
		end;
		CC := 'z';
	end;
	close(myfile);
end;

function inSchedule(d,h,m : word) : word;
var
	found : boolean;
	i,offset : word;
begin
	found := false;
	i := 0;
	while not found and (i < n) do
	begin
		if ((stoint(jadwal[i]) <= (d*24+h)*60+m) and (stoint(jadwal[i]) + jadwal[i].duration >= (d*24+h)*60+m)) then
		begin
			found := true;
			offset := ((d*24+h)*60+m) - stoint(jadwal[i]);
		end else
			inc(i);
	end;
	if found then
		inSchedule := jadwal[i].duration-offset
	else
		inSchedule := 0;
end;

procedure printSchedule;
var 
	i : word;
begin
	for i:=0 to n-1 do
		writeln(jadwal[i].day,' ',jadwal[i].hour,':',jadwal[i].minute,' ',jadwal[i].duration);
end;

procedure doRecord(time : integer);
var
	status,i : word;
	s : string;
	now_s : string;
begin
	str(now[0],s);
	now_s := s;
	for i:=1 to 6 do
	begin
		if i = 3 then
			continue;
		str(now[i],s);
		if length(s) < 2 then
			now_s := now_s+'_0'+s
		else
			now_s := now_s+'_'+s;
	end;
	str(time,s);
	command := 'doalarm '+ s +' mplayer -dumpstream -dumpfile "/var/www/streamripper ['+now_s+'].aac" http://example.com:12345';
	writeln(command);
	status := fpsystem(command);
	writeln('The value returned was: ',status);
end;

begin
	endSIG := false;
	writeln('Executing command Stream Controller...');
	parseSchedule;
	printSchedule;
	while not endSIG do
	begin
		GetDate(now[0],now[1],now[2],now[3]); {year mon day wday}
		GetTime(now[4],now[5],now[6],now[7]); {hour min sec hsec}
		mulai := inSchedule(now[3],now[4],now[5]);
		if mulai > 0 then
		begin
			writeln('Recording for ',mulai,' minutes at ',now[4],':',now[5],
			'.',now[6],' ',DayStr[now[3]],', ',now[2],' ',MonthStr[now[1]],
			' ',now[0]);
			doRecord(mulai * 60);
			writeln('Recording is done. waiting for next schedule...');
		end else
		begin
			writeln('still waiting at ',now[4],':',now[5],
			'.',now[6],' ',DayStr[now[3]],', ',now[2],' ',MonthStr[now[1]],
			' ',now[0]);
			sleep(5000);
		end;
		//parseSchedule;
	end;
end.