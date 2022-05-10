@echo off
REM Start the program
GOTO :Main

REM # ================================================================================================
REM # Documentation
REM #     Spine of the program; this makes sure that the execution works as intended.
REM # ================================================================================================
:Main
REM Update the terminal window title
TITLE DNF 2001 Leak Loader by Ozymandias81
CALL :MainMenu
GOTO :TerminateProcess

REM # ================================================================================================
REM # Documentation
REM #     Displays the main menu
REM # ================================================================================================
:MainMenu
REM Thrash the terminal buffer
CLS
ECHO --------------------------------------------------------------
ECHO Welcome to Ozy's DNF 2001 Leak BAT Loader, choose an option by 
ECHO typing the relative number and that's all. Use "X" to leave.
ECHO --------------------------------------------------------------
ECHO.
ECHO  [1] Run DNF 2001 (October 26 Leak - More Stable)
ECHO  [2] Run DNF 2001 (August 21 Leak - Less Stable)
ECHO  [3] Run Cannibal Editor
ECHO  [4] Run DNF 2001 Editor
ECHO.
ECHO  - USE FOLLOWING ONLY IF YOU KNOW WHAT ARE YOU DOING -
ECHO.
ECHO  [5] Reset your Config (delete generated .ini files)
ECHO  [6] Rebuild the Source Code (not sure how this works)
ECHO.
ECHO  [X] Exit
ECHO -----------------------------------------------------
REM Capture the user input
CALL :PromptUserInput
REM Inspect the input
GOTO :MainMenu_STDIN

REM # ================================================================================================
REM # Documentation
REM #     This function captures the standard input from the user.
REM # ================================================================================================
:PromptUserInput
SET /P STDIN=^>^>^>^>
GOTO :EOF

REM # ================================================================================================
REM # Documentation
REM #     Inspect the user's input and execute their desired action
REM # ================================================================================================
:MainMenu_STDIN
IF "%STDIN%" EQU "1" (
    CALL DNF2001a.bat
    GOTO :EOF
)
IF "%STDIN%" EQU "2" (
    CALL DNF2001b.bat
    GOTO :EOF
)
IF "%STDIN%" EQU "3" (
    CALL CANNIBAL.bat
    GOTO :EOF
)
IF "%STDIN%" EQU "4" (
    CALL DUKE-ED.bat
    GOTO :EOF
)
IF "%STDIN%" EQU "5" (
    CALL RESET.bat
    GOTO :MainMenu
)
IF "%STDIN%" EQU "6" (
    CALL REBUILD.bat
    GOTO :MainMenu
)
IF /I "%STDIN%" EQU "X" (
    GOTO :EOF
)
IF /I "%STDIN%" EQU "U" (
    CALL :MainMenu_STDIN_BadInput
    GOTO :MainMenu
)

REM # ================================================================================================
REM # Documentation
REM #     This function displays a message to the user that the STDIN was illegal and not supported
REM # ================================================================================================
:MainMenu_STDIN_BadInput
ECHO.
ECHO ---------------------------- ERROR: INVALID OPTION -----------------------------
ECHO The provided input from the user is not either valid or supported.
ECHO Please select from the choices provided.
ECHO.
ECHO REMINDER:
ECHO If you get stuck with selector, simply close the window or press CTRL+LSHIFT+C
ECHO ---------------------------- ERROR: INVALID OPTION -----------------------------
ECHO.
PAUSE
GOTO :MainMenu

REM # ================================================================================================
REM # Documentation
REM #     Terminate the program without destroying the console process if invoked via CUI.
REM # ================================================================================================
:TerminateProcess
ECHO Closing program. . .
REM Restore the terminal window's title to something generic
TITLE Command Prompt
EXIT /B 0