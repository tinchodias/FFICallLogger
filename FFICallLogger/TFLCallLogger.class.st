"
I'm a logger for ThreadedFFI ""same thread"" calls.


# Install with:	

	TFLCallLogger install.


# Other useful statements:

	TFLCallLogger instance inspect.
	TFLCallLogger start.
	TFLCallLogger stop.
	TFLCallLogger resetInstance.

"
Class {
	#name : #TFLCallLogger,
	#superclass : #CircularMemoryLogger,
	#instVars : [
		'filters'
	],
	#category : #'FFICallLogger-Core'
}

{ #category : #installation }
TFLCallLogger class >> install [
	"
	self install
	"

	TFSameThreadCall compile: 
'executeOn: runner withArguments: aCollection
	| answer |
	function validate.
	answer := self invokeFunction: function withArguments: aCollection.
	(TFLSignal
		function: function
		arguments: aCollection
		answer: (answer == self ifTrue: [ nil ] ifFalse: [ answer ])) emit.
	^ answer'

]

{ #category : #'system startup' }
TFLCallLogger class >> startUp: resuming [
	"If starting the image, all external addresses should be zero then we remove them."

	resuming ifTrue: [ self resetInstance ]
]

{ #category : #accessing }
TFLCallLogger >> addFilter: aUnaryBlockClosureThatAnswersBoolean [

	filters := filters copyWith: aUnaryBlockClosureThatAnswersBoolean.
	self announceChanged.
]

{ #category : #convenience }
TFLCallLogger >> addFilter: accessor deny: value [
	"Add a filter like '[ :signal | signal <accessor> ~= <value> ]'"

	| sourceCode aFilter |
	sourceCode := '[ :signal | signal {1} ~= {2} ]' format: { accessor. value storeString }.
	aFilter := self class compiler evaluate: sourceCode. 
	self addFilter: aFilter
]

{ #category : #convenience }
TFLCallLogger >> addFilter: accessor equals: value [
	"Add a filter like '[ :signal | signal <accessor> = <value> ]'"

	| sourceCode aFilter |
	sourceCode := '[ :signal | signal {1} = {2} ]' format: { accessor. value storeString }.
	aFilter := self class compiler evaluate: sourceCode. 
	self addFilter: aFilter
]

{ #category : #private }
TFLCallLogger >> announceChanged [

	self announcer announce: (ValueChanged newValue: self)
]

{ #category : #accessing }
TFLCallLogger >> filters [

	^ filters
]

{ #category : #initialization }
TFLCallLogger >> initialize [ 

	super initialize.
	self resetFilters.
]

{ #category : #accessing }
TFLCallLogger >> nextPut: aFFICallSignal [

	(self shouldRecord: aFFICallSignal) ifFalse: [ ^ self  ].

	aFFICallSignal prepareAsRecording.
	super nextPut: aFFICallSignal 
]

{ #category : #accessing }
TFLCallLogger >> removeFilter: aUnaryBlockClosure [
	"Remove a filter. We support sending this message from a closure iterating the filters."

	filters := filters copyWithout: aUnaryBlockClosure.
	self announceChanged.
]

{ #category : #accessing }
TFLCallLogger >> resetFilters [

	filters := {}.
	self announceChanged.
]

{ #category : #accessing }
TFLCallLogger >> shouldRecord: aSignal [

	^ filters noneSatisfy: [ :each |
		[ each value: aSignal ] onErrorDo: [ :error |
			"We assume remove implementation support doing it from a iteration block"
			self removeFilter: each. 
			('Removed filter due to error: ', error asString) traceCr ] ]
]

{ #category : #accessing }
TFLCallLogger >> start [

	self startFor: TFLSignal.
	self announceChanged
]

{ #category : #accessing }
TFLCallLogger >> stop [

	super stop.
	self announceChanged
]
