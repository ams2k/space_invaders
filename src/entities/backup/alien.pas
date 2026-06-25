unit Alien;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

uses
  SysUtils, Raylib;

type
  TAlienType = (
    Type1_1,
    Type2_1,
    Type3_1,
    Type4_1,
    Type5_1,
    Type1_2,
    Type2_2,
    Type3_2,
    Type4_2,
    Type5_2
  );

type

  { TAlien }

  TAlien = class
  private
    FAlienType: TAlienType;
    FPosition: TVector2;
    FIdAlien: Integer;
    FIdAlienChange: Byte;
  public
    constructor Create(AType: TAlienType; APosition: TVector2);

    procedure Draw;
    procedure Update(ADirection: Single; AIsRunning: Boolean);
    procedure MoveDown(ADistance: Single);
    function GetRect: TRectangle;
    class procedure UnloadImages;
    property AlienType: TAlienType read FAlienType;
    property Position: TVector2 read FPosition write FPosition;
  end;

var
  AlienImages: array[0..9] of TTexture2D;
  AlienLoaded: array[0..9] of Boolean;

implementation

constructor TAlien.Create(AType: TAlienType; APosition: TVector2);
var
  Id: Integer;
begin
  Id := Ord(AType);

  if not AlienLoaded[Id] then
  begin
    case AType of
      Type1_1:
      begin
        AlienImages[Id]     := LoadTexture('assets/textures/alien_1_1.png');
        AlienImages[Id + 5] := LoadTexture('assets/textures/alien_1_2.png');
      end;

      Type2_1:
      begin
        AlienImages[Id]     := LoadTexture('assets/textures/alien_2_1.png');
        AlienImages[Id + 5] := LoadTexture('assets/textures/alien_2_2.png');
      end;

      Type3_1:
      begin
        AlienImages[Id]     := LoadTexture('assets/textures/alien_3_1.png');
        AlienImages[Id + 5] := LoadTexture('assets/textures/alien_3_2.png');
      end;

      Type4_1:
      begin
        AlienImages[Id]     := LoadTexture('assets/textures/alien_4_1.png');
        AlienImages[Id + 5] := LoadTexture('assets/textures/alien_4_2.png');
      end;

      Type5_1:
      begin
        AlienImages[Id]     := LoadTexture('assets/textures/alien_5_1.png');
        AlienImages[Id + 5] := LoadTexture('assets/textures/alien_5_2.png');
      end;
    end;

    AlienLoaded[Id] := True;
    AlienLoaded[Id + 5] := True;
  end;

  FAlienType := AType;
  FPosition := APosition;
  FIdAlien := 0;
  FIdAlienChange := 0;
end;

procedure TAlien.Draw;
var
  Id: Integer;
begin
  Id := Ord(FAlienType) + FIdAlien;

  DrawTextureV(AlienImages[Id], FPosition, WHITE);
end;

procedure TAlien.Update(ADirection: Single; AIsRunning: Boolean);
begin
  FPosition.x := FPosition.x + ADirection;

  if AIsRunning then
  begin
    Inc(FIdAlienChange);

    if FIdAlienChange >= 80 then
      FIdAlienChange := 0;

    if FIdAlienChange < 40 then
      FIdAlien := 0
    else
      FIdAlien := 5;
  end;
end;

procedure TAlien.MoveDown(ADistance: Single);
begin
  FPosition.Y := FPosition.Y + ADistance;
end;

function TAlien.GetRect: TRectangle;
var
  Id: Integer;
begin
  Id := Ord(FAlienType);

  Result.x := FPosition.x;
  Result.y := FPosition.y;
  Result.width := AlienImages[Id].width;
  Result.height := AlienImages[Id].height;
end;

class procedure TAlien.UnloadImages;
var
  I: Integer;
begin
  for I := 0 to High(AlienImages) do
  begin
    if AlienLoaded[I] then
    begin
      UnloadTexture(AlienImages[I]);
      AlienLoaded[I] := False;
    end;
  end;
end;

initialization
  FillChar(AlienLoaded, SizeOf(AlienLoaded), 0);

finalization
  TAlien.UnloadImages;

end.

