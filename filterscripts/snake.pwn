#include <a_samp>

#define RGBA_WHITE                  0xFFFFFFFF
#define RGBA_RED                    0xFF0000FF
#define RGBA_GREEN                  0x00FF00FF
#define SNAKE_GRID_WIDTH			15
#define SNAKE_GRID_HEIGHT			15
#define SNAKE_GRID_SIZE				(SNAKE_GRID_WIDTH * SNAKE_GRID_HEIGHT)
#define MIN_SNAKE_WIDTH				0
#define MAX_SNAKE_WIDTH				(SNAKE_GRID_WIDTH - 1)
#define MIN_SNAKE_HEIGHT			0
#define MAX_SNAKE_HEIGHT    		(SNAKE_GRID_HEIGHT - 1)
#define MAX_SNAKE_SIZE          	SNAKE_GRID_SIZE
#define MAX_SNAKE_PLAYERS			4
#define MAX_SNAKE_GAMES				20
#define INVALID_SNAKE_GAME_BLOCK    -1
#define INVALID_SNAKE_TIMER			-1
#define INVALID_SNAKE_GAME			-1
#define INVALID_SNAKE_PLAYER_SLOT   -1
#define INVALID_SNAKE_DIRECTION 	-1
#define SNAKE_BLOCK_DATA_FOOD		-1
#define SNAKE_GAME_INTERVAL_MS		100
#define SNAKE_COUNTDOWN_S			10
#define SNAKE_COUNTOUT_S			5

enum {
	SNAKE_TDMODE_NONE,
	SNAKE_TDMODE_GAME,
	SNAKE_TDMODE_MENU,
	SNAKE_TDMODE_NEWGAME,
	SNAKE_TDMODE_JOINGAME,
	SNAKE_TDMODE_HIGHSCORE,
	SNAKE_TDMODE_KEYS
}

enum {
	SNAKE_STATE_NONE,
	SNAKE_STATE_COUNTDOWN,
	SNAKE_STATE_STARTED,
	SNAKE_STATE_GAMEOVER
}

enum {
	SNAKE_DIRECTION_U,
	SNAKE_DIRECTION_D,
	SNAKE_DIRECTION_L,
	SNAKE_DIRECTION_R,
	MAX_SNAKE_DIRECTIONS
}

//------------------------------------------------------------------------------
// Menu Textdraws

enum { // Menu Row Buttons
	PlayerText: SNAKE_MENU_RBUTTON_SP,
	PlayerText: SNAKE_MENU_RBUTTON_MP,
	PlayerText: SNAKE_MENU_RBUTTON_CREATE,
	PlayerText: SNAKE_MENU_RBUTTON_JOIN,
	PlayerText: SNAKE_MENU_RBUTTON_SCORE,
	PlayerText: SNAKE_MENU_RBUTTON_KEYS,
	MAX_SNAKE_MENU_RBUTTONS
}

enum {
	PlayerText: SNAKE_MENU_TD_BG, // Background
	PlayerText: SNAKE_MENU_TD_TITLE, // Title / Caption
	PlayerText: SNAKE_MENU_TD_XBUTTON, // Close Button
	PlayerText: SNAKE_MENU_TD_RBUTTON[MAX_SNAKE_MENU_RBUTTONS], // Row Button
	MAX_SNAKE_MENU_TEXTDRAWS
}

new PlayerText: g_SnakeMenuTextdraw[MAX_PLAYERS][MAX_SNAKE_MENU_TEXTDRAWS];

//------------------------------------------------------------------------------
// New Game Textdraws

enum { // New Game Tiny Buttons
	PlayerText: SNAKE_NEWGAME_TBUTTON_X, // Close
	PlayerText: SNAKE_NEWGAME_TBUTTON_B, // Back
	MAX_SNAKE_NEWGAME_TBUTTONS
}

enum {
	PlayerText: SNAKE_NEWGAME_TD_BG,
	PlayerText: SNAKE_NEWGAME_TD_TITLE,
	PlayerText: SNAKE_NEWGAME_TD_TBUTTON	[MAX_SNAKE_NEWGAME_TBUTTONS], // Tiny Button
	PlayerText: SNAKE_NEWGAME_TD_PBUTTON	[MAX_SNAKE_PLAYERS], // Player Button
	MAX_SNAKE_NEWGAME_TEXTDRAWS
}

new PlayerText: g_SnakeNewGameTextdraw[MAX_PLAYERS][MAX_SNAKE_NEWGAME_TEXTDRAWS];

//------------------------------------------------------------------------------
// Join Game Textdraws

#define MAX_SNAKE_JOINGAME_PAGESIZE \
	15

#define MIN_SNAKE_JOINGAME_PAGE \
	0

#define MAX_SNAKE_JOINGAME_PAGE \
	( ( MAX_SNAKE_GAMES - 1 ) / MAX_SNAKE_JOINGAME_PAGESIZE )

#define MAX_SNAKE_JOINGAME_PBUTTONS \
    ( MAX_SNAKE_PLAYERS * MAX_SNAKE_JOINGAME_PAGESIZE )

enum { // Tiny Buttons
	PlayerText: SNAKE_JOINGAME_TBUTTON_X,		// Close
	PlayerText: SNAKE_JOINGAME_TBUTTON_B,		// Back
	PlayerText: SNAKE_JOINGAME_TBUTTON_PAGE_F,	// First Page
	PlayerText: SNAKE_JOINGAME_TBUTTON_PAGE_P,	// Previous Page
	PlayerText: SNAKE_JOINGAME_TBUTTON_PAGE_N,	// Next Page
	PlayerText: SNAKE_JOINGAME_TBUTTON_PAGE_L,	// Last Page
	MAX_SNAKE_JOINGAME_TBUTTONS
}

enum {
	PlayerText: SNAKE_JOINGAME_TD_BG,										// Background Box
	PlayerText: SNAKE_JOINGAME_TD_TITLE,									// Title / Caption
	PlayerText: SNAKE_JOINGAME_TD_PAGE,										// Current Page
	PlayerText: SNAKE_JOINGAME_TD_GCOL,										// Game ID Column
	PlayerText: SNAKE_JOINGAME_TD_PCOL		[MAX_SNAKE_PLAYERS],			// Player Column
	PlayerText: SNAKE_JOINGAME_TD_GROW		[MAX_SNAKE_JOINGAME_PAGESIZE],	// Game Row
	PlayerText: SNAKE_JOINGAME_TD_TBUTTON	[MAX_SNAKE_JOINGAME_TBUTTONS], 	// Tiny Button
	PlayerText: SNAKE_JOINGAME_TD_PBUTTON	[MAX_SNAKE_JOINGAME_PBUTTONS],	// Player Button
	MAX_SNAKE_JOINGAME_TEXTDRAWS
}

enum e_SnakeJoinGameData {
	e_SnakeJoinGamePage
}

new
	PlayerText: g_SnakeJoinGameTextdraw[MAX_PLAYERS][MAX_SNAKE_JOINGAME_TEXTDRAWS],
	g_SnakeJoinGameData[MAX_PLAYERS][e_SnakeJoinGameData]
;

//------------------------------------------------------------------------------
// Score Textdraws

#define MAX_SNAKE_SCORE_PAGESIZE \
	15

#define MAX_SNAKE_SCORE_QUERYLEN \
	1000

#define MIN_SNAKE_SCORE_PAGE \
	0

#define MAX_SNAKE_SCORE_PAGE \
    2147483646 // max 32 bit integer value

enum {
	PlayerText: SNAKE_SCORE_TBUTTON_X,	// Close
	PlayerText: SNAKE_SCORE_TBUTTON_B,	// Back
	PlayerText: SNAKE_SCORE_TBUTTON_PAGE_F,	// First Page
	PlayerText: SNAKE_SCORE_TBUTTON_PAGE_P,	// Previous Page
	PlayerText: SNAKE_SCORE_TBUTTON_PAGE_N,	// Next Page
	PlayerText: SNAKE_SCORE_TBUTTON_PAGE_L,	// Last Page
	MAX_SNAKE_SCORE_TBUTTONS
}

enum {
	PlayerText: SNAKE_SCORE_COL_RANK,
	PlayerText: SNAKE_SCORE_COL_PLAYER,
	PlayerText: SNAKE_SCORE_COL_SIZE,
	PlayerText: SNAKE_SCORE_COL_KILLS,
	PlayerText: SNAKE_SCORE_COL_TIMEDATE,
	MAX_SNAKE_SCORE_COLUMNS
}

enum {
	PlayerText: SNAKE_SCORE_TD_BG,									// Background Box
	PlayerText: SNAKE_SCORE_TD_TITLE,								// Title / Caption
	PlayerText: SNAKE_SCORE_TD_PAGE,								// Page
	PlayerText: SNAKE_SCORE_TD_COL		[MAX_SNAKE_SCORE_COLUMNS],	// Columns
	PlayerText: SNAKE_SCORE_TD_TBUTTON	[MAX_SNAKE_SCORE_TBUTTONS],	// Tiny Buttons
	PlayerText: SNAKE_SCORE_TD_RANK		[MAX_SNAKE_SCORE_PAGESIZE],	// Rank Row
	PlayerText: SNAKE_SCORE_TD_PLAYER	[MAX_SNAKE_SCORE_PAGESIZE],	// Player Row
	PlayerText: SNAKE_SCORE_TD_SIZE		[MAX_SNAKE_SCORE_PAGESIZE],	// Size Row
	PlayerText: SNAKE_SCORE_TD_KILLS	[MAX_SNAKE_SCORE_PAGESIZE],	// Kill Rows
	PlayerText: SNAKE_SCORE_TD_TIMEDATE	[MAX_SNAKE_SCORE_PAGESIZE],	// Time & Date Rows
	MAX_SNAKE_SCORE_TEXTDRAWS
}

enum {
	SNAKE_SCORE_SORT_PLAYER_D, // Players in alphabetical order, descending
	SNAKE_SCORE_SORT_PLAYER_A, // Players in alphabetical order, ascending
	SNAKE_SCORE_SORT_SIZE_D, // Size in order, descending
	SNAKE_SCORE_SORT_SIZE_A, // Size in order, ascending
	SNAKE_SCORE_SORT_KILLS_D, // Kills in order, descending
	SNAKE_SCORE_SORT_KILLS_A, // Kills in order, ascending
	SNAKE_SCORE_SORT_TIMEDATE_D, // Time & Date in order, descending
	SNAKE_SCORE_SORT_TIMEDATE_A, // Time & Date in order, ascending
	MAX_SNAKE_SCORE_SORTMODES
}

enum e_SnakeScoreData {
	e_SnakeScorePage,
	e_SnakeScoreSort
}

new
	PlayerText: g_SnakeScoreTextdraw[MAX_PLAYERS][MAX_SNAKE_SCORE_TEXTDRAWS],
	g_SnakeScoreData[MAX_PLAYERS][e_SnakeScoreData],
	DB: g_SnakeScoreDB,
	g_SnakeScoreQuery[MAX_SNAKE_SCORE_QUERYLEN+1]
;

//------------------------------------------------------------------------------
// Key Textdraws

enum {
	PlayerText: SNAKE_KEY_TBUTTON_X,	// Close
	PlayerText: SNAKE_KEY_TBUTTON_B,	// Back
	MAX_SNAKE_KEY_TBUTTONS
}

enum {
	PlayerText: SNAKE_KEY_KEYACTION_L, // Left
	PlayerText: SNAKE_KEY_KEYACTION_R, // Right
	PlayerText: SNAKE_KEY_KEYACTION_D, // Down
	PlayerText: SNAKE_KEY_KEYACTION_U, // Up
	PlayerText: SNAKE_KEY_KEYACTION_X, // Close
	MAX_SNAKE_KEY_KEYACTIONS
}
enum {
	PlayerText: SNAKE_KEY_TD_BG,										// Background Box
	PlayerText: SNAKE_KEY_TD_TITLE,										// Title / Caption
	PlayerText: SNAKE_KEY_TD_TBUTTON		[MAX_SNAKE_KEY_TBUTTONS],	// Tiny Buttons
	PlayerText: SNAKE_KEY_TD_KEY_COL,                                	// Keystroke Column
	PlayerText: SNAKE_KEY_TD_ACTION_COL,                               	// Action Column
	PlayerText: SNAKE_KEY_TD_KEY_ROW		[MAX_SNAKE_KEY_KEYACTIONS],	// Key Row
	PlayerText: SNAKE_KEY_TD_ACTION_ROW		[MAX_SNAKE_KEY_KEYACTIONS],	// Action Row
	MAX_SNAKE_KEY_TEXTDRAWS
}

new
	PlayerText: g_SnakeKeyTextdraw[MAX_PLAYERS][MAX_SNAKE_KEY_TEXTDRAWS]
;

//------------------------------------------------------------------------------

enum e_SnakeData {
	e_SnakeState,
	e_SnakeTime,
	e_SnakeCurrentPlayerCount,
	e_SnakeTargetPlayerCount,
	e_SnakePlayerID			[MAX_SNAKE_PLAYERS],
	e_SnakeSortedPlayers    [MAX_SNAKE_PLAYERS],
	e_SnakeBlockData		[SNAKE_GRID_SIZE],
}

enum e_PlayerSnakeData {
	e_PlayerSnakeGameID,
	e_PlayerSnakeSlot,
	e_PlayerSnakeSize,
	e_PlayerSnakeKills,
	e_PlayerSnakeBlocks[MAX_SNAKE_SIZE],
	e_PlayerSnakeNextDirection,
	e_PlayerSnakeLastDirection,
	bool: e_PlayerSnakeAlive,
	e_PlayerSnakeTextdrawMode
}

enum {
	PlayerText: SNAKE_TD_GAME_BG,
	PlayerText: SNAKE_TD_GAME_BLOCK			[SNAKE_GRID_SIZE],
	PlayerText: SNAKE_TD_GAME_COUNTDOWN,
	PlayerText: SNAKE_TD_GAME_XKEYS,
	PlayerText: SNAKE_TD_GAME_PLAYER_COL,
	PlayerText: SNAKE_TD_GAME_SIZE_COL,
	PlayerText: SNAKE_TD_GAME_KILLS_COL,
	PlayerText: SNAKE_TD_GAME_ALIVE_COL,
	PlayerText: SNAKE_TD_GAME_PLAYER_ROW	[MAX_SNAKE_PLAYERS],
	PlayerText: SNAKE_TD_GAME_SIZE_ROW		[MAX_SNAKE_PLAYERS],
	PlayerText: SNAKE_TD_GAME_KILLS_ROW		[MAX_SNAKE_PLAYERS],
	PlayerText: SNAKE_TD_GAME_ALIVE_ROW		[MAX_SNAKE_PLAYERS],
	MAX_SNAKE_GAME_TEXTDRAWS
}

new
	g_SnakeData					[MAX_SNAKE_GAMES][e_SnakeData],
	g_PlayerSnakeData			[MAX_PLAYERS][e_PlayerSnakeData],
	PlayerText: g_SnakeGameTextDraw	[MAX_PLAYERS][MAX_SNAKE_GAME_TEXTDRAWS],
	g_SnakeTimer = INVALID_SNAKE_TIMER
