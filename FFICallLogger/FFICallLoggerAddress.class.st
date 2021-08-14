"
I represent a a picture or snapshot of an ExternalAddress.

"
Class {
	#name : #FFICallLoggerAddress,
	#superclass : #ByteArray,
	#type : #bytes,
	#category : #'FFICallLogger-Core'
}

{ #category : #printing }
FFICallLoggerAddress >> printOn: aStream [

	aStream
		nextPutAll: '@';
		nextPutAll: self hex
]
