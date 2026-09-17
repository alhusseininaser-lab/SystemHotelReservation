; =========================================================================
; PROJECT #7 : HOTEL RESERVATION SYSTEM
; -------------------------------------------------------------------------
; Core features implemented (as required by the project spec):
;   1) ADD     -> Book a room             
;   2) DELETE  -> Cancel a reservation     
;   3) UPDATE  -> Change dates/guest name   
;   4) QUERY   -> View all rooms / search  
;   Main Menu + continuous loop + safe Exit
; =========================================================================

.MODEL SMALL
.STACK 100H

.DATA
    MAX_ROOMS   EQU 10      
    NAME_SIZE   EQU 21    
    DATE_SIZE   EQU 9     

    ; ---------------- "DATABASE" : parallel arrays (one slot per room) -----
    
    RoomNumbers     dw 1,2,3,4,5,6,7,8,9,10
    RoomStatus      db MAX_ROOMS dup(0)
    GuestNames      db (MAX_ROOMS*NAME_SIZE) dup('$')
    CheckInDates    db (MAX_ROOMS*DATE_SIZE) dup('$')
    CheckOutDates   db (MAX_ROOMS*DATE_SIZE) dup('$')

    ; ---------------- Screen text -------------------------------------
    msgTitle        db 13,10,'====================================================',13,10
                    db '          HOTEL RESERVATION MANAGEMENT SYSTEM',13,10
                    
                    db '====================================================$'

    msgMenu         db 13,10,13,10
                    db '1. Book a Room            (ADD)',13,10
                    db '2. Cancel a Reservation   (DELETE)',13,10
                    db '3. Update a Reservation   (UPDATE)',13,10
                    db '4. View / Search Rooms    (QUERY)',13,10
                    db '5. Exit',13,10
                    db '----------------------------------------------------',13,10
                    db 'Enter your choice (1-5): $'

    msgInvalid      db 13,10,'*** Invalid choice, please try again ***',13,10,'$'
    msgAgain        db 13,10,13,10,'Perform another operation? (Y/N): $'
    msgBye          db 13,10,'Thank you for using the system. Goodbye!',13,10,'$'

    msgAskRoom      db 13,10,'Enter room number (1-10): $'
    msgRoomNotFound db 13,10,'*** Room number not found ***',13,10,'$'
    msgAlreadyBooked db 13,10,'*** This room is already booked ***',13,10,'$'
    msgAlreadyFree  db 13,10,'*** This room is free - nothing to do ***',13,10,'$'

    msgAskName      db 13,10,'Enter guest name (max 20 chars): $'
    msgAskCheckIn   db 13,10,'Enter check-in date  (DD/MM/YY): $'
    msgAskCheckOut  db 13,10,'Enter check-out date (DD/MM/YY): $'

    msgBooked       db 13,10,'>>> Room booked successfully <<<',13,10,'$'
    msgCancelled    db 13,10,'>>> Reservation cancelled. Room is now FREE <<<',13,10,'$'
    msgUpdated      db 13,10,'>>> Reservation updated successfully <<<',13,10,'$'

    msgSearchOrAll  db 13,10,'View (A)ll rooms or (S)earch one room? : $'
    msgTableHead    db 13,10
                    db 'ROOM   STATUS   GUEST NAME             CHECK-IN   CHECK-OUT',13,10
                    db '-------------------------------------------------------------',13,10,'$'
    msgFree         db 'FREE    $'
    msgBookedStat   db 'BOOKED  $'
    msgFreeDetails  db '  --                    --         --',13,10,'$'
    msgSpace        db ' $'

    ; ---------------- DOS buffered-input areas -------------------------
    
    roomBuf     db 3,0, 3 dup(0)
    nameBuf     db 20,0, 20 dup(0)
    dateBuf     db 8,0, 8 dup(0)

    ; ---------------- Working variables ---------------------------------
    roomNumEntered  dw 0
    roomIndex       dw 0      

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    CALL PrintTitle

MainLoop:
    LEA DX, msgMenu
    MOV AH, 09H
    INT 21H

    CALL ReadChoiceChar   

    CMP AL, '1'
    JE DoAdd
    CMP AL, '2'
    JE DoDelete
    CMP AL, '3'
    JE DoUpdate
    CMP AL, '4'
    JE DoQuery
    CMP AL, '5'
    JE DoExit

    LEA DX, msgInvalid
    MOV AH, 09H
    INT 21H
    JMP MainLoop

DoAdd:
    CALL AddReservation
    JMP AskAgain
DoDelete:
    CALL DeleteReservation
    JMP AskAgain
DoUpdate:
    CALL UpdateReservation
    JMP AskAgain
