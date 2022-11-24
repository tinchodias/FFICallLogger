"
I'm a Beacon signal with information about a ThreadedFFI call that was just executed.

A started `TFLCallLogger` instance records me. Browse its class comment for more information.

My instances have two states: ""initialized"" and ""prepared"". The method `TFLSignal>>#prepareAsRecording` mutates an instance as a kind of snapshot, so posterior modifications on the original FFI call object are not lost. This is a performance optimization, to avoid preparing instances that are filtered.

"
Class {
	#name : #TFLSignal,
	#superclass : #Announcement,
	#instVars : [
		'arguments',
		'answer',
		'moduleName',
		'functionName',
		'stack',
		'microsecondClockValue',
		'processId'
	],
	#category : #'FFICallLogger-Core'
}

{ #category : #convenience }
TFLSignal class >> browseInstallingMethod [
	"Open a browser on the ThreadedFFI method where this logger installs."

	<script>
	(TFSameThreadRunner>>#invokeFunction:withArguments:) browse
]

{ #category : #convenience }
TFLSignal class >> emitFromRunner: aTFSameThreadRunner function: function arguments: aCollection answer: answer [
	"Convenience method that creates and emits an instance of this class.
	IMPORTANT: it assumes it's sent from TFSameThreadCall>>#executeOn:withArguments:."

	(self
		function: function
		arguments: aCollection
		answer: (answer == aTFSameThreadRunner ifTrue: [ TFLNoAnswer instance ] ifFalse: [ answer ])
		stack: (thisContext stack allButFirst: 2)) emit.
]

{ #category : #'instance creation' }
TFLSignal class >> function: aFunction arguments: aCollection answer: anObject stack: anArrayOfContexts [

	^ self basicNew
		  initializeWithFunction: aFunction
		  arguments: aCollection
		  answer: anObject
		  stack: anArrayOfContexts;
		  yourself
]

{ #category : #installation }
TFLSignal class >> install [
	<script>

	TFSameThreadRunner compile: 
'invokeFunction: function withArguments: aCollection 
	| answer |
	function validate.
	answer := self primitivePerformWorkerCall: function withArguments: aCollection.
	TFLSignal emitFromRunner: self function: function arguments: aCollection answer: answer.
	^ answer'

]

{ #category : #installation }
TFLSignal class >> uninstall [
	<script>

	TFSameThreadRunner compile: 
'invokeFunction: function withArguments: aCollection 

	function validate.	
	^ self primitivePerformWorkerCall: function withArguments: aCollection 
	'

]

{ #category : #accessing }
TFLSignal >> answer [

	^ answer
]

{ #category : #accessing }
TFLSignal >> arguments [

	^ arguments
]

{ #category : #converting }
TFLSignal >> asBeaconSignal [
	^ self
]

{ #category : #accessing }
TFLSignal >> functionName [

	^ functionName
]

{ #category : #initialization }
TFLSignal >> initializeWithFunction: aFunction arguments: aCollection answer: anObject stack: anArrayOfContexts [

	self initialize.
	microsecondClockValue := DateAndTime clock microsecondClockValue.
	processId := Processor activeProcess name.
	moduleName := aFunction moduleName.
	functionName := aFunction functionName.
	arguments := aCollection.
	answer := anObject.
	stack := anArrayOfContexts
]

{ #category : #accessing }
TFLSignal >> moduleName [

	^ moduleName
]

{ #category : #accessing }
TFLSignal >> name [

	^ 'FFI Call'
]

{ #category : #printing }
TFLSignal >> oneLineContents [

	^ String streamContents: [ :s | self printOneLineContentsOn: s ]
]

{ #category : #accessing }
TFLSignal >> prepareAsRecording [
	"Copy collaborators as an 'immutable' objects."

	arguments := arguments collect: [ :each | each asTFLRecording ].
	answer := answer asTFLRecording.
]

{ #category : #printing }
TFLSignal >> printOn: stream [

	self printOneLineContentsOn: stream
]

{ #category : #printing }
TFLSignal >> printOneLineContentsOn: aStream [

	aStream
"		print: self timestamp;
		nextPutAll: ' | ';
		nextPutAll: processId;
		nextPutAll: ' | ';
		nextPutAll: self shortModuleName;
		nextPutAll: ' | ';"
		nextPutAll: functionName";
		nextPut: $(;
		nextPutAll: arguments asCommaString;
		nextPutAll: ') => ';
		print: answer
"
]

{ #category : #accessing }
TFLSignal >> processId [

	^ processId
]

{ #category : #accessing }
TFLSignal >> sender [
	"Answer the CompiledMethod that performed the call."

	^ stack first method
]

{ #category : #accessing }
TFLSignal >> shortModuleName [

	^ moduleName asPath basenameWithoutExtension
]

{ #category : #accessing }
TFLSignal >> stack [

	^ stack
]

{ #category : #accessing }
TFLSignal >> timestamp [
	
	^ DateAndTime fromMicrosecondClockValue: microsecondClockValue
]
