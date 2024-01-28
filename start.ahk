#NoEnv
SetBatchLines, -1

#Include lib/Chrome.ahk


; --- Create a new Chrome instance ---

FileCreateDir, ChromeProfile
ChromeInst := new Chrome("ChromeProfile", "https://www.google.com/")


; --- Connect to the page ---

if !(PageInst := ChromeInst.GetPage())
{
	MsgBox, Could not retrieve page!
	ChromeInst.Kill()
}
else
{
	PageInst.Disconnect()
}



ExitApp
return