DoQuery:
    CALL QueryRooms
    JMP AskAgain

AskAgain:
    LEA DX, msgAgain
    MOV AH, 09H
    INT 21H
    CALL ReadYesNoChar    
    CMP AL, 'Y'
    JE MainLoop
   

DoExit:
    LEA DX, msgBye
    MOV AH, 09H
    INT 21H
    MOV AH, 4CH
    INT 21H
MAIN ENDP


; =========================================================================
; PrintTitle 
; =========================================================================
PrintTitle PROC
    LEA DX, msgTitle
    MOV AH, 09H
    INT 21H
    RET
PrintTitle ENDP


; =========================================================================
; ReadChoiceChar :  (1-5)
; =========================================================================
ReadChoiceChar PROC
    MOV AH, 01H
    INT 21H       
    PUSH AX
    MOV AH, 01H
    INT 21H        
    POP AX
    RET
ReadChoiceChar ENDP


; =========================================================================
; ReadYesNoChar : reads a Y/N 
; =========================================================================
ReadYesNoChar PROC
    MOV AH, 01H
    INT 21H
    CMP AL, 'a'
    JB RYN_NoUpper
    CMP AL, 'z'
    JA RYN_NoUpper
    SUB AL, 20H 
RYN_NoUpper:
    PUSH AX
    MOV AH, 01H
    INT 21H        
    POP AX
    RET
ReadYesNoChar ENDP


; =========================================================================
; ReadRoomNumber 
; =========================================================================
ReadRoomNumber PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    LEA DX, msgAskRoom
    MOV AH, 09H
    INT 21H

    LEA DX, roomBuf
    MOV AH, 0AH
    INT 21H            

    LEA SI, roomBuf
    MOV CL, [SI+1]      
    MOV CH, 0
    ADD SI, 2           

    MOV AX, 0           

RRN_Loop:
    CMP CX, 0
    JE RRN_Done
    MOV BL, [SI]
    SUB BL, '0'         ; ASCII digit -> value 0-9
    MOV BH, 0
    PUSH BX             
    MOV DX, 10
    MUL DX              
    POP BX
    ADD AX, BX         
    INC SI
    DEC CX
    JMP RRN_Loop

RRN_Done:
    MOV roomNumEntered, AX

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
ReadRoomNumber ENDP


; =========================================================================
; FindRoomIndex : 
; =========================================================================
FindRoomIndex PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI

    MOV roomIndex, 0FFFFH
    LEA SI, RoomNumbers
    MOV CX, MAX_ROOMS
    MOV BX, 0

FRI_Loop:
    CMP CX, 0
    JE FRI_Done
    MOV AX, [SI]
    CMP AX, roomNumEntered
    JE FRI_Found
    ADD SI, 2
    INC BX
    DEC CX
    JMP FRI_Loop

FRI_Found:
    MOV roomIndex, BX

FRI_Done:
    POP SI
    POP CX
    POP BX
    POP AX
    RET
FindRoomIndex ENDP


; =========================================================================
; GetRecordAddr
; =========================================================================
GetRecordAddr PROC
    PUSH AX
    PUSH DX

    MOV AX, BX
    MUL CX              
    MOV DI, SI
    ADD DI, AX

    POP DX
    POP AX
    RET
GetRecordAddr ENDP


; =========================================================================
; CopyBufferToSlot : copies a DOS-buffered-input string into a fixed size
; =========================================================================
CopyBufferToSlot PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    MOV BL, [SI+1]      
    MOV BH, 0
    MOV AX, CX
    CMP BX, AX
    JBE CBS_LenOK
    MOV BX, AX          
CBS_LenOK:
    ADD SI, 2          

    MOV DX, CX        

CBS_CopyLoop:
    CMP BX, 0
    JE CBS_PadLoop
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    DEC BX
    DEC DX
    JMP CBS_CopyLoop

CBS_PadLoop:
    CMP DX, 0
    JE CBS_Terminate
    MOV BYTE PTR [DI], ' '
    INC DI
    DEC DX
    JMP CBS_PadLoop

CBS_Terminate:
    MOV BYTE PTR [DI], '$'

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
CopyBufferToSlot ENDP


; =========================================================================
; PrintNumber : prints the unsigned word held in AX as decimal digits
; =========================================================================
PrintNumber PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, 0
    MOV BX, 10

PN_DivLoop:
    MOV DX, 0
    DIV BX              ; AX = AX/10 
    PUSH DX
    INC CX
    CMP AX, 0
    JNE PN_DivLoop

PN_PrintLoop:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PN_PrintLoop

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PrintNumber ENDP


