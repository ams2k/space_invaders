program invaders;

{
  Space Invaders
  Convertido de uma versão escrita em ZIG
}

{$mode objfpc}{$H+}

uses
{$IFDEF LINUX}
cmem, cthreads,
{$ENDIF}
sysutils,
{uncomment if necessary}
//raymath, 
//rlgl,
raylib,
Game,
GameUtils,
Constants;

const
  screenWidth : Integer = 750;
  screenHeight: Integer = 700;

var
  ExitGame : Boolean;
  FontGame : TFont;
  FontDigital : TFont;
  G : TGame;
  ScoreText : string;
  HighScoreText : string;
  LifeOffset : Single;
  I, LBlink, lNivel : Integer;

begin
  // Initialization
  ExitGame := False;
  LBlink := 0;
  lNivel := 1;
  InitWindow(screenWidth + UI_OFFSET, screenHeight + (2 * UI_OFFSET), 'Space Invaders - FPC');
  InitAudioDevice;

  try
    FontGame := LoadFontEx('assets/fonts/monogram.ttf', 64, nil, 0);
    FontDigital := LoadFontEx('assets/fonts/digital.ttf', 64, nil, 0);

    try
      SetTargetFPS(60);
      SetExitKey(KEY_NULL);

      G := TGame.Create;

      try
        PlayMusicStream(G.Music);

        { Loop Principal }

        while not WindowShouldClose do
        begin
          UpdateMusicStream(G.Music); { atualiza a música de fundo }

          G.HandleInput(ExitGame); { Movimenta a spaceship e disparo }

          BeginDrawing; { vamos começar a desenhar a tela }

          try
            // pinta a tela de Grey, desenha um retângulo com bordas arredondadas
            // e uma linha na parte de baixo da tela

            ClearBackground(COLOR_GREY);
            DrawRectangleRoundedLines(RectangleCreate(10, 10, 780, 780), 0.18, 20, COLOR_YELLOW);
            DrawLineEx(Vector2Create(25, 730), Vector2Create(775, 730), 3, COLOR_YELLOW);

            // Informações no topo da tela

            DrawTextEx(FontGame, 'SCORE', Vector2Create(50, 15), 34, 2, COLOR_YELLOW);
            ScoreText := FormatScoreWithLeadingZeros(G.Score, 5);
            DrawTextEx(FontGame, PChar(ScoreText), Vector2Create(50, 45), 34, 2, COLOR_YELLOW);

            DrawTextEx(FontGame, 'F3 = EXIT', Vector2Create(260, 15), 34, 2, GREEN);

            DrawTextEx(FontGame, 'HIGH SCORE', Vector2Create(570, 15), 34, 2, COLOR_YELLOW);
            HighScoreText := FormatScoreWithLeadingZeros(G.HighScore, 5);
            DrawTextEx(FontGame, PChar(HighScoreText), Vector2Create(660, 45), 34, 2, COLOR_YELLOW);

            if G.Running then
            begin
              // jogo em andamento

              { Desenha a vidas restantes (naves) }

              LifeOffset := 50;

              for I := 1 to G.Lives do
              begin
                DrawTextureV(G.Spaceship.Image, Vector2Create(LifeOffset, 745), WHITE);
                LifeOffset += 50;
              end;

              DrawTextEx(FontGame, PChar( Format('LEVEL %.*d',[1, lNivel]) ), Vector2Create(570, 740), 34, 2, COLOR_YELLOW);
            end
            else
            begin
              // Você ganhou ou perdeu, iniciar novo jogo ?
              DrawTextEx(FontGame, '<ENTER> new game, <F3> exit', Vector2Create(100, 745), 24, 2, WHITE);

              if G.Lives > 0 then
              begin
                // você ganhou
                if LBlink < 50 then
                  DrawTextEx(FontGame, 'YOU WIN!', Vector2Create(570, 740), 34, 2, GREEN);

                LBlink += 1;
                if LBlink > 80 then LBlink := 0;
              end
              else
              begin
                // você perdeu
                if LBlink < 50 then
                  DrawTextEx(FontDigital, 'GAME OVER', Vector2Create(570, 740), 34, 2, RED);

                LBlink += 1;
                if LBlink > 80 then LBlink := 0;
              end;
            end;


            G.Draw; { desenha os objetos do jogo da tela }

            // pressiionando F3, abre tela perguntando se quer sair do jogo
            if IsKeyPressed(KEY_F3) then
              ExitGame := True;

            if not ExitGame then
              G.Update { atualiza os objetos dos jogo na tela }
            else
            begin
              // apresenta a tela perguntando se quer sair do jogo
              DrawRectangle(200, 200, 410, 200, COLOR_BG);
              DrawRectangleLinesEx(RectangleCreate(202, 202, 407, 197), 1, RED);
              DrawText('SAIR DO JOGO', 265, 220, 40, RED);
              DrawText('ENTER = CONTINUAR / ESC = SAIR', 220, 360, 20, COLOR_BLUE);

              if IsKeyPressed(KEY_ESCAPE) then
                Break  // sair do jogo
              else if IsKeyPressed(KEY_ENTER) then
              begin
                LBlink := 0;
                lNivel += 1;
                ExitGame := False; // continuar jogando
              end;
            end;

          finally
            EndDrawing; { terminamos de desenhar na tela }
          end;

        end; // Loop Principal

      finally
        G.Free;
      end;

    finally
      // descarrega as fontes
      UnloadFont(FontGame);
      UnloadFont(FontDigital);
    end;

  finally
    CloseAudioDevice;
    CloseWindow;
  end;
end.

