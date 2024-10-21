# this module will be replaced when effect interpreters are implemented
hosted Effect
    exposes [
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
        createDirIfNotExist,
        fileWriteUtf8,
        browserGetScreenshot,
        # browserGetPdf,
        elementGetText,
        elementIsSelected,
        elementGetAttribute,
        elementGetProperty,
        elementSendKeys,
        elementClear,
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
    ]
    imports []

# effects that are provided by the host
stdoutLine : Str -> Task {} Str

stdinLine : {} -> Task Str Str

wait : U64 -> Task {} Str

getTimeMilis : {} -> Task I64 Str

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

# element effects
elementClick : Str, Str -> Task {} Str

elementSendKeys : Str, Str, Str -> Task {} Str

elementClear : Str, Str -> Task {} Str

elementGetText : Str, Str -> Task Str Str

elementIsSelected : Str, Str -> Task Str Str

elementGetAttribute : Str, Str, Str -> Task Str Str

elementGetProperty : Str, Str, Str -> Task Str Str