;

new const g_SnakeColors[MAX_SNAKE_PLAYERS] = {
	0xFF0000FF, 0xFFFF00FF, 0x0000FFFF, 0xFF00FFFF
};

//------------------------------------------------------------------------------

CreateSnakeGameTextdraws(playerid) {
	g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BG] =
	CreatePlayerTextDraw			(playerid, 320.0, 49.0, "_");
	PlayerTextDrawAlignment			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BG], 2);
	PlayerTextDrawLetterSize		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BG], 0.0, 39.2);
	PlayerTextDrawUseBox			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BG], 1);
	PlayerTextDrawBoxColor			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BG], 150);
	PlayerTextDrawTextSize			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BG], 0.0, 270.0);
	PlayerTextDrawShow				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BG]);

	g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_COUNTDOWN] =
	CreatePlayerTextDraw			(playerid, 320.0, 49.0, "_");
	PlayerTextDrawAlignment			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_COUNTDOWN], 2);
	PlayerTextDrawBackgroundColor	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_COUNTDOWN], 255);
	PlayerTextDrawFont				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_COUNTDOWN], 2);
	PlayerTextDrawLetterSize		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_COUNTDOWN], 0.4, 2.0);
	PlayerTextDrawColor				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_COUNTDOWN], -1);
	PlayerTextDrawSetOutline		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_COUNTDOWN], 1);
	PlayerTextDrawSetProportional	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_COUNTDOWN], 1);
	PlayerTextDrawUseBox			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_COUNTDOWN], 1);
	PlayerTextDrawBoxColor			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_COUNTDOWN], -206);
	PlayerTextDrawTextSize			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_COUNTDOWN], 0.0, 270.0);
	PlayerTextDrawShow              (playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_COUNTDOWN]);

	g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_XKEYS] =
	CreatePlayerTextDraw			(playerid, 320.0, 393.0, GetPlayerStopSnakeButtons(playerid));
	PlayerTextDrawAlignment			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_XKEYS], 2);
	PlayerTextDrawBackgroundColor	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_XKEYS], 255);
	PlayerTextDrawFont				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_XKEYS], 2);
	PlayerTextDrawLetterSize		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_XKEYS], 0.2, 1.0);
	PlayerTextDrawColor				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_XKEYS], -1);
	PlayerTextDrawSetOutline		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_XKEYS], 1);
	PlayerTextDrawSetProportional	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_XKEYS], 1);
	PlayerTextDrawUseBox			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_XKEYS], 1);
	PlayerTextDrawBoxColor			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_XKEYS], -206);
	PlayerTextDrawTextSize			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_XKEYS], 0.0, 270.0);
	PlayerTextDrawShow				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_XKEYS]);

	g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_PLAYER_COL] =
	CreatePlayerTextDraw			(playerid, 185.0, 329.0, "Player");
	PlayerTextDrawBackgroundColor	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_PLAYER_COL], 255);
	PlayerTextDrawFont				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_PLAYER_COL], 1);
	PlayerTextDrawLetterSize		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_PLAYER_COL], 0.2, 1.0);
	PlayerTextDrawColor				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_PLAYER_COL], -1);
	PlayerTextDrawSetOutline		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_PLAYER_COL], 1);
	PlayerTextDrawSetProportional	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_PLAYER_COL], 1);
	PlayerTextDrawUseBox			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_PLAYER_COL], 1);
	PlayerTextDrawBoxColor			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_PLAYER_COL], -206);
	PlayerTextDrawTextSize			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_PLAYER_COL], 365.0, 0.0);
	PlayerTextDrawShow				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_PLAYER_COL]);

	g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_SIZE_COL] =
	CreatePlayerTextDraw			(playerid, 368.0, 329.0, "Size");
	PlayerTextDrawBackgroundColor	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_SIZE_COL], 255);
	PlayerTextDrawFont				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_SIZE_COL], 1);
	PlayerTextDrawLetterSize		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_SIZE_COL], 0.2, 1.0);
	PlayerTextDrawColor				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_SIZE_COL], -1);
	PlayerTextDrawSetOutline		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_SIZE_COL], 1);
	PlayerTextDrawSetProportional	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_SIZE_COL], 1);
	PlayerTextDrawUseBox			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_SIZE_COL], 1);
	PlayerTextDrawBoxColor			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_SIZE_COL], -206);
	PlayerTextDrawTextSize			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_SIZE_COL], 395.0, 0.0);
	PlayerTextDrawShow				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_SIZE_COL]);

	g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_KILLS_COL] =
	CreatePlayerTextDraw			(playerid, 398.0, 329.0, "Kills");
	PlayerTextDrawBackgroundColor	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_KILLS_COL], 255);
	PlayerTextDrawFont				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_KILLS_COL], 1);
	PlayerTextDrawLetterSize		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_KILLS_COL], 0.2, 1.0);
	PlayerTextDrawColor				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_KILLS_COL], -1);
	PlayerTextDrawSetOutline		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_KILLS_COL], 1);
	PlayerTextDrawSetProportional	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_KILLS_COL], 1);
	PlayerTextDrawUseBox			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_KILLS_COL], 1);
	PlayerTextDrawBoxColor			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_KILLS_COL], -206);
	PlayerTextDrawTextSize			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_KILLS_COL], 425.0, 0.0);
	PlayerTextDrawShow				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_KILLS_COL]);

	g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_ALIVE_COL] =
	CreatePlayerTextDraw			(playerid, 428.0, 329.0, "Alive");
	PlayerTextDrawBackgroundColor	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_ALIVE_COL], 255);
	PlayerTextDrawFont				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_ALIVE_COL], 1);
	PlayerTextDrawLetterSize		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_ALIVE_COL], 0.2, 1.0);
	PlayerTextDrawColor				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_ALIVE_COL], -1);
	PlayerTextDrawSetOutline		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_ALIVE_COL], 1);
	PlayerTextDrawSetProportional	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_ALIVE_COL], 1);
	PlayerTextDrawUseBox			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_ALIVE_COL], 1);
	PlayerTextDrawBoxColor			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_ALIVE_COL], -206);
	PlayerTextDrawTextSize			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_ALIVE_COL], 455.0, 0.0);
	PlayerTextDrawShow				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_ALIVE_COL]);

	for(new row, Float:y = 342.0; row < MAX_SNAKE_PLAYERS; row ++, y += 13.0) {
		g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_PLAYER_ROW][row] =
		CreatePlayerTextDraw			(playerid, 185.0, y, "Player");
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_PLAYER_ROW][row], 255);
		PlayerTextDrawFont				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_PLAYER_ROW][row], 1);
		PlayerTextDrawLetterSize		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_PLAYER_ROW][row], 0.2, 1.0);
		PlayerTextDrawColor				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_PLAYER_ROW][row], -1);
		PlayerTextDrawSetProportional	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_PLAYER_ROW][row], 1);
		PlayerTextDrawSetShadow			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_PLAYER_ROW][row], 1);
		PlayerTextDrawTextSize			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_PLAYER_ROW][row], 365.0, 0.0);

		g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_SIZE_ROW][row] =
		CreatePlayerTextDraw			(playerid, 368.0, y, "Size");
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_SIZE_ROW][row], 255);
		PlayerTextDrawFont				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_SIZE_ROW][row], 1);
		PlayerTextDrawLetterSize		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_SIZE_ROW][row], 0.2, 1.0);
		PlayerTextDrawColor				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_SIZE_ROW][row], -1);
		PlayerTextDrawSetProportional	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_SIZE_ROW][row], 1);
		PlayerTextDrawSetShadow			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_SIZE_ROW][row], 1);
		PlayerTextDrawTextSize			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_SIZE_ROW][row], 395.0, 0.0);

		g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_KILLS_ROW][row] =
		CreatePlayerTextDraw			(playerid, 398.0, y, "Kills");
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_KILLS_ROW][row], 255);
		PlayerTextDrawFont				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_KILLS_ROW][row], 1);
		PlayerTextDrawLetterSize		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_KILLS_ROW][row], 0.2, 1.0);
		PlayerTextDrawColor				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_KILLS_ROW][row], -1);
		PlayerTextDrawSetProportional	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_KILLS_ROW][row], 1);
		PlayerTextDrawSetShadow			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_KILLS_ROW][row], 1);
		PlayerTextDrawTextSize			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_KILLS_ROW][row], 425.0, 0.0);

		g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_ALIVE_ROW][row] =
		CreatePlayerTextDraw			(playerid, 428.0, y, "Alive");
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_ALIVE_ROW][row], 255);
		PlayerTextDrawFont				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_ALIVE_ROW][row], 1);
		PlayerTextDrawLetterSize		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_ALIVE_ROW][row], 0.2, 1.0);
		PlayerTextDrawColor				(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_ALIVE_ROW][row], -1);
		PlayerTextDrawSetProportional	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_ALIVE_ROW][row], 1);
		PlayerTextDrawSetShadow			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_ALIVE_ROW][row], 1);
		PlayerTextDrawTextSize			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_ALIVE_ROW][row], 455.0, 0.0);
	}
	return 1;
}

CreateSnakeMenuTextdraws(playerid) {
	g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_BG] =
	CreatePlayerTextDraw		(playerid, 320.0, 115.0, "_");
	PlayerTextDrawAlignment		(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_BG], 2);
	PlayerTextDrawLetterSize	(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_BG], 0.0, 13.4);
	PlayerTextDrawUseBox		(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_BG], 1);
	PlayerTextDrawBoxColor		(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_BG], 100);
	PlayerTextDrawTextSize		(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_BG], 0.0, 160.0);

	g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_TITLE] =
	CreatePlayerTextDraw			(playerid, 243.0, 103.0, "Snake Menu");
	PlayerTextDrawBackgroundColor	(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_TITLE], 255);
	PlayerTextDrawFont				(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_TITLE], 0);
	PlayerTextDrawLetterSize		(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_TITLE], 0.6, 2.0);
	PlayerTextDrawColor				(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_TITLE], -1);
	PlayerTextDrawSetOutline		(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_TITLE], 1);
	PlayerTextDrawSetProportional	(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_TITLE], 1);

	for(new btn, Float:y = 132.0, str[22+1]; btn < MAX_SNAKE_MENU_RBUTTONS; btn ++, y += 18.0) {
		switch(btn) {
		    case SNAKE_MENU_RBUTTON_SP: {
		        str = "Singleplayer";
		    }
		    case SNAKE_MENU_RBUTTON_MP: {
		        str = "Multiplayer";
		    }
		    case SNAKE_MENU_RBUTTON_CREATE: {
		        str = "Create Game";
		    }
		    case SNAKE_MENU_RBUTTON_JOIN: {
		        str = "Join Game";
		    }
		    case SNAKE_MENU_RBUTTON_SCORE: {
		        str = "View Highscore";
		    }
		    case SNAKE_MENU_RBUTTON_KEYS: {
		        str = "Keys";
		    }
		    default: {
		        continue;
		    }
		}

		g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_RBUTTON][btn] =
		CreatePlayerTextDraw			(playerid, 320.0, y, str);
		PlayerTextDrawAlignment			(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_RBUTTON][btn], 2);
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_RBUTTON][btn], 255);
		PlayerTextDrawFont				(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_RBUTTON][btn], 1);
		PlayerTextDrawLetterSize		(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_RBUTTON][btn], 0.3, 1.5);
		PlayerTextDrawColor				(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_RBUTTON][btn], -1);
		PlayerTextDrawSetOutline		(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_RBUTTON][btn], 0);
		PlayerTextDrawSetProportional	(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_RBUTTON][btn], 1);
		PlayerTextDrawSetShadow			(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_RBUTTON][btn], 1);
		PlayerTextDrawUseBox			(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_RBUTTON][btn], 1);
		PlayerTextDrawBoxColor			(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_RBUTTON][btn], -16777116);
		PlayerTextDrawTextSize			(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_RBUTTON][btn], 13.0, 160.0);
		PlayerTextDrawSetSelectable		(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_RBUTTON][btn], 1);
	}

	g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_XBUTTON] =
	CreatePlayerTextDraw			(playerid, 390.0, 115.0, "x");
	PlayerTextDrawAlignment			(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_XBUTTON], 2);
	PlayerTextDrawBackgroundColor	(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_XBUTTON], 255);
	PlayerTextDrawFont				(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_XBUTTON], 2);
	PlayerTextDrawLetterSize		(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_XBUTTON], 0.2, 1.1);
	PlayerTextDrawColor				(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_XBUTTON], -1);
	PlayerTextDrawSetOutline		(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_XBUTTON], 1);
	PlayerTextDrawSetProportional	(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_XBUTTON], 1);
	PlayerTextDrawUseBox			(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_XBUTTON], 1);
	PlayerTextDrawBoxColor			(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_XBUTTON], -16777116);
	PlayerTextDrawTextSize			(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_XBUTTON], 9.0, 20.0);
	PlayerTextDrawSetSelectable		(playerid, g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_XBUTTON], 1);


	for(new i; i < MAX_SNAKE_MENU_TEXTDRAWS; i ++) {
		PlayerTextDrawShow(playerid, g_SnakeMenuTextdraw[playerid][i]);
	}
	return 1;
}

