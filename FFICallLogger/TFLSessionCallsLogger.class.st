"
I'm a tool to list the FFI calls performed on image startup.

Easy steps to use it:

1. Open the Pharo image from a terminal.
2. Customize `TFLSessionCallsLogger class>>#script` and `TFLSessionCallsLogger>>#shouldLog:`.
3. Evaluate `TFLSessionCallsLogger prepareAndQuit` to start recording and quit the image. 
4. Copy the `pharo-ui` command written on stdout.
5. Paste and execute it on the terminal.
6. Check a file that is created on the current working directory, with the recorded calls.

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

	| bannedFunctionNames |
	bannedFunctionNames := #( "SDL_PollEvent" ).

	^ (bannedFunctionNames includes: aTFLSignal functionName) not
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
