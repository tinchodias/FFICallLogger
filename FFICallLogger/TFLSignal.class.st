"
I'm a Beacon signal with information about a ThreadedFFI call that was just executed.

A started `TFLCallLogger instance` records me. Browse its class comment for more information.

My instances have two states: ""initialized"" and ""prepared"". The method ""prepareAsRecording"" mutates an instance as a kind of snapshot, so posterior modifications on the original FFI call object are not lost. This is a performance optimization, to avoid preparing instances that are filtered.

"
Class {
	#name : #TFLSignal,
	#superclass : #BeaconSignal,
	#instVars : [
		'arguments',
		'answer',
		'moduleName',
		'functionName'
	],
	#category : #'FFICallLogger-Core'
}

{ #category : #'instance creation' }
TFLSignal class >> function: aFunction arguments: aCollection answer: anObject [

	^ self basicNew
		  initializeWithFunction: aFunction
		  arguments: aCollection
		  answer: anObject;
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
TFLSignal >> initializeWithFunction: aFunction arguments: aCollection answer: anObject [

	self initialize.
	moduleName := aFunction moduleName.
	functionName := aFunction functionName.
	arguments := aCollection.
	answer := anObject
]

{ #category : #accessing }
TFLSignal >> moduleName [

	^ moduleName
]

{ #category : #accessing }
TFLSignal >> name [

	^ 'FFI Call'
]

{ #category : #accessing }
TFLSignal >> prepareAsRecording [
	"Copy collaborators as an 'immutable' objects."

	arguments := arguments collect: [ :each | each asFFILoggerRecording ].
	"Array streamContents: [
		arguments do: [ :each |  ] ]."
	answer := answer asFFILoggerRecording.
]

{ #category : #printing }
TFLSignal >> printOneLineContentsOn: stream [
	
	functionName printOn: stream.

]
