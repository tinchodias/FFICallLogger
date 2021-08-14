"
I represent the C NULL address.

I implement singleton via #instance in class-side, and provide specialized printing protocol.
"
Class {
	#name : #FFICallLoggerNULLAddress,
	#superclass : #ByteArray,
	#type : #bytes,
	#classInstVars : [
		'instance'
	],
	#category : #'FFICallLogger-Core'
}

{ #category : #accessing }
FFICallLoggerNULLAddress class >> instance [

	^ instance ifNil: [ instance := self new ]
]

{ #category : #printing }
FFICallLoggerNULLAddress >> printOn: aStream [

	aStream nextPutAll: '@NULL'
]
