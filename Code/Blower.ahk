#Requires AutoHotkey v2.0
CoordMode("Mouse", "Screen")
SetTitleMatchMode(2)  ; Allow partial matching of window titles

; Set the target window title
winTitle := "Leaf Blower Revolution"

; Check if the game window exists
if !WinExist(winTitle) {
    MsgBox("Leaf Blower Not Open.", "Error", 16)
    ExitApp()
}

; Get the window position and size
leftX := topY := winWidth := winHeight := 0
WinGetPos(&leftX, &topY, &winWidth, &winHeight, winTitle)
rightX := leftX + winWidth
bottomY := topY + winHeight

; Movement parameters
horizontalStep := 60   ; Pixels moved per step horizontally
verticalStep := 180    ; Pixels moved downward after reaching an edge
delayMs := 20          ; Delay between movements (milliseconds) - half speed

; Adjust the scanning area:
contentOffset := 60    ; Skip the title bar (in pixels)
topY += contentOffset  ; Start scanning below the title bar

; Initialize mouse position and direction
currentX := leftX, currentY := topY, direction := 1  ; 1 = right, -1 = left

; Global variable to track pause state
global isPaused := false

; Set a timer to control mouse movement
SetTimer(MoveMouse, delayMs)

MoveMouse() {
    global currentX, currentY, direction, leftX, rightX, bottomY, topY, horizontalStep, verticalStep

    ; Reset to the top if we reach below the window
    if (currentY > bottomY) {
        currentY := topY
        currentX := leftX
        direction := 1
    }

    ; Move in a zigzag pattern.
    currentX += horizontalStep * direction
    if (currentX > rightX || currentX < leftX) {
        ; When reaching an edge, move down one row and reverse direction.
        currentY += verticalStep
        direction *= -1
        currentX := (direction == 1 ? leftX : rightX)
    }

    ; Move the mouse to the calculated position.
    MouseMove(currentX, currentY, 0)
}

; Press the tilde (grave) key (SC029) to toggle pause/unpause of mouse movement.
SC029:: {
    global isPaused, delayMs
    isPaused := !isPaused
    if isPaused {
        ; Pause the movement by disabling the timer.
        SetTimer(MoveMouse, 0)
    } else {
        ; Unpause the movement by restoring the timer.
        SetTimer(MoveMouse, delayMs)
    }
    return
}

; Press Esc to exit the script.
Esc::ExitApp()