CreateSnakeNewGameTextdraws(playerid) {
	g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_BG] =
	CreatePlayerTextDraw			(playerid, 320.0, 115.0, "_");
	PlayerTextDrawAlignment			(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_BG], 2);
	PlayerTextDrawLetterSize		(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_BG], 0.0, 9.4);
	PlayerTextDrawUseBox			(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_BG], 1);
	PlayerTextDrawBoxColor			(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_BG], 100);
	PlayerTextDrawTextSize			(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_BG], 0.0, 200.0);

	g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TITLE] =
	CreatePlayerTextDraw			(playerid, 221.0, 103.0, "Create Snake Game");
	PlayerTextDrawBackgroundColor	(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TITLE], 255);
	PlayerTextDrawFont				(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TITLE], 0);
	PlayerTextDrawLetterSize		(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TITLE], 0.6, 2.0);
	PlayerTextDrawColor				(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TITLE], -1);
	PlayerTextDrawSetOutline		(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TITLE], 1);
	PlayerTextDrawSetProportional	(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TITLE], 1);

	for(new btn, Float:y = 132.0, str[10+1]; btn < MAX_SNAKE_PLAYERS; btn ++, y += 18.0) {
		format(str, sizeof str, "%i %s", btn + 1, (btn == 0) ? ("Player") : ("Players"));

		g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_PBUTTON][btn] =
		CreatePlayerTextDraw			(playerid, 320.0, y, str);
		PlayerTextDrawAlignment			(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_PBUTTON][btn], 2);
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_PBUTTON][btn], 255);
		PlayerTextDrawFont				(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_PBUTTON][btn], 1);
		PlayerTextDrawLetterSize		(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_PBUTTON][btn], 0.3, 1.5);
		PlayerTextDrawColor				(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_PBUTTON][btn], -1);
		PlayerTextDrawSetOutline		(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_PBUTTON][btn], 0);
		PlayerTextDrawSetProportional	(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_PBUTTON][btn], 1);
		PlayerTextDrawSetShadow			(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_PBUTTON][btn], 1);
		PlayerTextDrawUseBox			(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_PBUTTON][btn], 1);
		PlayerTextDrawBoxColor			(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_PBUTTON][btn], -16777116);
		PlayerTextDrawTextSize			(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_PBUTTON][btn], 13.0, 200.0);
		PlayerTextDrawSetSelectable		(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_PBUTTON][btn], 1);
	}
	
	for(new btn, Float:x, str[2]; btn < MAX_SNAKE_NEWGAME_TBUTTONS; btn ++) {
		switch(btn) {
			case SNAKE_NEWGAME_TBUTTON_X: { // Close
				x = 410.0;
				str = "x";
			}
			case SNAKE_NEWGAME_TBUTTON_B: { // Back
				x = 387.0;
				str = "<";
			}
			default: {
				str = "E";
			}
		}

		g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TBUTTON][btn] =
		CreatePlayerTextDraw			(playerid, x, 115.0, str);
		PlayerTextDrawAlignment			(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TBUTTON][btn], 2);
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TBUTTON][btn], 255);
		PlayerTextDrawFont				(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TBUTTON][btn], 2);
		PlayerTextDrawLetterSize		(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TBUTTON][btn], 0.2, 1.1);
		PlayerTextDrawColor				(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TBUTTON][btn], -1);
		PlayerTextDrawSetOutline		(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TBUTTON][btn], 1);
		PlayerTextDrawSetProportional	(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TBUTTON][btn], 1);
		PlayerTextDrawUseBox			(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TBUTTON][btn], 1);
		PlayerTextDrawBoxColor			(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TBUTTON][btn], -16777116);
		PlayerTextDrawTextSize			(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TBUTTON][btn], 10.0, 20.0);
		PlayerTextDrawSetSelectable		(playerid, g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TBUTTON][btn], 1);
	}
	
	for(new td; td < MAX_SNAKE_NEWGAME_TEXTDRAWS; td ++) {
	    PlayerTextDrawShow(playerid, g_SnakeNewGameTextdraw[playerid][td]);
	}
}

CreateSnakeJoinGameTextdraws(playerid) {
	g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_BG] =
	CreatePlayerTextDraw			(playerid, 320.0, 105.0, "_");
	PlayerTextDrawAlignment			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_BG], 2);
	PlayerTextDrawLetterSize		(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_BG], 0.0, 24.9);
	PlayerTextDrawUseBox			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_BG], 1);
	PlayerTextDrawBoxColor			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_BG], 100);
	PlayerTextDrawTextSize			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_BG], 0.0, 364.0);
    PlayerTextDrawShow				(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_BG]);

	g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TITLE] =
	CreatePlayerTextDraw			(playerid, 140.0, 92.0, "Join Game");
	PlayerTextDrawBackgroundColor	(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TITLE], 255);
	PlayerTextDrawFont				(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TITLE], 0);
	PlayerTextDrawLetterSize		(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TITLE], 0.6, 2.0);
	PlayerTextDrawColor				(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TITLE], -1);
	PlayerTextDrawSetOutline		(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TITLE], 1);
	PlayerTextDrawSetProportional	(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TITLE], 1);
    PlayerTextDrawShow				(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TITLE]);

	g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PAGE] =
	CreatePlayerTextDraw			(playerid, 320.0, 105.0, "page");
	PlayerTextDrawAlignment			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PAGE], 2);
	PlayerTextDrawBackgroundColor	(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PAGE], 255);
	PlayerTextDrawFont				(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PAGE], 2);
	PlayerTextDrawLetterSize		(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PAGE], 0.2, 1.1);
	PlayerTextDrawColor				(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PAGE], -1);
	PlayerTextDrawSetOutline		(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PAGE], 1);
	PlayerTextDrawSetProportional	(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PAGE], 1);
    PlayerTextDrawShow				(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PAGE]);

	g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GCOL] =
	CreatePlayerTextDraw			(playerid, 140.0, 122.0, "Game ID");
	PlayerTextDrawBackgroundColor	(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GCOL], 255);
	PlayerTextDrawFont				(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GCOL], 1);
	PlayerTextDrawLetterSize		(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GCOL], 0.2, 1.0);
	PlayerTextDrawColor				(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GCOL], -1);
	PlayerTextDrawSetOutline		(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GCOL], 1);
	PlayerTextDrawSetProportional	(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GCOL], 1);
	PlayerTextDrawUseBox			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GCOL], 1);
	PlayerTextDrawBoxColor			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GCOL], 0xFFFFFF32);
	PlayerTextDrawTextSize			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GCOL], 180.0, 9.0);
    PlayerTextDrawShow				(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GCOL]);

	for(new col, Float:x, str[8+1]; col < MAX_SNAKE_PLAYERS; col ++) {
		x = 180.0 + (col * 80.0);
		
		format(str, sizeof str, "Player %i", col + 1);
		
		g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PCOL][col] =
		CreatePlayerTextDraw			(playerid, x + 4.0, 122.0, str);
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PCOL][col], 255);
		PlayerTextDrawFont				(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PCOL][col], 1);
		PlayerTextDrawLetterSize		(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PCOL][col], 0.2, 1.0);
		PlayerTextDrawColor				(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PCOL][col], g_SnakeColors[col]);
		PlayerTextDrawSetOutline		(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PCOL][col], 1);
		PlayerTextDrawSetProportional	(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PCOL][col], 1);
		PlayerTextDrawUseBox			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PCOL][col], 1);
		PlayerTextDrawBoxColor			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PCOL][col], 0xFFFFFF32);
		PlayerTextDrawTextSize			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PCOL][col], x + 80.0, 9.0);
	    PlayerTextDrawShow				(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PCOL][col]);
	}

	for(new row, Float:y; row < MAX_SNAKE_JOINGAME_PAGESIZE; row ++) {
		y = 135.0 + (row * 13.0);
		
		g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GROW][row] =
		CreatePlayerTextDraw			(playerid, 140.0, y, "Game ID");
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GROW][row], 255);
		PlayerTextDrawFont				(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GROW][row], 1);
		PlayerTextDrawLetterSize		(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GROW][row], 0.2, 1.0);
		PlayerTextDrawColor				(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GROW][row], -1);
		PlayerTextDrawSetOutline		(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GROW][row], 0);
		PlayerTextDrawSetProportional	(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GROW][row], 1);
		PlayerTextDrawSetShadow			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GROW][row], 1);
		PlayerTextDrawUseBox			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GROW][row], 0);
		PlayerTextDrawBoxColor			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GROW][row], -16777116);
		PlayerTextDrawTextSize			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GROW][row], 180.0, 9.0);
	}

	for(new idx, col, row, Float:x, Float:y; idx < MAX_SNAKE_JOINGAME_PBUTTONS; idx ++) {
		x = 180.0 + (col * 80.0);
		
		y = 135.0 + (row * 13.0);
		
		g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PBUTTON][idx] =
		CreatePlayerTextDraw			(playerid, x + 4.0, y, "Player");
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PBUTTON][idx], 255);
		PlayerTextDrawFont				(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PBUTTON][idx], 1);
		PlayerTextDrawLetterSize		(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PBUTTON][idx], 0.2, 1.0);
		PlayerTextDrawColor				(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PBUTTON][idx], g_SnakeColors[col]);
		PlayerTextDrawSetOutline		(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PBUTTON][idx], 0);
		PlayerTextDrawSetProportional	(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PBUTTON][idx], 1);
		PlayerTextDrawSetShadow			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PBUTTON][idx], 1);
		PlayerTextDrawUseBox			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PBUTTON][idx], 0);
		PlayerTextDrawBoxColor			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PBUTTON][idx], -16777116);
		PlayerTextDrawTextSize			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PBUTTON][idx], x + 80.0, 9.0);
		PlayerTextDrawSetSelectable		(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PBUTTON][idx], 1);

		if( ++ col == MAX_SNAKE_PLAYERS ) {
		    row ++;
		    col = 0;
		}
	}

	for(new btn, str[3+1], Float:x; btn < MAX_SNAKE_JOINGAME_TBUTTONS; btn ++) {
		switch(btn) {
			case SNAKE_JOINGAME_TBUTTON_X: {
			    str = "x";
			    x = 492.0;
			}
			case SNAKE_JOINGAME_TBUTTON_B: {
			    str = "<";
			    x = 469.0;
			}
			case SNAKE_JOINGAME_TBUTTON_PAGE_F: {
			    str = "P<<";
			    x = 377.0;
			}
			case SNAKE_JOINGAME_TBUTTON_PAGE_P: {
			    str = "P-";
			    x = 400.0;
			}
			case SNAKE_JOINGAME_TBUTTON_PAGE_N: {
			    str = "P+";
			    x = 423.0;
			}
			case SNAKE_JOINGAME_TBUTTON_PAGE_L: {
			    str = "P>>";
			    x = 446.0;
			}
		}

		g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TBUTTON][btn] =
		CreatePlayerTextDraw			(playerid, x, 105.0, str);
		PlayerTextDrawAlignment			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TBUTTON][btn], 2);
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TBUTTON][btn], 255);
		PlayerTextDrawFont				(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TBUTTON][btn], 2);
		PlayerTextDrawLetterSize		(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TBUTTON][btn], 0.2, 1.1);
		PlayerTextDrawColor				(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TBUTTON][btn], -1);
		PlayerTextDrawSetOutline		(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TBUTTON][btn], 1);
		PlayerTextDrawSetProportional	(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TBUTTON][btn], 1);
		PlayerTextDrawUseBox			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TBUTTON][btn], 1);
		PlayerTextDrawBoxColor			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TBUTTON][btn], -16777116);
		PlayerTextDrawTextSize			(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TBUTTON][btn], 9.0, 20.0);
		PlayerTextDrawSetSelectable		(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TBUTTON][btn], 1);
	    PlayerTextDrawShow				(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TBUTTON][btn]);
	}
}

ApplySnakeJoinGamePage(playerid) {
	new str[8+1];

	format(str, sizeof str, "page %i", g_SnakeJoinGameData[playerid][e_SnakeJoinGamePage] + 1);

    PlayerTextDrawSetString(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PAGE], str);
}

ApplySnakeJoinGameIDs(playerid) {
	new offset = g_SnakeJoinGameData[playerid][e_SnakeJoinGamePage] * MAX_SNAKE_JOINGAME_PAGESIZE;

	for(new row, gameid, str[2+1]; row < MAX_SNAKE_JOINGAME_PAGESIZE; row ++) {
		gameid = offset + row;

		if( gameid >= 0 && gameid < MAX_SNAKE_GAMES ) {
			format(str, sizeof str, "%i", gameid + 1);

			PlayerTextDrawSetString(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GROW][row], str);

			PlayerTextDrawShow(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GROW][row]);
		} else {
		    PlayerTextDrawHide(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_GROW][row]);
		}
	}
}

ApplySnakeJoinGamePlayers(playerid) {
	new
		gameid = g_SnakeJoinGameData[playerid][e_SnakeJoinGamePage] * MAX_SNAKE_JOINGAME_PAGESIZE,
		playerslot,
		name[MAX_PLAYER_NAME+1],
		str[MAX_PLAYER_NAME+1]
	;

	for(new idx; idx < MAX_SNAKE_JOINGAME_PBUTTONS; idx ++) {
		if( gameid < MAX_SNAKE_GAMES ) {
			new snake_playerid = g_SnakeData[gameid][e_SnakePlayerID][playerslot];

			if( snake_playerid == INVALID_PLAYER_ID ) {
				if( g_SnakeData[gameid][e_SnakeState] == SNAKE_STATE_COUNTDOWN && g_SnakeData[gameid][e_SnakeCurrentPlayerCount] < g_SnakeData[gameid][e_SnakeTargetPlayerCount] ) {
					PlayerTextDrawSetString(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PBUTTON][idx], "<join game>");

					PlayerTextDrawShow(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PBUTTON][idx]);
				} else {
					PlayerTextDrawHide(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PBUTTON][idx]);
				}
			} else {
				GetPlayerName(snake_playerid, name, MAX_PLAYER_NAME+1);

				format(str, MAX_PLAYER_NAME+1, "[%i] %s", snake_playerid, name);

				PlayerTextDrawSetString(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PBUTTON][idx], str);

				PlayerTextDrawShow(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PBUTTON][idx]);
			}
		} else {
			PlayerTextDrawHide(playerid, g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PBUTTON][idx]);
		}

		if( ++ playerslot == MAX_SNAKE_PLAYERS ) {
			gameid ++;
		    playerslot = 0;
		}
	}
}

