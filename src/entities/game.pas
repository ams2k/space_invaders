unit Game;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  fgl,
  Raylib,
  Alien,
  Laser,
  Spaceship,
  Obstacle,
  MysteryShip,
  Constants;

type
  TAlienList = specialize TFPGList<TAlien>;
  TLaserList = specialize TFPGList<TLaser>;

type

  { TGame }

  TGame = class
  private
    FSpaceship: TSpaceship;
    FAliens: TAlienList;
    FAlienLasers: TLaserList;
    FObstacles: array[0..3] of TObstacle;
    FMysteryShip: TMysteryShip;

    FTimeLastAlienFired: Double;
    FAlienDirection: Single;
    FAlienLaserInterval: Double;

    FMysteryShipSpawnInterval: Double;
    FTimeLastSpawn: Double;

    FLives: Integer;
    FRunning: Boolean;

    FScore: Integer;
    FHighScore: Integer;

    FMusic: TMusic;
    FExplosionSound: TSound;

    procedure CreateAliens;
    procedure CreateObstacles;
    procedure DeinitNonMedia;
    procedure MoveAliens;
    procedure MoveDownAliens(ADistance: Single);
    procedure AlienShootLaser;
    procedure SpaceShipShootLaser;
    procedure DeleteInactiveLasers;
    procedure CheckForCollisions;
    procedure CheckForHighScore;
    procedure InitGame;
    procedure EndGame;
    procedure RemoveAlien(Index: Integer);
    procedure RemoveBlock(AObstacle: TObstacle; Index: Integer);
    procedure SaveHighScoreToFile;
    function LoadHighScoreFromFile: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Draw;
    procedure Update;
    procedure HandleInput(AExitGame: Boolean);
    procedure Reset;
    property Score: Integer read FScore;
    property HighScore: Integer read FHighScore;
    property Lives: Integer read FLives;
    property Running: Boolean read FRunning;
    property Spaceship: TSpaceship read FSpaceship;
    property Music: TMusic read FMusic;
  end;

implementation

constructor TGame.Create;
begin
  inherited Create;

  InitGame;

  FLives := 3;
  FScore := 0;
  FHighScore := LoadHighScoreFromFile;

  FMusic := LoadMusicStream('assets/audio/music.ogg');
  FExplosionSound := LoadSound('assets/audio/explosion.ogg');
end;

destructor TGame.Destroy;
var
  I : Integer;
begin
  TAlien.UnloadImages;

  UnloadMusicStream(FMusic);
  UnloadSound(FExplosionSound);

  FSpaceship.Free;
  FMysteryShip.Free;

  for I := 0 to High(FObstacles) do
    FObstacles[I].Free;

  FAliens.Free;
  FAlienLasers.Free;

  inherited Destroy;
end;

procedure TGame.CreateAliens;
var
  Row, Col : Integer;
  Pos : TVector2;
  AlienType : TAlienType;
begin
  for Row := 0 to 4 do
  begin
    for Col := 0 to 10 do
    begin
      Pos.X := Col * 55 + 75;
      Pos.Y := Row * 55 + 110;

      case Row of
        0 : AlienType := Type5_1;
        1 : AlienType := Type4_1;
        2 : AlienType := Type3_1;
        3 : AlienType := Type2_1;
      else
        AlienType := Type1_1;
      end;

      FAliens.Add(TAlien.Create(AlienType, Pos));
    end;
  end;
end;

procedure TGame.CreateObstacles;
var
  I : Integer;
  Pos : TVector2;
  Gap : Single;
  ObstacleWidth : Integer;
begin
  ObstacleWidth := 23 * 3;
  Gap := (GetScreenWidth - (4 * ObstacleWidth)) / 5;

  for I := 0 to 3 do
  begin
    Pos.X := (I + 1) * Gap + (I * ObstacleWidth);
    Pos.Y := GetScreenHeight - 100 - (2 * UI_OFFSET);
    FObstacles[I] := TObstacle.Create(Pos);
  end;
end;

