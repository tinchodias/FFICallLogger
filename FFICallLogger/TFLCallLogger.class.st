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
		'filters',
		'numberOfFilteredSignals'
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
		answer: (answer == self ifTrue: [ nil ] ifFalse: [ answer ])
		sender: thisContext sender sender method) emit.
	^ answer'

]

{ #category : #'system startup' }
TFLCallLogger class >> startUp: resuming [
	"If starting the image, all external addresses should be zero then we remove them."

	resuming ifTrue: [ self resetInstance ]
]

{ #category : #accessing }
TFLCallLogger >> addFilter: aClosureThatReceivesSignalAndAnswersBoolean [

	filters := filters copyWith: aClosureThatReceivesSignalAndAnswersBoolean.
	self announceChanged.
]

{ #category : #convenience }
TFLCallLogger >> addFilter: accessor deny: value [
	"Add a filter like '[ :signal | signal <accessor> ~= <value> ]'"

	| body |
	body := 'signal {1} ~= {2}' format: { accessor. value storeString }.
	self addFilterByCompiling: body

]

{ #category : #convenience }
TFLCallLogger >> addFilter: accessor equals: value [
	"Add a filter like '[ :signal | signal <accessor> = <value> ]'"

	| body |
	body := 'signal {1} = {2}' format: { accessor. value storeString }.
	self addFilterByCompiling: body
]

{ #category : #convenience }
TFLCallLogger >> addFilterByCompiling: body [
	"Add a filter like '[ :signal | <body> ]'"

	| sourceCode aFilter |
	sourceCode := '[ :signal | {1} ]'
		format: { body trimmed withSeparatorsCompacted }.
	aFilter := self class compiler evaluate: sourceCode. 
	self addFilter: aFilter

]

{ #category : #convenience }
TFLCallLogger >> addFilterHasArgumentLike: value [
	"Add a filter for calls with at least one argument that converted to string equals to <value> as string."

	| body |
	body := 'signal arguments anySatisfy: [ :each | each asString = {1} ]' 
		format: { value asString storeString }.
	self addFilterByCompiling: body
]

{ #category : #convenience }
TFLCallLogger >> addFilterSignalsLike: aTFLSignal [ 
	
	| body |
	body := 'signal oneLineContents = {1}' format: { aTFLSignal oneLineContents storeString }.
	self addFilterByCompiling: body
]

{ #category : #private }
TFLCallLogger >> announceChanged [

	self announcer announce: (ValueChanged newValue: self)
]

{ #category : #initialization }
TFLCallLogger >> basicReset [

	super basicReset.
	self resetFilteredSignals
]

{ #category : #accessing }
TFLCallLogger >> filters [

	^ filters
]

{ #category : #accessing }
TFLCallLogger >> filters: aCollection [

	filters := aCollection.
	self announceChanged.
]

{ #category : #initialization }
TFLCallLogger >> initialize [ 

	super initialize.
	self resetFilters.
	self resetFilteredSignals.
]

{ #category : #accessing }
TFLCallLogger >> nextPut: aFFICallSignal [

	aFFICallSignal prepareAsRecording. "TODO: argument filtering need to prepare not-lazily"

	(self shouldRecord: aFFICallSignal)
		ifTrue: [ super nextPut: aFFICallSignal ]
		ifFalse: [
			numberOfFilteredSignals := numberOfFilteredSignals + 1.
			self announceChanged ]

]

{ #category : #accessing }
TFLCallLogger >> numberOfFilteredSignals [

	^ numberOfFilteredSignals
]

{ #category : #accessing }
TFLCallLogger >> removeFilter: aUnaryBlockClosure [
	"Remove a filter. We support sending this message from a closure iterating the filters."

	filters := filters copyWithout: aUnaryBlockClosure.
	self announceChanged.
]

{ #category : #initialization }
TFLCallLogger >> resetFilteredSignals [

	numberOfFilteredSignals := 0.
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
			('Removed filter due to error: ', error asString) traceCr.
			true ] ]

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
