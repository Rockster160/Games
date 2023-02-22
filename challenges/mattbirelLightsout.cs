using System;
using LightsOut;
using System.Collections;
using static Raylib;
using static Raygui;
class MainWindow
{
	Font notoMono;
	Sound switchSound;
	Vector2 screenSize = .(600, 634);
	Vector2 windowPosition;
	Vector2 panOffset = Vector2.Zero;
	bool exitWindow = false;
	bool dragWindow = false;
	bool resizeWindow = false;
	bool wasOverResize = false;
	int32 menuState = 0, menuActive = -1, menuFocused = -1;
	Rectangle menuRec = .(0, 0, 290, 180);
	function void(MainWindow this)[] menuFunctions = new function void(MainWindow this)[]( => HandleNewGame, => HandleIncreaseSize, => HandleDecreaseSize, => HandleQuit) ~ delete _;
	String newGame = new $"#{(int32)GuiIconName.ICON_RESTART}# New Game          Ctrl N " ~ delete _;
	String increaseSize = new $"#{(int32)GuiIconName.ICON_ARROW_UP}# Increase Size     Ctrl + " ~ delete _;
	String decreaseSize = new $"#{(int32)GuiIconName.ICON_ARROW_DOWN}# Decrease Size     Ctrl - " ~ delete _;
	String quitGame = new $"#{(int32)GuiIconName.ICON_EXIT}# Quit              Ctrl Q " ~ delete _;
	char8*[] menuItems = new char8*[](newGame, increaseSize, decreaseSize, quitGame) ~ delete _;
	int32 gameSize = 5, movesMade = 0;
	uint8[] board = new uint8[gameSize * gameSize] ~ delete _;
	uint8[] solution = new uint8[gameSize * gameSize] ~ delete _;
	bool gameWon = false;
	bool showSolution = false;
	uint8 gameStates = 2;

	private void Init()
	{
		SetConfigFlags(.FLAG_WINDOW_HIDDEN | .FLAG_WINDOW_UNDECORATED);
		InitWindow((int32)screenSize.x, (int32)screenSize.y, "Lights Out");

		Image icon = LoadImageFromMemory(".png", &Assets.Bulb, Assets.Bulb.Count);
		SetWindowIcon(icon);
		UnloadImage(icon);

		int32 monitorNum = GetCurrentMonitor();
		windowPosition = GetMonitorPosition(monitorNum);
		windowPosition.x += GetMonitorWidth(monitorNum) / 2 - screenSize.x / 2;
		windowPosition.y += GetMonitorHeight(monitorNum) / 2 - screenSize.y / 2;
		SetWindowPosition((int32)windowPosition.x, (int32)windowPosition.y);

		ClearWindowState(.FLAG_WINDOW_HIDDEN);

		notoMono = LoadFontFromMemory(".ttf", &Assets.NotoMono, Assets.NotoMono.Count, 18, null, 0);
		SetTextureFilter(notoMono.texture, .TEXTURE_FILTER_TRILINEAR);
		GuiSetFont(notoMono);
		GuiSetStyle(.DEFAULT, .TEXT_SIZE, 18);
		GuiSetStyle(.LISTVIEW, .TEXT_SIZE, 18);
		GuiSetStyle(.LISTVIEW, .TEXT_ALIGNMENT, TEXT_ALIGN_RIGHT);

		InitAudioDevice();
		switchSound = LoadSoundFromWave(LoadWaveFromMemory(".wav", &Assets.Switch, Assets.Switch.Count));

		SetTargetFPS(60);
	}

