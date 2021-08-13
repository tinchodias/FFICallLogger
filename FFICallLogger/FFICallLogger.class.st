"
I'm a logger for TFFI calls.

# Install with:	

TFSameThreadCall compile: 
'executeOn: runner withArguments: aCollection
	(WrapperSignal on: {function. aCollection}) emit.
	function validate.	
	^ self invokeFunction: function withArguments: aCollection'


# Use like:

	FFICallLogger instance inspect.

"
Class {
	#name : #FFICallLogger,
	#superclass : #CircularMemoryLogger,
	#instVars : [
		'ignoredAddresses',
		'ignoredModuleNames',
		'ignoredProcessIds'
	],
	#category : #'FFICallLogger-Core'
}

{ #category : #'system startup' }
FFICallLogger class >> startUp: resuming [
	"If starting the image, all external addresses should be zero then we remove them."

	resuming ifTrue: [ self resetInstance ]
]

{ #category : #accessing }
FFICallLogger >> addIgnoredAddress: anExternalAddress [

	ignoredAddresses add: anExternalAddress
]

{ #category : #accessing }
FFICallLogger >> addIgnoredModule: aString [

	ignoredModuleNames add: aString
]

{ #category : #accessing }
FFICallLogger >> addIgnoredProcessId: aProcessId [

	ignoredProcessIds add: aProcessId
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
FFICallLogger >> nextPut: aWrapperSignal [

	(self shouldIgnore: aWrapperSignal) ifFalse: [
		super nextPut: aWrapperSignal ]
]

{ #category : #accessing }
FFICallLogger >> resetIgnored [

	ignoredAddresses := WeakSet new.
	ignoredModuleNames := WeakSet new.
	ignoredProcessIds := WeakSet new.
]

{ #category : #accessing }
FFICallLogger >> shouldIgnore: aWrapperSignal [
	
	^ (ignoredAddresses includes: aWrapperSignal target first address) or: [ 
		(ignoredModuleNames includes: aWrapperSignal target first moduleName) or: [ 
			(ignoredProcessIds includes: aWrapperSignal processId) ] ]
]

{ #category : #accessing }
FFICallLogger >> start [

	self startFor: WrapperSignal
]