CreateSnakeScoreTextdraws(playerid) {
	g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_BG] =
	CreatePlayerTextDraw			(playerid, 320.0, 105.0, "_");
	PlayerTextDrawAlignment			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_BG], 2);
	PlayerTextDrawLetterSize		(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_BG], 0.0, 24.9);
	PlayerTextDrawUseBox			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_BG], 1);
	PlayerTextDrawBoxColor			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_BG], 100);
	PlayerTextDrawTextSize			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_BG], 0.0, 364.0);
	PlayerTextDrawShow              (playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_BG]);

	g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TITLE] =
	CreatePlayerTextDraw			(playerid, 140.0, 92.0, "Snake Highscore");
	PlayerTextDrawBackgroundColor	(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TITLE], 255);
	PlayerTextDrawFont				(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TITLE], 0);
	PlayerTextDrawLetterSize		(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TITLE], 0.6, 2.0);
	PlayerTextDrawColor				(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TITLE], -1);
	PlayerTextDrawSetOutline		(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TITLE], 1);
	PlayerTextDrawSetProportional	(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TITLE], 1);
	PlayerTextDrawShow              (playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TITLE]);

	g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PAGE] =
	CreatePlayerTextDraw			(playerid, 320.0, 105.0, "page");
	PlayerTextDrawAlignment			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PAGE], 2);
	PlayerTextDrawBackgroundColor	(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PAGE], 255);
	PlayerTextDrawFont				(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PAGE], 2);
	PlayerTextDrawLetterSize		(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PAGE], 0.2, 1.1);
	PlayerTextDrawColor				(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PAGE], -1);
	PlayerTextDrawSetOutline		(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PAGE], 1);
	PlayerTextDrawSetProportional	(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PAGE], 1);
	PlayerTextDrawShow              (playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PAGE]);

	for(new btn, Float:x, str[3+1]; btn < MAX_SNAKE_SCORE_TBUTTONS; btn ++) {
	    switch(btn) {
			case SNAKE_SCORE_TBUTTON_X: {
			    x = 492.0;
			    str = "x";
			}
			case SNAKE_SCORE_TBUTTON_B: {
			    x = 469.0;
			    str = "<";
			}
			case SNAKE_SCORE_TBUTTON_PAGE_F: {
			    x = 377.0;
			    str = "P<<";
			}
			case SNAKE_SCORE_TBUTTON_PAGE_P: {
			    x = 400.0;
			    str = "P-";
			}
			case SNAKE_SCORE_TBUTTON_PAGE_N: {
			    x = 423.0;
			    str = "P+";
			}
			case SNAKE_SCORE_TBUTTON_PAGE_L: {
			    x = 446.0;
			    str = "P>>";
			}
	        default: {
	            continue;
	        }
	    }

		g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TBUTTON][btn] =
		CreatePlayerTextDraw			(playerid, x, 105.0, str);
		PlayerTextDrawAlignment			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TBUTTON][btn], 2);
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TBUTTON][btn], 255);
		PlayerTextDrawFont				(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TBUTTON][btn], 2);
		PlayerTextDrawLetterSize		(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TBUTTON][btn], 0.2, 1.1);
		PlayerTextDrawColor				(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TBUTTON][btn], -1);
		PlayerTextDrawSetOutline		(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TBUTTON][btn], 1);
		PlayerTextDrawSetProportional	(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TBUTTON][btn], 1);
		PlayerTextDrawUseBox			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TBUTTON][btn], 1);
		PlayerTextDrawBoxColor			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TBUTTON][btn], -16777116);
		PlayerTextDrawTextSize			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TBUTTON][btn], 9.0, 20.0);
		PlayerTextDrawSetSelectable		(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TBUTTON][btn], 1);
		PlayerTextDrawShow              (playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TBUTTON][btn]);
	}

	for(new col, Float:x, Float:x_size, str[11+1], bool:selectable; col < MAX_SNAKE_SCORE_COLUMNS; col ++) {
		switch(col) {
			case SNAKE_SCORE_COL_RANK: {
			    x = 140.0;
			    x_size = 230.0;
			    str = "Rank";
			    selectable = false;
			}
			case SNAKE_SCORE_COL_PLAYER: {
			    x = 234.0;
			    x_size = 350.0;
			    str = "Player";
			    selectable = true;
			}
			case SNAKE_SCORE_COL_SIZE: {
			    x = 354.0;
			    x_size = 380.0;
			    str = "Size";
			    selectable = true;
			}
			case SNAKE_SCORE_COL_KILLS: {
			    x = 384.0;
			    x_size = 410.0;
			    str = "Kills";
			    selectable = true;
			}
			case SNAKE_SCORE_COL_TIMEDATE: {
			    x = 414.0;
			    x_size = 500.0;
			    str = "Time & Date";
			    selectable = true;
			}
		    default: {
		        continue;
		    }
		}

		g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][col] =
		CreatePlayerTextDraw			(playerid, x, 122.0, str);
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][col], 255);
		PlayerTextDrawFont				(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][col], 1);
		PlayerTextDrawLetterSize		(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][col], 0.2, 1.0);
		PlayerTextDrawColor				(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][col], RGBA_WHITE);
		PlayerTextDrawSetOutline		(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][col], 1);
		PlayerTextDrawSetProportional	(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][col], 1);
		PlayerTextDrawUseBox			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][col], 1);
		PlayerTextDrawBoxColor			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][col], 0xFFFFFF32);
		PlayerTextDrawTextSize			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][col], x_size, 9.0);
		PlayerTextDrawSetSelectable		(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][col], selectable ? 1 : 0);
		PlayerTextDrawShow              (playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][col]);
	}

	for(new row, Float:y = 135.0; row < MAX_SNAKE_SCORE_PAGESIZE; row ++, y += 13.0) {
		g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_RANK][row] =
		CreatePlayerTextDraw			(playerid, 140.0, y, "Rank");
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_RANK][row], 255);
		PlayerTextDrawFont				(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_RANK][row], 1);
		PlayerTextDrawLetterSize		(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_RANK][row], 0.2, 1.0);
		PlayerTextDrawColor				(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_RANK][row], -1);
		PlayerTextDrawSetProportional	(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_RANK][row], 1);
		PlayerTextDrawSetShadow			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_RANK][row], 1);
		PlayerTextDrawUseBox			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_RANK][row], 1);
		PlayerTextDrawBoxColor			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_RANK][row], 0);
		PlayerTextDrawTextSize			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_RANK][row], 230.0, 9.0);

		g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PLAYER][row] =
		CreatePlayerTextDraw			(playerid, 234.0, y, "Player");
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PLAYER][row], 255);
		PlayerTextDrawFont				(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PLAYER][row], 1);
		PlayerTextDrawLetterSize		(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PLAYER][row], 0.2, 1.0);
		PlayerTextDrawColor				(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PLAYER][row], -1);
		PlayerTextDrawSetProportional	(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PLAYER][row], 1);
		PlayerTextDrawSetShadow			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PLAYER][row], 1);
		PlayerTextDrawUseBox			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PLAYER][row], 1);
		PlayerTextDrawBoxColor			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PLAYER][row], 0);
		PlayerTextDrawTextSize			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PLAYER][row], 350.0, 9.0);

		g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_SIZE][row] =
		CreatePlayerTextDraw			(playerid, 354.0, y, "Size");
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_SIZE][row], 255);
		PlayerTextDrawFont				(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_SIZE][row], 1);
		PlayerTextDrawLetterSize		(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_SIZE][row], 0.2, 1.0);
		PlayerTextDrawColor				(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_SIZE][row], -1);
		PlayerTextDrawSetProportional	(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_SIZE][row], 1);
		PlayerTextDrawSetShadow			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_SIZE][row], 1);
		PlayerTextDrawUseBox			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_SIZE][row], 1);
		PlayerTextDrawBoxColor			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_SIZE][row], 0);
		PlayerTextDrawTextSize			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_SIZE][row], 380.0, 9.0);

		g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_KILLS][row] =
		CreatePlayerTextDraw			(playerid, 384.0, y, "Kills");
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_KILLS][row], 255);
		PlayerTextDrawFont				(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_KILLS][row], 1);
		PlayerTextDrawLetterSize		(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_KILLS][row], 0.2, 1.0);
		PlayerTextDrawColor				(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_KILLS][row], -1);
		PlayerTextDrawSetProportional	(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_KILLS][row], 1);
		PlayerTextDrawSetShadow			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_KILLS][row], 1);
		PlayerTextDrawUseBox			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_KILLS][row], 1);
		PlayerTextDrawBoxColor			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_KILLS][row], 0);
		PlayerTextDrawTextSize			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_KILLS][row], 410.0, 9.0);

		g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TIMEDATE][row] =
		CreatePlayerTextDraw			(playerid, 414.0, y, "Time & Date");
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TIMEDATE][row], 255);
		PlayerTextDrawFont				(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TIMEDATE][row], 1);
		PlayerTextDrawLetterSize		(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TIMEDATE][row], 0.2, 1.0);
		PlayerTextDrawColor				(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TIMEDATE][row], -1);
		PlayerTextDrawSetProportional	(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TIMEDATE][row], 1);
		PlayerTextDrawSetShadow			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TIMEDATE][row], 1);
		PlayerTextDrawUseBox			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TIMEDATE][row], 1);
		PlayerTextDrawBoxColor			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TIMEDATE][row], 0);
		PlayerTextDrawTextSize			(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TIMEDATE][row], 500.0, 9.0);
	}
}

ApplySnakeScorePage(playerid) {
	new str[15+1];
	
	format(str, sizeof str, "page %i", g_SnakeScoreData[playerid][e_SnakeScorePage] + 1);
	
	PlayerTextDrawSetString(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PAGE], str);
}

ApplySnakeScoreSorting(playerid) {
	PlayerTextDrawBoxColor(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][SNAKE_SCORE_COL_PLAYER], 0xFFFFFF32);
	PlayerTextDrawBoxColor(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][SNAKE_SCORE_COL_SIZE], 0xFFFFFF32);
	PlayerTextDrawBoxColor(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][SNAKE_SCORE_COL_KILLS], 0xFFFFFF32);
	PlayerTextDrawBoxColor(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][SNAKE_SCORE_COL_TIMEDATE], 0xFFFFFF32);

	switch( g_SnakeScoreData[playerid][e_SnakeScoreSort] ) {
		case SNAKE_SCORE_SORT_PLAYER_D: {
			PlayerTextDrawBoxColor(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][SNAKE_SCORE_COL_PLAYER], 0x00FF0032);
		}
		case SNAKE_SCORE_SORT_PLAYER_A: {
			PlayerTextDrawBoxColor(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][SNAKE_SCORE_COL_PLAYER], 0xFF000032);
		}
		case SNAKE_SCORE_SORT_SIZE_D: {
			PlayerTextDrawBoxColor(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][SNAKE_SCORE_COL_SIZE], 0x00FF0032);
		}
		case SNAKE_SCORE_SORT_SIZE_A: {
			PlayerTextDrawBoxColor(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][SNAKE_SCORE_COL_SIZE], 0xFF000032);
		}
		case SNAKE_SCORE_SORT_KILLS_D: {
			PlayerTextDrawBoxColor(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][SNAKE_SCORE_COL_KILLS], 0x00FF0032);
		}
		case SNAKE_SCORE_SORT_KILLS_A: {
			PlayerTextDrawBoxColor(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][SNAKE_SCORE_COL_KILLS], 0xFF000032);
		}
		case SNAKE_SCORE_SORT_TIMEDATE_D: {
			PlayerTextDrawBoxColor(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][SNAKE_SCORE_COL_TIMEDATE], 0x00FF0032);
		}
		case SNAKE_SCORE_SORT_TIMEDATE_A: {
			PlayerTextDrawBoxColor(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][SNAKE_SCORE_COL_TIMEDATE], 0xFF000032);
		}
	}

	PlayerTextDrawShow(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][SNAKE_SCORE_COL_PLAYER]);
	PlayerTextDrawShow(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][SNAKE_SCORE_COL_SIZE]);
	PlayerTextDrawShow(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][SNAKE_SCORE_COL_KILLS]);
	PlayerTextDrawShow(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][SNAKE_SCORE_COL_TIMEDATE]);
}

ApplySnakeScoreRows(playerid) {
	new
		offset = g_SnakeScoreData[playerid][e_SnakeScorePage] * MAX_SNAKE_SCORE_PAGESIZE,
		DBResult: db_result,
		rows
	;

	switch( g_SnakeScoreData[playerid][e_SnakeScoreSort] ) {
		case SNAKE_SCORE_SORT_PLAYER_D: {
			format(g_SnakeScoreQuery, MAX_SNAKE_SCORE_QUERYLEN+1, "SELECT *, (DATETIME(scoretimedate, 'localtime')) AS localscoretimedate FROM snakescore ORDER BY playername DESC LIMIT %i OFFSET %i", MAX_SNAKE_SCORE_PAGESIZE, offset);
		}
		case SNAKE_SCORE_SORT_PLAYER_A: {
			format(g_SnakeScoreQuery, MAX_SNAKE_SCORE_QUERYLEN+1, "SELECT *, (DATETIME(scoretimedate, 'localtime')) AS localscoretimedate FROM snakescore ORDER BY playername ASC LIMIT %i OFFSET %i", MAX_SNAKE_SCORE_PAGESIZE, offset);
		}
		case SNAKE_SCORE_SORT_SIZE_D: {
			format(g_SnakeScoreQuery, MAX_SNAKE_SCORE_QUERYLEN+1, "SELECT *, (DATETIME(scoretimedate, 'localtime')) AS localscoretimedate FROM snakescore ORDER BY size DESC LIMIT %i OFFSET %i", MAX_SNAKE_SCORE_PAGESIZE, offset);
		}
		case SNAKE_SCORE_SORT_SIZE_A: {
			format(g_SnakeScoreQuery, MAX_SNAKE_SCORE_QUERYLEN+1, "SELECT *, (DATETIME(scoretimedate, 'localtime')) AS localscoretimedate FROM snakescore ORDER BY size ASC LIMIT %i OFFSET %i", MAX_SNAKE_SCORE_PAGESIZE, offset);
		}
		case SNAKE_SCORE_SORT_KILLS_D: {
			format(g_SnakeScoreQuery, MAX_SNAKE_SCORE_QUERYLEN+1, "SELECT *, (DATETIME(scoretimedate, 'localtime')) AS localscoretimedate FROM snakescore ORDER BY kills DESC LIMIT %i OFFSET %i", MAX_SNAKE_SCORE_PAGESIZE, offset);
		}
		case SNAKE_SCORE_SORT_KILLS_A: {
			format(g_SnakeScoreQuery, MAX_SNAKE_SCORE_QUERYLEN+1, "SELECT *, (DATETIME(scoretimedate, 'localtime')) AS localscoretimedate FROM snakescore ORDER BY kills ASC LIMIT %i OFFSET %i", MAX_SNAKE_SCORE_PAGESIZE, offset);
		}
		case SNAKE_SCORE_SORT_TIMEDATE_D: {
			format(g_SnakeScoreQuery, MAX_SNAKE_SCORE_QUERYLEN+1, "SELECT *, (DATETIME(scoretimedate, 'localtime')) AS localscoretimedate FROM snakescore ORDER BY scoretimedate DESC LIMIT %i OFFSET %i", MAX_SNAKE_SCORE_PAGESIZE, offset);
		}
		case SNAKE_SCORE_SORT_TIMEDATE_A: {
			format(g_SnakeScoreQuery, MAX_SNAKE_SCORE_QUERYLEN+1, "SELECT *, (DATETIME(scoretimedate, 'localtime')) AS localscoretimedate FROM snakescore ORDER BY scoretimedate ASC LIMIT %i OFFSET %i", MAX_SNAKE_SCORE_PAGESIZE, offset);
		}
	}
	
	db_result = db_query(g_SnakeScoreDB, g_SnakeScoreQuery);

	rows = db_num_rows(db_result);
	
	for(new row, rank[10+1], pname[MAX_PLAYER_NAME+1], size[10+1], kills[10+1], timedate[19+1]; row < rows; row ++) {
		format(rank, sizeof rank, "%i", offset + row + 1);
	    db_get_field_assoc(db_result, "playername", pname, MAX_PLAYER_NAME+1);
		db_get_field_assoc(db_result, "size", size, sizeof size);
		db_get_field_assoc(db_result, "kills", kills, sizeof kills);
		db_get_field_assoc(db_result, "localscoretimedate", timedate, sizeof timedate);
		db_next_row(db_result);

		PlayerTextDrawSetString(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_RANK][row], rank);
		PlayerTextDrawSetString(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PLAYER][row], pname);
		PlayerTextDrawSetString(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_SIZE][row], size);
		PlayerTextDrawSetString(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_KILLS][row], kills);
		PlayerTextDrawSetString(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TIMEDATE][row], timedate);
		
		PlayerTextDrawShow(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_RANK][row]);
		PlayerTextDrawShow(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PLAYER][row]);
		PlayerTextDrawShow(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_SIZE][row]);
		PlayerTextDrawShow(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_KILLS][row]);
		PlayerTextDrawShow(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TIMEDATE][row]);
	}
	
	for(new row = rows; row < MAX_SNAKE_SCORE_PAGESIZE; row ++) {
		PlayerTextDrawHide(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_RANK][row]);
		PlayerTextDrawHide(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_PLAYER][row]);
		PlayerTextDrawHide(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_SIZE][row]);
		PlayerTextDrawHide(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_KILLS][row]);
		PlayerTextDrawHide(playerid, g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TIMEDATE][row]);
	}

	db_free_result(db_result);
}

