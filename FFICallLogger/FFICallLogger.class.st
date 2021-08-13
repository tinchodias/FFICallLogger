"
I'm a logger for FFICallSignal.

# Install with:	

TFSameThreadCall compile: 
'executeOn: runner withArguments: aCollection
	| answer |
	function validate.
	answer := self invokeFunction: function withArguments: aCollection.
	(FFICallSignal
		function: function
		arguments: aCollection
		answer: (answer == self ifTrue: [ nil ] ifFalse: [ answer ])) emit.
	^ answer'


# Use like:

	FFICallLogger instance inspect.
	FFICallLogger instance reset.

"
Class {
	#name : #FFICallLogger,
	#superclass : #CircularMemoryLogger,
	#instVars : [
		'ignoreRules'
	],
	#category : #'FFICallLogger-Core'
}

{ #category : #'system startup' }
FFICallLogger class >> startUp: resuming [
	"If starting the image, all external addresses should be zero then we remove them."

	resuming ifTrue: [ self resetInstance ]
]

{ #category : #accessing }
FFICallLogger >> addIgnoreRule: aUnaryBlockClosure [

	ignoreRules := ignoreRules copyWith: aUnaryBlockClosure
]

{ #category : #initialization }
FFICallLogger >> initialize [ 

	super initialize.
	self resetIgnored.
]

{ #category : #spec }
FFICallLogger >> inspectorForCallsIn: aBuilder [
	<inspectorPresentationOrder: -1 title: 'Calls'>

	^ aBuilder instantiate: FFICallLoggerPresenter on: self
]

{ #category : #accessing }
FFICallLogger >> nextPut: aFFICallSignal [

	(self shouldIgnore: aFFICallSignal) ifTrue: [ ^ self  ].

	aFFICallSignal prepareAsRecording.
	super nextPut: aFFICallSignal 
]

{ #category : #accessing }
FFICallLogger >> resetIgnored [

	ignoreRules := {}.

]

{ #category : #accessing }
FFICallLogger >> shouldIgnore: aSignal [

	^ ignoreRules anySatisfy: [ :each | each value: aSignal ]
]

{ #category : #accessing }
FFICallLogger >> start [

	self startFor: FFICallSignal
]
