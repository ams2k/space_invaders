unit GameUtils;

{$mode objfpc}{$H+}

interface

function FormatScoreWithLeadingZeros(Number: Integer; Width: Integer): string;

implementation

uses
  SysUtils;

function FormatScoreWithLeadingZeros(Number: Integer; Width: Integer): string;
begin
  Result := Format('%.*d', [Width, Number]);
end;

end.

