hosted Effect
    exposes [
        setTimeouts!,
        setScriptTimeoutOverride!,
        setAssertTimeoutOverride!,
        setPageLoadTimeoutOverride!,
        setImplicitTimeoutOverride!,
        resetTestOverrides!,
        setWindowSize!,
        setWindowSizeOverride!,
        getAssertTimeout!,
        stdoutLine!,
        stdinLine!,
        wait!,
        startSession!,
        deleteSession!,
        browserNavigateTo!,
        browserFindElement!,
        browserFindElements!,
        elementClick!,
        getTimeMilis!,
        isDebugMode!,
        isVerbose!,
        resetTestLogBucket!,
        getLogsFromBucket!,
        getTestNameFilter!,
        createDirIfNotExist!,
        fileWriteUtf8!,
        browserGetScreenshot!,
        addCookie!,
        getCookie!,
        getAllCookies!,
        deleteCookie!,
        deleteAllCookies!,
        alertDismiss!,
        alertSendText!,
        alertGetText!,
        alertAccept!,
        # browserGetPdf,
        elementGetText!,
        elementIsSelected!,
        elementIsDisplayed!,
        elementGetAttribute!,
        elementGetProperty!,
        elementSendKeys!,
        elementClear!,
        elementFindElement!,
        elementFindElements!,
        elementGetCss!,
        elementGetTag!,
        elementGetRect!,
        browserSetWindowRect!,
        browserGetWindowRect!,
        browserGetTitle!,
        browserGetUrl!,
        browserReload!,
        browserNavigateBack!,
        browserNavigateForward!,
        browserMaximize!,
        browserMinimize!,
        browserFullScreen!,
        executeJs!,
        getEnv!,
        getPageSource!,
        switchToFrameByElementId!,
        switchToParentFrame!,
    ]
    imports []

# effects that are provided by the host
setTimeouts! : U64, U64, U64, U64 => {}

setAssertTimeoutOverride! : U64 => {}

setPageLoadTimeoutOverride! : U64 => {}

setScriptTimeoutOverride! : U64 => {}

setImplicitTimeoutOverride! : U64 => {}

resetTestOverrides! : {} => {}

setWindowSize! : Str => {}

setWindowSizeOverride! : Str => {}

getAssertTimeout! : {} => U64

stdoutLine! : Str => {}

stdinLine! : {} => Str

wait! : U64 => {}

getTimeMilis! : {} => I64

isDebugMode! : {} => I64

isVerbose! : {} => I64

resetTestLogBucket! : {} => {}

getLogsFromBucket! : {} => List Str

getTestNameFilter! : {} => Str

# file system
createDirIfNotExist! : Str => Result {} Str

fileWriteUtf8! : Str, Str => Result {} Str

# driver effects
startSession! : {} => Result Str Str

deleteSession! : Str => Result {} Str

# browser effects
browserNavigateTo! : Str, Str => Result {} Str

browserGetTitle! : Str => Result Str Str

browserGetUrl! : Str => Result Str Str

browserFindElement! : Str, Str, Str => Result Str Str

browserFindElements! : Str, Str, Str => Result (List Str) Str

browserSetWindowRect! : Str, I64, I64, I64, I64, I64 => Result (List I64) Str

browserGetWindowRect! : Str => Result (List I64) Str

browserGetScreenshot! : Str => Result Str Str

# browserGetPdf : Str, F64, F64, F64, F64, F64, F64, F64, Str, I64, I64, List Str -> Task Str Str

browserNavigateBack! : Str => Result {} Str

browserNavigateForward! : Str => Result {} Str

browserReload! : Str => Result {} Str

browserMaximize! : Str => Result (List I64) Str

browserMinimize! : Str => Result (List I64) Str

browserFullScreen! : Str => Result (List I64) Str

executeJs! : Str, Str, Str => Result Str Str

addCookie! : Str, Str, Str, Str, Str, Str, I64, I64, I64 => Result {} Str

deleteCookie! : Str, Str => Result {} Str

deleteAllCookies! : Str => Result {} Str

getCookie! : Str, Str => Result (List Str) Str

getAllCookies! : Str => Result (List (List Str)) Str

alertAccept! : Str => Result {} Str

alertDismiss! : Str => Result {} Str

alertSendText! : Str, Str => Result {} Str

alertGetText! : Str => Result Str Str

# element effects
elementClick! : Str, Str => Result {} Str

elementSendKeys! : Str, Str, Str => Result {} Str

elementClear! : Str, Str => Result {} Str

elementGetText! : Str, Str => Result Str Str

elementIsSelected! : Str, Str => Result Str Str

elementIsDisplayed! : Str, Str => Result Str Str

elementGetAttribute! : Str, Str, Str => Result Str Str

elementGetProperty! : Str, Str, Str => Result Str Str

elementFindElement! : Str, Str, Str, Str => Result Str Str

elementFindElements! : Str, Str, Str, Str => Result (List Str) Str

elementGetTag! : Str, Str => Result Str Str

elementGetCss! : Str, Str, Str => Result Str Str

elementGetRect! : Str, Str => Result (List F64) Str

getEnv! : Str => Str

getPageSource! : Str => Result Str Str

switchToFrameByElementId! : Str, Str => Result {} Str

switchToParentFrame! : Str => Result {} Str
