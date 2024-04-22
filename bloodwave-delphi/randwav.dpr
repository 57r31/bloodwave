program randwav;

uses
  Unit1 in 'Unit1.pas';

{$R *.res}

var phile:TSearchRec; files, filernd:word;

begin
randomize;
if FindFirst('*.wav',faanyfile,phile)<>0 then exit; files:=1;
writeln(phile.name);
while findnext(phile)=0 do begin inc(files); writeln(phile.name); end;
// got number of files
randomize; filernd:=random(files)+1;
if filernd=1 then
  begin
  FindFirst('*.wav',faanyfile,phile);
  PlaySound(pchar(phile.Name),0,snd_FILENAME);
  end
else
  begin
  FindFirst('*.wav',faanyfile,phile);
  for files:=1 to filernd do findnext(phile);
  PlaySound(pchar(phile.Name),0,snd_FILENAME);
  end;
end.
