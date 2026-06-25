unit MysteryShip;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

uses
  Raylib,
  Constants;

type

  { TMysteryShip }

  TMysteryShip = class
  private
    FImage1: TTexture2D;
    FImage2: TTexture2D;
    FPosition: TVector2;
    FSpeed: Single;
    FIsAlive: Boolean;
    FIdShip: Byte;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Spawn;
    procedure Update;
    procedure Draw;

    function GetRect: TRectangle;
    property IsAlive: Boolean read FIsAlive write FIsAlive;
  end;

implementation

constructor TMysteryShip.Create;
begin
  FImage1 := LoadTexture('assets/textures/mystery_1_1.png');
  FImage2 := LoadTexture('assets/textures/mystery_1_2.png');

  FPosition := Vector2Create(0,0);
  FSpeed := 0;
  FIsAlive := False;
  FIdShip := 0;
end;

destructor TMysteryShip.Destroy;
begin
  UnloadTexture(FImage1);
  UnloadTexture(FImage2);
end;

procedure TMysteryShip.Spawn;
var
  Side : Integer;
begin
  FPosition.y := 90;

  Side := GetRandomValue(0, 1);

  if Side = 0 then
  begin
    FPosition.x := UI_OFFSET div 2;
    FSpeed := 3;
  end
  else
  begin
    FPosition.x := GetScreenWidth - FImage1.width - (UI_OFFSET div 2);
    FSpeed := -3;
  end;

  FIsAlive := True;
end;

procedure TMysteryShip.Update;
var
  Offset : Integer;
begin
  if not FIsAlive then
    Exit;

  FPosition.x := FPosition.x + FSpeed;
  Offset := UI_OFFSET div 2;

  if (FPosition.x > GetScreenWidth - FImage1.width - Offset) or (FPosition.x < Offset) then
     FIsAlive := False;

  Inc(FIdShip);

  if FIdShip > 16 then
    FIdShip := 0;
end;

procedure TMysteryShip.Draw;
begin
  if not FIsAlive then
    Exit;

  if FIdShip < 8 then
    DrawTextureV(FImage1,FPosition,WHITE)
  else
    DrawTextureV(FImage2,FPosition,WHITE);
end;

function TMysteryShip.GetRect: TRectangle;
begin
  Result.x := FPosition.x;
  Result.y := FPosition.y;

  if FIsAlive then
  begin
    Result.width := FImage1.width;
    Result.height := FImage1.height;
  end
  else
  begin
    Result.width := 0;
    Result.height := 0;
  end;
end;

end.

