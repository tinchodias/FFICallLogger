"
A TFLCallLoggerTest is a test class for testing the behavior of TFLCallLogger
"
Class {
	#name : #TFLCallLoggerTest,
	#superclass : #TestCase,
	#category : #'FFICallLogger-Tests-Core'
}

{ #category : #running }
TFLCallLoggerTest >> doMemcpyCall [

	| a b |
	a := ByteArray new: 1.
	b := a copy.
	LibC memCopy: a to: b size: a size.
]

{ #category : #tests }
TFLCallLoggerTest >> selectMemcpyCallsFrom: aCollectionOfSignals [

	^ aCollectionOfSignals select: [ :each | each functionName = #memcpy ]
]

{ #category : #running }
TFLCallLoggerTest >> setUp [
	super setUp.
	
	TFLSignal install

]

{ #category : #running }
TFLCallLoggerTest >> tearDown [

	TFLSignal uninstall.

	super tearDown.

]

{ #category : #tests }
TFLCallLoggerTest >> testInstance [
	
	TFLCallLogger instance start.
	self doMemcpyCall.
	TFLCallLogger instance stop.

	self denyEmpty: (self selectMemcpyCallsFrom: TFLCallLogger instance recordings)

]

{ #category : #tests }
TFLCallLoggerTest >> testResetInstance [
	
	TFLCallLogger instance start.
	self doMemcpyCall.
	TFLCallLogger instance stop.
	TFLCallLogger resetInstance.

	self assertEmpty: TFLCallLogger instance recordings
]

{ #category : #tests }
TFLCallLoggerTest >> testStart [
	
	| logger |
	logger := TFLCallLogger new.
	logger start.
	self doMemcpyCall.
	logger stop.

	self denyEmpty: (self selectMemcpyCallsFrom: logger recordings)
]

{ #category : #tests }
TFLCallLoggerTest >> testStop [
	
	| logger |
	logger := TFLCallLogger new.
	logger start.
	logger stop.
	self doMemcpyCall.

	self assertEmpty: (self selectMemcpyCallsFrom: logger recordings)
]
