# this module will be replaced when effect interpreters are implemented
hosted Effect
    exposes [
        setTimeouts,
        setScriptTimeoutOverride,
        setAssertTimeoutOverride,
        setPageLoadTimeoutOverride,
        setImplicitTimeoutOverride,
        resetTestOverrides,
        setWindowSize,
        setWindowSizeOverride,
        getAssertTimeout,
        stdoutLine,
        stdinLine,
        wait,
        startSession,
        deleteSession,
        browserNavigateTo,
        browserFindElement,
        browserFindElements,
        elementClick,
        getTimeMilis,
        isDebugMode,
        isVerbose,
        incrementTest,
        getTestNameFilter,
        getLogsForTest,
        createDirIfNotExist,
        fileWriteUtf8,
        browserGetScreenshot,
        addCookie,
        getCookie,
        getAllCookies,
        deleteCookie,
        deleteAllCookies,
        alertDismiss,
        alertSendText,
        alertGetText,
        alertAccept,
        # browserGetPdf,
        elementGetText,
        elementIsSelected,
        elementIsDisplayed,
        elementGetAttribute,
        elementGetProperty,
        elementSendKeys,
        elementClear,
        elementFindElement,
        elementFindElements,
        elementGetCss,
        elementGetTag,
        elementGetRect,
        browserSetWindowRect,
        browserGetWindowRect,
        browserGetTitle,
        browserGetUrl,
        browserReload,
        browserNavigateBack,
        browserNavigateForward,
        browserMaximize,
        browserMinimize,
        browserFullScreen,
        executeJs,
        getEnv,
        getPageSource,
    ]
    imports []

# effects that are provided by the host
setTimeouts : U64, U64, U64, U64 -> Task {} Str

setAssertTimeoutOverride : U64 -> Task {} Str

setPageLoadTimeoutOverride : U64 -> Task {} Str

setScriptTimeoutOverride : U64 -> Task {} Str

setImplicitTimeoutOverride : U64 -> Task {} Str

resetTestOverrides : {} -> Task {} Str

setWindowSize : Str -> Task {} Str

setWindowSizeOverride : Str -> Task {} Str

getAssertTimeout : {} -> Task I64 Str

stdoutLine : Str -> Task {} Str

stdinLine : {} -> Task Str Str

wait : U64 -> Task {} Str

getTimeMilis : {} -> Task I64 Str

isDebugMode : {} -> Task I64 Str

isVerbose : {} -> Task I64 Str

incrementTest : {} -> Task {} Str

getLogsForTest : I64 -> Task (List Str) Str

getTestNameFilter : {} -> Task Str Str

# file system
createDirIfNotExist : Str -> Task {} Str

fileWriteUtf8 : Str, Str -> Task {} Str

# driver effects
startSession : {} -> Task Str Str

deleteSession : Str -> Task {} Str

# browser effects
browserNavigateTo : Str, Str -> Task {} Str

browserGetTitle : Str -> Task Str Str

browserGetUrl : Str -> Task Str Str

browserFindElement : Str, Str, Str -> Task Str Str

browserFindElements : Str, Str, Str -> Task (List Str) Str

browserSetWindowRect : Str, I64, I64, I64, I64, I64 -> Task (List I64) Str

browserGetWindowRect : Str -> Task (List I64) Str

browserGetScreenshot : Str -> Task Str Str

# browserGetPdf : Str, F64, F64, F64, F64, F64, F64, F64, Str, I64, I64, List Str -> Task Str Str

browserNavigateBack : Str -> Task {} Str

browserNavigateForward : Str -> Task {} Str

browserReload : Str -> Task {} Str

browserMaximize : Str -> Task (List I64) Str

browserMinimize : Str -> Task (List I64) Str

browserFullScreen : Str -> Task (List I64) Str

executeJs : Str, Str, Str -> Task Str Str

addCookie : Str, Str, Str, Str, Str, Str, I64, I64, I64 -> Task {} Str

deleteCookie : Str, Str -> Task {} Str

deleteAllCookies : Str -> Task {} Str

getCookie : Str, Str -> Task (List Str) Str

getAllCookies : Str -> Task (List (List Str)) Str

alertAccept : Str -> Task {} Str

alertDismiss : Str -> Task {} Str

alertSendText : Str, Str -> Task {} Str

alertGetText : Str -> Task Str Str

# element effects
elementClick : Str, Str -> Task {} Str

elementSendKeys : Str, Str, Str -> Task {} Str

elementClear : Str, Str -> Task {} Str

elementGetText : Str, Str -> Task Str Str

elementIsSelected : Str, Str -> Task Str Str

elementIsDisplayed : Str, Str -> Task Str Str

elementGetAttribute : Str, Str, Str -> Task Str Str

elementGetProperty : Str, Str, Str -> Task Str Str

elementFindElement : Str, Str, Str, Str -> Task Str Str

elementFindElements : Str, Str, Str, Str -> Task (List Str) Str

elementGetTag : Str, Str -> Task Str Str

elementGetCss : Str, Str, Str -> Task Str Str

elementGetRect : Str, Str -> Task (List F64) Str

getEnv : Str -> Task Str Str

getPageSource : Str -> Task Str Str
