"
I represent a ""immutable"" snapshot of an `ExternalAddress`.

A bit more precisely: I'm a copy of the address that isn't supposed to change for example, when the finalization process executes `ExternalAddress>>#beNull` on the original address.

"
Class {
	#name : 'TFLAddress',
	#superclass : 'ByteArray',
	#type : 'bytes',
	#category : 'FFICallLogger-Recordings',
	#package : 'FFICallLogger',
	#tag : 'Recordings'
}

{ #category : 'instance creation' }
TFLAddress class >> newFrom: anExternalAddress [

	| sz |
	sz := anExternalAddress size.
	^ (self basicNew: sz)
		replaceFrom: 1 to: sz with: anExternalAddress startingAt: 1;
		yourself
]

{ #category : 'printing' }
TFLAddress >> asString [
	"Answer a string that represents the receiver."

	^ self printString
]

{ #category : 'printing' }
TFLAddress >> printOn: aStream [
	"Print a lowercase hexadecimal String representation of my 4 higher bytes, prefixed by @."

	aStream nextPutAll: '@'.
	self from: 1 to: 4 do: [ :each | each printLowercaseHexByteOn: aStream ]
]
