Extension { #name : #ExternalAddress }

{ #category : #'*FFICallLogger' }
ExternalAddress >> asFFILoggerRecording [
	"Self is mutated on free as null, so answer a new object that won't change."

	^ self isNull
		ifTrue:[ FFICallLoggerNULLAddress instance ]
		ifFalse: [ FFICallLoggerAddress newFrom: self ]

]