	public void Run()
	{
		Init();
		HandleNewGame();

		while (!WindowShouldClose() && !exitWindow)
		{
			Vector2 mousePosition = IsCursorOnScreen() ? GetMousePosition() : Vector2.Zero;
			bool isLeftMouse = IsMouseButtonPressed(.MOUSE_LEFT_BUTTON);

			HandleDrag(mousePosition, isLeftMouse);
			HandleResize(mousePosition, isLeftMouse);
			HandleMenu(mousePosition);
			HandleInputs();

			BeginDrawing();
			DrawWindow(isLeftMouse);
			DrawGame(mousePosition);
			DrawMenu(isLeftMouse);
			EndDrawing();
		}

		Dispose();
	}
	private void HandleInputs()
	{
		bool ctrl = IsKeyDown(.KEY_LEFT_CONTROL) || IsKeyDown(.KEY_RIGHT_CONTROL);
		KeyboardKey key = GetKeyPressed();
		if (ctrl)
		{
			if (key == .KEY_N)
			{
				HandleNewGame();
			} else if (key == .KEY_Q)
			{
				HandleQuit();
			} else if (key == .KEY_MINUS || key == .KEY_KP_SUBTRACT)
			{
				HandleDecreaseSize();
			} else if (key == .KEY_KP_ADD || key == .KEY_EQUAL)
			{
				HandleIncreaseSize();
			} else if (key == .KEY_S)
			{
				showSolution = !showSolution;
			}
		} else if (key == .KEY_MINUS || key == .KEY_KP_SUBTRACT)
		{
			HandleDecreaseStates();
		} else if (key == .KEY_KP_ADD || key == .KEY_EQUAL)
		{
			HandleIncreaseStates();
		}
	}
	private void HandleNewGame()
	{
		Random rnd = scope Random();
		Array.Clear(board, 0, board.Count);
		Array.Clear(solution, 0, solution.Count);
		for (int i = 0; i < 100000; i++)
		{
			ToggleBoardCell(rnd.NextI32() % board.Count);
		}
		movesMade = 0;
		gameWon = false;
	}
	private void ResizeBoard()
	{
		delete board;
		delete solution;
		board = new uint8[gameSize * gameSize];
		solution = new uint8[gameSize * gameSize];
	}
	private void HandleIncreaseSize()
	{
		gameSize++;
		if (gameSize > 20) { gameSize = 20; }
		ResizeBoard();
		HandleNewGame();
	}
	private void HandleDecreaseSize()
	{
		gameSize--;
		if (gameSize < 2) { gameSize = 2; }
		ResizeBoard();
		HandleNewGame();
	}
	private void HandleIncreaseStates()
	{
		gameStates++;
		if (gameStates > 5) { gameStates = 5; }
		HandleNewGame();
	}
	private void HandleDecreaseStates()
	{
		gameStates--;
		if (gameStates < 2) { gameStates = 2; }
		HandleNewGame();
	}
	private void HandleQuit()
	{
		exitWindow = true;
	}
	private bool HasWon(uint8[] state)
	{
		for (int i = 0; i < state.Count; i++)
		{
			if (state[i] != 0)
			{
				return false;
			}
		}
		return true;
	}
	private void ToggleBoardCell(int cell)
	{
		int x = cell % gameSize;
		board[cell] = (board[cell] + 1) % gameStates;
		if (x > 0)
		{
			board[cell - 1] = (board[cell - 1] + 1) % gameStates;
		}
		if (x < gameSize - 1)
		{
			board[cell + 1] = (board[cell + 1] + 1) % gameStates;
		}
		if (cell >= gameSize)
		{
			board[cell - gameSize] = (board[cell - gameSize] + 1) % gameStates;
		}
		if (cell + gameSize < board.Count)
		{
			board[cell + gameSize] = (board[cell + gameSize] + 1) % gameStates;
		}
		solution[cell] = (solution[cell] + 1) % gameStates;
		movesMade++;
	}
	private void DrawGame(Vector2 mousePosition)
	{
		int32 spacing = 4;
		int32 headerSpacingY = 34;
		int32 squareSizeX = (int32)(screenSize.x - 20 - gameSize * spacing) / gameSize;
		int32 squareSizeY = (int32)(screenSize.y - headerSpacingY - 10 - gameSize * spacing) / gameSize;

		int32 startX = 10;
		int32 startY = headerSpacingY;
		int cell = 0;
		for (int y = 0; y < gameSize; y++)
		{
			for (int x = 0; x < gameSize; x++)
			{
				uint8 boardVal = board[cell++];
				if (boardVal == 0)
				{
					DrawRectangleGradientEx(.(startX, startY, squareSizeX, squareSizeY), .BLUE, .DARKBLUE, .BLUE, .SKYBLUE);
				} else
				{
					DrawRectangleGradientEx(.(startX, startY, squareSizeX, squareSizeY), .(220, 220, 220, 255), .(200, 200, 200, 255), .(220, 220, 220, 255), .WHITE);
					if (gameStates > 2)
					{
						DrawTextEx(notoMono, scope $"{boardVal}", .(startX + squareSizeX / 2 - 4, startY + squareSizeY / 2 - 8), 18, 0, .BLACK);
					}
				}

				Rectangle cellRect = .(startX, startY, squareSizeX, squareSizeY);
				if (!gameWon && CheckCollisionPointRec(mousePosition, cellRect))
				{
					DrawRectangleLinesEx(cellRect, 3f, .DARKBLUE);
					if (menuState == 0 && IsMouseButtonPressed(.MOUSE_BUTTON_LEFT))
					{
						ToggleBoardCell(cell - 1);
						PlaySound(switchSound);
						if (HasWon(board))
						{
							gameWon = true;
						}
					}
				} else
				{
					DrawRectangleLines(startX, startY, squareSizeX, squareSizeY, .BLACK);
				}

				if (showSolution && solution[cell - 1] != 0)
				{
					DrawRectangleLinesEx(cellRect, 3f, .RED);
				}

				startX += spacing + squareSizeX;
			}

			startX = 10;
			startY += spacing + squareSizeY;
		}

		if (gameWon)
		{
			if (GuiMessageBox(.(screenSize.x / 2 - 125, screenSize.y / 2 - 50, 250, 100), "Congratulations!", scope $"You Won in {movesMade} moves!", "OK") >= 0)
			{
				HandleNewGame();
			}
		}
	}
	private void DrawWindow(bool isLeftMouse)
	{
		ClearBackground(.RAYWHITE);

		exitWindow = exitWindow || GuiWindowBox(.(0, 0, screenSize.x, screenSize.y), scope $"#{(int32)GuiIconName.ICON_BREAKPOINT_ON}# Lights Out - Moves Made {movesMade}");

		DrawTriangle(.(screenSize.x, screenSize.y - 16), .(screenSize.x - 16, screenSize.y), .(screenSize.x, screenSize.y), .LIGHTGRAY);
	}
	private void DrawMenu(bool isLeftMouse)
	{
		if (menuState >= 1)
		{
			int32 itemHeight = GuiGetStyle(.LISTVIEW, .LIST_ITEMS_HEIGHT) + GuiGetStyle(.LISTVIEW, .LIST_ITEMS_SPACING);
			menuRec.height = itemHeight * menuItems.Count + 4;
			int32 focused = menuFocused;
			menuActive = GuiListViewEx(menuRec, &menuItems[0], (int32)menuItems.Count, &focused, null, menuActive);
			menuFocused = menuActive = focused;
			if (focused != -1 && isLeftMouse)
			{
				menuFunctions[focused](this);
				menuState = 0;
				menuFocused = menuActive = -1;
			}
		}

		if (isLeftMouse)
		{
			menuState = 0;
			menuFocused = menuActive = -1;
		}
	}
	private void HandleDrag(Vector2 mousePosition, bool isLeftMouse)
	{
		if (isLeftMouse && CheckCollisionPointRec(mousePosition, .(0, 0, screenSize.x, 20)))
		{
			dragWindow = true;
			panOffset = mousePosition;
		}

		if (dragWindow)
		{
			windowPosition.x += (mousePosition.x - panOffset.x);
			windowPosition.y += (mousePosition.y - panOffset.y);

			if (IsMouseButtonReleased(.MOUSE_LEFT_BUTTON))
			{
				dragWindow = false;
			}

			SetWindowPosition((int32)windowPosition.x, (int32)windowPosition.y);
		}
	}
	private void HandleResize(Vector2 mousePosition, bool isLeftMouse)
	{
		bool overResize = CheckCollisionPointRec(mousePosition, .(screenSize.x - 16, screenSize.y - 16, 16, 16));
		if (isLeftMouse && overResize)
		{
			resizeWindow = true;
			panOffset =  screenSize - mousePosition;
		}

		if (overResize != wasOverResize)
		{
			wasOverResize = overResize;
			SetMouseCursor(overResize ? .MOUSE_CURSOR_RESIZE_NWSE : .MOUSE_CURSOR_DEFAULT);
		}

		if (resizeWindow)
		{
			screenSize.x = (panOffset.x + mousePosition.x);
			screenSize.y = (panOffset.y + mousePosition.y);
			if (screenSize.x < 350) { screenSize.x = 350; }
			if (screenSize.y < 350) { screenSize.y = 350; }

			if (IsMouseButtonReleased(.MOUSE_LEFT_BUTTON))
			{
				SetMouseCursor(.MOUSE_CURSOR_DEFAULT);
				resizeWindow = false;
			}

			SetWindowSize((int32)screenSize.x, (int32)screenSize.y);
		}
	}
	private void HandleMenu(Vector2 mousePosition)
	{
		if (IsMouseButtonPressed(.MOUSE_RIGHT_BUTTON))
		{
			menuState = 1;
			menuFocused = menuActive = -1;
			menuRec.x = mousePosition.x;
			menuRec.y = mousePosition.y;
			if (menuRec.x + menuRec.width >= screenSize.x - 4)
			{
				menuRec.x = screenSize.x - menuRec.width - 4;
			}
			if (menuRec.y + menuRec.height >= screenSize.y - 4)
			{
				menuRec.y = screenSize.y - menuRec.height - 4;
			}
		}
	}
	private void Dispose()
	{
		UnloadFont(notoMono);
		UnloadSound(switchSound);
		CloseAudioDevice();
		CloseWindow();
	}
}
