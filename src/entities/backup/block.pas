unit Block;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

uses
  Raylib;

type
  TBlock = class
  private
    FPosition: TVector2;
  public
    constructor Create(APosition: TVector2);

    procedure Draw;
    function GetRect: TRectangle;

    property Position: TVector2 read FPosition write FPosition;
  end;

implementation

constructor TBlock.Create(APosition: TVector2);
begin
  FPosition := APosition;
end;

procedure TBlock.Draw;
begin
  DrawRectangle(
    Trunc(FPosition.x),
    Trunc(FPosition.y),
    3,
    3,
    PURPLE
  );
end;

function TBlock.GetRect: TRectangle;
begin
  Result.x := FPosition.x;
  Result.y := FPosition.y;
  Result.width := 3;
  Result.height := 3;
end;

end.

