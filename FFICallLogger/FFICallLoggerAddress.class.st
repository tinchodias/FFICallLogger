"
I represent a a picture or snapshot of an ExternalAddress.

"
Class {
	#name : #FFICallLoggerAddress,
	#superclass : #ByteArray,
	#type : #bytes,
	#category : #'FFICallLogger-Core'
}

{ #category : #'instance creation' }
FFICallLoggerAddress class >> newFrom: anExternalAddress [

	| sz |
	sz := anExternalAddress size.
	^ (self basicNew: sz)
		replaceFrom: 1 to: sz with: anExternalAddress startingAt: 1;
		yourself
]

{ #category : #printing }
FFICallLoggerAddress >> printOn: aStream [
	"Answer a lowercase hexadecimal String representation of the receiver prefixed by @."

	aStream nextPutAll: '@'.
	self do: [ :each | each printLowercaseHexByteOn: aStream ]
]
