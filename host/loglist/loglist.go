package loglist

var (
	logLinesPerTest       = make(map[int64]([]string))
	currentTest     int64 = 0
)

// FIXME - good enough for know, but will be a pain point in the future

func IncrementCurrentTest() {
	currentTest++
}

func GetCurrentTest() int64 {
	return currentTest
}

func AddLogForTest(message string) {
	testIndex := currentTest

	// make sure to make a copy of the str - this memory will be realocated
	bytesCopy := make([]byte, len(message))
	copy(bytesCopy, []byte(message))
	messageCopy := string(bytesCopy)

	messages, ok := logLinesPerTest[testIndex]
	if ok {
		messages = append(messages, messageCopy)
		logLinesPerTest[testIndex] = messages
	} else {
		logLinesPerTest[testIndex] = []string{messageCopy}
	}
}

func GetLogsForTest(testIndex int64) []string {
	messages, ok := logLinesPerTest[testIndex]
	if ok {
		return messages
	} else {
		return make([]string, 0)
	}
}