CreateSnakeKeyTextdraws(playerid) {
	g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_BG] =
	CreatePlayerTextDraw			(playerid, 320.0, 115.0, "_");
	PlayerTextDrawAlignment			(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_BG], 2);
	PlayerTextDrawLetterSize		(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_BG], 0.0, 9.8);
	PlayerTextDrawUseBox			(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_BG], 1);
	PlayerTextDrawBoxColor			(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_BG], 100);
	PlayerTextDrawTextSize			(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_BG], 0.0, 302.0);

	g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TITLE] =
	CreatePlayerTextDraw				(playerid, 173.0, 103.0, "Snake Keys");
	PlayerTextDrawBackgroundColor		(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TITLE], 255);
	PlayerTextDrawFont					(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TITLE], 0);
	PlayerTextDrawLetterSize			(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TITLE], 0.6, 2.0);
	PlayerTextDrawColor					(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TITLE], -1);
	PlayerTextDrawSetOutline			(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TITLE], 1);
	PlayerTextDrawSetProportional		(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TITLE], 1);

	for(new btn, Float:x, str[2]; btn < MAX_SNAKE_KEY_TBUTTONS; btn ++) {
		switch(btn) {
			case SNAKE_KEY_TBUTTON_X: { // Close
				x = 461.0;
				str = "x";
			}
			case SNAKE_KEY_TBUTTON_B: { // Back
				x = 438.0;
				str = "<";
			}
		}

		g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TBUTTON][btn] =
		CreatePlayerTextDraw			(playerid, x, 115.0, str);
		PlayerTextDrawAlignment			(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TBUTTON][btn], 2);
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TBUTTON][btn], 255);
		PlayerTextDrawFont				(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TBUTTON][btn], 2);
		PlayerTextDrawLetterSize		(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TBUTTON][btn], 0.2, 1.1);
		PlayerTextDrawColor				(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TBUTTON][btn], -1);
		PlayerTextDrawSetOutline		(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TBUTTON][btn], 1);
		PlayerTextDrawSetProportional	(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TBUTTON][btn], 1);
		PlayerTextDrawUseBox			(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TBUTTON][btn], 1);
		PlayerTextDrawBoxColor			(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TBUTTON][btn], -16777116);
		PlayerTextDrawTextSize			(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TBUTTON][btn], 9.0, 20.0);
		PlayerTextDrawSetSelectable		(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TBUTTON][btn], 1);
	}

	g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_KEY_COL] =
	CreatePlayerTextDraw			(playerid, 169.0, 129.0, "Key");
	PlayerTextDrawBackgroundColor	(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_KEY_COL], 255);
	PlayerTextDrawFont				(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_KEY_COL], 1);
	PlayerTextDrawLetterSize		(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_KEY_COL], 0.2, 1.0);
	PlayerTextDrawColor				(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_KEY_COL], -1);
	PlayerTextDrawSetOutline		(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_KEY_COL], 1);
	PlayerTextDrawSetProportional	(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_KEY_COL], 1);
	PlayerTextDrawUseBox			(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_KEY_COL], 1);
	PlayerTextDrawBoxColor			(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_KEY_COL], -206);
	PlayerTextDrawTextSize			(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_KEY_COL], 318.0, 300.0);
	PlayerTextDrawSetSelectable		(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_KEY_COL], 0);

	g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_ACTION_COL] =
	CreatePlayerTextDraw			(playerid, 322.0, 129.0, "Action");
	PlayerTextDrawBackgroundColor	(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_ACTION_COL], 255);
	PlayerTextDrawFont				(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_ACTION_COL], 1);
	PlayerTextDrawLetterSize		(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_ACTION_COL], 0.2, 1.0);
	PlayerTextDrawColor				(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_ACTION_COL], -1);
	PlayerTextDrawSetOutline		(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_ACTION_COL], 1);
	PlayerTextDrawSetProportional	(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_ACTION_COL], 1);
	PlayerTextDrawUseBox			(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_ACTION_COL], 1);
	PlayerTextDrawBoxColor			(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_ACTION_COL], -206);
	PlayerTextDrawTextSize			(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_ACTION_COL], 471.0, 300.0);
	PlayerTextDrawSetSelectable		(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_ACTION_COL], 0);

	new bool:is_vehicle = bool:!!GetPlayerVehicleID(playerid);

	for(new key, Float:y = 142.0, str_key[100], str_action[100]; key < MAX_SNAKE_KEY_KEYACTIONS; key ++, y += 13.0) {
		switch(key) {
			case SNAKE_KEY_KEYACTION_L: { // Left
				str_key = is_vehicle ? ("~k~~VEHICLE_STEERLEFT~") : ("~k~~GO_LEFT~");
				str_action = "Move Snake Left";
			}
			case SNAKE_KEY_KEYACTION_R: { // Right
				str_key = is_vehicle ? ("~k~~VEHICLE_STEERRIGHT~") : ("~k~~GO_RIGHT~");
				str_action = "Move Snake Right";
			}
			case SNAKE_KEY_KEYACTION_D: { // Down
				str_key = is_vehicle ? ("~k~~VEHICLE_STEERDOWN~") : ("~k~~GO_BACK~");
				str_action = "Move Snake Down";
			}
			case SNAKE_KEY_KEYACTION_U: { // Up
				str_key = is_vehicle ? ("~k~~VEHICLE_STEERUP~") : ("~k~~GO_FORWARD~");
				str_action = "Move Snake Up";
			}
			case SNAKE_KEY_KEYACTION_X: { // Close
				str_key = is_vehicle ? ("~k~~VEHICLE_ENTER_EXIT~ + ~k~~VEHICLE_HORN~ + ~k~~VEHICLE_BRAKE~") : ("~k~~VEHICLE_ENTER_EXIT~ + ~k~~PED_DUCK~ + ~k~~PED_JUMPING~");
				str_action = "Close Game";
			}
		    default: {
		        continue;
		    }
		}

		g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_KEY_ROW][key] =
		CreatePlayerTextDraw			(playerid, 169.0, y, str_key);
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_KEY_ROW][key], 255);
		PlayerTextDrawFont				(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_KEY_ROW][key], 1);
		PlayerTextDrawLetterSize		(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_KEY_ROW][key], 0.2, 1.0);
		PlayerTextDrawColor				(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_KEY_ROW][key], -1);
		PlayerTextDrawSetOutline		(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_KEY_ROW][key], 0);
		PlayerTextDrawSetProportional	(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_KEY_ROW][key], 1);
		PlayerTextDrawSetShadow			(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_KEY_ROW][key], 1);
		PlayerTextDrawTextSize			(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_KEY_ROW][key], 318.0, 0.0);

		g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_ACTION_ROW][key] =
		CreatePlayerTextDraw			(playerid, 322.0, y, str_action);
		PlayerTextDrawBackgroundColor	(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_ACTION_ROW][key], 255);
		PlayerTextDrawFont				(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_ACTION_ROW][key], 1);
		PlayerTextDrawLetterSize		(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_ACTION_ROW][key], 0.2, 1.0);
		PlayerTextDrawColor				(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_ACTION_ROW][key], -1);
		PlayerTextDrawSetOutline		(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_ACTION_ROW][key], 0);
		PlayerTextDrawSetProportional	(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_ACTION_ROW][key], 1);
		PlayerTextDrawSetShadow			(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_ACTION_ROW][key], 1);
		PlayerTextDrawTextSize			(playerid, g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_ACTION_ROW][key], 471.0, 0.0);
	}

	for(new td; td < MAX_SNAKE_KEY_TEXTDRAWS; td ++) {
	    PlayerTextDrawShow(playerid, g_SnakeKeyTextdraw[playerid][td]);
	}
}

CreateSnakeTextdraws(playerid, tdmode) {
	if( tdmode == g_PlayerSnakeData[playerid][e_PlayerSnakeTextdrawMode] ) {
	    return 0;
	}
	
	if(g_PlayerSnakeData[playerid][e_PlayerSnakeTextdrawMode] != SNAKE_TDMODE_NONE) {
	    DestroySnakeTextdraws(playerid);
	}
	
	switch(tdmode) {
		case SNAKE_TDMODE_GAME: {
            CreateSnakeGameTextdraws(playerid);
		}
		case SNAKE_TDMODE_MENU: {
			CreateSnakeMenuTextdraws(playerid);
		}
		case SNAKE_TDMODE_NEWGAME: {
            CreateSnakeNewGameTextdraws(playerid); 
		}
		case SNAKE_TDMODE_JOINGAME: {
			CreateSnakeJoinGameTextdraws(playerid);
			ApplySnakeJoinGameIDs(playerid);
			ApplySnakeJoinGamePage(playerid);
			ApplySnakeJoinGamePlayers(playerid);
		}
		case SNAKE_TDMODE_HIGHSCORE: {
			CreateSnakeScoreTextdraws(playerid);
			ApplySnakeScorePage(playerid);
			ApplySnakeScoreSorting(playerid);
			ApplySnakeScoreRows(playerid);
		}
		case SNAKE_TDMODE_KEYS: {
			CreateSnakeKeyTextdraws(playerid);
		}
	    default: {
	        return 0;
	    }
	}

	g_PlayerSnakeData[playerid][e_PlayerSnakeTextdrawMode] = tdmode;

	return 1;
}

DestroySnakeTextdraws(playerid) {
	switch( g_PlayerSnakeData[playerid][e_PlayerSnakeTextdrawMode] ) {
		case SNAKE_TDMODE_NONE: {
		    return 0;
		}
		case SNAKE_TDMODE_GAME: {
			for(new td; td < MAX_SNAKE_GAME_TEXTDRAWS; td ++) {
		        PlayerTextDrawDestroy(playerid, g_SnakeGameTextDraw[playerid][td]);

		        g_SnakeGameTextDraw[playerid][td] = PlayerText: INVALID_TEXT_DRAW;
			}
		}
		case SNAKE_TDMODE_MENU: {
			for(new td; td < MAX_SNAKE_MENU_TEXTDRAWS; td ++) {
				PlayerTextDrawDestroy(playerid, g_SnakeMenuTextdraw[playerid][td]);

				g_SnakeMenuTextdraw[playerid][td] = PlayerText:INVALID_TEXT_DRAW;
			}
		}
		case SNAKE_TDMODE_NEWGAME: {
			for(new td; td < MAX_SNAKE_NEWGAME_TEXTDRAWS; td ++) {
				PlayerTextDrawDestroy(playerid, g_SnakeNewGameTextdraw[playerid][td]);

				g_SnakeNewGameTextdraw[playerid][td] = PlayerText:INVALID_TEXT_DRAW;
			}
		}
		case SNAKE_TDMODE_JOINGAME: {
			for(new td; td < MAX_SNAKE_JOINGAME_TEXTDRAWS; td ++) {
			    PlayerTextDrawDestroy(playerid, g_SnakeJoinGameTextdraw[playerid][td]);
			    
			    g_SnakeJoinGameTextdraw[playerid][td] = PlayerText:INVALID_TEXT_DRAW;
			}
		}
		case SNAKE_TDMODE_HIGHSCORE: {
			for(new td; td < MAX_SNAKE_SCORE_TEXTDRAWS; td ++) {
			    PlayerTextDrawDestroy(playerid, g_SnakeScoreTextdraw[playerid][td]);

			    g_SnakeScoreTextdraw[playerid][td] = PlayerText:INVALID_TEXT_DRAW;
			}
		}
		case SNAKE_TDMODE_KEYS: {
			for(new td; td < MAX_SNAKE_KEY_TEXTDRAWS; td ++) {
			    PlayerTextDrawDestroy(playerid, g_SnakeKeyTextdraw[playerid][td]);

			    g_SnakeKeyTextdraw[playerid][td] = PlayerText:INVALID_TEXT_DRAW;
			}
		}
	}
	
	g_PlayerSnakeData[playerid][e_PlayerSnakeTextdrawMode] = SNAKE_TDMODE_NONE;
	return 1;
}

BlockToPos(block, &x, &y) {
	x = block % SNAKE_GRID_WIDTH;
	y = block / SNAKE_GRID_WIDTH;
}

PosToBlock(x, y) {
	return x + (y * SNAKE_GRID_WIDTH);
}

GetEmptySnakeBlocks(gameid, block_array[], block_limit) {
	new block_count;
	for(new block; block < SNAKE_GRID_SIZE; block ++) {
		if( g_SnakeData[gameid][e_SnakeBlockData][block] == INVALID_PLAYER_ID ) {
			if(block_count >= block_limit) {
			    return block_count;
			}
            block_array[block_count ++] = block;
		}
	}
	return block_count;
}

GetRandomEmptyBlock(gameid) {
	new empty_block_array[SNAKE_GRID_SIZE], empty_block_count;

	empty_block_count = GetEmptySnakeBlocks(gameid, empty_block_array, SNAKE_GRID_SIZE);

	if( empty_block_count == 0 ) {
		return INVALID_SNAKE_GAME_BLOCK;
	}

	new
		random_index = random(empty_block_count),
		random_block = empty_block_array[random_index]
	;

	return random_block;
}

GetFoodSnakeBlocks(gameid) {
	new block_count;

	for(new block; block < SNAKE_GRID_SIZE; block ++) {
		if(g_SnakeData[gameid][e_SnakeBlockData][block] == SNAKE_BLOCK_DATA_FOOD) {
		    block_count ++;
		}
	}

	return block_count;
}

GetSnakeAlivePlayers(gameid) {
	new alive_players;

	for(new p; p < MAX_SNAKE_PLAYERS; p ++) {
		new playerid = g_SnakeData[gameid][e_SnakePlayerID][p];

		if( playerid != INVALID_PLAYER_ID && g_PlayerSnakeData[playerid][e_PlayerSnakeAlive] ) {
		    alive_players ++;
		}
	}

	return alive_players;
}

DefaultPlayerSnakeData(playerid) {
	for(new b; b < MAX_SNAKE_SIZE; b ++) {
		g_PlayerSnakeData[playerid][e_PlayerSnakeBlocks][b] = 0;
	}

	g_PlayerSnakeData[playerid][e_PlayerSnakeSize] = 0;
	g_PlayerSnakeData[playerid][e_PlayerSnakeKills] = 0;
	g_PlayerSnakeData[playerid][e_PlayerSnakeNextDirection] = random(MAX_SNAKE_DIRECTIONS);
	g_PlayerSnakeData[playerid][e_PlayerSnakeLastDirection] = INVALID_SNAKE_DIRECTION;
	g_PlayerSnakeData[playerid][e_PlayerSnakeGameID] = INVALID_SNAKE_GAME;
	g_PlayerSnakeData[playerid][e_PlayerSnakeSlot] = INVALID_SNAKE_PLAYER_SLOT;
	g_PlayerSnakeData[playerid][e_PlayerSnakeAlive] = false;
	g_PlayerSnakeData[playerid][e_PlayerSnakeTextdrawMode] = SNAKE_TDMODE_NONE;

	for(new td; td < MAX_SNAKE_GAME_TEXTDRAWS; td ++) {
   	    g_SnakeGameTextDraw[playerid][td] = PlayerText: INVALID_TEXT_DRAW;
	}
}

