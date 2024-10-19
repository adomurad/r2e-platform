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
        elementClick,
        getTimeMilis,
        createDirIfNotExist,
        fileWriteUtf8,
        getScreenshot,
        elementGetText,
        elementIsSelected,
        elementGetAttribute,
        elementGetProperty,
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

browserFindElement : Str, Str, Str -> Task Str Str

getScreenshot : Str -> Task Str Str

# element effects
elementClick : Str, Str -> Task {} Str

elementGetText : Str, Str -> Task Str Str

elementIsSelected : Str, Str -> Task Str Str

elementGetAttribute : Str, Str, Str -> Task Str Str

elementGetProperty : Str, Str, Str -> Task Str Str
