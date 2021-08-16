"
I represent a a picture or snapshot of an ExternalAddress.

"
Class {
	#name : #TFLAddress,
	#superclass : #ByteArray,
	#type : #bytes,
	#category : #'FFICallLogger-Recordings'
}

{ #category : #'instance creation' }
TFLAddress class >> newFrom: anExternalAddress [

	| sz |
	sz := anExternalAddress size.
	^ (self basicNew: sz)
		replaceFrom: 1 to: sz with: anExternalAddress startingAt: 1;
		yourself
]

{ #category : #printing }
TFLAddress >> printOn: aStream [
	"Answer a lowercase hexadecimal String representation of the receiver prefixed by @."

	aStream nextPutAll: '@'.
	self do: [ :each | each printLowercaseHexByteOn: aStream ]
]
