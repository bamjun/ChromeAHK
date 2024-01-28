; Sleep, 20000

; 컴퓨터 부팅되고, 인터넷이 연결안되어있으면, 바로 에러 출력됨. 69초동안 1초마다, 인터넷 연결 확인해서 연결되어있으면, 다음으로 이동.
Loop, 60
{
    if (IsInternetConnected())
    {

        #NoEnv
        SetBatchLines, -1

        #Include lib/Chrome.ahk

        openchrome()
        break
    }
    Sleep, 1000 ; 5초마다 체크하려면 5000으로 변경 가능
}
ExitApp

;인터넷 연결 확인용.
IsInternetConnected()
{
    try
    {
        WinHTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        WinHTTP.Open("GET", "https://www.google.com", false)
        WinHTTP.Send()
        return WinHTTP.Status = 200
    }
    catch
    {
        return false
    }
}

; 크롬 연결.
openchrome() {
    ; --- Create a new Chrome instance ---

    ; Instead of providing a URL here, let's try
    ; navigating later for demonstration purposes
    ; FileCreateDir, ChromeProfile
    ChromeInst := new Chrome("ChromeProfile")

    ; --- Connect to the page ---

    if !(PageInst := ChromeInst.GetPage())
    {
        MsgBox, Could not retrieve page!
        ChromeInst.Kill()
    }
    else
    {
        ; --- Navigate to the desired URL ---
        Random, randomValue, 0, 2

        if ( randomValue = 0) {

            PageInst.Call("Page.navigate", {"url": "https://www.youtube.com/@NBCNews"})
            PageInst.WaitForLoad()
            PageInst.Evaluate("document.getElementsByClassName('yt-tab-shape-wiz__tab')[3].click();")

            Loop, 100 {
                value := PageInst.Evaluate("document.getElementsByClassName('yt-tab-shape-wiz__tab yt-tab-shape-wiz__tab--tab-selected')[0].textContent;").value
                ; value가 라이브인 경우 스크립트를 멈춥니다.
                if (value = "라이브") {
                    break ; 반복문 종료
                }
                PageInst.Evaluate("document.getElementsByClassName('yt-tab-shape-wiz__tab')[3].click();")
                sleep, 100
            }
            ;loop 100 반복해도 라이브를 클릭 못하면 스크립트 종료
            if (value != "라이브") {
                ExitApp
            }
            PageInst.WaitForLoad()
            Loop, 5 {
                valueForLiveNew := PageInst.Evaluate("document.getElementsByClassName('yt-simple-endpoint focus-on-expand style-scope ytd-rich-grid-media')[" . A_Index-1 . "].textContent.slice(0,12)").value
                ; value가 라이브인 경우 스크립트를 멈춥니다.
                if (valueForLiveNew = "LIVE: NBC Ne") {
                    PageInst.Evaluate("document.getElementsByClassName('yt-simple-endpoint focus-on-expand style-scope ytd-rich-grid-media')[" . A_Index-1 . "].click();")
                    Loop, 10 {
                        titleForScreen := PageInst.Evaluate("document.getElementsByClassName('ytp-fullscreen-button ytp-button')[0].title").value
                        sleep, 1000
                        ; value가 라이브인 경우 스크립트를 멈춥니다.
                        if (titleForScreen = "전체 화면(f)") {
                            PageInst.Evaluate("document.getElementsByClassName('ytp-fullscreen-button ytp-button')[0].click();")
                            PageInst.Disconnect()
                            ExitApp
                        }
                        sleep, 500
                    }
                    PageInst.Disconnect()
                    ExitApp
                } else if (valueForLiveNew = "NBC News NOW") {
                    PageInst.Evaluate("document.getElementsByClassName('yt-simple-endpoint focus-on-expand style-scope ytd-rich-grid-media')[" . A_Index-1 . "].click();")
                    Loop, 10 {
                        titleForScreen := PageInst.Evaluate("document.getElementsByClassName('ytp-fullscreen-button ytp-button')[0].title").value
                        sleep, 1000
                        ; value가 라이브인 경우 스크립트를 멈춥니다.
                        if (titleForScreen = "전체 화면(f)") {
                            PageInst.Evaluate("document.getElementsByClassName('ytp-fullscreen-button ytp-button')[0].click();")
                            loop, 20 {
                                Try {
                                    PageInst.Evaluate("document.getElementsByClassName('ytp-ad-text ytp-ad-skip-button-text-centered ytp-ad-skip-button-text')[0].click();")
                                }
                                sleep, 900
                            }
                            PageInst.Disconnect()
                            ExitApp
                        }
                        sleep, 500
                    }
                    PageInst.Disconnect()
                    ExitApp
                }
            }

            PageInst.Evaluate("document.getElementsByClassName('yt-simple-endpoint focus-on-expand style-scope ytd-rich-grid-media')[1].click();")
            PageInst.Disconnect()

        } else if (randomValue = 1) {
            PageInst.Call("Page.navigate", {"url": "https://www.youtube.com/@YahooFinance/streams"})
            PageInst.WaitForLoad()
            PageInst.Evaluate("document.getElementsByClassName('yt-tab-shape-wiz__tab')[3].click();")

            PageInst.WaitForLoad()
            Loop, 5 {
                stringLive = "실시간"
                ; PageInst.Evaluate("let element = document.querySelectorAll('ytd-thumbnail span#text.style-scope.ytd-thumbnail-overlay-time-status-renderer[aria-label=" . stringLive . "]');")
                numberLength := PageInst.Evaluate("document.querySelectorAll('ytd-thumbnail span#text.style-scope.ytd-thumbnail-overlay-time-status-renderer[aria-label=" . stringLive . "]').length;").value
                ; LIVE 중인 항목이 1개 이상일때, LIVE개수만큼 loop 돌림, 첫번째 LIVE가 클릭 될꺼임.. 추후 첫번째 라이브가, 진짜 라이브방송중이 아니면 수정예정.
                if (numberLength >= 1) {
                    loop, %numberLength% {
                        PageInst.Evaluate("document.querySelectorAll('ytd-thumbnail span#text.style-scope.ytd-thumbnail-overlay-time-status-renderer[aria-label=" . stringLive . "]')[" . A_Index-1 . "].click();")
                        Loop, 10 {
                            titleForScreen := PageInst.Evaluate("document.getElementsByClassName('ytp-fullscreen-button ytp-button')[0].title").value
                            sleep, 1000
                            ; value가 라이브인 경우 스크립트를 멈춥니다.
                            if (titleForScreen = "전체 화면(f)") {
                                PageInst.Evaluate("document.getElementsByClassName('ytp-fullscreen-button ytp-button')[0].click();")
                                loop, 20 {
                                    Try {
                                        PageInst.Evaluate("document.getElementsByClassName('ytp-ad-text ytp-ad-skip-button-text-centered ytp-ad-skip-button-text')[0].click();")
                                    }
                                    sleep, 900
                                }
                                PageInst.Disconnect()
                                ExitApp
                            }
                            sleep, 500
                        }
                        PageInst.Disconnect()
                        ExitApp
                    }
                }
                Sleep, 500
            }

            PageInst.Disconnect()

        } else {
            PageInst.Call("Page.navigate", {"url": "https://www.youtube.com/watch?v=iyOq8DhaMYw"})
            PageInst.WaitForLoad()

            Loop, 10 {
                titleForScreen := PageInst.Evaluate("document.getElementsByClassName('ytp-fullscreen-button ytp-button')[0].title").value
                sleep, 1000
                ; value가 라이브인 경우 스크립트를 멈춥니다.
                if (titleForScreen = "전체 화면(f)") {
                    PageInst.Evaluate("document.getElementsByClassName('ytp-fullscreen-button ytp-button')[0].click();")
                    loop, 20 {
                        Try {
                            PageInst.Evaluate("document.getElementsByClassName('ytp-ad-text ytp-ad-skip-button-text-centered ytp-ad-skip-button-text')[0].click();")
                        }
                        sleep, 900
                    }
                    PageInst.Disconnect()
                    ExitApp
                }
                sleep, 500
            }
            PageInst.Disconnect()
        }
    }
    ExitApp

}

esc::ExitApp