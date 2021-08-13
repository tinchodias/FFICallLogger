"
I'm a Beacon signal with information about a FFI call that was just executed.

The FFICallLogger can record my emission (#emit).

"
Class {
	#name : #FFICallSignal,
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
FFICallSignal class >> function: aFunction arguments: aCollection answer: anObject [

	^ self basicNew
		  initializeWithFunction: aFunction
		  arguments: aCollection
		  answer: anObject;
		  yourself
]

{ #category : #accessing }
FFICallSignal >> answer [

	^ answer
]

{ #category : #accessing }
FFICallSignal >> arguments [

	^ arguments
]

{ #category : #accessing }
FFICallSignal >> functionName [

	^ functionName
]

{ #category : #initialization }
FFICallSignal >> initializeWithFunction: aFunction arguments: aCollection answer: anObject [

	self initialize.
	moduleName := aFunction moduleName.
	functionName := aFunction functionName.
	arguments := aCollection.
	answer := anObject
]

{ #category : #accessing }
FFICallSignal >> moduleName [

	^ moduleName
]

{ #category : #accessing }
FFICallSignal >> name [

	^ 'FFI Call'
]

{ #category : #accessing }
FFICallSignal >> prepareAsRecording [
	"Copy collaborators as an 'immutable' objects."

	arguments := arguments collect: [ :each | each asFFILoggerRecording ].
	"Array streamContents: [
		arguments do: [ :each |  ] ]."
	answer := answer asFFILoggerRecording.
]

{ #category : #printing }
FFICallSignal >> printOneLineContentsOn: stream [
	
	functionName printOn: stream.

]
