"
I'm a Beacon signal with information about a ThreadedFFI call that was just executed.

A started `TFLCallLogger instance` records me. Browse its class comment for more information.

My instances have two states: ""initialized"" and ""prepared"". The method #prepareAsRecording mutates an instance as a kind of snapshot, so posterior modifications on the original FFI call object are not lost. This is a performance optimization, to avoid preparing instances that are filtered.

"
Class {
	#name : #TFLSignal,
	#superclass : #BeaconSignal,
	#instVars : [
		'arguments',
		'answer',
		'moduleName',
		'functionName',
		'stack'
	],
	#category : #'FFICallLogger-Core'
}

{ #category : #convenience }
TFLSignal class >> emitFromCall: aTFSameThreadCall arguments: aCollection answer: answer [
	"Convenience method that creates and emits an instance of this class.
	IMPORTANT: it assumes it's sent from TFSameThreadCall>>#executeOn:withArguments:."

	(self
		function: aTFSameThreadCall function
		arguments: aCollection
		answer: (answer == aTFSameThreadCall ifTrue: [ nil ] ifFalse: [ answer ])
		stack: (thisContext stack allButFirst: 3)) emit.
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

{ #category : #accessing }
TFLSignal >> answer [

	^ answer
]

{ #category : #accessing }
TFLSignal >> arguments [

	^ arguments
]

{ #category : #accessing }
TFLSignal >> functionName [

	^ functionName
]

{ #category : #initialization }
TFLSignal >> initializeWithFunction: aFunction arguments: aCollection answer: anObject stack: anArrayOfContexts [

	self initialize.
	moduleName := aFunction moduleName asPath basename.
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
TFLSignal >> printOneLineContentsOn: aStream [

	aStream
		nextPutAll: processId;
		nextPutAll: ' => ';
		nextPutAll: moduleName;
		nextPutAll: ' / ';
		nextPutAll: functionName;
		nextPut: $(;
		nextPutAll: arguments asCommaString;
		nextPutAll: ') => ';
		print: answer

]

{ #category : #accessing }
TFLSignal >> sender [
	"Answer the CompiledMethod that performed the call."

	^ stack first method
]

{ #category : #accessing }
TFLSignal >> stack [

	^ stack
]
