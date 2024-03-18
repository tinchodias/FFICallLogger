"
I represent the answer of a call to a ""void"" function.

I implement singleton via #instance in class-side, and provide specialized printing protocol.
"
Class {
	#name : 'TFLNoAnswer',
	#superclass : 'Object',
	#classInstVars : [
		'instance'
	],
	#category : 'FFICallLogger-Recordings',
	#package : 'FFICallLogger',
	#tag : 'Recordings'
}

{ #category : 'accessing' }
TFLNoAnswer class >> instance [

	^ instance ifNil: [ instance := self new ]
]

{ #category : 'printing' }
TFLNoAnswer >> printOn: aStream [

	aStream nextPutAll: 'void'
]
