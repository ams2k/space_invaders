unit Spaceship;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  fgl,
  Raylib,
  Laser,
  Constants;

type
  TLaserList = specialize TFPGList<TLaser>;

type
  TSpaceship = class
  private
    FImage: TTexture2D;
    FPosition: TVector2;
    FLasers: TLaserList;
    FLastFireTime: Double;
    FLaserSound: TSound;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Draw;
    procedure MoveLeft;
    procedure MoveRight;
    procedure FireLaser;
    function GetRect: TRectangle;
    property Position: TVector2 read FPosition write FPosition;
    property Lasers: TLaserList read FLasers;
    property Image: TTexture2D read FImage;
  end;

implementation

constructor TSpaceship.Create;
var
  PosX: Integer;
  PosY: Integer;
begin
  inherited Create;

  FImage := LoadTexture('assets/textures/spaceship.png');
  FLaserSound := LoadSound('assets/audio/laser.ogg');

  PosX := (GetScreenWidth - FImage.width) div 2;
  PosY := GetScreenHeight - FImage.height - (2 * UI_OFFSET);

  FPosition.x := PosX;
  FPosition.y := PosY;

  FLasers := TLaserList.Create;
  FLastFireTime := GetTime;
end;

destructor TSpaceship.Destroy;
begin
  FLasers.Free;

  UnloadTexture(FImage);
  UnloadSound(FLaserSound);

  inherited Destroy;
end;

procedure TSpaceship.Draw;
begin
  DrawTextureV(FImage, FPosition, WHITE);
end;

procedure TSpaceship.MoveLeft;
var
  Constraint: Integer;
begin
  FPosition.x := FPosition.x - 7;

  Constraint := UI_OFFSET div 2;

  if FPosition.x < Constraint then
    FPosition.x := Constraint;
end;

procedure TSpaceship.MoveRight;
var
  RightBoundary: Single;
begin
  FPosition.x := FPosition.x + 7;

  RightBoundary := GetScreenWidth - FImage.width - (UI_OFFSET div 2);

  if FPosition.x > RightBoundary then
    FPosition.x := RightBoundary;
end;

procedure TSpaceship.FireLaser;
var
  CurrTime: Double;
  Pos: TVector2;
  L: TLaser;
begin
  CurrTime := GetTime;

  if (CurrTime - FLastFireTime) < 0.35 then
    Exit;

  FLastFireTime := CurrTime;

  Pos.x := FPosition.x + (FImage.width div 2) - 2;
  Pos.y := FPosition.y;

  L := TLaser.Create(Pos, -6, GREEN);

  FLasers.Add(L);

  PlaySound(FLaserSound);
end;

function TSpaceship.GetRect: TRectangle;
begin
  Result.x := FPosition.x;
  Result.y := FPosition.y;

  Result.width := FImage.width;
  Result.height := FImage.height;
end;

end.

