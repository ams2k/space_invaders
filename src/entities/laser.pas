unit Laser;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

uses
  Raylib, Constants;

type
  TLaser = class
  private
    FPosition: TVector2;
    FSpeed: Integer;
    FIsActive: Boolean;
    FColor: TColor;
  public
    constructor Create(APosition: TVector2; ASpeed: Integer; AColor: TColor);
    procedure Draw;
    procedure Update;
    function GetRect: TRectangle;
    property IsActive: Boolean read FIsActive write FIsActive;
    property Position: TVector2 read FPosition write FPosition;
  end;

implementation

constructor TLaser.Create(APosition: TVector2; ASpeed: Integer; AColor: TColor);
begin
  FPosition := APosition;
  FSpeed := ASpeed;
  FColor := AColor;
  FIsActive := True;
end;

procedure TLaser.Draw;
begin
  if not FIsActive then
    Exit;

  DrawRectangle(Trunc(FPosition.x), Trunc(FPosition.y), 4, 15, FColor);
end;

procedure TLaser.Update;
begin
  if not FIsActive then
    Exit;

  FPosition.y := FPosition.y + FSpeed;

  if (FPosition.y < (UI_OFFSET div 2)) or
     (FPosition.y > GetScreenHeight - (2 * UI_OFFSET)) then
    FIsActive := False;
end;

function TLaser.GetRect: TRectangle;
begin
  Result.x := FPosition.x;
  Result.y := FPosition.y;
  Result.width := 8;
  Result.height := 15;
end;

end.

