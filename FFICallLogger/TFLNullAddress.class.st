"
I represent the C NULL address.

I implement singleton via #instance in class-side, and provide specialized printing protocol.
"
Class {
	#name : #TFLNullAddress,
	#superclass : #Object,
	#type : #bytes,
	#classInstVars : [
		'instance'
	],
	#category : #'FFICallLogger-Recordings'
}

{ #category : #accessing }
TFLNullAddress class >> instance [

	^ instance ifNil: [ instance := self new ]
]

{ #category : #printing }
TFLNullAddress >> printOn: aStream [

	aStream nextPutAll: '@NULL'
]