DefaultGameSnakeData(gameid) {
	g_SnakeData[gameid][e_SnakeState] = SNAKE_STATE_NONE;
	g_SnakeData[gameid][e_SnakeTime] = gettime();
	g_SnakeData[gameid][e_SnakeCurrentPlayerCount] = 0;
	g_SnakeData[gameid][e_SnakeTargetPlayerCount] = 0;

	for(new p; p < MAX_SNAKE_PLAYERS; p ++) {
		g_SnakeData[gameid][e_SnakePlayerID][p] = INVALID_PLAYER_ID;
	}

	for(new p; p < MAX_SNAKE_PLAYERS; p ++) {
		g_SnakeData[gameid][e_SnakeSortedPlayers][p] = INVALID_PLAYER_ID;
	}

	for(new b; b < SNAKE_GRID_SIZE; b ++) {
	    g_SnakeData[gameid][e_SnakeBlockData][b] = INVALID_PLAYER_ID;
	}

	new random_block = random(SNAKE_GRID_SIZE);

	g_SnakeData[gameid][e_SnakeBlockData][random_block] = SNAKE_BLOCK_DATA_FOOD;
}

IsSnakeDirectionAllowed(direction, last_direction) {
	if(direction == SNAKE_DIRECTION_D && last_direction == SNAKE_DIRECTION_U) {
		return 0;
	}

	if(direction == SNAKE_DIRECTION_U && last_direction == SNAKE_DIRECTION_D) {
		return 0;
	}

	if(direction == SNAKE_DIRECTION_L && last_direction == SNAKE_DIRECTION_R) {
	    return 0;
	}

	if(direction == SNAKE_DIRECTION_R && last_direction == SNAKE_DIRECTION_L) {
		return 0;
	}

	return 1;
}

ApplySnakeDirection(playerid) {
	new keys, ud, lr, direction;

	GetPlayerKeys(playerid, keys, ud, lr);

	if(ud == KEY_UP) {
		direction = SNAKE_DIRECTION_U;
	} else if(ud == KEY_DOWN) {
		direction = SNAKE_DIRECTION_D;
	} else if(lr == KEY_LEFT) {
		direction = SNAKE_DIRECTION_L;
	} else if(lr == KEY_RIGHT) {
		direction = SNAKE_DIRECTION_R;
	} else {
	    return 1;
	}

	if( g_PlayerSnakeData[playerid][e_PlayerSnakeSize] == 1 || IsSnakeDirectionAllowed(direction, g_PlayerSnakeData[playerid][e_PlayerSnakeLastDirection]) ) {
		g_PlayerSnakeData[playerid][e_PlayerSnakeNextDirection] = direction;
	}

	return 1;
}

GetSnakeNextBlock(block, direction) {
	new x, y;

	BlockToPos(block, x, y);

	switch(direction) {
		case SNAKE_DIRECTION_U: {
			if(++ y > MAX_SNAKE_HEIGHT) {
			    y = MIN_SNAKE_HEIGHT;
			}
		}
		case SNAKE_DIRECTION_D: {
			if(-- y < MIN_SNAKE_HEIGHT) {
			    y = MAX_SNAKE_HEIGHT;
			}
		}
		case SNAKE_DIRECTION_L: {
			if(-- x < MIN_SNAKE_WIDTH) {
			    x = MAX_SNAKE_WIDTH;
			}
		}
		case SNAKE_DIRECTION_R: {
			if(++ x > MAX_SNAKE_WIDTH) {
			    x = MIN_SNAKE_WIDTH;
			}
		}
	}

	return PosToBlock(x, y);
}

SortSnakePlayers(gameid) {
	for(new p1; p1 < MAX_SNAKE_PLAYERS; p1 ++) {
		new playerid_1 = g_SnakeData[gameid][e_SnakePlayerID][p1];

		if( playerid_1 == INVALID_PLAYER_ID ) {
		    continue;
		}

		new
			bool: alive_1 = g_PlayerSnakeData[playerid_1][e_PlayerSnakeAlive],
			size_1 = g_PlayerSnakeData[playerid_1][e_PlayerSnakeSize],
			kills_1 = g_PlayerSnakeData[playerid_1][e_PlayerSnakeKills],
			pos_1
		;

		for(new p2; p2 < MAX_SNAKE_PLAYERS; p2++) {
			new playerid_2 = g_SnakeData[gameid][e_SnakePlayerID][p2];

			if( playerid_2 == INVALID_PLAYER_ID ) {
			    continue;
			}

			new
				bool:alive_2 = g_PlayerSnakeData[playerid_2][e_PlayerSnakeAlive],
				size_2 = g_PlayerSnakeData[playerid_2][e_PlayerSnakeSize],
				kills_2 = g_PlayerSnakeData[playerid_2][e_PlayerSnakeKills]
			;

			if( size_2 > size_1) {
			    pos_1 ++;
			} else if( size_1 > size_2) {

			} else if( kills_2 > kills_1) {
				pos_1 ++;
			} else if( kills_1 > kills_2) {

			} else if( alive_2 && !alive_1 ) {
			    pos_1 ++;
			} else if( !alive_2 && alive_1) {

			} else if( p1 > p2 ) {
			    pos_1 ++;
			}
		}

		if( pos_1 < MAX_SNAKE_PLAYERS ) {
		    g_SnakeData[gameid][e_SnakeSortedPlayers][pos_1] = playerid_1;
		}
	}
}

RefreshSnakePlayersForPlayer(td_playerid) {
	new gameid = g_PlayerSnakeData[td_playerid][e_PlayerSnakeGameID];

	if(gameid == INVALID_SNAKE_GAME) {
	    return 0;
	}

	for(new row; row < g_SnakeData[gameid][e_SnakeCurrentPlayerCount]; row ++) {
		new row_playerid = g_SnakeData[gameid][e_SnakeSortedPlayers][row];

		if( row_playerid == INVALID_PLAYER_ID ) {
		    continue;
		}

		new
		    bool:alive = g_PlayerSnakeData[row_playerid][e_PlayerSnakeAlive],
			slot = g_PlayerSnakeData[row_playerid][e_PlayerSnakeSlot],
			color = g_SnakeColors[slot],
			name[MAX_PLAYER_NAME+1],
			size_str[10+1],
			kills_str[10+1]
		;

		GetPlayerName(row_playerid, name, MAX_PLAYER_NAME+1);
		PlayerTextDrawSetString(td_playerid, g_SnakeGameTextDraw[td_playerid][SNAKE_TD_GAME_PLAYER_ROW][row], name);
		PlayerTextDrawColor(td_playerid, g_SnakeGameTextDraw[td_playerid][SNAKE_TD_GAME_PLAYER_ROW][row], color);
		PlayerTextDrawShow(td_playerid, g_SnakeGameTextDraw[td_playerid][SNAKE_TD_GAME_PLAYER_ROW][row]);

		format(size_str, sizeof size_str, "%i", g_PlayerSnakeData[row_playerid][e_PlayerSnakeSize]);
		PlayerTextDrawSetString(td_playerid, g_SnakeGameTextDraw[td_playerid][SNAKE_TD_GAME_SIZE_ROW][row], size_str);
		PlayerTextDrawColor(td_playerid, g_SnakeGameTextDraw[td_playerid][SNAKE_TD_GAME_SIZE_ROW][row], color);
		PlayerTextDrawShow(td_playerid, g_SnakeGameTextDraw[td_playerid][SNAKE_TD_GAME_SIZE_ROW][row]);

		format(kills_str, sizeof kills_str, "%i", g_PlayerSnakeData[row_playerid][e_PlayerSnakeKills]);
		PlayerTextDrawSetString(td_playerid, g_SnakeGameTextDraw[td_playerid][SNAKE_TD_GAME_KILLS_ROW][row], kills_str);
		PlayerTextDrawColor(td_playerid, g_SnakeGameTextDraw[td_playerid][SNAKE_TD_GAME_KILLS_ROW][row], color);
		PlayerTextDrawShow(td_playerid, g_SnakeGameTextDraw[td_playerid][SNAKE_TD_GAME_KILLS_ROW][row]);

		PlayerTextDrawSetString(td_playerid, g_SnakeGameTextDraw[td_playerid][SNAKE_TD_GAME_ALIVE_ROW][row], alive ? ("Yes") : ("No"));
		PlayerTextDrawColor(td_playerid, g_SnakeGameTextDraw[td_playerid][SNAKE_TD_GAME_ALIVE_ROW][row], color);
		PlayerTextDrawShow(td_playerid, g_SnakeGameTextDraw[td_playerid][SNAKE_TD_GAME_ALIVE_ROW][row]);
	}

	for(new row = g_SnakeData[gameid][e_SnakeCurrentPlayerCount]; row < MAX_SNAKE_PLAYERS; row ++) {
		PlayerTextDrawHide(td_playerid, g_SnakeGameTextDraw[td_playerid][SNAKE_TD_GAME_PLAYER_ROW][row]);
		PlayerTextDrawHide(td_playerid, g_SnakeGameTextDraw[td_playerid][SNAKE_TD_GAME_SIZE_ROW][row]);
		PlayerTextDrawHide(td_playerid, g_SnakeGameTextDraw[td_playerid][SNAKE_TD_GAME_KILLS_ROW][row]);
		PlayerTextDrawHide(td_playerid, g_SnakeGameTextDraw[td_playerid][SNAKE_TD_GAME_ALIVE_ROW][row]);
	}

	return 1;
}

RefreshSnakePlayersForGame(gameid) {
	for(new p; p < MAX_SNAKE_PLAYERS; p ++) {
		new l_playerid = g_SnakeData[gameid][e_SnakePlayerID][p];

		if( l_playerid != INVALID_PLAYER_ID ) {
			RefreshSnakePlayersForPlayer(l_playerid);
		}
	}
}

CreateSnakeBlockForPlayer(playerid, block, color) {
	if(g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BLOCK][block] != PlayerText: INVALID_TEXT_DRAW) {
		PlayerTextDrawDestroy(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BLOCK][block]);

		g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BLOCK][block] = PlayerText: INVALID_TEXT_DRAW;
	}

	new x, y;

	BlockToPos(block, x, y);

	g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BLOCK][block] =
	CreatePlayerTextDraw		(playerid, 194.0 + (x * 18.0), 310.0 - (y * 17.0), "_");
	PlayerTextDrawAlignment		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BLOCK][block], 2);
	PlayerTextDrawLetterSize	(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BLOCK][block], 0.0, 1.5);
	PlayerTextDrawUseBox		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BLOCK][block], 1);
	PlayerTextDrawBoxColor		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BLOCK][block], color);
	PlayerTextDrawTextSize		(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BLOCK][block], 0.0, 15.0);
	PlayerTextDrawShow			(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BLOCK][block]);

	return g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BLOCK][block] != PlayerText: INVALID_TEXT_DRAW;
}

CreateSnakeBlockForGame(gameid, block, color) {
	for(new p; p < MAX_SNAKE_PLAYERS; p ++) {
		new playerid = g_SnakeData[gameid][e_SnakePlayerID][p];

		if( playerid != INVALID_PLAYER_ID ) {
			CreateSnakeBlockForPlayer(playerid, block, color);
		}
	}
}

DestroySnakeBlockForPlayer(playerid, block) {
	if(g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BLOCK][block] == PlayerText: INVALID_TEXT_DRAW) {
	    return 0;
	}

	PlayerTextDrawDestroy(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BLOCK][block]);
	g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_BLOCK][block] = PlayerText: INVALID_TEXT_DRAW;

	return 1;
}

DestroySnakeBlockForGame(gameid, block) {
	for(new p; p < MAX_SNAKE_PLAYERS; p ++) {
		new playerid = g_SnakeData[gameid][e_SnakePlayerID][p];

		if( playerid != INVALID_PLAYER_ID ) {
	        DestroySnakeBlockForPlayer(playerid, block);
		}
	}
}

GetSnakeFreePlayerSlot(gameid) {
	for(new p; p < MAX_SNAKE_PLAYERS; p ++) {
		if( g_SnakeData[gameid][e_SnakePlayerID][p] == INVALID_PLAYER_ID ) {
			return p;
		}
	}
	return INVALID_SNAKE_PLAYER_SLOT;
}

JoinSnake(j_playerid, gameid, playerslot) {
	if( g_PlayerSnakeData[j_playerid][e_PlayerSnakeGameID] != INVALID_SNAKE_GAME ) {
	    return 0;
	}

	new random_block = GetRandomEmptyBlock(gameid);

	if( random_block == INVALID_SNAKE_GAME_BLOCK ) {
	    return 0;
	}

	if( playerslot < 0 || playerslot >= MAX_SNAKE_PLAYERS ) {
	    return 0;
	}
	
	if( g_SnakeData[gameid][e_SnakePlayerID][playerslot] != INVALID_PLAYER_ID ) {
	    return 0;
	}

	CreateSnakeTextdraws(j_playerid, SNAKE_TDMODE_GAME);

	g_SnakeData[gameid][e_SnakePlayerID][playerslot] = j_playerid;
	g_SnakeData[gameid][e_SnakeCurrentPlayerCount] ++;
	g_SnakeData[gameid][e_SnakeBlockData][random_block] = j_playerid;
	g_SnakeData[gameid][e_SnakeTime] = gettime() + SNAKE_COUNTDOWN_S;

	g_PlayerSnakeData[j_playerid][e_PlayerSnakeSlot] = playerslot;
	g_PlayerSnakeData[j_playerid][e_PlayerSnakeGameID] = gameid;
	g_PlayerSnakeData[j_playerid][e_PlayerSnakeAlive] = true;
	g_PlayerSnakeData[j_playerid][e_PlayerSnakeSize] = 1;
	g_PlayerSnakeData[j_playerid][e_PlayerSnakeKills] = 0;
	g_PlayerSnakeData[j_playerid][e_PlayerSnakeBlocks][0] = random_block;

	for(new p; p < MAX_SNAKE_PLAYERS; p ++) {
		new l_playerid = g_SnakeData[gameid][e_SnakePlayerID][p];

		if( l_playerid == INVALID_PLAYER_ID || l_playerid == j_playerid ) {
		    continue;
		}

		CreateSnakeBlockForPlayer(j_playerid, g_PlayerSnakeData[l_playerid][e_PlayerSnakeBlocks][0], g_SnakeColors[p]); // Show other snakes for joined player
	}

	CreateSnakeBlockForGame(gameid, g_PlayerSnakeData[j_playerid][e_PlayerSnakeBlocks][0], g_SnakeColors[playerslot]); // Show joined snake for all players

	for(new b; b < SNAKE_GRID_SIZE; b ++) {
		if( g_SnakeData[gameid][e_SnakeBlockData][b] == SNAKE_BLOCK_DATA_FOOD ) {
		    CreateSnakeBlockForPlayer(j_playerid, b, RGBA_WHITE); // Show food for joined player
		}
	}

	TogglePlayerControllable(j_playerid, false);

	PlayerPlaySound(j_playerid, 1068, 0.0, 0.0, 0.0);

	SortSnakePlayers(gameid), RefreshSnakePlayersForGame(gameid);
	return 1;
}