procedure TGame.Draw;
var
  I : Integer;
begin
  FSpaceship.Draw;

  for I := 0 to FSpaceship.Lasers.Count-1 do
    FSpaceship.Lasers[I].Draw;

  for I := 0 to FAlienLasers.Count-1 do
    FAlienLasers[I].Draw;

  for I := 0 to High(FObstacles) do
    FObstacles[I].Draw;

  for I := 0 to FAliens.Count-1 do
    FAliens[I].Draw;

  FMysteryShip.Draw;
end;

procedure TGame.HandleInput(AExitGame: Boolean);
// movimenta o canhão e disparo
begin
  if IsKeyDown(KEY_D) or
     IsKeyDown(KEY_RIGHT) then
    FSpaceship.MoveRight
  else
  if IsKeyDown(KEY_A) or
     IsKeyDown(KEY_LEFT) then
    FSpaceship.MoveLeft;

  if (not FRunning) or AExitGame then
    Exit;

  if IsKeyDown(KEY_SPACE) then
    FSpaceship.FireLaser;
end;

procedure TGame.InitGame;
// inicialização dos objetos
var
  CurrTime : Double;
begin
  CurrTime := GetTime;

  FSpaceship := TSpaceship.Create;

  FAliens := TAlienList.Create;
  FAlienLasers := TLaserList.Create;

  CreateAliens;
  CreateObstacles;

  FMysteryShip := TMysteryShip.Create;

  FTimeLastAlienFired := CurrTime;
  FTimeLastSpawn := CurrTime;

  FMysteryShipSpawnInterval := GetRandomValue(10, 20);

  FLives += 1;
  FRunning := True;

  FAlienDirection := 1;
  FAlienLaserInterval := 0.35;
end;

procedure TGame.Reset;
// reinicia o jogo
begin
  DeinitNonMedia;
  InitGame;
end;

procedure TGame.MoveAliens;
// movimento dos aliens
var
  I: Integer;
  Alien: TAlien;
  ConstraintOffset: Integer;
  Id: Integer;
begin
  ConstraintOffset := UI_OFFSET div 2;

  for I := 0 to FAliens.Count - 1 do
  begin
    Alien := FAliens[I];

    Id := Ord(Alien.AlienType);

    if (AlienImages[Id].id<>0) then
    begin
      if Round(Alien.Position.X) +
         AlienImages[Id].Width >
         GetScreenWidth - ConstraintOffset then
      begin
        FAlienDirection := -1;
        MoveDownAliens(4);
      end
      else
      if Alien.Position.X < ConstraintOffset then
      begin
        FAlienDirection := 1;
        MoveDownAliens(4);
      end;
    end;

    Alien.Update(FAlienDirection, FRunning);
  end;
end;

procedure TGame.MoveDownAliens(ADistance: Single);
// coloca os aliens uma linha abaixo
var
  I: Integer;
begin
  for I := 0 to FAliens.Count - 1 do
    FAliens[I].MoveDown(ADistance);
end;

procedure TGame.AlienShootLaser;
// aliens disparando
var
  Index, I : Integer;
  L : TLaser;
  LPos : TVector2;
begin
  if FRunning and (FAliens.Count > 0) and (GetTime - FTimeLastAlienFired > FAlienLaserInterval) then
  begin
    // aliens disparando de tempos em tempos
    FTimeLastAlienFired := GetTime;
    Index := GetRandomValue(0, FAliens.Count-1);
    LPos.X := FAliens[Index].Position.X + 20;
    LPos.Y := FAliens[Index].Position.Y + 20;
    L := TLaser.Create(LPos, 6, RED);
    FAlienLasers.Add(L);
  end;

  // move para baixo, o laser disparado por cada alien

  I := 0;
  while I < FAlienLasers.Count do
  begin
    FAlienLasers[I].Update;
    Inc(I);
  end;
end;

procedure TGame.SpaceShipShootLaser;
// movimenta o laser da spaceship (canhão)
var
  I: Integer;
