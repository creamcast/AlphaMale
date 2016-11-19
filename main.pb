EnableExplicit
#EVENT_ALPHADOWN = 1
#EVENT_ALPHAUP = 2
#BTN_RESIZE = 1
#GADGET_TXT1 = 2

Procedure ResizeImg(img, winid)
	Define newwinw = WindowWidth(winid)
	Define newwinh = WindowHeight(winid)
	Define tmpimg = CopyImage(img, #PB_Any)
	ResizeImage(tmpimg, newwinw, newwinh, #PB_Image_Raw  )
	StartDrawing(WindowOutput(winid))	
	DrawImage(ImageID(tmpimg), 0, 0 ) 
	StopDrawing()
	FreeImage(tmpimg)
EndProcedure

Procedure WinCallback(WindowID, Msg, WParam, LParam)
	Define Result = #PB_ProcessPureBasicEvents
	;If Msg = #WM_SIZE 
	;	Select WParam  
				
	;	EndSelect 
	;ElseIf Msg = #WM_SETFOCUS
		;SetWindowLongPtr_(WindowID, #DWLP_MSGRESULT, #MA_NOACTIVATE)
		;ProcedureReturn #MA_NOACTIVATE
	;ElseIf Msg = #WM_MOUSEACTIVATE
		;SetWindowLongPtr_(WindowID, #DWLP_MSGRESULT, #MA_NOACTIVATE)
		;ProcedureReturn #MA_NOACTIVATE
	;EndIf
	ProcedureReturn Result
EndProcedure


Procedure Main()
	UseJPEGImageDecoder() 
	UseJPEG2000ImageDecoder() 
	UsePNGImageDecoder() 
	
	Define imgfile.s = ""
	Define imgid = 0
	Define winid = 1
	Define winsubid = 2
	Define winw = 800
	Define winh = 600
	Define winsubw = 200
	Define winsubh = 200
	Define event = 0
	Define event_menu = 0
	Define quit = 0
	Define alpha = 128
	Define stickmode = 1
	
	;get image file
	imgfile = OpenFileRequester("Choose Image","", "Image file | *.png;*.jpg", 0)
	imgid = LoadImage(#PB_Any, imgfile, 0)
	If imgid = 0
		MessageRequester("ERROR", "could not open image",#PB_MessageRequester_Ok)
		ProcedureReturn 0
	EndIf
	winw = ImageWidth(imgid)
	winh = ImageHeight(imgid)
	
	;create windows
	winid = OpenWindow(#PB_Any, 300, 300, winw, winh, "",  #PB_Window_ScreenCentered | #PB_Window_SizeGadget | #PB_Window_Tool )
	winsubid = OpenWindow(#PB_Any, 0, 0, winsubw, winsubh, "Alpha: " + Str(alpha))
	If winid = 0 Or winsubid = 0
		MessageRequester("ERROR", "could not open window",#PB_MessageRequester_Ok)
		ProcedureReturn 0
	EndIf
	
	;create buttons
	TextGadget(#GADGET_TXT1, 10, 10, winsubw, 20, "Press Keys: (1 -Alpha) (2 +Alpha)")
	ButtonGadget(#BTN_RESIZE, 10, 30, winsubw-20, winsubh-40, "RESIZE")
	
	SetWindowCallback(@WinCallback())    ; activate the callback
	StickyWindow(winid, 1) ;make window always in front
	;draw image on window
	StartDrawing(WindowOutput(winid))
	DrawImage(ImageID(imgid), 0, 0 ) 
	StopDrawing()
	
	;transparent
	SetWindowLong_(WindowID(winid), #GWL_EXSTYLE, #WS_EX_LAYERED | #WS_EX_TRANSPARENT | #WS_EX_TOPMOST)
	SetLayeredWindowAttributes_(WindowID(winid),#Blue,alpha,#LWA_ALPHA)
	SetWindowTitle(winid, "STICK MODE")
	
	;Window event
	InitKeyboard()
	AddKeyboardShortcut(winsubid, #PB_Shortcut_1, #EVENT_ALPHADOWN)
	AddKeyboardShortcut(winsubid, #PB_Shortcut_2, #EVENT_ALPHAUP)
	Repeat
		event = WaitWindowEvent()
		Select event
			Case #PB_Event_Gadget
				Select EventGadget()
					Case #BTN_RESIZE
						If stickmode = 1
							SetWindowLong_(WindowID(winid), #GWL_EXSTYLE,#WS_EX_LAYERED | #WS_EX_TOPMOST)
							SetGadgetText(#BTN_RESIZE, "STICK")
							stickmode = 0
							SetWindowTitle(winid, "RESIZE MODE")
							SetActiveWindow(winid)
						Else
							SetWindowLong_(WindowID(winid), #GWL_EXSTYLE, #WS_EX_LAYERED | #WS_EX_TRANSPARENT | #WS_EX_TOPMOST)
							SetGadgetText(#BTN_RESIZE, "RESIZE")
							SetWindowTitle(winid, "STICK MODE")

							stickmode = 1
						EndIf
				EndSelect
			Case #PB_Event_Menu
				event_menu = EventMenu()
				If event_menu = #EVENT_ALPHADOWN
					;------------DOWN-----------------
					alpha = alpha - 4
					If alpha < 0 
						alpha = 0
					EndIf
					SetWindowTitle(winsubid, "Alpha: " + Str(alpha))
					SetLayeredWindowAttributes_(WindowID(winid),#Blue,alpha,#LWA_ALPHA)
					;---------------------------------
				ElseIf event_menu = #EVENT_ALPHAUP
					;------------UP-------------------
					alpha = alpha + 4
					If alpha > 255
						alpha = 255
					EndIf
					SetWindowTitle(winsubid, "Alpha: " + Str(alpha))
					SetLayeredWindowAttributes_(WindowID(winid),#Blue,alpha,#LWA_ALPHA)
					;---------------------------------
				EndIf
			Case #PB_Event_SizeWindow	: ResizeImg(imgid, winid)
			Case #PB_Event_CloseWindow	: quit = 1
		EndSelect
	Until quit= 1
	
	FreeImage(imgid)
EndProcedure

Main()
