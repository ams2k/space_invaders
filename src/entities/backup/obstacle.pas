unit Obstacle;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  fgl,
  Raylib,
  Block;

type
  TObstacleGrid = array[0..12, 0..22] of Boolean;

const
  Grid: TObstacleGrid = (
    (False,False,False,False,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,False,False,False,False),
    (False,False,False,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,False,False,False),
    (False,False,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,False,False),
    (False,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,False),
    (True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True),
    (True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True),
    (True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True),
    (True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True),
    (True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True),
    (True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True),
    (True,True,True,True,True,True,False,False,False,False,False,False,False,False,False,False,False,True,True,True,True,True,True),
    (True,True,True,True,True,False,False,False,False,False,False,False,False,False,False,False,False,False,True,True,True,True,True),
    (True,True,True,True,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,True,True,True,True)
  );

type
  TBlockList = specialize TFPGList<TBlock>;

type
  TObstacle = class
  private
    FPosition: TVector2;
    FBlocks: TBlockList;
  public
    constructor Create(const APosition: TVector2);
    destructor Destroy; override;

    procedure Draw;

    property Position: TVector2 read FPosition;
    property Blocks: TBlockList read FBlocks;
  end;

implementation

constructor TObstacle.Create(const APosition: TVector2);
var
  I, J : Integer;
  BlockPos : TVector2;
begin
  inherited Create;

  FPosition := APosition;
  FBlocks := TBlockList.Create;

  for I := 0 to High(Grid) do
  begin
    for J := 0 to High(Grid[I]) do
    begin
      if Grid[I, J] then
      begin
        BlockPos.x := APosition.x + (J * 3);
        BlockPos.y := APosition.y + (I * 3);

        FBlocks.Add(TBlock.Create(BlockPos));
      end;
    end;
  end;
end;

destructor TObstacle.Destroy;
begin
  FBlocks.Free;
  inherited Destroy;
end;

procedure TObstacle.Draw;
var
  I : Integer;
begin
  for I := 0 to FBlocks.Count - 1 do
    FBlocks[I].Draw;
end;

end.