begin
  I := 0;
  while I < FSpaceship.Lasers.Count do
  begin
    FSpaceship.Lasers[I].Update;
    Inc(I);
  end;
end;

procedure TGame.DeleteInactiveLasers;
// remove laser inativo por ter atingido algum alvo ou saiu da tela
var
  I : Integer;
begin
  I := 0;
  while I < FAlienLasers.Count do
  begin
    if not FAlienLasers[I].IsActive then
      FAlienLasers.Delete(I)
    else
      Inc(I);
  end;

  I := 0;
  while I < FSpaceship.Lasers.Count do
  begin
    if not FSpaceship.Lasers[I].IsActive then
      FSpaceship.Lasers.Delete(I)
    else
      Inc(I);
  end;
end;

procedure TGame.Update;
// atualização de todos os objetos do jogo
begin
  if not FRunning then
  begin
    if IsKeyPressed(KEY_ENTER) then
      Reset;
    //Exit;
  end;

  // Exibe a nave alien mistério em intervalos
  if FRunning and (GetTime - FTimeLastSpawn > FMysteryShipSpawnInterval) then
  begin
    FMysteryShip.Spawn;
    FTimeLastSpawn := GetTime;
    FMysteryShipSpawnInterval := GetRandomValue(10, 20);
  end;

  if FRunning then MoveAliens;           // movimenta os aliens
  AlienShootLaser;      // movimenta os laser's dos aliens
  SpaceShipShootLaser;  // movimenta os laser's da spaceship (canhão)
  FMysteryShip.Update;  // movimenta a nave alien mistério
  CheckForCollisions;   // checa se houve alguma colisão
  DeleteInactiveLasers; // remove laser's disparados inativos
end;

procedure TGame.SaveHighScoreToFile;
// salva o score
var
  SL : TStringList;
begin
  SL := TStringList.Create;
  try
    SL.Add(IntToStr(FHighScore));
    SL.SaveToFile('highscore.txt');
  finally
    SL.Free;
  end;
end;

function TGame.LoadHighScoreFromFile: Integer;
// carrega o score anterior
var
  SL : TStringList;
begin
  Result := 0;

  if not FileExists('highscore.txt') then
    Exit;

  SL := TStringList.Create;
  try
    SL.LoadFromFile('highscore.txt');

    if SL.Count > 0 then
      Result := StrToIntDef(Trim('0'+SL[0]), 0);
  finally
    SL.Free;
  end;
end;

procedure TGame.RemoveAlien(Index: Integer);
begin
  if (Index < 0) or (Index >= FAliens.Count) then
    Exit;

  FAliens[Index] := FAliens[FAliens.Count - 1];
  FAliens.Delete(FAliens.Count - 1);
end;

procedure TGame.RemoveBlock(AObstacle: TObstacle; Index: Integer);
begin
  if (Index < 0) or (Index >= AObstacle.Blocks.Count) then
    Exit;

  AObstacle.Blocks[Index] := AObstacle.Blocks[AObstacle.Blocks.Count - 1];

  AObstacle.Blocks.Delete(AObstacle.Blocks.Count - 1);
end;

procedure TGame.CheckForCollisions;
// checa se houve colisões entre os objetos
var
  I, J, K : Integer;
  LaserRect : TRectangle;
  AlienRect : TRectangle;
  ShipRect  : TRectangle;
  HitAlien : TAlien;
  HitFound : Boolean;