; =========================================================================
; AddReservation ("ADD") : books a free room
; =========================================================================
AddReservation PROC
    CALL ReadRoomNumber
    CALL FindRoomIndex

    CMP roomIndex, 0FFFFH
    JNE AR_Found
    LEA DX, msgRoomNotFound
    MOV AH, 09H
    INT 21H
    RET

AR_Found:
    MOV BX, roomIndex

    LEA SI, RoomStatus
    MOV CX, 1
    CALL GetRecordAddr
    MOV AL, [DI]
    CMP AL, 1
    JNE AR_IsFree
    LEA DX, msgAlreadyBooked
    MOV AH, 09H
    INT 21H
    RET

AR_IsFree:
    ; ---- guest name ----
    LEA DX, msgAskName
    MOV AH, 09H
    INT 21H
    LEA DX, nameBuf
    MOV AH, 0AH
    INT 21H

    LEA SI, GuestNames
    MOV CX, NAME_SIZE
    CALL GetRecordAddr      
    LEA SI, nameBuf
    MOV CX, NAME_SIZE-1
    CALL CopyBufferToSlot

    ; ---- check-in date ----
    LEA DX, msgAskCheckIn
    MOV AH, 09H
    INT 21H
    LEA DX, dateBuf
    MOV AH, 0AH
    INT 21H

    LEA SI, CheckInDates
    MOV CX, DATE_SIZE
    CALL GetRecordAddr
    LEA SI, dateBuf
    MOV CX, DATE_SIZE-1
    CALL CopyBufferToSlot

    ; ---- check-out date ----
    LEA DX, msgAskCheckOut
    MOV AH, 09H
    INT 21H
    LEA DX, dateBuf
    MOV AH, 0AH
    INT 21H

    LEA SI, CheckOutDates
    MOV CX, DATE_SIZE
    CALL GetRecordAddr
    LEA SI, dateBuf
    MOV CX, DATE_SIZE-1
    CALL CopyBufferToSlot

    ; ---- mark the room as booked ----
    LEA SI, RoomStatus
    MOV CX, 1
    CALL GetRecordAddr
    MOV BYTE PTR [DI], 1

    LEA DX, msgBooked
    MOV AH, 09H
    INT 21H
    RET
AddReservation ENDP


; =========================================================================
; DeleteReservation ("DELETE")
; =========================================================================
DeleteReservation PROC
    CALL ReadRoomNumber
    CALL FindRoomIndex

    CMP roomIndex, 0FFFFH
    JNE DR_Found
    LEA DX, msgRoomNotFound
    MOV AH, 09H
    INT 21H
    RET

DR_Found:
    MOV BX, roomIndex

    LEA SI, RoomStatus
    MOV CX, 1
    CALL GetRecordAddr
    MOV AL, [DI]
    CMP AL, 0
    JNE DR_IsBooked
    LEA DX, msgAlreadyFree
    MOV AH, 09H
    INT 21H
    RET

DR_IsBooked:
    LEA SI, GuestNames
    MOV CX, NAME_SIZE
    CALL GetRecordAddr
    MOV BYTE PTR [DI], '$'       

    LEA SI, CheckInDates
    MOV CX, DATE_SIZE
    CALL GetRecordAddr
    MOV BYTE PTR [DI], '$'

    LEA SI, CheckOutDates
    MOV CX, DATE_SIZE
    CALL GetRecordAddr
    MOV BYTE PTR [DI], '$'

    LEA SI, RoomStatus
    MOV CX, 1
    CALL GetRecordAddr
    MOV BYTE PTR [DI], 0           ; room is FREE again

    LEA DX, msgCancelled
    MOV AH, 09H
    INT 21H
    RET
DeleteReservation ENDP


