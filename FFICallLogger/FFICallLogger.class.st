"
I'm a logger for FFI calls.


# Install with:	

	FFICallLogger install.


# Use like:

	FFICallLogger instance inspect.
	FFICallLogger resetInstance.

"
Class {
	#name : #FFICallLogger,
	#superclass : #CircularMemoryLogger,
	#instVars : [
		'ignoreRules'
	],
	#category : #'FFICallLogger-Core'
}

{ #category : #installation }
FFICallLogger class >> install [
	"
	self install
	"

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

]

{ #category : #'system startup' }
FFICallLogger class >> startUp: resuming [
	"If starting the image, all external addresses should be zero then we remove them."

	resuming ifTrue: [ self resetInstance ]
]

{ #category : #accessing }
FFICallLogger >> addIgnoreRule: aUnaryBlockClosure [

	ignoreRules := ignoreRules copyWith: aUnaryBlockClosure.
	self announceChanged.
]

{ #category : #accessing }
FFICallLogger >> announceChanged [

	self announcer announce: (ValueChanged newValue: self)
]

{ #category : #accessing }
FFICallLogger >> ignoreRules [

	^ ignoreRules
]

{ #category : #initialization }
FFICallLogger >> initialize [ 

	super initialize.
	self resetIgnoreRules.
]

{ #category : #spec }
FFICallLogger >> inspectorForCallsIn: aBuilder [
	<inspectorPresentationOrder: -1 title: 'Calls'>

	^ aBuilder instantiate: FFICallsPresenter on: self
]

{ #category : #spec }
FFICallLogger >> inspectorForIgnoreRulesIn: aBuilder [
	<inspectorPresentationOrder: -0.5 title: 'Ignore Rules'>

	^ aBuilder instantiate: FFIIgnoredRulesPresenter on: self
]

{ #category : #accessing }
FFICallLogger >> nextPut: aFFICallSignal [

	(self shouldIgnore: aFFICallSignal) ifTrue: [ ^ self  ].

	aFFICallSignal prepareAsRecording.
	super nextPut: aFFICallSignal 
]

{ #category : #accessing }
FFICallLogger >> removeIgnoreRule: aUnaryBlockClosure [

	ignoreRules := ignoreRules copyWithout: aUnaryBlockClosure.
	self announceChanged.
]

{ #category : #accessing }
FFICallLogger >> resetIgnoreRules [

	ignoreRules := {}.
	self announceChanged.
]

{ #category : #accessing }
FFICallLogger >> shouldIgnore: aSignal [

	^ ignoreRules anySatisfy: [ :each | each value: aSignal ]
]

{ #category : #accessing }
FFICallLogger >> start [

	self startFor: FFICallSignal.
	self announceChanged
]

{ #category : #accessing }
FFICallLogger >> stop [

	super stop.
	self announceChanged
]