begin

  { ==========================
    LASERS DA NAVE
    ========================== }

  HitFound := False;

  for I := 0 to FSpaceship.Lasers.Count - 1 do
  begin
    LaserRect := FSpaceship.Lasers[I].GetRect;
    J := 0;

    while J < FAliens.Count do
    begin
      if CheckCollisionRecs(LaserRect, FAliens[J].GetRect) then
      begin
        HitAlien := FAliens[J];

        case HitAlien.AlienType of
          Type1_1: Inc(FScore, 100);
          Type2_1: Inc(FScore, 200);
          Type3_1: Inc(FScore, 300);
          Type4_1: Inc(FScore, 350);
          Type5_1: Inc(FScore, 380);
        end;

        CheckForHighScore;
        RemoveAlien(J);
        FSpaceship.Lasers[I].IsActive := False;
        PlaySound(FExplosionSound);
        HitFound := True;
        Break;
      end;

      Inc(J);
    end;

    if FRunning and (HitFound or (FAliens.Count < 1)) then
    begin
      if FAliens.Count < 1 then EndGame;
      Break;
    end;

    { Laser da SpaceShip atingem os escudos / obstáculos }

    for J := 0 to High(FObstacles) do
    begin
      K := 0;

      while K < FObstacles[J].Blocks.Count do
      begin
        if CheckCollisionRecs(LaserRect, FObstacles[J].Blocks[K].GetRect) then
        begin
          RemoveBlock(FObstacles[J], K);
          FSpaceship.Lasers[I].IsActive := False;
        end
        else
          Inc(K);
      end;
    end;

    { Laser da SpaceShip atingem a nave misteriosa }

    if CheckCollisionRecs(LaserRect, FMysteryShip.GetRect) then
    begin
      FMysteryShip.IsAlive := False;
      FSpaceship.Lasers[I].IsActive := False;
      Inc(FScore, 500);
      CheckForHighScore;
      PlaySound(FExplosionSound);
      Break;
    end;

  end;

  if not FRunning then Exit;

  { ==========================
    LASERS DOS ALIENS
    ========================== }

  ShipRect := FSpaceship.GetRect;

  for I := 0 to FAlienLasers.Count - 1 do
  begin
    LaserRect := FAlienLasers[I].GetRect;

    if CheckCollisionRecs(LaserRect, ShipRect) then
    begin
      FAlienLasers[I].IsActive := False;
      Dec(FLives);

      if FLives <= 0 then
        EndGame;

      Break;
    end;

    for J := 0 to High(FObstacles) do
    begin
      K := 0;

      while K < FObstacles[J].Blocks.Count do
      begin
        if CheckCollisionRecs(LaserRect, FObstacles[J].Blocks[K].GetRect) then
        begin
          RemoveBlock(FObstacles[J], K);
          FAlienLasers[I].IsActive := False;
        end
        else
          Inc(K);
      end;
    end;
  end;

  { ==========================
    ALIENS COM OBSTÁCULOS
    ========================== }

  for I := 0 to FAliens.Count - 1 do
  begin
    AlienRect := FAliens[I].GetRect;

    for J := 0 to High(FObstacles) do
    begin
      K := 0;

      while K < FObstacles[J].Blocks.Count do
      begin
        if CheckCollisionRecs(AlienRect, FObstacles[J].Blocks[K].GetRect) then
        begin
          RemoveBlock(FObstacles[J], K);
        end
        else
          Inc(K);
      end;
    end;

    if CheckCollisionRecs(AlienRect, ShipRect) then
    begin
      EndGame;
      Exit;
    end;

  end;
end;

procedure TGame.CheckForHighScore;
begin
  if FScore > FHighScore then
  begin
    FHighScore := FScore;
    SaveHighScoreToFile;
  end;
end;

procedure TGame.EndGame;
begin
  FRunning := False;
end;

procedure TGame.DeinitNonMedia;
var
  I: Integer;
begin
  if Assigned(FSpaceship) then
    FreeAndNil(FSpaceship);

  if Assigned(FMysteryShip) then
    FreeAndNil(FMysteryShip);

  if Assigned(FAliens) then
  begin
    for I := FAliens.Count - 1 downto 0 do
      FAliens[I].Free;
    FreeAndNil(FAliens);
  end;

  if Assigned(FAlienLasers) then
  begin
    for I := FAlienLasers.Count - 1 downto 0 do
      FAlienLasers[I].Free;
    FreeAndNil(FAlienLasers);
  end;

  for I := Low(FObstacles) to High(FObstacles) do
    FObstacles[I].Free;
end;


end.