; =========================================================================
; UpdateReservation ("UPDATE"
; =========================================================================
UpdateReservation PROC
    CALL ReadRoomNumber
    CALL FindRoomIndex

    CMP roomIndex, 0FFFFH
    JNE UR_Found
    LEA DX, msgRoomNotFound
    MOV AH, 09H
    INT 21H
    RET

UR_Found:
    MOV BX, roomIndex

    LEA SI, RoomStatus
    MOV CX, 1
    CALL GetRecordAddr
    MOV AL, [DI]
    CMP AL, 1
    JE UR_IsBooked
    LEA DX, msgAlreadyFree
    MOV AH, 09H
    INT 21H
    RET

UR_IsBooked:
    LEA DX, msgAskName
    MOV AH, 09H
    INT 21H
    LEA DX, nameBuf
    MOV AH, 0AH
    INT 21H

    LEA SI, GuestNames
    MOV CX, NAME_SIZE
    CALL GetRecordAddr
    LEA SI, nameBuf
    MOV CX, NAME_SIZE-1
    CALL CopyBufferToSlot

    LEA DX, msgAskCheckIn
    MOV AH, 09H
    INT 21H
    LEA DX, dateBuf
    MOV AH, 0AH
    INT 21H

    LEA SI, CheckInDates
    MOV CX, DATE_SIZE
    CALL GetRecordAddr
    LEA SI, dateBuf
    MOV CX, DATE_SIZE-1
    CALL CopyBufferToSlot

    LEA DX, msgAskCheckOut
    MOV AH, 09H
    INT 21H
    LEA DX, dateBuf
    MOV AH, 0AH
    INT 21H

    LEA SI, CheckOutDates
    MOV CX, DATE_SIZE
    CALL GetRecordAddr
    LEA SI, dateBuf
    MOV CX, DATE_SIZE-1
    CALL CopyBufferToSlot

    LEA DX, msgUpdated
    MOV AH, 09H
    INT 21H
    RET
UpdateReservation ENDP


; =========================================================================
; QueryRooms ("QUERY") : view all rooms, or search a single room
; =========================================================================
QueryRooms PROC
    LEA DX, msgSearchOrAll
    MOV AH, 09H
    INT 21H

    MOV AH, 01H
    INT 21H
    CMP AL, 'a'
    JB QR_NoUpper
    CMP AL, 'z'
    JA QR_NoUpper
    SUB AL, 20H
QR_NoUpper:
    PUSH AX
    MOV AH, 01H
    INT 21H          
    POP AX

    CMP AL, 'S'
    JE QR_Search
    CMP AL, 'A'
    JE QR_All

    LEA DX, msgInvalid
    MOV AH, 09H
    INT 21H
    RET

QR_All:
    CALL ShowAllRooms
    RET

QR_Search:
    CALL ReadRoomNumber
    CALL FindRoomIndex
    CMP roomIndex, 0FFFFH
    JNE QR_ShowOne
    LEA DX, msgRoomNotFound
    MOV AH, 09H
    INT 21H
    RET

QR_ShowOne:
    LEA DX, msgTableHead
    MOV AH, 09H
    INT 21H
    MOV BX, roomIndex
    CALL PrintRoomLine
    RET
QueryRooms ENDP


; =========================================================================
; ShowAllRooms : prints the full table (all 10 rooms)
; =========================================================================
ShowAllRooms PROC
    PUSH BX

    LEA DX, msgTableHead
    MOV AH, 09H
    INT 21H

    MOV BX, 0
SAR_Loop:
    CMP BX, MAX_ROOMS
    JE SAR_Done
    CALL PrintRoomLine
    INC BX
    JMP SAR_Loop

SAR_Done:
    POP BX
    RET
ShowAllRooms ENDP


; =========================================================================
; PrintRoomLine : prints one row of the table for room index BX
; =========================================================================
PrintRoomLine PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    ; ---- room number ----
    LEA SI, RoomNumbers
    MOV CX, 2
    CALL GetRecordAddr
    MOV AX, [DI]
    CALL PrintNumber

    LEA DX, msgSpace
    MOV AH, 09H
    INT 21H
    LEA DX, msgSpace
    MOV AH, 09H
    INT 21H

    ; ---- status ----
    ; IMPORTANT: keep BX unchanged because BX is the room index.
    LEA SI, RoomStatus
    MOV CX, 1
    CALL GetRecordAddr
    MOV AL, [DI]
    CMP AL, 1
    JE PRL_Booked

    ; Room is FREE: show status and empty details.
    LEA DX, msgFree
    MOV AH, 09H
    INT 21H
    LEA DX, msgFreeDetails
    MOV AH, 09H
    INT 21H
    JMP PRL_Exit

PRL_Booked:
    ; Room is BOOKED: 
    LEA DX, msgBookedStat
    MOV AH, 09H
    INT 21H

    LEA SI, GuestNames
    MOV CX, NAME_SIZE
    CALL GetRecordAddr
    MOV DX, DI
    MOV AH, 09H
    INT 21H

    LEA DX, msgSpace
    MOV AH, 09H
    INT 21H

    LEA SI, CheckInDates
    MOV CX, DATE_SIZE
    CALL GetRecordAddr
    MOV DX, DI
    MOV AH, 09H
    INT 21H

    LEA DX, msgSpace
    MOV AH, 09H
    INT 21H

    LEA SI, CheckOutDates
    MOV CX, DATE_SIZE
    CALL GetRecordAddr
    MOV DX, DI
    MOV AH, 09H
    INT 21H

    MOV DL, 13
    MOV AH, 02H
    INT 21H
    MOV DL, 10
    INT 21H

PRL_Exit:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PrintRoomLine ENDP

END MAIN









