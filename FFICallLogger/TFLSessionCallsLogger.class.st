"
I'm a Beacon logger for `TFLSignal` to a waitfree queue.

"
Class {
	#name : #TFLSessionCallsLogger,
	#superclass : #SignalLogger,
	#instVars : [
		'signalsWaitfreeQueue',
		'session'
	],
	#category : #'FFICallLogger-Core'
}

{ #category : #installation }
TFLSessionCallsLogger class >> logToFileAndQuit [
	<script>

	| logFileReference |
	logFileReference := TFLSessionCallsLogger instance flushSignalsToNewFile.
	
	Stdio stdout << ('

Log file written:
	{1}

' format: { logFileReference basename }) withUnixLineEndings; flush.

	Smalltalk snapshot: false andQuit: true.

]

{ #category : #installation }
TFLSessionCallsLogger class >> prepareAndQuit [
	<script>

	Stdio stdout << ('

Log with something like:

./pharo-ui {1} eval "{2} {3}."

' format: {
		SmalltalkImage current shortImageName.
		TFLSessionCallsLogger name.
		#script }) withUnixLineEndings; flush.
	
	TFLSessionCallsLogger stop; resetInstance.
	Smalltalk garbageCollect.
	TFLSessionCallsLogger start.
	Smalltalk snapshot: true andQuit: true.
]

{ #category : #installation }
TFLSessionCallsLogger class >> script [

[

| w s |
1 second wait.
"
w := World worldState worldRenderer window.
s := World worldState worldRenderer actualScreenSize.
(OSWindowResizeEvent for: w)
				width: s x;
				height: s y;
				deliver.
				
 World worldState worldRenderer window focus. "

1 seconds wait.				
				
			self logToFileAndQuit.] fork
]

{ #category : #accessing }
TFLSessionCallsLogger >> ensureQueueForCurrentSession [

	(signalsWaitfreeQueue notNil and: [ session = SessionManager default currentSession ])
		ifTrue: [ ^ self ].

	session := SessionManager default currentSession.
	signalsWaitfreeQueue := WaitfreeQueue new.

]

{ #category : #accessing }
TFLSessionCallsLogger >> flushSignals [
	"Answer the recorded signals, and flush internal collection."

	| results |
	results := LinkedList new.

	signalsWaitfreeQueue flush: [ :each | results add: each ].

	^ results
]

{ #category : #writing }
TFLSessionCallsLogger >> flushSignalsToNewFile [

	| aFileReference |
	aFileReference := (Time microsecondClockValue asString , '.log') asFileReference.

	aFileReference writeStreamDo: [ :aStream | 
		self flushSignals do: [ :each | 
			aStream nextPutAll: each oneLineContents; lf ] ].
	
	^ aFileReference

]

{ #category : #accessing }
TFLSessionCallsLogger >> nextPut: aTFLSignal [

	(self shouldLog: aTFLSignal) ifFalse: [ ^ self ].

	self ensureQueueForCurrentSession.

	aTFLSignal prepareAsRecording.
	signalsWaitfreeQueue nextPut: aTFLSignal
]

{ #category : #testing }
TFLSessionCallsLogger >> shouldLog: aTFLSignal [

	| banned |
	banned := #( SDL_PollEvent SDL_GetWindowSize 
	
	SDL_LockTexture
SDL_UnlockTexture
SDL_RenderCopy
SDL_RenderPresent

).

	^ (banned includes: aTFLSignal functionName) not
]

{ #category : #accessing }
TFLSessionCallsLogger >> start [

	TFLSignal install.
	self startFor: TFLSignal
]

{ #category : #accessing }
TFLSessionCallsLogger >> stop [

	super stop.
	TFLSignal uninstall.

]