KillSnake(playerid) {
	new gameid = g_PlayerSnakeData[playerid][e_PlayerSnakeGameID];

	if( gameid == INVALID_SNAKE_GAME ) {
	    return 0;
	}

	if( !g_PlayerSnakeData[playerid][e_PlayerSnakeAlive] ) {
	    return 0;
	}

	g_PlayerSnakeData[playerid][e_PlayerSnakeAlive] = false;

    for(new b; b < g_PlayerSnakeData[playerid][e_PlayerSnakeSize]; b ++) {
		new block = g_PlayerSnakeData[playerid][e_PlayerSnakeBlocks][b];

		g_SnakeData[gameid][e_SnakeBlockData][block] = SNAKE_BLOCK_DATA_FOOD;

		CreateSnakeBlockForGame(gameid, block, 0xFFFFFFFF);
    }

	InsertSnakeScore(playerid);

	if( GetSnakeAlivePlayers(gameid) <= 1 ) {
	    g_SnakeData[gameid][e_SnakeState] = SNAKE_STATE_GAMEOVER;
	    g_SnakeData[gameid][e_SnakeTime] = gettime() + SNAKE_COUNTOUT_S;
	}

	SortSnakePlayers(gameid), RefreshSnakePlayersForGame(gameid);
	return 1;
}

LeaveSnake(playerid) {
	new gameid = g_PlayerSnakeData[playerid][e_PlayerSnakeGameID];

	if( gameid == INVALID_SNAKE_GAME ) {
	    return 0;
	}

	if( g_PlayerSnakeData[playerid][e_PlayerSnakeAlive] ) {
        KillSnake(playerid);
	} else {
		SortSnakePlayers(gameid), RefreshSnakePlayersForGame(gameid);
	}

    g_SnakeData[gameid][e_SnakeCurrentPlayerCount] --;
	g_SnakeData[gameid][e_SnakePlayerID][ g_PlayerSnakeData[playerid][e_PlayerSnakeSlot] ] = INVALID_PLAYER_ID;

	g_PlayerSnakeData[playerid][e_PlayerSnakeSlot] = INVALID_SNAKE_PLAYER_SLOT;
	g_PlayerSnakeData[playerid][e_PlayerSnakeGameID] = INVALID_SNAKE_GAME;

	DestroySnakeTextdraws(playerid);

	PlayerPlaySound(playerid, 1069, 0.0, 0.0, 0.0); // Stop music

	TogglePlayerControllable(playerid, true);

	if( g_SnakeData[gameid][e_SnakeCurrentPlayerCount] <= 0 ) {
		DefaultGameSnakeData(gameid);
	}

	return 1;
}

FindSnakeGameToJoin() {
	for(new gameid; gameid < MAX_SNAKE_GAMES; gameid ++) {
		if( g_SnakeData[gameid][e_SnakeState] != SNAKE_STATE_COUNTDOWN ) {
			continue;
		}

        if( g_SnakeData[gameid][e_SnakeCurrentPlayerCount] >= g_SnakeData[gameid][e_SnakeTargetPlayerCount] ) {
			continue;
		}

		return gameid;
	}
	return INVALID_SNAKE_GAME;
}

FindEmptySnakeGame() {
	for(new gameid; gameid < MAX_SNAKE_GAMES; gameid ++) {
		if( g_SnakeData[gameid][e_SnakeState] != SNAKE_STATE_NONE ) {
			continue;
		}

		return gameid;
	}
	return INVALID_SNAKE_GAME;
}

GetPlayerStopSnakeButtons(playerid) {
	new str[200];

	switch(GetPlayerState(playerid)) {
	    case PLAYER_STATE_DRIVER, PLAYER_STATE_PASSENGER: {
			str = "~w~press ~r~~k~~VEHICLE_ENTER_EXIT~~w~ + ~r~~k~~VEHICLE_HORN~~w~ + ~r~~k~~VEHICLE_BRAKE~~w~ to stop playing.";
	    } default: {
	        str = "~w~press ~r~~k~~VEHICLE_ENTER_EXIT~~w~ + ~r~~k~~PED_DUCK~~w~ + ~r~~k~~PED_JUMPING~~w~ to stop playing.";
	    }
	}

	return str;
}

InsertSnakeScore(playerid) {
	new playername[MAX_PLAYER_NAME+1];

	GetPlayerName(playerid, playername, MAX_PLAYER_NAME+1);

	format(g_SnakeScoreQuery, MAX_SNAKE_SCORE_QUERYLEN+1, "INSERT INTO snakescore (playername, size, kills) VALUES ('%q', '%i', '%i')", playername, g_PlayerSnakeData[playerid][e_PlayerSnakeSize], g_PlayerSnakeData[playerid][e_PlayerSnakeKills]);

	db_free_result( db_query(g_SnakeScoreDB, g_SnakeScoreQuery) );
}

//------------------------------------------------------------------------------

public OnFilterScriptInit() {
	for(new gameid; gameid < MAX_SNAKE_GAMES; gameid ++) {
		DefaultGameSnakeData(gameid);
	}

	for(new playerid, max_playerid = GetPlayerPoolSize(); playerid <= max_playerid; playerid ++) {
		if( IsPlayerConnected(playerid) ) {
			DefaultPlayerSnakeData(playerid);

			g_SnakeJoinGameData[playerid][e_SnakeJoinGamePage] = 0;

			g_SnakeScoreData[playerid][e_SnakeScorePage] = 0;
			g_SnakeScoreData[playerid][e_SnakeScoreSort] = SNAKE_SCORE_SORT_SIZE_D;
		}
	}

	g_SnakeTimer = SetTimer("OnSnakeUpdate", SNAKE_GAME_INTERVAL_MS, true);
	
	g_SnakeScoreDB = db_open("snake.db");
	
	if( g_SnakeScoreDB == DB:0 ) {
	    print("ERROR: Snake database could not be opened!");
	} else {
		print("Snake database opened successfully.");

        g_SnakeScoreQuery = "\
			CREATE TABLE IF NOT EXISTS snakescore \
			(\
			playername TEXT, \
			size INT, \
			kills INT, \
			scoretimedate TEXT DEFAULT (DATETIME('now'))\
			)\
		";

		db_free_result( db_query(g_SnakeScoreDB, g_SnakeScoreQuery) );
	}
}

public OnFilterScriptExit() {
	KillTimer(g_SnakeTimer);
	
	for(new playerid, max_playerid = GetPlayerPoolSize(); playerid <= max_playerid; playerid ++) {
		if( !IsPlayerConnected(playerid) ) {
			continue;
		}

		if( g_PlayerSnakeData[playerid][e_PlayerSnakeGameID] != INVALID_SNAKE_GAME ) {
		    LeaveSnake(playerid);
		}
		
		if( g_PlayerSnakeData[playerid][e_PlayerSnakeTextdrawMode] != SNAKE_TDMODE_NONE ) {
			DestroySnakeTextdraws(playerid);
		}
	}
	
	if( !db_close(g_SnakeScoreDB) ) {
	    print("ERROR: Snake database could not be closed!");
	} else {
		print("Snake database closed successfully.");
	}
}

public OnPlayerConnect(playerid) {
	DefaultPlayerSnakeData(playerid);

	g_SnakeJoinGameData[playerid][e_SnakeJoinGamePage] = 0;

	g_SnakeScoreData[playerid][e_SnakeScorePage] = 0;
	g_SnakeScoreData[playerid][e_SnakeScoreSort] = SNAKE_SCORE_SORT_SIZE_D;
	return 1;
}

public OnPlayerDisconnect(playerid, reason) {
	if( g_PlayerSnakeData[playerid][e_PlayerSnakeGameID] != INVALID_SNAKE_GAME ) {
		LeaveSnake(playerid);
	}
	return 1;
}

public OnPlayerUpdate(playerid) {
	if( g_PlayerSnakeData[playerid][e_PlayerSnakeGameID] != INVALID_SNAKE_GAME ) {
		ApplySnakeDirection(playerid);
	}
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate) {
	if( g_PlayerSnakeData[playerid][e_PlayerSnakeTextdrawMode] == SNAKE_TDMODE_GAME && (newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER || oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER) ) {
	    PlayerTextDrawSetString(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_XKEYS], GetPlayerStopSnakeButtons(playerid));
	}
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if( g_PlayerSnakeData[playerid][e_PlayerSnakeGameID] != INVALID_SNAKE_GAME && (newkeys & KEY_SECONDARY_ATTACK) && (newkeys & KEY_CROUCH) && (newkeys & KEY_JUMP) ) {
		LeaveSnake(playerid);
	}
}

