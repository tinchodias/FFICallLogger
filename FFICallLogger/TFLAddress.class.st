"
I represent a ""immutable"" snapshot of an ExternalAddress.

Maybe a bit more precisely, I'm a copy of the address that won't change.

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
TFLAddress >> asString [
	"Answer a string that represents the receiver."

	^ self printString
]

{ #category : #printing }
TFLAddress >> printOn: aStream [
	"Answer a lowercase hexadecimal String representation of the receiver prefixed by @."

	aStream nextPutAll: '@'.
	self do: [ :each | each printLowercaseHexByteOn: aStream ]
]