public OnPlayerClickTextDraw(playerid, Text:clickedid) {
	if( clickedid == Text:INVALID_TEXT_DRAW) {
		switch( g_PlayerSnakeData[playerid][e_PlayerSnakeTextdrawMode] ) {
			case SNAKE_TDMODE_MENU, SNAKE_TDMODE_NEWGAME, SNAKE_TDMODE_JOINGAME, SNAKE_TDMODE_HIGHSCORE, SNAKE_TDMODE_KEYS: {
				DestroySnakeTextdraws(playerid);
			}
		}
	}
	return 0;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid) {
	if( g_PlayerSnakeData[playerid][e_PlayerSnakeTextdrawMode] == SNAKE_TDMODE_MENU ) {
		if( playertextid == g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_RBUTTON][SNAKE_MENU_RBUTTON_SP] ) {
			new create_gameid = FindEmptySnakeGame();

			if( create_gameid == INVALID_SNAKE_GAME ) {
				return 1;
			}

			if( !JoinSnake(playerid, create_gameid, .playerslot = 0) ) {
			    return 1;
			}

			g_SnakeData[create_gameid][e_SnakeTargetPlayerCount] = 1;

			g_SnakeData[create_gameid][e_SnakeState] = SNAKE_STATE_COUNTDOWN;

		    CancelSelectTextDraw(playerid);

			return 1;
		}
		if( playertextid == g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_RBUTTON][SNAKE_MENU_RBUTTON_MP] ) {
			new gameid = FindSnakeGameToJoin();

			if( gameid != INVALID_SNAKE_GAME) {
				new playerslot = GetSnakeFreePlayerSlot(gameid);

				if( JoinSnake(playerid, gameid, playerslot) ) {
				    CancelSelectTextDraw(playerid);
				    return 1;
				}
			}

			gameid = FindEmptySnakeGame();

			if( gameid != INVALID_SNAKE_GAME && JoinSnake(playerid, gameid, .playerslot = 0) ) {
				g_SnakeData[gameid][e_SnakeTargetPlayerCount] = 2;

				g_SnakeData[gameid][e_SnakeState] = SNAKE_STATE_COUNTDOWN;
					
				CancelSelectTextDraw(playerid);
				return 1;
			}

			SendClientMessage(playerid, RGBA_RED, "ERROR: A game could not be found right now!");
			return 1;
		}
		if( playertextid == g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_RBUTTON][SNAKE_MENU_RBUTTON_CREATE] ) {
			CreateSnakeTextdraws(playerid, SNAKE_TDMODE_NEWGAME);
			return 1;
		}
		if( playertextid == g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_RBUTTON][SNAKE_MENU_RBUTTON_JOIN] ) {
			CreateSnakeTextdraws(playerid, SNAKE_TDMODE_JOINGAME);
			return 1;
		}
		if( playertextid == g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_RBUTTON][SNAKE_MENU_RBUTTON_SCORE] ) {
			CreateSnakeTextdraws(playerid, SNAKE_TDMODE_HIGHSCORE);
			return 1;
		}
		if( playertextid == g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_RBUTTON][SNAKE_MENU_RBUTTON_KEYS] ) {
			CreateSnakeTextdraws(playerid, SNAKE_TDMODE_KEYS);
			return 1;
		}
		if( playertextid == g_SnakeMenuTextdraw[playerid][SNAKE_MENU_TD_XBUTTON] ) {
			DestroySnakeTextdraws(playerid);

			CancelSelectTextDraw(playerid);
			return 1;
		}
	}
	
	if( g_PlayerSnakeData[playerid][e_PlayerSnakeTextdrawMode] == SNAKE_TDMODE_NEWGAME ) {
	    for(new btn; btn < MAX_SNAKE_PLAYERS; btn ++) {
			if( playertextid == g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_PBUTTON][btn] ) {
				new gameid = FindEmptySnakeGame();

				if( gameid != INVALID_SNAKE_GAME && JoinSnake(playerid, gameid, .playerslot = 0) ) {
					g_SnakeData[gameid][e_SnakeTargetPlayerCount] = btn + 1;

					g_SnakeData[gameid][e_SnakeState] = SNAKE_STATE_COUNTDOWN;

					CancelSelectTextDraw(playerid);
				}
		        return 1;
			}
		}

		if(playertextid == g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TBUTTON][SNAKE_NEWGAME_TBUTTON_X]) { // Close
			DestroySnakeTextdraws(playerid);
			
			CancelSelectTextDraw(playerid);
		    return 1;
		}
		if(playertextid == g_SnakeNewGameTextdraw[playerid][SNAKE_NEWGAME_TD_TBUTTON][SNAKE_NEWGAME_TBUTTON_B]) { // Back
			CreateSnakeTextdraws(playerid, SNAKE_TDMODE_MENU);
		    return 1;
		}
	}
	
	if( g_PlayerSnakeData[playerid][e_PlayerSnakeTextdrawMode] == SNAKE_TDMODE_JOINGAME ) {
	    if( playertextid == g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TBUTTON][SNAKE_JOINGAME_TBUTTON_X] ) { // Close
			DestroySnakeTextdraws(playerid);

			CancelSelectTextDraw(playerid);
	        return 1;
	    }
	    if( playertextid == g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TBUTTON][SNAKE_JOINGAME_TBUTTON_B] ) { // Back
			CreateSnakeTextdraws(playerid, SNAKE_TDMODE_MENU);
	        return 1;
	    }
	    if( playertextid == g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TBUTTON][SNAKE_JOINGAME_TBUTTON_PAGE_F] ) { // First Page
			if( g_SnakeJoinGameData[playerid][e_SnakeJoinGamePage] <= MIN_SNAKE_JOINGAME_PAGE ) {
			
			} else {
			    g_SnakeJoinGameData[playerid][e_SnakeJoinGamePage] = MIN_SNAKE_JOINGAME_PAGE;
				ApplySnakeJoinGamePage(playerid);
				ApplySnakeJoinGameIDs(playerid);
				ApplySnakeJoinGamePlayers(playerid);
			}
	        return 1;
	    }
	    if( playertextid == g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TBUTTON][SNAKE_JOINGAME_TBUTTON_PAGE_P]) { // Previous Page
			if( g_SnakeJoinGameData[playerid][e_SnakeJoinGamePage] <= MIN_SNAKE_JOINGAME_PAGE ) {

			} else {
			    g_SnakeJoinGameData[playerid][e_SnakeJoinGamePage] --;
				ApplySnakeJoinGamePage(playerid);
				ApplySnakeJoinGameIDs(playerid);
				ApplySnakeJoinGamePlayers(playerid);
			}
	        return 1;
	    }
	    if( playertextid == g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TBUTTON][SNAKE_JOINGAME_TBUTTON_PAGE_N]) { // Next Page
			if( g_SnakeJoinGameData[playerid][e_SnakeJoinGamePage] >= MAX_SNAKE_JOINGAME_PAGE ) {

			} else {
			    g_SnakeJoinGameData[playerid][e_SnakeJoinGamePage] ++;
				ApplySnakeJoinGamePage(playerid);
				ApplySnakeJoinGameIDs(playerid);
				ApplySnakeJoinGamePlayers(playerid);
			}
	        return 1;
	    }
	    if( playertextid == g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_TBUTTON][SNAKE_JOINGAME_TBUTTON_PAGE_L]) { // Last Page
			if( g_SnakeJoinGameData[playerid][e_SnakeJoinGamePage] >= MAX_SNAKE_JOINGAME_PAGE ) {

			} else {
			    g_SnakeJoinGameData[playerid][e_SnakeJoinGamePage] = MAX_SNAKE_JOINGAME_PAGE;
				ApplySnakeJoinGamePage(playerid);
				ApplySnakeJoinGameIDs(playerid);
				ApplySnakeJoinGamePlayers(playerid);
			}
	        return 1;
	    }
	    
	    for(new btn; btn < MAX_SNAKE_JOINGAME_PBUTTONS; btn ++) {
		    if( playertextid == g_SnakeJoinGameTextdraw[playerid][SNAKE_JOINGAME_TD_PBUTTON][btn] ) {
				new gameid = (g_SnakeJoinGameData[playerid][e_SnakeJoinGamePage] * MAX_SNAKE_JOINGAME_PAGESIZE) + btn / MAX_SNAKE_PLAYERS;

				if( gameid >= MAX_SNAKE_GAMES ) {
					return 1;
				}

				if( g_SnakeData[gameid][e_SnakeState] != SNAKE_STATE_COUNTDOWN ) {
					return 1;
				}

				if( g_SnakeData[gameid][e_SnakeCurrentPlayerCount] >= g_SnakeData[gameid][e_SnakeTargetPlayerCount] ) {
				    return 1;
				}

				new playerslot = btn % MAX_SNAKE_PLAYERS;

				if( !JoinSnake(playerid, gameid, playerslot) ) {
					return 1;
				}

				CancelSelectTextDraw(playerid);

		        return 1;
		    }
	    }
	}

	if( g_PlayerSnakeData[playerid][e_PlayerSnakeTextdrawMode] == SNAKE_TDMODE_HIGHSCORE ) {
		if( playertextid == g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][SNAKE_SCORE_COL_PLAYER] ) {
			if( g_SnakeScoreData[playerid][e_SnakeScoreSort] == SNAKE_SCORE_SORT_PLAYER_D ) {
                g_SnakeScoreData[playerid][e_SnakeScoreSort] = SNAKE_SCORE_SORT_PLAYER_A;
			} else {
                g_SnakeScoreData[playerid][e_SnakeScoreSort] = SNAKE_SCORE_SORT_PLAYER_D;
			}
			ApplySnakeScoreSorting(playerid);
			ApplySnakeScoreRows(playerid);
			return 1;
		}
		if( playertextid == g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][SNAKE_SCORE_COL_SIZE] ) {
			if( g_SnakeScoreData[playerid][e_SnakeScoreSort] == SNAKE_SCORE_SORT_SIZE_D ) {
                g_SnakeScoreData[playerid][e_SnakeScoreSort] = SNAKE_SCORE_SORT_SIZE_A;
			} else {
                g_SnakeScoreData[playerid][e_SnakeScoreSort] = SNAKE_SCORE_SORT_SIZE_D;
			}
			ApplySnakeScoreSorting(playerid);
			ApplySnakeScoreRows(playerid);
			return 1;
		}
		if( playertextid == g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][SNAKE_SCORE_COL_KILLS] ) {
			if( g_SnakeScoreData[playerid][e_SnakeScoreSort] == SNAKE_SCORE_SORT_KILLS_D ) {
                g_SnakeScoreData[playerid][e_SnakeScoreSort] = SNAKE_SCORE_SORT_KILLS_A;
			} else {
                g_SnakeScoreData[playerid][e_SnakeScoreSort] = SNAKE_SCORE_SORT_KILLS_D;
			}
			ApplySnakeScoreSorting(playerid);
			ApplySnakeScoreRows(playerid);
			return 1;
		}
		if( playertextid == g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_COL][SNAKE_SCORE_COL_TIMEDATE] ) {
			if( g_SnakeScoreData[playerid][e_SnakeScoreSort] == SNAKE_SCORE_SORT_TIMEDATE_D ) {
                g_SnakeScoreData[playerid][e_SnakeScoreSort] = SNAKE_SCORE_SORT_TIMEDATE_A;
			} else {
                g_SnakeScoreData[playerid][e_SnakeScoreSort] = SNAKE_SCORE_SORT_TIMEDATE_D;
			}
			ApplySnakeScoreSorting(playerid);
			ApplySnakeScoreRows(playerid);
			return 1;
		}
		if( playertextid == g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TBUTTON][SNAKE_SCORE_TBUTTON_X] ) {
			DestroySnakeTextdraws(playerid);

			CancelSelectTextDraw(playerid);
			return 1;
		}
		if( playertextid == g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TBUTTON][SNAKE_SCORE_TBUTTON_B] ) {
			CreateSnakeTextdraws(playerid, SNAKE_TDMODE_MENU);
			return 1;
		}
		if( playertextid == g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TBUTTON][SNAKE_SCORE_TBUTTON_PAGE_F] ) {
			if( g_SnakeScoreData[playerid][e_SnakeScorePage] <= MIN_SNAKE_SCORE_PAGE ) {
			
			} else {
                g_SnakeScoreData[playerid][e_SnakeScorePage] = MIN_SNAKE_SCORE_PAGE;
				ApplySnakeScorePage(playerid);
				ApplySnakeScoreRows(playerid);
			}
			return 1;
		}
		if( playertextid == g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TBUTTON][SNAKE_SCORE_TBUTTON_PAGE_P] ) {
			if( g_SnakeScoreData[playerid][e_SnakeScorePage] <= MIN_SNAKE_SCORE_PAGE ) {

			} else {
                g_SnakeScoreData[playerid][e_SnakeScorePage] --;
				ApplySnakeScorePage(playerid);
				ApplySnakeScoreRows(playerid);
			}
			return 1;
		}
		if( playertextid == g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TBUTTON][SNAKE_SCORE_TBUTTON_PAGE_N] ) {
			if( g_SnakeScoreData[playerid][e_SnakeScorePage] >= MAX_SNAKE_SCORE_PAGE ) {

			} else {
                g_SnakeScoreData[playerid][e_SnakeScorePage] ++;
				ApplySnakeScorePage(playerid);
				ApplySnakeScoreRows(playerid);
			}
			return 1;
		}
		if( playertextid == g_SnakeScoreTextdraw[playerid][SNAKE_SCORE_TD_TBUTTON][SNAKE_SCORE_TBUTTON_PAGE_L] ) {
			if( g_SnakeScoreData[playerid][e_SnakeScorePage] >= MAX_SNAKE_SCORE_PAGE ) {

			} else {
                g_SnakeScoreData[playerid][e_SnakeScorePage] = MAX_SNAKE_SCORE_PAGE;
				ApplySnakeScorePage(playerid);
				ApplySnakeScoreRows(playerid);
			}
			return 1;
		}
	}
	
	if ( g_PlayerSnakeData[playerid][e_PlayerSnakeTextdrawMode] == SNAKE_TDMODE_KEYS ) {
		if( playertextid == g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TBUTTON][SNAKE_KEY_TBUTTON_X] ) { // Close
			DestroySnakeTextdraws(playerid);

			CancelSelectTextDraw(playerid);
		    return 1;
		}
		if( playertextid == g_SnakeKeyTextdraw[playerid][SNAKE_KEY_TD_TBUTTON][SNAKE_KEY_TBUTTON_B] ) { // Back
			CreateSnakeTextdraws(playerid, SNAKE_TDMODE_MENU);
			return 1;
		}
	}
	return 0;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    if( !strcmp(cmdtext, "/snake", true) ) {
	    CreateSnakeTextdraws(playerid, SNAKE_TDMODE_MENU);
		SelectTextDraw(playerid, RGBA_RED);
        return 1;
    }
    return 0;
}

//------------------------------------------------------------------------------

forward OnSnakeUpdate();
public OnSnakeUpdate() {
	for(new gameid; gameid < MAX_SNAKE_GAMES; gameid ++) {
		switch(g_SnakeData[gameid][e_SnakeState]) {
			case SNAKE_STATE_NONE: {
			    continue;
			}
			case SNAKE_STATE_COUNTDOWN: {
				if(g_SnakeData[gameid][e_SnakeCurrentPlayerCount] < g_SnakeData[gameid][e_SnakeTargetPlayerCount]) {
					new countdown_str[50];

					format(countdown_str, sizeof countdown_str,
						"waiting for players %i/%i", g_SnakeData[gameid][e_SnakeCurrentPlayerCount], g_SnakeData[gameid][e_SnakeTargetPlayerCount]
					);

					for(new p; p < MAX_SNAKE_PLAYERS; p ++) {
						new playerid = g_SnakeData[gameid][e_SnakePlayerID][p];

						if( playerid != INVALID_PLAYER_ID ) {
						    PlayerTextDrawSetString(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_COUNTDOWN], countdown_str);
						}
					}
				} else if(g_SnakeData[gameid][e_SnakeCurrentPlayerCount] == g_SnakeData[gameid][e_SnakeTargetPlayerCount]) {
					new
						timeleft = g_SnakeData[gameid][e_SnakeTime] - gettime(),
						countdown_str[6+1]
					;

					if(timeleft > 0) {
					    format(countdown_str, sizeof countdown_str, "%i", timeleft);
					} else {
					    countdown_str = "Go!";

					    g_SnakeData[gameid][e_SnakeState] ++;
					    
					    g_SnakeData[gameid][e_SnakeTime] = gettime() + 1;
					}

					for(new p; p < MAX_SNAKE_PLAYERS; p ++) {
						new playerid = g_SnakeData[gameid][e_SnakePlayerID][p];

						if( playerid != INVALID_PLAYER_ID ) {
						    PlayerTextDrawSetString(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_COUNTDOWN], countdown_str);
						}
					}
				}
			}
			case SNAKE_STATE_STARTED: {
			    new bool: foodeaten = false;

				if( gettime() == g_SnakeData[gameid][e_SnakeTime] ) {
					for(new p; p < MAX_SNAKE_PLAYERS; p ++) {
						new playerid = g_SnakeData[gameid][e_SnakePlayerID][p];

						if( playerid != INVALID_PLAYER_ID ) {
							PlayerTextDrawSetString(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_COUNTDOWN], "_");
						}
					}
				}

				for(new p; p < MAX_SNAKE_PLAYERS; p ++) {
					new playerid = g_SnakeData[gameid][e_SnakePlayerID][p];

					if( playerid == INVALID_PLAYER_ID ) {
					    continue;
					}

					if( !g_PlayerSnakeData[playerid][e_PlayerSnakeAlive] ) {
					    continue;
					}

					new
						head_block = g_PlayerSnakeData[playerid][e_PlayerSnakeBlocks][0],
						direction = g_PlayerSnakeData[playerid][e_PlayerSnakeNextDirection],
						next_block = GetSnakeNextBlock(head_block, direction),
						next_block_data = g_SnakeData[gameid][e_SnakeBlockData][next_block],
						size = g_PlayerSnakeData[playerid][e_PlayerSnakeSize],
						tail_block = g_PlayerSnakeData[playerid][e_PlayerSnakeBlocks][size - 1]
					;

					if( next_block_data == SNAKE_BLOCK_DATA_FOOD ) { // Next Block = Food
				        g_PlayerSnakeData[playerid][e_PlayerSnakeSize] ++;

			    	    PlayerPlaySound(playerid, 5205, 0.0, 0.0, 0.0);
			    	    
			    	    foodeaten = true;
					} else if( next_block_data != INVALID_PLAYER_ID ) { // Next Block = Player
						if( next_block_data != playerid ) { // Next block is another player = kill for other player
							g_PlayerSnakeData[next_block_data][e_PlayerSnakeKills] ++;
						}

					    KillSnake(playerid);

	        		    PlayerPlaySound(playerid, 5206, 0.0, 0.0, 0.0);
					} else { // Next Block = Empty
						g_SnakeData[gameid][e_SnakeBlockData][tail_block] = INVALID_PLAYER_ID;

						DestroySnakeBlockForGame(gameid, tail_block);
					}

					if( !g_PlayerSnakeData[playerid][e_PlayerSnakeAlive] ) {
					    continue;
					}

					if( g_PlayerSnakeData[playerid][e_PlayerSnakeSize] > 1 ) {
						for(new b = g_PlayerSnakeData[playerid][e_PlayerSnakeSize] - 1; b > 0; b --) {
							g_PlayerSnakeData[playerid][e_PlayerSnakeBlocks][b] = g_PlayerSnakeData[playerid][e_PlayerSnakeBlocks][b - 1];
						}
					}

					CreateSnakeBlockForGame(gameid, next_block, g_SnakeColors[ g_PlayerSnakeData[playerid][e_PlayerSnakeSlot] ]);

					g_PlayerSnakeData[playerid][e_PlayerSnakeBlocks][0] = next_block;
					g_SnakeData[gameid][e_SnakeBlockData][next_block] = playerid;

					g_PlayerSnakeData[playerid][e_PlayerSnakeLastDirection] = direction;
				}

				if( foodeaten && GetFoodSnakeBlocks(gameid) == 0 ) {
					new random_block = GetRandomEmptyBlock(gameid);

					if( random_block != INVALID_SNAKE_GAME_BLOCK ) {
						g_SnakeData[gameid][e_SnakeBlockData][random_block] = SNAKE_BLOCK_DATA_FOOD;

						CreateSnakeBlockForGame(gameid, random_block, RGBA_WHITE);
					}
				}

				if( foodeaten ) {
					SortSnakePlayers(gameid), RefreshSnakePlayersForGame(gameid);
				}
			}
			case SNAKE_STATE_GAMEOVER: {
			    new timeleft = g_SnakeData[gameid][e_SnakeTime] - gettime();

				if(timeleft > 0) {
				    new countdown_str[2+1];

					format(countdown_str, sizeof countdown_str, "%i", timeleft);

				    for(new p; p < MAX_SNAKE_PLAYERS; p ++) {
						new playerid = g_SnakeData[gameid][e_SnakePlayerID][p];

						if( playerid != INVALID_PLAYER_ID ) {
							PlayerTextDrawSetString(playerid, g_SnakeGameTextDraw[playerid][SNAKE_TD_GAME_COUNTDOWN], countdown_str);
						}
				    }
				} else {
				    for(new p; p < MAX_SNAKE_PLAYERS; p ++) {
						new playerid = g_SnakeData[gameid][e_SnakePlayerID][p];

						if( playerid != INVALID_PLAYER_ID ) {
							LeaveSnake(playerid);
						}
				    }
				}
			}
		}
	}
}
